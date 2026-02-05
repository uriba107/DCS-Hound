--- HOUND.Contact.Estimator
-- @module HOUND.Contact.Estimator
do
    local l_math = math
    -- local l_mist = HOUND.Mist
    local TwoPI = 2 * l_math.pi
    local HalfPi = l_math.pi / 2
    local HoundUtils = HOUND.Utils
    local matrix = HOUND.Matrix

    -- @type HOUND.Contact.Datapoint
    HOUND.Contact.Estimator = {}
    HOUND.Contact.Estimator.__index = HOUND.Contact.Estimator

    --- Legacy Kalman implementation
    -- @section kalman
    HOUND.Contact.Estimator.Kalman = {}

    --- Fuzzy logic score
    function HOUND.Contact.Estimator.accuracyScore(err)
        local score = 0
        if type(err) == "number" then
            score = HoundUtils.Mapping.linear(err, 0, 100000, 1, 0, true)
            score = HoundUtils.Cluster.gaussianKernel(score, 0.2)
        end
        if type(score) == "number" then
            return score
        else
            return 0
        end
    end

    --- Kalman Filter implementation for position
    -- @local
    -- @return Kalman filter instance
    function HOUND.Contact.Estimator.Kalman.posFilter()
        local Kalman = {}

        Kalman.P = {
            x = 0.5,
            z = 0.5
        }

        Kalman.estimated = {}

        Kalman.update = function(self, datapoint)
            if type(self.estimated.p) ~= "table" and HoundUtils.Dcs.isPoint(datapoint) then
                self.estimated.p = {
                    x = datapoint.x,
                    z = datapoint.z,
                    y = datapoint.y
                }
            end

            if type(datapoint.err.score) ~= "table" then
                return self.estimated.p
            end
            self.P.x = self.P.x + math.sqrt(datapoint.err.score.x)
            self.P.z = self.P.z + math.sqrt(datapoint.err.score.z)

            local Kx = self.P.x / (self.P.x + (datapoint.err.score.x))
            local Kz = self.P.z / (self.P.z + (datapoint.err.score.z))

            self.estimated.p.x = self.estimated.p.x + (Kx * (datapoint.x - self.estimated.p.x))
            self.estimated.p.z = self.estimated.p.z + (Kz * (datapoint.z - self.estimated.p.z))

            self.P.x = (1 - Kx) * self.P.x
            self.P.z = (1 - Kz) * self.P.z

            self.estimated.p = HoundUtils.Geo.setHeight(self.estimated.p)
            return self.estimated.p
        end

        Kalman.get = function(self)
            return self.estimated.p
        end

        return Kalman
    end

    --- Kalman Filter implementation for Azimuth
    -- @local
    -- @param maxError maximum expected angular error (~2σ bound) in radians
    -- @return Kalman filter instance
    function HOUND.Contact.Estimator.Kalman.AzFilter(maxError)
        local Kalman = {}
        Kalman.P = 0.5
        -- Convert maxError (~2σ) to variance (σ²) for Kalman calculations
        local sigma = maxError / 2
        Kalman.noiseVariance = sigma * sigma

        Kalman.estimated = nil

        Kalman.update = function(self, newAz, predictedAz, processNoise)
            if not self.estimated then
                self.estimated = newAz
            end
            local predAz = self.estimated
            local noiseVar = self.noiseVariance
            if type(predictedAz) == "number" then
                predAz = predictedAz
            end
            if type(processNoise) == "number" then
                -- processNoise is also maxError, convert to variance
                local sigma_p = processNoise / 2
                noiseVar = sigma_p * sigma_p
            end

            self.P = self.P + noiseVar -- add process noise as variance
            local K = self.P / (self.P + self.noiseVariance)
            local deltaAz = newAz - predAz
            self.estimated = ((self.estimated + K * (deltaAz)) + TwoPI) % TwoPI
            self.P = (1 - K) * self.P
        end

        Kalman.get = function(self)
            return self.estimated
        end

        return Kalman
    end

    --- Kalman Filter implementation for position.
    -- @local
    -- @return Kalman filter instance
    function HOUND.Contact.Estimator.Kalman.AzElFilter()
        local Kalman = {}
        Kalman.K = {
            Az = 0,
            El = 0
        }
        Kalman.P = {
            Az = 1,
            El = 1
        }
        Kalman.estimated = {
            pos = nil,
            Az = nil,
            El = nil
        }

        Kalman.reset = function(self)
            self.P = {
                Az = 1,
                El = 1
            }
        end

        Kalman.update = function(self, datapoint)
            if not self.estimated.pos then
                self.estimated.Az = (1 / self.P.Az) * datapoint.az
                self.estimated.El = (1 / self.P.El) * datapoint.el
                self.estimated.pos = HoundUtils.Geo.getProjectedIP(datapoint.platformPos, self.estimated.Az,
                    self.estimated.El)
                return self.estimated
            end
            local prediction = self:predict(datapoint)

            -- update uncertenties
            -- TODO: make smarter
            local errEstimate = {
                Az = datapoint.platformPrecision,
                El = datapoint.platformPrecision
            }

            self.K.Az = self.P.Az / (self.P.Az + errEstimate.Az)
            self.K.El = self.P.El / (self.P.El + errEstimate.El)

            self.estimated.Az = self.estimated.Az + (self.K.Az * (datapoint.az - prediction.Az))
            self.estimated.El = self.estimated.El + (self.K.El * (datapoint.el - prediction.El))
            self.estimated.pos = HoundUtils.Geo.getProjectedIP(datapoint.platformPos, self.estimated.Az,
                self.estimated.El)

            self.P.Az = (1 - self.K.Az)
            self.P.El = (1 - self.K.El)

            return self.estimated
        end

        Kalman.predict = function(self, datapoint)
            local prediction = {}
            prediction.Az, prediction.El = HoundUtils.Elint.getAzimuth(datapoint.platformPos, self.estimated.pos, 0)
            -- prediction.pos = HoundUtils.Geo.getProjectedIP(datapoint.platformPos,prediction.Az,prediction.El)
            return prediction
        end

        Kalman.getValue = function(self)
            return self.estimated
        end

        return Kalman
    end

    --- Pseudo-linear Kalman filter
    -- @section UB-PLKF

    --- UB-PLKF (Unbiased Pseudo-Linear Kalman Filter)
    -- Implementation of algorithem described in https://www.mdpi.com/2072-4292/13/15/2915
    HOUND.Contact.Estimator.UPLKF = {}
    HOUND.Contact.Estimator.UPLKF.__index = HOUND.Contact.Estimator.UPLKF

    --- Create PLKF instance
    -- @local
    -- @param p0 Initial position (DCS point)
    -- @param[type=?table] v0 Initial velocity (x,z)
    -- @param[type=?number] timestamp Initial time
    -- @param[type=?number] initialPosError Uncertainty of position measurement
    -- @param[type=?boolean] isMobile Is the platform mobile?
    function HOUND.Contact.Estimator.UPLKF:create(p0, v0, timestamp, initialPosError, isMobile)
        if not HoundUtils.Dcs.isPoint(p0) then return nil end
        local instance = {}
        setmetatable(instance, HOUND.Contact.Estimator.UPLKF)
        instance.t0 = timestamp or timer.getAbsTime()
        instance.mobile = isMobile or false
        v0 = v0 or { z = 0, x = 0 }

        -- intialize the State Matrix
        -- DCS is wierd. X is north, Z is east, Y is up. so values are flipped so it will conform to normal X,Y used in the whitepaper
        instance.state = matrix({
            { p0.x },
            { p0.z },
            { v0.x },
            { v0.z }
        })
        -- initialize State Covariance Matrix
        local position_accuracy = initialPosError or 10000
        position_accuracy = l_math.min(position_accuracy, 10000)
        -- Set velocity uncertainty to 30 m/s (slightly higher than max velocity of 27.78 m/s)
        local velocity_accuracy = instance.mobile and 30 or 1
        instance.P = matrix({
            { l_math.pow(position_accuracy, 2), 0,                                0,                                0 },
            { 0,                                l_math.pow(position_accuracy, 2), 0,                                0 },
            { 0,                                0,                                l_math.pow(velocity_accuracy, 2), 0 },
            { 0,                                0,                                0,                                l_math.pow(velocity_accuracy, 2) }
        })

        if HOUND.KALMAN_DEBUG and  HOUND.DEBUG then
            instance.marker = HoundUtils.Marker.create()
            trigger.action.outText("new KF: x:" .. instance.state[2][1] .. "| y: " .. instance.state[1][1], 20)
        end
        return instance
    end

    --- get current estimated position in DCS point from a Kalman state
    -- @local
    -- @param[type=?table] state from which position will be extracted. defaults self.state.
    -- @return DCS point.
    function HOUND.Contact.Estimator.UPLKF:getEstimatedPos(state)
        local X_k = state or self.state
        local pos = { x = X_k[1][1], z = X_k[2][1] }
        if HoundUtils.Dcs.isPoint(pos) then
            pos = HoundUtils.Geo.setPointHeight(pos)
            return pos
        end
    end

    --- Get uncertainty ellipse from covariance matrix P
    -- Extracts position covariance (upper-left 2x2 of P) and computes ellipse parameters
    -- @local
    -- @param[opt] confidence Confidence level multiplier (default 2.45 for ~95% confidence)
    -- @return table with major, minor, theta, az, r (same format as calculateEllipse)
    function HOUND.Contact.Estimator.UPLKF:getUncertainty(confidence)
        -- Default to ~95% confidence (chi-squared with 2 DOF: sqrt(5.991) ≈ 2.45)
        local k = confidence or 2.45

        -- Extract position covariance (upper-left 2x2 block)
        local P_xx = self.P[1][1]  -- variance in x (North)
        local P_zz = self.P[2][2]  -- variance in z (East)
        local P_xz = self.P[1][2]  -- covariance x-z

        -- Eigenvalue decomposition for 2x2 symmetric matrix
        -- λ = (trace ± sqrt(trace² - 4*det)) / 2
        local trace = P_xx + P_zz
        local det = P_xx * P_zz - P_xz * P_xz
        local discriminant = l_math.max(0, trace * trace - 4 * det)  -- ensure non-negative
        local sqrt_disc = l_math.sqrt(discriminant)

        local lambda1 = (trace + sqrt_disc) / 2  -- larger eigenvalue
        local lambda2 = (trace - sqrt_disc) / 2  -- smaller eigenvalue

        -- Semi-axes are sqrt(eigenvalue) * confidence_multiplier
        local major = k * l_math.sqrt(l_math.max(0, lambda1))
        local minor = k * l_math.sqrt(l_math.max(0, lambda2))

        -- Orientation angle: angle of eigenvector for larger eigenvalue
        -- θ = 0.5 * atan2(2*P_xz, P_xx - P_zz)
        local theta = 0.5 * l_math.atan2(2 * P_xz, P_xx - P_zz)

        -- Build uncertainty_data in same format as calculateEllipse
        local uncertenty_data = {}
        uncertenty_data.major = l_math.floor(major * 2 + 0.5)  -- full axis length, rounded
        uncertenty_data.minor = l_math.floor(minor * 2 + 0.5)  -- full axis length, rounded
        uncertenty_data.theta = theta
        uncertenty_data.az = l_math.floor(l_math.deg(theta) + 0.5)
        uncertenty_data.r = (uncertenty_data.major + uncertenty_data.minor) / 4

        return uncertenty_data
    end

    --- normalize azimuth to East aligned counterclockwise
    -- @local
    -- @number azimuth in radians (0-2Pi)
    -- @return angle in radian (-pi to pi) east aligned counterclockwise rotation
    function HOUND.Contact.Estimator.UPLKF.normalizeAz(azimuth)
        -- Convert from DCS azimuth (clockwise from North) to bearing (clockwise from East)
        local bearing = (HalfPi - azimuth + TwoPI) % TwoPI
        -- Normalize to [-pi, pi]
        return (((bearing) + l_math.pi) % TwoPI) - l_math.pi
    end

    --- Convert bearing to DCS azimuth
    -- @local
    -- @number bearing in radians (clockwise from East)
    -- @return azimuth in radians (clockwise from North)
    function HOUND.Contact.Estimator.UPLKF.bearingToAzimuth(bearing)
        return (HalfPi - bearing + TwoPI) % TwoPI
    end

    --- update debug marker
    -- draw a debug marker from current self.state
    -- @local
    function HOUND.Contact.Estimator.UPLKF:updateMarker()
        HOUND.Logger.trace("updating marker")
        local pos = self:getEstimatedPos()
        self.marker:update({
            useLegacyMarker = false
            ,
            pos = pos,
            text = "UB-PLKF",
            coalition = -1
        })
    end

    --- create F matrix
    -- @local
    -- @param deltaT
    -- @return F matrix
    function HOUND.Contact.Estimator.UPLKF:getF(deltaT)
        local Ft = matrix(4, "I")
        Ft[1][3] = deltaT
        Ft[2][4] = deltaT
        return Ft
    end

    --- create the Q matrix
    -- @local
    -- @param[type=?number] deltaT time from last mesurement. default is 10 seconds
    -- @return Q matrix
    -- Process noise represents target motion uncertainty (acceleration), NOT measurement noise
    -- For stationary radars: very low (q_a ~ 0.01 m/s²)
    -- For mobile targets: moderate (q_a ~ 1 m/s² for slowly maneuvering)
    function HOUND.Contact.Estimator.UPLKF:getQ(deltaT)
        local dT = deltaT or 10
        -- q_a is acceleration standard deviation in m/s²
        -- Stationary radar: tiny movements only (vibration, wind)
        -- Mobile: slow maneuvering ground vehicles
        local q_a = self.mobile and 0.5 or 0.01
        local q = q_a * q_a  -- variance

        -- Standard discrete-time process noise for constant velocity model
        -- See paper equation (3)
        return matrix({
            { (dT^4)/4 * q, 0,             (dT^3)/2 * q, 0 },
            { 0,            (dT^4)/4 * q,  0,            (dT^3)/2 * q },
            { (dT^3)/2 * q, 0,             (dT^2) * q,   0 },
            { 0,            (dT^3)/2 * q,  0,            (dT^2) * q },
        })
    end

    --- Kalman prediction step for provided state
    -- @local
    -- @param[type=table] X state matrix for prediction
    -- @param[type=table] P state covariance matrix
    -- @param[type=number] timestep (in seconds)
    -- @param[type=?table] Q process nose matrix. will be generated with generic settings if not provided
    -- @return x_hat the predicted state matrix
    -- @return P_hat the predicted state covariance matrix
    function HOUND.Contact.Estimator.UPLKF:predictStep(X, P, timestep, Q)
        local F = self:getF(timestep)
        local Q = Q or self:getQ(timestep)
        -- predict state (Q only affects covariance, NOT state)
        local x_hat = F * X
        -- Predicted state covariance matrix
        local P_hat = F * P * F:transpose() + Q

        -- Clamp velocities to 30 m/s
        x_hat[3][1] = HoundUtils.Mapping.clamp(x_hat[3][1], -30.0, 30.0)
        x_hat[4][1] = HoundUtils.Mapping.clamp(x_hat[4][1], -30.0, 30.0)
        return x_hat, P_hat
    end

    --- Perform a prediction for the filter and update state
    -- @param[type=?number] timestamp DCS AbsTime timestamp
    -- @local
    function HOUND.Contact.Estimator.UPLKF:predict(timestamp)
        timestamp = timestamp or timer.getAbsTime()
        local deltaT = timestamp - self.t0
        self.t0 = timestamp

        -- predict state
        self.state, self.P = self:predictStep(self.state, self.P, deltaT)
    end

    --- perform update of state with mesurment
    -- @local
    -- @param[type=table] p0 Position of platform (DCS point)
    -- @param[type=number] z current mesurment
    -- @param[type=number] timestamp time of mesurment
    -- @param[type=number] z_err maximum error in mesurment (radians)
    function HOUND.Contact.Estimator.UPLKF:update(p0, z, timestamp, z_err)
        timestamp = timestamp or timer.getAbsTime()
        local deltaT = timestamp - self.t0

        -- Measurement noise: convert maxError (~2σ) to standard deviation
        local sigma_r = (z_err or l_math.rad(HOUND.MAX_ANGULAR_RES_DEG)) / 2

        local x_hat, P_k
        -- If deltaT is very small (< 0.5s), skip prediction - measurements are essentially simultaneous
        -- This handles multiple platforms measured in the same loop iteration
        if deltaT < 0.5 then
            x_hat = self.state
            P_k = self.P
        else
            self.t0 = timestamp  -- only update time reference for significant time steps
            local Q = self:getQ(deltaT)
            x_hat, P_k = self:predictStep(self.state, self.P, deltaT, Q)
        end

        local estimatedPos = self:getEstimatedPos(x_hat)

        -- Use DCS azimuth directly - getAzimuth returns atan2(Δz, Δx) which matches paper's β
        local beta_measured = z  -- measured azimuth (with noise)

        -- Use MEASURED bearing for H, z, and m (standard PLKF approach)
        -- UB-PLKF uses predicted bearing, but that can diverge when estimate is far from truth
        -- Standard PLKF is more robust for initial convergence
        local cos_beta_k, sin_beta_k = l_math.cos(beta_measured), l_math.sin(beta_measured)

        -- m_k per equation (43): m_k = cos(β̂)*(p̂_x - s_x) + sin(β̂)*(p̂_y - s_y)
        -- This is the projection of (target - sensor) vector onto the bearing direction
        -- In DCS: x = North, z = East; s = sensor (p0), p̂ = estimated target
        local m_k = cos_beta_k * (estimatedPos.x - p0.x) + sin_beta_k * (estimatedPos.z - p0.z)

        -- Safeguard against m_k approaching zero (would cause numerical instability)
        if l_math.abs(m_k) < 100 then
            m_k = (m_k >= 0) and 100 or -100
        end

        -- H̄_k matrix per equation (43): [sin(β), -cos(β), 0, 0] / m_k
        -- In DCS coordinates (X=North, Z=East)
        local H_k = matrix({
            { sin_beta_k / m_k, -cos_beta_k / m_k, 0, 0 }
        })

        -- Pseudo-linear measurement z_k per equation (7-8):
        -- z_k = sin(β̃) * s_x - cos(β̃) * s_y  (where s is sensor position p0)
        -- Then z̄_k = z_k / m_k per equation (43)
        local cos_z, sin_z = l_math.cos(beta_measured), l_math.sin(beta_measured)
        local z_pseudo = sin_z * p0.x - cos_z * p0.z
        local z_k = matrix({ { z_pseudo / m_k } })

        -- S_k per equation (47): H̄_k * P * H̄_k^T + σ_k²
        -- R_k = σ² (bearing noise variance)
        local R_k = matrix({ { sigma_r * sigma_r } })
        local S_k = H_k * P_k * H_k:transpose() + R_k

        -- Kalman Gain
        local K_k = P_k * H_k:transpose() * S_k:invert()

        local y_k = z_k - H_k * x_hat

        -- HOUND.Logger.debug("beta_measured: " .. beta_measured .. " m_k: " .. m_k .. " y_k: " .. y_k[1][1])
        -- update globals
        self.state = x_hat + (K_k * y_k)
        self.P = (matrix(4, "I") - K_k * H_k) * P_k

        -- Clamp final velocities to 30 m/s
        self.state[3][1] = HoundUtils.Mapping.clamp(self.state[3][1], -30.0, 30.0)
        self.state[4][1] = HoundUtils.Mapping.clamp(self.state[4][1], -30.0, 30.0)

        if HOUND.KALMAN_DEBUG and HOUND.DEBUG then
            self:updateMarker()
        end
    end

    setmetatable(HOUND.Contact.Estimator.UPLKF,
        { __call = function(...) return HOUND.Contact.Estimator.UPLKF.create(...) end })
end
