--- HOUND.Contact.Estimator
-- @module HOUND.Contact.Estimator
do
    local l_math = math
    -- local l_mist = HOUND.Mist
    local TwoPI = 2*l_math.pi
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
            score = HoundUtils.Mapping.linear(err,0,100000,1,0,true)
            score = HoundUtils.Cluster.gaussianKernel(score,0.2)
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

        Kalman.update = function(self,datapoint)
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

            local Kx = self.P.x / (self.P.x+(datapoint.err.score.x))
            local Kz = self.P.z / (self.P.z+(datapoint.err.score.z))

            self.estimated.p.x = self.estimated.p.x + (Kx * (datapoint.x-self.estimated.p.x))
            self.estimated.p.z = self.estimated.p.z + (Kz * (datapoint.z-self.estimated.p.z))

            self.P.x = (1-Kx) * self.P.x
            self.P.z = (1-Kz) * self.P.z

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
    -- @param noise angular error
    -- @return Kalman filter instance
    function HOUND.Contact.Estimator.Kalman.AzFilter(noise)
        local Kalman = {}
        Kalman.P = 0.5
        Kalman.noise = noise

        Kalman.estimated = nil

        Kalman.update = function (self,newAz,predictedAz,processNoise)
            if not self.estimated then
                self.estimated = newAz
            end
            local predAz = self.estimated
            local noiseP = self.noise
            if type(predictedAz) == "number" then
                predAz = predictedAz
            end
            if type(processNoise) == "number" then
                noiseP = processNoise
            end

            self.P = self.P + l_math.sqrt(noiseP) -- add "process noise" in the form of standard diviation
            local K = self.P / (self.P+self.noise)
            local deltaAz = newAz-predAz
            self.estimated = ((self.estimated + K * (deltaAz)) + TwoPI) % TwoPI
            self.P = (1-K) * self.P
        end

        Kalman.get = function (self)
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

        Kalman.update = function(self,datapoint)
            if not self.estimated.pos and datapoint:getPos() then
                self.estimated.Az = (1/self.P.Az) * datapoint.az
                self.estimated.El = (1/self.P.El) * datapoint.el
                self.estimated.pos = HoundUtils.Geo.getProjectedIP(datapoint.platformPos,self.estimated.Az,self.estimated.El)
                return self.estimated
            end
            local prediction = self:predict(datapoint)

            -- update uncertenties
            -- TODO: make smarter
            local errEstimate = {
                Az = datapoint.platformPrecision,
                El = datapoint.platformPrecision
            }

            self.K.Az = self.P.Az / (self.P.Az+errEstimate.Az)
            self.K.El = self.P.El / (self.P.El+errEstimate.El)

            self.estimated.Az = self.estimated.Az + (self.K.Az * (datapoint.az-prediction.Az))
            self.estimated.El = self.estimated.El + (self.K.El * (datapoint.el-prediction.El))
            self.estimated.pos = HoundUtils.Geo.getProjectedIP(datapoint.platformPos,self.estimated.Az,self.estimated.El)

            self.P.Az = (1-self.K.Az)
            self.P.El = (1-self.K.El)

            return self.estimated
        end

        Kalman.predict = function(self,datapoint)
            local prediction = {}
            prediction.Az,prediction.El = HoundUtils.Elint.getAzimuth( datapoint.platformPos , self.estimated.pos, 0 )
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

    -- TODO: fix divergence

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
    function HOUND.Contact.Estimator.UPLKF:create(p0,v0,timestamp,initialPosError,isMobile)
        if not HoundUtils.Dcs.isPoint(p0) then return nil end
        local instance = {}
        setmetatable( instance,HOUND.Contact.Estimator.UPLKF )
        instance.t0 = timestamp or timer.getAbsTime()
        instance.mobile = isMobile or false
        instance._maxNoise = 0
        v0 = v0 or {z=0,x=0}

        -- intialize the State Matrix
        -- DCS is wierd. X is north, Z is east, Y is up. so values are flipped so it will conform to normal X,Y used in the whitepaper
        instance.state = matrix({
            {p0.x},
            {p0.z},
            {v0.x},
            {v0.z}
        })
        -- initialize State Covariance Matrix
        local position_accuracy = initialPosError or 10000
        position_accuracy = l_math.min(position_accuracy,10000)
        local velocity_accuracy = 1
        instance.P = matrix({
            {l_math.pow(position_accuracy,2),0,0,0},
            {0,l_math.pow(position_accuracy,2),0,0},
            {0,0,l_math.pow(velocity_accuracy,2),0},
            {0,0,0,l_math.pow(velocity_accuracy,2)}
        })

        -- if not instance.mobile then
        --     instance.P[3][3] = 0
        --     instance.P[4][4] = 0
        --     instance.Q[3][3] = 0
        --     instance.Q[4][4] = 0
        -- end

        if HOUND.DEBUG then
            instance.marker = HoundUtils.Marker.create()
            trigger.action.outText("new KF: x:" .. instance.state[2][1] .. "| y: " .. instance.state[1][1],20)
        end
        return instance
    end

    --- get current estimated position in DCS point from a Kalman state
    -- @local
    -- @param[type=?table] state from which position will be extracted. defaults self.state.
    -- @return DCS point.
    function HOUND.Contact.Estimator.UPLKF:getEstimatedPos(state)
        local X_k = state or self.state
        local pos = {x = X_k[1][1], z = X_k[2][1]}
        if HoundUtils.Dcs.isPoint(pos) then
            pos = HoundUtils.Geo.setPointHeight(pos)
            return pos
        end
    end

    --- normalize azimuth to East aligned counterclockwise
    -- @local
    -- @number azimuth in radians (0-2Pi)
    -- @return angle in radian (-pi to pi) east aligned counterclockwise rotation
    function HOUND.Contact.Estimator.UPLKF.normalizeAz(azimuth)
        -- return (((HalfPi - azimuth) + l_math.pi) % TwoPI) - l_math.pi
        -- try normlize to +- pi without changing direction or 0
        return (((azimuth) + l_math.pi) % TwoPI) - l_math.pi
        -- try normlize to +- pi counterclockwise
        -- return (((TwoPI - azimuth) + l_math.pi) % TwoPI) - l_math.pi
    end

    --- update debug marker
    -- draw a debug marker from current self.state
    -- @local
    function HOUND.Contact.Estimator.UPLKF:updateMarker()
        HOUND.Logger.trace("updating marker")
        local pos = self:getEstimatedPos()
        self.marker:update({useLegacyMarker = false
        ,pos=pos,text="UB-PLKF",coalition=-1})
    end

    --- create F matrix
    -- @local
    -- @param deltaT
    -- @return F matrix
    function HOUND.Contact.Estimator.UPLKF:getF(deltaT)
        local Ft = matrix(4,"I")
        Ft[1][3] = deltaT
        Ft[2][4] = deltaT
        return Ft
    end

    --- create the Q matrix
    -- @local
    -- @param[type=?number] deltaT time from last mesurement. default is 10 seconds
    -- @param[type=?number] sigma error in mesurment. default is 0.1 radians
    -- @return Q matrix
    function HOUND.Contact.Estimator.UPLKF:getQ(deltaT,sigma)
        -- initialize Process Noise Covariance Matrix
        local dT = deltaT or 10
        local sigma_a = sigma or self._maxNoise
        sigma_a = sigma_a/2

        -- return matrix({
        --     {0.25*l_math.pow(dT,4)*sigma_a,0,0.5*l_math.pow(dT,3)*sigma_a,0},
        --     {0,0.25*l_math.pow(dT,4)*sigma_a,0,0.5*l_math.pow(dT,3)*sigma_a},
        --     {0.5*l_math.pow(dT,3)*sigma_a,0,l_math.pow(dT,2)*sigma_a,0},
        --     {0,0.5*l_math.pow(dT,3)*sigma_a,0,l_math.pow(dT,2)*sigma_a},
        -- })

        return matrix(4,4,0)  -- no noise

    end

    --- Kalman prediction step for provided state
    -- @local
    -- @param[type=table] X state matrix for prediction
    -- @param[type=table] P state covariance matrix
    -- @param[type=number] timestep (in seconds)
    -- @param[type=?table] Q process nose matrix. will be generated with generic settings if not provided
    -- @return x_hat the predicted state matrix
    -- @return P_hat the predicted state covariance matrix
    function HOUND.Contact.Estimator.UPLKF:predictStep(X,P,timestep,Q)
        local F = self:getF(timestep)
        local Q = Q or self:getQ(timestep)
        -- predict state
        local x_hat = F * X + Q
        -- Predicted state covariance matrix
        local P_hat = F * P * F:transpose() + Q

        -- x_hat[3][1] = HoundUtils.Mapping.clamp(x_hat[3][1],-25.0,25.0)
        -- x_hat[4][1] = HoundUtils.Mapping.clamp(x_hat[4][1],-25.0,25.0)
        return x_hat,P_hat
    end

    --- Perform a prediction for the filter and update state
    -- @param[type=?number] timestamp DCS AbsTime timestamp
    -- @local
    function HOUND.Contact.Estimator.UPLKF:predict(timestamp)
        timestamp = timestamp or timer.getAbsTime()
        local deltaT = timestamp - self.t0
        self.t0 = timestamp

        -- predict state
        self.state,self.P = self:predictStep(self.state,self.P,deltaT)
    end

    --- perform update of state with mesurment
    -- @local
    -- @param[type=table] p0 Position of platform (DCS point)
    -- @param[type=number] z current mesurment
    -- @param[type=number] timestamp time of mesurment
    -- @param[type=number] z_err maximum error in mesurment (radians)
    function HOUND.Contact.Estimator.UPLKF:update(p0,z,timestamp,z_err)
        -- HOUND.Logger.debug("pre:\n state " .. mist.utils.tableShow(self.state) .."\n P: " .. mist.utils.tableShow(self.P))

        timestamp = timestamp or timer.getAbsTime()
        local deltaT = timestamp - self.t0
        self.t0 = timestamp
        local err = z_err or l_math.rad(HOUND.MAX_ANGULAR_RES_DEG)
        local Ri = err/2
        self._maxNoise = l_math.max(self._maxNoise,err)

        -- predict state and covariance matrix
        -- local F = self:getFt(deltaT)
        local Q = self:getQ(deltaT)
        -- clamp velocities



        local x_hat,P_k = self:predictStep(self.state,self.P,deltaT,Q)

        local estimatedPos = self:getEstimatedPos(x_hat)
        local d_k = HoundUtils.Geo.get2DDistance(p0,estimatedPos)

        -- -- full PLKF whitepaper
        local z_hat = self.normalizeAz(HoundUtils.Elint.getAzimuth(p0,estimatedPos))
        local cos_beta_k,sin_beta_k = l_math.cos(z_hat),l_math.sin(z_hat)
        local m_k = cos_beta_k*estimatedPos.x + sin_beta_k*estimatedPos.z - d_k
        local H_k = matrix({
            {sin_beta_k/m_k,-cos_beta_k/m_k,0,0}
        })
        local z_k = matrix({{self.normalizeAz(z)}})/m_k

        -- generate new s_K based on item 47
        local R_k = matrix({{l_math.sqrt(Ri)}})
        local S_k = H_k * P_k * H_k:transpose() + R_k

        -- Kalman Gain
        local K_k = P_k * H_k:transpose() * S_k:invert()

        local y_k = z_k - H_k * x_hat

        HOUND.Logger.debug("z: ".. self.normalizeAz(z) .. "\n z_hat: ".. z_hat )
        -- update globals
        self.state = x_hat + (K_k * y_k)
        self.P = (matrix(4,"I") - K_k * H_k) * P_k

        -- self.state[3][1] = HoundUtils.Mapping.clamp(self.state[3][1],-25.0,25.0)
        -- self.state[4][1] = HoundUtils.Mapping.clamp(self.state[4][1],-25.0,25.0)

        if HOUND.DEBUG then
            self:updateMarker()
        end
    end

    setmetatable(HOUND.Contact.Estimator.UPLKF,{ __call = function( ... ) return HOUND.Contact.Estimator.UPLKF.create( ... ) end } )

end
