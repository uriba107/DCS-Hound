-- --------------------------------------
do
    HoundElintDatapoint = {}
    HoundElintDatapoint.__index = HoundElintDatapoint

    function HoundElintDatapoint:New(platform0, p0, az0, el0, t0,isPlatformStatic,sensorMargins)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HoundElintDatapoint)
        elintDatapoint.platformPos = p0
        elintDatapoint.az = az0
        elintDatapoint.el = el0
        elintDatapoint.t = tonumber(t0)
        elintDatapoint.platformId = platform0:getID()
        elintDatapoint.platfromName = platform0:getName()
        elintDatapoint.platformStatic = isPlatformStatic or false
        elintDatapoint.platformPrecision = sensorMargins or math.rad(20)
        elintDatapoint.estimatedPos = nil
        return elintDatapoint
    end

    function HoundElintDatapoint:estimatePos()
        if self.el == nil then return end
        local l_math = math
        -- env.info("decl is " .. l_mist.utils.toDegree(self.el))
        local maxSlant = self.platformPos.y/l_math.abs(l_math.sin(self.el))

        local unitVector = {
            x = l_math.cos(self.el)*l_math.cos(self.az),
            z = l_math.cos(self.el)*l_math.sin(self.az),
            y = l_math.sin(self.el)
        }
        -- env.info("unit Vector: X " ..unitVector.x .." ,Z "..unitVector.z..", Y:" .. unitVector.y .. " | maxSlant " .. maxSlant)

        self.estimatedPos = land.getIP(self.platformPos, unitVector , maxSlant+1000 )
        -- debugging
        -- env.info(l_mist.utils.tableShow( self.estimatedPos))
        -- local latitude, longitude, altitude = coord.LOtoLL(self.estimatedPos)
        -- env.info("estimated 3d point: Lat " ..latitude.." ,lon "..longitude..", alt:" .. tostring(altitude) )
    end
end

