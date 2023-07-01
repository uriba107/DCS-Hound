--- HOUND.Contact.Base
-- Contact class. containing related functions
-- @module HOUND.Contact.Base
do
    --- HOUND.Contact decleration
    -- Contact class. containing related functions
    -- @type HOUND.Contact.Base
    HOUND.Contact.Base = {}
    HOUND.Contact.Base.__index = HOUND.Contact.Base

    -- local l_math = math
    -- local l_mist = mist
    -- local pi_2 = l_math.pi*2
    local HoundUtils = HOUND.Utils

    --- create new HOUND.Contact instance
    -- @param DCSObject emitter DCS Unit
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @return HOUND.Contact instance
    function HOUND.Contact.Base:New(DCSObject,HoundCoalition)
        if not DCSObject or type(DCSObject) ~= "table" or not DCSObject.getName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact instance")
            return
        end
        local instance = {}
        setmetatable(instance, HOUND.Contact.Base)
        instance.DCSobject = DCSObject
        instance.DCSgroupName = nil
        instance.DCSobjectName = nil
        instance.typeAssigned = {"Unknown"}

        instance.pos = {
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
        instance.uncertenty_data = nil
        instance.last_seen = timer.getAbsTime()
        instance.first_seen = timer.getAbsTime()
        instance.maxWeaponsRange = 0
        instance.detectionRange = 0

        instance._platformCoalition = HoundCoalition
        instance.primarySector = "default"
        instance.threatSectors = {
            default = true
        }
        instance.state = nil
        instance.preBriefed = false
        instance.events = {}
        instance._markpoints = {
            pos = HoundUtils.Marker.create(),
            area = HoundUtils.Marker.create()
        }
        return instance
    end

    --- Destructor function
    function HOUND.Contact.Base:destroy()
        HOUND.Logger.error("HOUND.Contact.Base:destroy() prototype envoked. please override")
    end

    --- Get Contact Group Name
    -- @return String
    function HOUND.Contact.Base:getGroupName()
        return self.DCSgroupName
    end

    --- Get the DCS unit name
    -- @return String
    function HOUND.Contact.Base:getDcsName()
        return self.DCSobjectName
    end

    --- Get the underlying DCS Object
    -- @return DCS Unit or DCS staticObject
    function HOUND.Contact.Base:getDcsObject()
        return self.DCSobject or self.DCSobjectName
    end
    --- Get last seen in seconds
    -- @return number in seconds since contact was last seen
    function HOUND.Contact.Base:getLastSeen()
        return HoundUtils.absTimeDelta(self.last_seen)
    end

    --- get DCS Object instane assoiciated with contact
    -- @return DCS object (unit or group)
    function HOUND.Contact.Base:getObject()
        return self.DCSobject
    end
    --- check if contact has estimated position
    -- @return (Bool) True if contact has estimated position
    function HOUND.Contact.Base:hasPos()
        return HoundUtils.Dcs.isPoint(self.pos.p)
    end

    --- get max weapons range
    -- @return Number max weapon range of contact
    function HOUND.Contact.Base:getMaxWeaponsRange()
        return self.maxWeaponsRange
    end

    --- get max detection range
    -- @return Number max detection range of contact
    function HOUND.Contact.Base:getRadarDetectionRange()
        return self.detectionRange
    end

    --- get type assinged string
    -- @return string
    function HOUND.Contact.Base:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end

    --- get NATO designation
    -- @return string
    function HOUND.Contact.Base:getNatoDesignation()
        local natoDesignation = string.gsub(self:getTypeAssigned(),"(SA)-",'')
            if natoDesignation == "Naval" then
                natoDesignation = self:getType()
            end
        return natoDesignation
    end

    --- check if contact DCS Unit is still alive
    -- @return Boolean
    function HOUND.Contact.Base:isAlive()
        return self.DCSobjectAlive
    end

    --- Check if contact is Active
    -- @return (Bool) True if seen in the last 15 seconds
    function HOUND.Contact.Base:isActive()
        return self:getLastSeen()/16 < 1.0
    end

    --- check if contact is recent
    -- @return (Bool) True if seen in the last 2 minutes
    function HOUND.Contact.Base:isRecent()
        return self:getLastSeen()/120 < 1.0
    end

    --- check if contact position is accurate
    -- @return Bool - True target is pre briefed
    function HOUND.Contact.Base:isAccurate()
        return self.preBriefed
    end

    --- get preBriefed status
    -- @return Bool - True if target is prebriefed
    function HOUND.Contact.Base:getPreBriefed()
        return self.preBriefed
    end

    --- set preBriefed status
    -- @return Bool - True if target is prebriefed
    function HOUND.Contact.Base:setPreBriefed(state)
        if type(state) == "boolean" then
            self.preBriefed = state
        end
    end

    --- check if contact is timed out
    -- @return (Bool) True if timed out
    function HOUND.Contact.Base:isTimedout()
        return self:getLastSeen() > HOUND.CONTACT_TIMEOUT
    end

    --- Get current state
    -- @return Contact state in @{HOUND.EVENTS}
    function HOUND.Contact.Base:getState()
        return self.state
    end

    --- Queue new event
    -- @param eventId @{HOUND.EVENTS}
    function HOUND.Contact.Base:queueEvent(eventId)
        if eventId == HOUND.EVENTS.NO_CHANGE then return end
        local event = {
            id = eventId,
            initiator = self,
            time = timer.getTime()
        }
        table.insert(self.events,event)
    end

    --- get event queue
    -- @return table of event skeletons
    function HOUND.Contact.Base:getEventQueue()
        return self.events
    end
    --- Sector Mangment
    -- @section sectors

    --- Get primaty sector for contact
    -- @return name of sector the position is in
    function HOUND.Contact.Base:getPrimarySector()
        return self.primarySector
    end

    --- get sectors contact is threatening
    -- @return list of sector names
    function HOUND.Contact.Base:getSectors()
        return self.threatSectors
    end

    --- check if threatens sector
    -- @param sectorName
    -- @return Boot True if theat
    function HOUND.Contact.Base:isInSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    --- set correct sector 'default position' sector state
    -- @local
    function HOUND.Contact.Base:updateDefaultSector()
        self.threatSectors[self.primarySector] = true
        if self.primarySector == "default" then return end
        for k,v in pairs(self.threatSectors) do
            if k ~= "default" and v == true then
                self.threatSectors["default"] = false
                return
            end
        end
        self.threatSectors["default"] = true
    end

    --- Update sector data
    -- @string sectorName name of sector
    -- @string inSector true if contact is in the sector
    -- @string threatsSector true if contact threatens sector
    function HOUND.Contact.Base:updateSector(sectorName,inSector,threatsSector)
        if inSector == nil and threatsSector == nil then
            -- this sector has no zone this might need some logic. but for now just no.
            return
        end
        self.threatSectors[sectorName] = threatsSector or false

        if inSector and self.primarySector ~= sectorName then
            self.primarySector = sectorName
            self.threatSectors[sectorName] = true
        end
        self:updateDefaultSector()
    end

    --- add contact to names sector
    -- @string sectorName name of sector
    function HOUND.Contact.Base:addSector(sectorName)
        self.threatSectors[sectorName] = true
        self:updateDefaultSector()
    end

    --- remove contact from named sector
    -- @string sectorName name of sector
    function HOUND.Contact.Base:removeSector(sectorName)
        if self.threatSectors[sectorName] then
            self.threatSectors[sectorName] = false
            self:updateDefaultSector()
        end
    end

    --- check if contact in names sector
    -- @string sectorName name of sector
    -- @return (Bool) True if contact thretens sector
    function HOUND.Contact.Base:isThreatsSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    --- Marker managment
    -- @section markers

    --- Remove all contact's F10 map markers
    -- @local
    function HOUND.Contact.Base:removeMarkers()
        for _,marker in pairs(self._markpoints) do
            marker:remove()
        end
    end
end