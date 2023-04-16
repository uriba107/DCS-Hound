--- HOUND.Contact.Site
-- Site class. containing related functions
-- @module HOUND.Contact.Site
do
    --- HOUND.Contact.Site decleration
    -- Site class. containing related functions
    -- @type HOUND.Contact.Site
    HOUND.Contact.Site = {}
    HOUND.Contact.Site.__index = HOUND.Contact.Site

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    --- create new HOUND.Contact.Site instance
    -- @param HoundContact emitter HoundContact
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @param[opt] SiteId specify uid for the Site. if not present Group ID will be used
    -- @return HOUND.Contact.Site instance
    function HOUND.Contact.Site.New(HoundContact,HoundCoalition,SiteId)
        if not HoundContact or type(HoundContact) ~= "table" or not HoundContact.getGroupName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact.Site instance")
            return
        end
        local elintsite = {}
        setmetatable(elintsite, HOUND.Contact.Site)
        elintsite.group = HoundContact.unit:getGroup()
        elintsite.gid = SiteId or elintsite.group:getId()
        elintsite.DCSgroupName = elintsite.group:getName()
        elintsite.typeAssigned = HoundContact.typeAssigned

        elintsite.emitters = { HoundContact }
        elintsite.primaryEmitter = HoundContact
        elintsite.last_seen = HoundContact:getLastSeen()
        elintsite.first_seen = HoundContact.first_seen
        elintsite.maxWeaponsRange = HoundContact:getMaxWeaponsRange()
        elintsite.detectionRange = HoundContact:getRadarDetectionRange()

        elintsite.state = HOUND.EVENTS.SITE_NEW
        elintsite.preBriefed = HoundContact:isAccurate()


        return elintsite
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
    -- @return Bool True if seen in the last 15 seconds
    function HOUND.Contact.Site:isActive()
        return self:getLastSeen()/16 < 1.0
    end

    --- check if contact is recent
    -- @return Bool True if seen in the last 2 minutes
    function HOUND.Contact.Site:isRecent()
        return self:getLastSeen()/120 < 1.0
    end

    --- check if contact position is accurate
    -- @return Bool - True target is pre briefed
    function HOUND.Contact.Site:isAccurate()
        return self.preBriefed
    end

    --- check if contact is timed out
    -- @return Bool True if timed out
    function HOUND.Contact.Site:isTimedout()
        return self:getLastSeen() > HOUND.CONTACT_TIMEOUT
    end

    --- Get current state
    -- @return Contact state in @{HOUND.EVENTS}
    function HOUND.Contact.Site:getState()
        return self.state
    end
end