do
    HoundContact = {}
    HoundContact.__index = HoundContact

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    function HoundContact:New(DCS_Unit,platformCoalition)
        local elintcontact = {}
        setmetatable(elintcontact, HoundContact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = DCS_Unit:getID()
        elintcontact.DCStypeName = DCS_Unit:getTypeName()
        elintcontact.typeName = DCS_Unit:getTypeName()
        elintcontact.isEWR = false
        elintcontact.typeAssigned = "Unknown" 
        elintcontact.band = "C"
        if setContains(HoundDB.Sam,DCS_Unit:getTypeName())  then
            local unitName = DCS_Unit:getTypeName()
            elintcontact.typeName =  HoundDB.Sam[unitName].Name
            elintcontact.isEWR = (HoundDB.Sam[unitName].Role == "EWR")
            elintcontact.typeAssigned = HoundDB.Sam[unitName].Assigned
            elintcontact.band = HoundDB.Sam[unitName].Band
        end
         
        elintcontact.pos = {
            p = nil,
            grid = nil,
            LL = {
                lat = nil, 
                lon = nil,
            },
            be = {
                brg = nil,
                rng = nil
            }
        }
        elintcontact.uncertenty_radius = nil
        elintcontact.last_seen = timer.getAbsTime()
        elintcontact.first_seen = timer.getAbsTime()
        elintcontact.maxRange = HoundUtils.getSamMaxRange(DCS_Unit)
        elintcontact.dataPoints = {}
        elintcontact.markpointID = nil
        elintcontact.platformCoalition = platformCoalition
        return elintcontact
    end

    function HoundContact:CleanTimedout()
        if HoundUtils:timeDelta(timer.getAbsTime(), self.last_seen) > 900 then
            -- if contact wasn't seen for 15 minuts purge all currnent data
            self.dataPoints = {}
        end
    end

    function HoundContact:isAlive()
        if self.unit:isExist() == false or self.unit:getLife() < 1 then return false end
        return true
    end

    function HoundContact:countDatapoints()
        local count = 0
        for _,platformDataPoints in pairs(self.dataPoints) do
            count = count + length(platformDataPoints)
        end
        return count
    end

    function HoundContact:getName()
        return self.typeName .. " " .. (self.uid%100)
    end

    function HoundContact:getId()
        return self.uid%100
    end

    function HoundContact:AddPoint(datapoint)

        self.last_seen = datapoint.t
        if length(self.dataPoints[datapoint.platformId]) == 0 then
            self.dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            -- if Reciver is static, just keep the last Datapoint, as position never changes.
            -- if There is a datapoint, do rolling avarage on AZ to clean errors out.
            if length(self.dataPoints[datapoint.platformId]) > 0 then
                datapoint.az =  HoundUtils.AzimuthAverage({datapoint.az,self.dataPoints[datapoint.platformId][1].az})
            end
            self.dataPoints[datapoint.platformId] = {datapoint}
            return
        end
        if datapoint.el ~=nil then
            datapoint:estimatePos()
        end

        if length(self.dataPoints[datapoint.platformId]) < 2 then
            table.insert(self.dataPoints[datapoint.platformId], datapoint)
        else
            local LastElementIndex = table.getn(self.dataPoints[datapoint.platformId])
            local DeltaT = HoundUtils:timeDelta(self.dataPoints[datapoint.platformId][LastElementIndex - 1].t, datapoint.t)
            if  DeltaT >= 55 then
                table.insert(self.dataPoints[datapoint.platformId], datapoint)
            else
                self.dataPoints[datapoint.platformId][LastElementIndex] = datapoint
            end
            if table.getn(self.dataPoints[datapoint.platformId]) > 15 then
                table.remove(self.dataPoints[datapoint.platformId], 1)
            end
        end
    end

    function HoundContact:triangulatePoints(earlyPoint, latePoint)
        local p1 = earlyPoint.platformPos
        local p2 = latePoint.platformPos

        local m1 = l_math.tan(earlyPoint.az)
        local m2 = l_math.tan(latePoint.az)

        local b1 = -m1 * p1.x + p1.z
        local b2 = -m2 * p2.x + p2.z

        local Easting = (b2 - b1) / (m1 - m2)
        local Northing = m1 * Easting + b1

        local pos = {}
        pos.x = Easting
        pos.z = Northing
        pos.y = land.getHeight({x=pos.x,y=pos.z})

        return pos
    end

    function HoundContact:calculateAzimuthBias(dataPoints)

        local azimuths = {}
        for k,v in ipairs(dataPoints) do
            table.insert(azimuths,v.az)
        end

        return  HoundUtils.AzimuthAverage(azimuths)
    end

    function HoundContact:getDeltaSubsetPercent(Table,referencePos,NthPercentile)
        local t = l_mist.utils.deepCopy(Table)
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(length(t)*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,length(t)),percentile)
        local RelativeToPos = {}
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,l_mist.vec.sub(t[i],referencePos))
        end

        return RelativeToPos
    end

    function HoundContact:calculateEllipse(estimatedPositions,Theta)

        local RelativeToPos = HoundContact:getDeltaSubsetPercent(estimatedPositions,self.pos.p,HOUND.PERCENTILE)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        for k,v in ipairs(RelativeToPos) do
            min.x = l_math.min(min.x,v.x)
            max.x = l_math.max(max.x,v.x)
            min.y = l_math.min(min.y,v.z)
            max.y = l_math.max(max.y,v.z)
        end

        
        local x = l_mist.utils.round(l_math.abs(min.x)+l_math.abs(max.x))
        local y = l_mist.utils.round(l_math.abs(min.y)+l_math.abs(max.y))

        -- -- experimental BS
        if Theta == nil then

            local AzBiasPool = {}

            for _,pos in ipairs(estimatedPositions) do
                local deltaVec = l_mist.vec.sub(self.pos.p,pos)
                table.insert(AzBiasPool,l_math.atan2(deltaVec.z,deltaVec.x))
            end

            Theta = HoundUtils.AzimuthAverage(AzBiasPool)
        end
        
        -- working rotation matrix BS
        local sinTheta = l_math.sin(Theta)
        local cosTheta = l_math.cos(Theta)

        for k,v in ipairs(RelativeToPos) do
            local newPos = {}
            newPos.y = v.y
            newPos.x = v.x*cosTheta - v.z*sinTheta
            newPos.z = v.x*sinTheta + v.z*cosTheta
            RelativeToPos[k] = newPos
        end

        self.uncertenty_radius = {}
        self.uncertenty_radius.major = l_math.max(x,y)
        self.uncertenty_radius.minor = l_math.min(x,y)
        self.uncertenty_radius.az = l_mist.utils.round(l_mist.utils.toDegree(Theta))
        self.uncertenty_radius.r  = (x+y)/4
        
    end

    function HoundContact:calculatePos(estimatedPositions,converge)
        if estimatedPositions == nil then return end
        self.pos.p = l_mist.getAvgPoint(estimatedPositions)
        if converge then
            local subList = estimatedPositions
            local subsetPos = self.pos.p
            while (length(subList) * HOUND.PERCENTILE) > 5 do
                -- env.info("itterating Pos " .. length(subList))
                local NewsubList = HoundContact:getDeltaSubsetPercent(subList,subsetPos,HOUND.PERCENTILE)
                -- env.info("Before integration: x: " .. self.pos.p.x .. " Z: " .. self.pos.p.z )
                subsetPos = l_mist.getAvgPoint(NewsubList)
                -- env.info("delta : x: " ..subsetPos.x .. " Z: " ..subsetPos.z )
                -- subsetPos.x = subsetPos.x/2
                -- subsetPos.z = subsetPos.z/2
                -- env.info("half delta : x: " ..subsetPos.x .. " Z: " ..subsetPos.z )

                self.pos.p.x = self.pos.p.x + (subsetPos.x )
                self.pos.p.z = self.pos.p.z + (subsetPos.z )
                -- env.info("After integration: x: " .. self.pos.p.x .. " Z: " .. self.pos.p.z )
                -- self.pos.p = l_mist.getAvgPoint({l_mist.vec.add(self.pos.p,subsetPos),self.pos.p})
                subList = NewsubList

            end
        end
        self.pos.p.y = land.getHeight({x=self.pos.p.x,y=self.pos.p.z})
        local bullsPos = coalition.getMainRefPoint(self.platformCoalition)
        self.pos.LL.lat, self.pos.LL.lon =  coord.LOtoLL(self.pos.p)
        self.pos.elev = self.pos.p.y
        self.pos.grid  = coord.LLtoMGRS(self.pos.LL.lat, self.pos.LL.lon)
        self.pos.be = HoundUtils.getBR(bullsPos,self.pos.p)
    end

    function HoundContact:removeMarker()
        if self.markpointID ~= nil then
            for _ = 1, length(self.markpointID) do
                trigger.action.removeMark(table.remove(self.markpointID))
            end
        end
    end

    function HoundContact:getMarkerId()
        if self.markpointID == nil then self.markpointID = {} end
        local idx = HoundUtils.getMarkId()
        table.insert(self.markpointID, idx)
        return idx
    end
    
    function HoundContact:drawMarkerCircle()
        local fillcolor = {0,0,0,0.15}
        local linecolor = {0,0,0,0.3}
        if self.platformCoalition == coalition.side.BLUE then
            fillcolor[1] = 1
            linecolor[1] = 1
        end
        if self.platformCoalition == coalition.side.RED then
            fillcolor[3] = 1
            linecolor[3] = 1
        end  
        trigger.action.circleToAll(self.platformCoalition,self:getMarkerId(),self.pos.p,self.uncertenty_radius.r,linecolor,fillcolor,2,true)
    end

    function HoundContact:drawMarkerPolygon(numPoints)
        if numPoints == nil then numPoints = 4 end
        if numPoints ~= 4 then 
            env.info("DCS limitation, only 4 points are allowed")
            numPoints = 4
         end

        -- x = minorAxis*cos(theta)
        -- y = majorAxis*sin(theta)
        local angleStep = pi_2/numPoints
        local theta = l_math.rad(self.uncertenty_radius.az)

        local polygonPoints = {}
        -- generate ellips points
        for pointAngle = angleStep, pi_2, angleStep do
            -- env.info("polygon angle " .. l_math.deg(pointAngle))
            local point = {}
            point.x = self.uncertenty_radius.major/2 * l_math.cos(pointAngle)
            point.z = self.uncertenty_radius.minor/2 * l_math.sin(pointAngle)
            -- rotate and translate into correct position
            local x = point.x * l_math.cos(theta) - point.z * l_math.sin(theta)
            local z = point.x * l_math.sin(theta) + point.z * l_math.cos(theta)
            point.x = x + self.pos.p.x
            point.z = z + self.pos.p.z
            point.y = land.getHeight({x=point.x,y=point.z})

            table.insert(polygonPoints, point)
        end

        -- draw the marker
        local fillcolor = {0,0,0,0.15}
        local linecolor = {0,0,0,0.3}
        if self.platformCoalition == coalition.side.BLUE then
            fillcolor[1] = 1
            linecolor[1] = 1
        end
        if self.platformCoalition == coalition.side.RED then
            fillcolor[3] = 1
            linecolor[3] = 1
        end  
        trigger.action.quadToAll(self.platformCoalition,self:getMarkerId(), polygonPoints[1] , polygonPoints[2] , polygonPoints[3] , polygonPoints[4] , linecolor,fillcolor,2,true)
    end

    function HoundContact:updateMarker(coalitionID,MarkerType)
        if self.pos.p == nil or self.uncertenty_radius == nil then return end


        -- local idx0 = self:getMarkerId()
        self:removeMarker()

        trigger.action.markToCoalition(self:getMarkerId(), self.typeName .. " " .. (self.uid%100) .. " (" .. self.uncertenty_radius.major .. "/" .. self.uncertenty_radius.minor .. "@" .. self.uncertenty_radius.az .. "|" .. l_math.floor(HoundUtils:timeDelta(self.last_seen)) .. "s)",self.pos.p,self.platformCoalition,true)
        if MarkerType == HOUND.MARKER.CIRCLE then
            self:drawMarkerCircle()
        end
        if MarkerType == HOUND.MARKER.DIAMOND or MarkerType == HOUND.MARKER.POLYGON then
            self:drawMarkerPolygon(4)
        end
        -- linecolor[4] = 0.6
        -- trigger.action.textToAll(self.platformCoalition , self.markpointID+1 , self.pos.p , linecolor,{0,0,0,0} , 12 , true , self.typeName .. " " .. (self.uid%100) .. "\n(" .. self.uncertenty_radius.major .. "/" .. self.uncertenty_radius.minor .. "@" .. self.uncertenty_radius.az .. "|" .. HoundUtils:timeDelta(self.last_seen) .. "s)")
    end

    function HoundContact:getTextData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local GridPos = ""
        if utmZone then
            GridPos = GridPos .. self.pos.grid.UTMZone .. " " 
        end
        GridPos = GridPos .. self.pos.grid.MGRSDigraph
        local BE = self.pos.be.brStr .. " for " .. self.pos.be.rng
        if MGRSdigits == nil then
            return GridPos,BE
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        GridPos = GridPos .. " " .. E .. " " .. N
        
        return GridPos,BE
    end

    function HoundContact:getTtsData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local phoneticGridPos = ""
        if utmZone then
            phoneticGridPos =  phoneticGridPos .. HoundUtils.TTS.toPhonetic(self.pos.grid.UTMZone) .. " "
        end

        phoneticGridPos =  phoneticGridPos ..  HoundUtils.TTS.toPhonetic(self.pos.grid.MGRSDigraph)
        local phoneticBulls = HoundUtils.TTS.toPhonetic(self.pos.be.brStr) 
                                .. " for " .. self.pos.be.rng
        if MGRSdigits==nil then
            return phoneticGridPos,phoneticBulls
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        phoneticGridPos = phoneticGridPos .. " " .. HoundUtils.TTS.toPhonetic(E) .. " " .. HoundUtils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end

    function HoundContact:generateTtsBrief(NATO)
        if self.pos.p == nil or self.uncertenty_radius == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = string.gsub(self.typeAssigned,"(SA)-",'')
        end
        local str = reportedName .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos -- .. ", bullseye " .. phoneticBulls 
        end
        str = str .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r ) .. "."
        return str
    end

    function HoundContact:generateTtsReport(refPos)
        if self.pos.p == nil then return end
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,3)
        local msg =  self:getName() .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true) 
        if BR ~= nil 
            then
                msg = msg .. " from you " .. HoundUtils.TTS.toPhonetic(BR.brStr) .. " for " .. BR.rng
            else
                msg = msg .." at bullseye " .. phoneticBulls 
        end
        msg = msg .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r )
        msg = msg .. ", position " .. HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon)
        msg = msg .. ", I repeat " .. HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon)
        msg = msg .. ", MGRS " .. phoneticGridPos
        msg = msg .. ", elevation  " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. " feet MSL"
        msg = msg .. ", ellipse " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_radius.major) .. " by " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_radius.minor) .. ", aligned bearing " .. HoundUtils.TTS.toPhonetic(string.format("%03d",self.uncertenty_radius.az))
        msg = msg .. ", first seen " .. HoundUtils.TTS.getTtsTime(self.first_seen) .. ", last seen " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils:getControllerResponse()
        return msg
    end

    function HoundContact:generateTextReport(refPos)
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true,3)
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local msg =  self:getName() .." (" .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true).. ")\n"
        msg = msg .. "Accuracy: " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r ) .. "\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        if BR ~= nil then
            msg = msg .. "BR: " .. BR.brStr .. " for " .. BR.rng
        end
        msg = msg .. "LL: " .. HoundUtils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. "ft\n"
        msg = msg .. "Ellipse: " ..  self.uncertenty_radius.major .. " by " ..  self.uncertenty_radius.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_radius.az) .. "\n"
        msg = msg .. "First detected: " .. HoundUtils.Text.getTime(self.first_seen) .. " Last Contact: " ..  HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils:getControllerResponse()
        return msg
    end

    function HoundContact:generateRadioItemText()
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self.typeName .. (self.uid % 100) .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end 


    function HoundContact:generatePopUpReport(isTTS)
        local msg = "BREAK, BREAK! New threat detected! "
        msg = msg .. self.typeName .. " " .. (self.uid % 100)
        local GridPos,BePos 
        if isTTS then
            GridPos,BePos = self:getTtsData(true)
            msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
        else
            GridPos,BePos = self:getTextData(true)
            msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
        end
        msg = msg .. " is now Alive!"
        return msg
    end

    function HoundContact:generateDeathReport(isTTS)
        local msg = self:getName()
        local GridPos,BePos 
        if isTTS then
            GridPos,BePos = self:getTtsData(true)
            msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
        else
            GridPos,BePos = self:getTextData(true)
            msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
        end
        msg = msg .. " has been destroyed!"
        return msg
    end

    function HoundContact:processData()
        local newContact = (self.pos.p == nil)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}

        for _,platformDatapoints in pairs(self.dataPoints) do 
            if length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do 
                    if datapoint.isReciverStatic then
                        table.insert(staticDataPoints,datapoint) 
                    else
                        table.insert(mobileDataPoints,datapoint) 
                    end
                    if datapoint.estimatedPos ~= nil then
                        table.insert(estimatePositions,datapoint.estimatedPos)
                    end
                    platforms[datapoint.platfromName] = 1
                end
            end
        end
        local numMobilepoints = length(mobileDataPoints)
        local numStaticPoints = length(staticDataPoints)

        if numMobilepoints+numStaticPoints < 2 and length(estimatePositions) == 0 then return end
        -- Static against all statics
        if numStaticPoints > 1 then
            for i=1,numStaticPoints-1 do
                for j=i+1,numStaticPoints do
                    local err = (staticDataPoints[i].platformPrecision + staticDataPoints[j].platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoints[i].az,staticDataPoints[j].az) > err then
                        table.insert(estimatePositions,self:triangulatePoints(staticDataPoints[i],staticDataPoints[j]))
                    end
                end
            end
        end

        -- Statics against all mobiles
        if numStaticPoints > 0  and numMobilepoints > 0 then
            for i,staticDataPoint in ipairs(staticDataPoints) do
                for j,mobileDataPoint in ipairs(mobileDataPoints) do
                    local err = (staticDataPoint.platformPrecision + mobileDataPoint.platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoint.az,mobileDataPoint.az) > err then
                        table.insert(estimatePositions,self:triangulatePoints(staticDataPoint,mobileDataPoint))
                    end
                end
            end
         end

        -- mobiles agains mobiles
        if numMobilepoints > 1 then
            for i=1,numMobilepoints-1 do
                for j=i+1,numMobilepoints do
                    if mobileDataPoints[i].platformPos  ~= mobileDataPoints[j].platformPos then
                        local err = (mobileDataPoints[i].platformPrecision + mobileDataPoints[j].platformPrecision)/2
                        if HoundUtils.angleDeltaRad(mobileDataPoints[i].az,mobileDataPoints[j].az) > err then
                            table.insert(estimatePositions,self:triangulatePoints(mobileDataPoints[i],mobileDataPoints[j]))
                        end
                    end
                end
            end
        end
        
        if length(estimatePositions) > 2 then
            self:calculatePos(estimatePositions,true)

            -- local combinedDataPoints = {} 
            -- if numMobilepoints > 0 then
            --     for k,v in ipairs(mobileDataPoints) do table.insert(combinedDataPoints,v) end
            -- end
            -- if numStaticPoints > 0 then
            --     for k,v in ipairs(staticDataPoints) do table.insert(combinedDataPoints,v) end
            -- end
            -- self:calculateEllipse(estimatePosition,self:calculateAzimuthBias(combinedDataPoints))
            self:calculateEllipse(estimatePositions)

            local detected_by = {}

            for key, value in pairs(platforms) do
                table.insert(detected_by,key)
            end
            self.detected_by = detected_by
        end

        if newContact and self.pos.p ~= nil and self.isEWR == false then
            return true
        end
        return false

    end
    function HoundContact:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DCSunitName = self.unit:getName()
        if self.pos.p ~= nil and self.uncertenty_radius ~= nil then

        contact.pos = self.pos.p
        contact.accuracy = HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r )
        contact.uncertenty = {
            major = self.uncertenty_radius.major,
            minor = self.uncertenty_radius.minor,
            heading = self.uncertenty_radius.az
        }
        contact.maxRange = self.maxRange
        contact.last_seen = self.last_seen
        end
        contact.detected_by = self.detected_by
        return contact
    end
end
