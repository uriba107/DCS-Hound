--- HoundEstimator
-- @module HoundEstimator
do
    local l_math = math
    local l_mist = mist
    local PI_2 = 2*l_math.pi

    -- @type HoundDatapoint
    HoundEstimator = {}
    HoundEstimator.__index = HoundEstimator
    HoundEstimator.Kalman = {}

    --- Kalman Filter implementation for position
    -- @local
    -- @return Kalman filter instance
    function HoundEstimator.Kalman.posFilter()
        local Kalman = {}
        Kalman.K = {
            x = 0,
            z = 0,
            -- minor = 0,
            -- major = 0,
            -- theta = 0
        }
        Kalman.P = {
            x = 1,
            z = 1,
            -- major = 1,
            -- minor = 1,
            -- theta = 1
        }

        Kalman.estimated = {}

        Kalman.update = function(self,pos,errorData)
            if type(self.estimated.p) ~= "table" and HoundUtils.Geo.isDcsPoint(pos) then
                self.estimated.p = l_mist.utils.deepCopy(pos)
            end

            -- start with 50km error
            local errX = 500000
            local errZ = 500000

            if type(errorData) == "table" and errorData.theta then
                local sinTheta = l_math.sin(errorData.theta)
                local cosTheta = l_math.cos(errorData.theta)

                errX = l_math.max(l_math.abs(errorData.minor/2*cosTheta), l_math.abs(-errorData.major/2*sinTheta))
                errZ = l_math.max(l_math.abs(errorData.minor/2*sinTheta), l_math.abs(errorData.major/2*cosTheta))

            -- if not self.estimated.major then self.estimated.major = errorData.major end
            -- if not self.estimated.minor then self.estimated.minor = errorData.minor end
            -- if not self.estimated.theta then self.estimated.theta = errorData.theta end

            -- self.K.major = self.P.major / (self.P.major+(errorData.major/self.estimated.major))
            -- self.K.minor = self.P.minor / (self.P.minor+(errorData.minor/self.estimated.minor))
            -- self.K.theta = l_math.abs(HoundUtils.angleDeltaRad(self.estimated.theta,errorData.theta))/PI_2
            elseif type(errorData) == "number" then
                errX = errorData
                errZ = errorData
            end


            self.K.x = self.P.x / (self.P.x+(errX/100))
            self.K.z = self.P.z / (self.P.z+(errZ/100))
            -- HoundLogger.trace("Pos Kalman: errors " .. (errX/1000) .. "|" .. (errZ/1000) .. " gains: " .. self.K.x.."|".. self.K.z)
            -- HoundLogger.trace("deltas: " .. (pos.x-self.estimated.p.x) .. " (" .. (self.K.x * (pos.x-self.estimated.p.x)) .. ")|".. (pos.z-self.estimated.p.z).. " ("..(self.K.z * (pos.z-self.estimated.p.z)) .. ")")

            self.estimated.p.x = self.estimated.p.x + (self.K.x * (pos.x-self.estimated.p.x))
            self.estimated.p.z = self.estimated.p.z + (self.K.z * (pos.z-self.estimated.p.z))
            -- if type(errorData.minor) == "number" and type(errorData.major) == "number" then
            --     self.estimated.major = self.estimated.major + (self.K.major * (errorData.major-self.estimated.major))
            --     self.estimated.minor = self.estimated.minor + (self.K.minor * (errorData.minor-self.estimated.minor))
            --     self.estimated.theta = ( self.estimated.theta + (self.K.theta * HoundUtils.angleDeltaRad(self.estimated.theta,errorData.theta)) + PI_2) % PI_2
            --     self.P.major = (1-self.K.major)
            --     self.P.minor = (1-self.K.minor)
            -- end

            self.P.x = (1-self.K.x)
            self.P.z = (1-self.K.z)

            self.estimated.p = HoundUtils.Geo.setHeight(self.estimated.p)
            return self.estimated.p
        end

        Kalman.get = function(self)
            return self.estimated.p
        end

        -- Kalman.getEllipse = function(self)
        --     return {
        --         theta = self.estimated.theta,
        --         minor = l_mist.utils.round(self.estimated.minor),
        --         major = l_mist.utils.round(self.estimated.major),
        --         az = l_mist.utils.round(l_math.deg(self.estimated.theta)),
        --         r  = l_mist.utils.round((self.estimated.major+self.estimated.minor)/4)
        --     }
        -- end
        return Kalman
    end

    --- Kalman Filter implementation for Azimuth
    -- @local
    -- @param noise angular error
    -- @return Kalman filter instance
    function HoundEstimator.Kalman.AzFilter(noise)
        local Kalman = {}
        Kalman.P = 1
        Kalman.K = 0
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
            self.K = self.P / (self.P+self.noise)
            local deltaAz = newAz-predAz
            -- HoundLogger.trace("In values: " .. l_math.deg(newAz) .. " p: " .. l_math.deg(predAz) .. " delta " .. l_math.deg(deltaAz) .. " with Gain: " .. l_math.deg(self.K * deltaAz))
            self.estimated = ((self.estimated + self.K * (deltaAz)) + PI_2) % PI_2
            self.P = (1-self.K)
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
