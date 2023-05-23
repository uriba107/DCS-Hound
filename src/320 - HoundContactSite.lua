--- HOUND.Contact.Site
-- Site class containing related functions
-- @module HOUND.Contact.Site
-- @see HOUND.Contact.Base
do
    --- HOUND.Contact.Site  (Extends @{HOUND.Contact.Base})
    -- Site class containing related functions
    -- @type HOUND.Contact.Site
    HOUND.Contact.Site = {}
    HOUND.Contact.Site = HOUND.inheritsFrom(HOUND.Contact.Base)

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    --- create new HOUND.Contact.Site instance
    -- @param HoundContact emitter HoundContact
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @param[opt] SiteId specify uid for the Site. if not present Group ID will be used
    -- @return HOUND.Contact.Site instance
    function HOUND.Contact.Site:New(HoundContact,HoundCoalition,SiteId)
        if not HoundContact or type(HoundContact) ~= "table" or not HoundContact.getGroupName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact.Site instance")
            return
        end
        local instance = self:superClass():New(HoundContact:getDCSObject(),HoundCoalition)
        setmetatable(instance, HOUND.Contact.Site)
        self.__index = self
        instance.DCSobject = HoundContact:getDCSObject():getGroup()
        instance.gid = SiteId or instance.DCSobject:getId()
        instance.DCSgroupName = instance.DCSobject:getName()
        instance.DCSobjectName = instance.DCSobject:getName()
        instance.typeAssigned = HoundContact.typeAssigned

        instance.emitters = { }
        instance.emitters[HoundContact:getDcsName()] = HoundContact
        instance.primaryEmitter = HoundContact
        instance.last_seen = HoundContact:getLastSeen()
        instance.first_seen = HoundContact.first_seen
        instance.maxWeaponsRange = HoundContact:getMaxWeaponsRange()
        instance.detectionRange = HoundContact:getRadarDetectionRange()

        instance.state = HOUND.EVENTS.SITE_NEW
        instance.preBriefed = HoundContact:isAccurate()

        return instance
    end

    --- Destructor function
    function HOUND.Contact.Site:destroy()
        HOUND.Logger.debug("site destroy")
    end

    --- Getters and Setters
    -- @section settings

    --- Get contact name
    -- @return String
    function HOUND.Contact.Site:getName()
        return self:getType() .. " " .. self:getId()
    end

    --- Get contact type name
    -- @return String
    function HOUND.Contact.Site:getType()
        return self.typeName
    end

    --- Get Site GID
    -- @return Number
    function HOUND.Contact.Site:getId()
        return self.gid%100
    end

    --- Get Contact Group Name
    -- @return String
    function HOUND.Contact.Site:getGroupName()
        return self.DCSgroupName
    end

    --- Get the DCS unit name
    -- @return String
    function HOUND.Contact.Site:getDcsName()
        return self.DCSgroupName
    end

    --- Get the underlying DCS Object
    -- @return DCS Group or DCS staticObject
    function HOUND.Contact.Site:getDCSObject()
        return self.group or self.DCSgroupName
    end
    --- Get last seen in seconds
    -- @return number in seconds since contact was last seen
    function HOUND.Contact.Site:getLastSeen()
        return HOUND.Utils.absTimeDelta(self.last_seen)
    end

    --- get type assinged string
    -- @return string
    function HOUND.Contact.Site:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end

    --- Check if contact is Active
    -- @return (Bool) True if seen in the last 15 seconds
    function HOUND.Contact.Site:isActive()
        return self:getLastSeen()/16 < 1.0
    end

    --- check if contact is recent
    -- @return (Bool) True if seen in the last 2 minutes
    function HOUND.Contact.Site:isRecent()
        return self:getLastSeen()/120 < 1.0
    end

    --- check if contact position is accurate
    -- @return Bool - True target is pre briefed
    function HOUND.Contact.Site:isAccurate()
        return self.preBriefed
    end

    --- check if contact is timed out
    -- @return (Bool) True if timed out
    function HOUND.Contact.Site:isTimedout()
        return self:getLastSeen() > HOUND.CONTACT_TIMEOUT
    end

    --- Get current state
    -- @return Contact state in @{HOUND.EVENTS}
    function HOUND.Contact.Site:getState()
        return self.state
    end

    --- Emitter managment
    -- @section Emitters

    --- Add emitter to site
    -- @param HoundEmitter @{HOUND.Contact.Emitter} radar to add
    -- @return @{HOUND.EVENTS} 
    function HOUND.Contact.Site:addEmitter(HoundEmitter)
        self.state = HOUND.EVENTS.NO_CHANGE
        if HoundEmitter:getGroupName() == self:getGroupName() then
            if not self.emitters[HoundEmitter:getDcsName()] then
                self.emitters[HoundEmitter:getDcsName()] = HoundEmitter
                self:selectPrimaryEmitter()
                self:updateTypeAssigned()
                self.state = HOUND.EVENTS.SITE_UPDATED
            end
        end
        return self.state
    end

    --- Add emitter to site
    -- @param HoundEmitter @{HOUND.Contact.Emitter} radar to remove
    -- @return @{HOUND.EVENTS}
    function HOUND.Contact.Site:removeEmitter(HoundEmitter)
        self.state = HOUND.EVENTS.NO_CHANGE
        if HoundEmitter:getGroupName() == self:getGroupName() then
            if self.emitters[HoundEmitter:getGroupName()] then
                self.emitters[HoundEmitter:getGroupName()] = nil
                self:selectPrimaryEmitter()
                self.state = HOUND.EVENTS.SITE_UPDATED
            end
        end
        return self.state
    end

    --- select primaty emitter for site
    -- @return (Bool) True if primary changed
    function HOUND.Contact.Site:selectPrimaryEmitter()
        local emitters_list = {}
        for _,emitter in pairs(self.emitters) do
            table.insert(emitters_list,emitter)
        end
        table.sort(emitters_list,HOUND.Utils.Sort.ContactsByPrio)
        if self.primaryEmitter ~= emitters_list[1] then
            self.primaryEmitter = emitters_list[1]
            self.state = HOUND.EVENTS.SITE_UPDATED
            return true
        end
        return false
    end

    --- update site type
    -- @return (Bool) True if site type changed
    function HOUND.Contact.Site:updateTypeAssigned()
        local type = self.primaryEmitter.typeAssigned or {}
        if HOUND.Length(type) ~= 1 then
            for emitter in self.emitters do
                type = HOUND.setIntersection(type,emitter.typeAssigned)
            end
        end
        if self.typeAssigned ~= type then
            self.typeAssigned = type
            self.state = HOUND.EVENTS.SITE_UPDATED
        end
    end

end