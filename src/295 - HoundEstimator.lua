--- HoundEstimator
-- @module HoundEstimator
do
    local l_math = math
    -- local l_mist = mist
    local PI_2 = 2*l_math.pi

    -- @type HoundDatapoint
    HoundEstimator = {}
    HoundEstimator.__index = HoundEstimator
    HoundEstimator.Kalman = {}


    --- Fuzzy logic score
    function HoundEstimator.accuracyScore(err)
        local score = 0
        if type(err) == "number" then
            score = HoundUtils.Mapping.linear(err,0,100000,1,0,true)
            score = HoundUtils.Cluster.gaussianKernel(score,0.2)
        end
        -- HoundLogger.trace("err in KM: ".. err/1000 .. " | score: " .. score)
        if type(score) == "number" then
            return score
        else
            return 0
        end
    end


    --- Kalman Filter implementation for position
    -- @local
    -- @return Kalman filter instance
    function HoundEstimator.Kalman.posFilter()
        local Kalman = {}

        Kalman.P = {
            x = 0.5,
            z = 0.5
        }

        Kalman.estimated = {}

        Kalman.update = function(self,datapoint)
            if type(self.estimated.p) ~= "table" and HoundUtils.Geo.isDcsPoint(datapoint) then
                self.estimated.p = {
                    x = datapoint.x,
                    z = datapoint.z,
                    y = datapoint.y
                }
            end

            if type(datapoint.err.score) ~= "table" then
                HoundLogger.trace("Datapoint did not contain score")
                return self.estimated.p
            end
            self.P.x = self.P.x + math.sqrt(datapoint.err.score.x)
            self.P.z = self.P.z + math.sqrt(datapoint.err.score.z)

            local Kx = self.P.x / (self.P.x+(datapoint.err.score.x))
            local Kz = self.P.z / (self.P.z+(datapoint.err.score.z))
            -- HoundLogger.trace("score(K): " .. datapoint.err.score.x .. "/" .. datapoint.err.score.z .. " (" .. self.K.x .. "/".. self.K.z  .. ")")

            self.estimated.p.x = self.estimated.p.x + (Kx * (datapoint.x-self.estimated.p.x))
            self.estimated.p.z = self.estimated.p.z + (Kz * (datapoint.z-self.estimated.p.z))

            self.P.x = (1-Kx) * self.P.x
            self.P.z = (1-Kz) * self.P.z

            -- HoundLogger.trace("P: " .. self.P.x .. "|" .. self.P.z .. " || old logic: ".. (1-self.K.x) .. "|" .. (1-self.K.z))
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
    function HoundEstimator.Kalman.AzFilter(noise)
        local Kalman = {}
        Kalman.P = 0.5
        Kalman.noise = noise

        Kalman.estimated = nil

        Kalman.update = function (self,newAz,predictedAz)
            if not self.estimated then
                self.estimated = newAz
            end
            local predAz = self.estimated
            if type(predictedAz) == "number" then
                predAz = predictedAz
            end
            self.P = self.P + l_math.sqrt(self.noise) -- add "process noise" in the form of standard diviation
            local K = self.P / (self.P+self.noise)
            local deltaAz = newAz-predAz
            -- HoundLogger.trace("In values: " .. l_math.deg(newAz) .. " p: " .. l_math.deg(predAz) .. " delta " .. l_math.deg(deltaAz) .. " with Gain: " .. l_math.deg(self.K * deltaAz))
            self.estimated = ((self.estimated + K * (deltaAz)) + PI_2) % PI_2
            self.P = (1-K) * self.P
            -- HoundLogger.trace("Out values: " .. l_math.deg(self.estimated) )
        end

        Kalman.get = function (self)
            return self.estimated
        end

        return Kalman
    end

    --- Kalman Filter implementation for position.
    -- @local
    -- @return Kalman filter instance
    function HoundEstimator.Kalman.AzElFilter()
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
end
