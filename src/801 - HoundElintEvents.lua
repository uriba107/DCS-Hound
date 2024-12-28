--- Hound Main interface
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2021
-- @module HoundElint

do
    --- EventHandler functions
    -- @section eventHandler

    local HoundUtils = HOUND.Utils

    --- builtin prototype for onHoundEvent function
    -- this function does NOTHING out of the box. put you own code here if needed
    -- @param houndEvent incoming event
    function HoundElint:onHoundEvent(houndEvent)
        return nil
    end

    --- built in onHoundEvent function
    -- @param houndEvent incoming event
    -- @local
    function HoundElint:onHoundInternalEvent(houndEvent)
        if houndEvent.houndId ~= self.settings:getId() then
            -- HOUND.Logger.trace("Processing Event " .. HOUND.reverseLookup(HOUND.EVENTS,houndEvent.id) .. " for myself? " .. tostring(houndEvent.houndId == self:getId()))
            return
        end
        if houndEvent.id == HOUND.EVENTS.HOUND_DISABLED then return end

        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowFirst)

        if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
            for _,sector in pairs(sectors) do
                sector:updateSectorMembership(houndEvent.initiator)
            end
        end
        if self:isRunning() then

            for _,sector in pairs(sectors) do
                -- if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
                --     sector:notifyEmitterNew(houndEvent.initiator)
                -- end
                if houndEvent.id == HOUND.EVENTS.RADAR_DESTROYED then
                    sector:notifyEmitterDead(houndEvent.initiator)
                end
                if houndEvent.id == HOUND.EVENTS.SITE_CREATED then
                    if not houndEvent.initiator.isEWR then
                        sector:notifySiteNew(houndEvent.initiator)
                    end
                end
                if houndEvent.id == HOUND.EVENTS.SITE_CLASSIFIED then
                    if not houndEvent.initiator.isEWR then
                        sector:notifySiteIdentified(houndEvent.initiator)
                    end
                end
                if houndEvent.id == HOUND.EVENTS.SITE_REMOVED or houndEvent.id == HOUND.EVENTS.SITE_ASLEEP then
                    sector:notifySiteDead(houndEvent.initiator,(houndEvent.id == HOUND.EVENTS.SITE_REMOVED))
                end
                if houndEvent.id == HOUND.EVENTS.SITE_LAUNCH then
                    sector:notifySiteLaunching(houndEvent.initiator)
                end
            end

            if houndEvent.id == HOUND.EVENTS.SITE_CREATED or houndEvent.id == HOUND.EVENTS.SITE_CLASSIFIED then
                self:populateRadioMenu()
                if self.settings:getMarkSites() then
                    houndEvent.initiator:updateMarker(HOUND.MARKER.NONE)
                end
            end
            if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
                if self.settings:getUseMarkers() then
                    houndEvent.initiator:updateMarker(self.settings:getMarkerType())
                end
            end
            -- HOUND.Logger.trace("Processing " ..  HOUND.reverseLookup(HOUND.EVENTS,houndEvent.id) .. " event for " .. tostring(houndEvent.initiator:getName()) .. " with BDA set to " .. tostring(self.settings:getBDA()))
            if not self.settings:getBDA() then return end
            -- do there only then BDA is enabled
            if houndEvent.id == HOUND.EVENTS.SITE_REMOVED then
                houndEvent.initiator:destroy()
                self.contacts:removeSite(houndEvent.initiator)
                self:populateRadioMenu()
            end
            if houndEvent.id == HOUND.EVENTS.RADAR_DESTROYED then
                -- HOUND.Logger.trace("Processing HOUND.EVENTS.RADAR_DESTROYED for " .. houndEvent.initiator:getName())
                self.contacts:removeContact(houndEvent.initiator)
                self:populateRadioMenu()
            end
        end
    end

    --- built in dcs onEvent
    -- @param DcsEvent incoming dcs event
    -- @local
    function HoundElint:onEvent(DcsEvent)
        if not HoundUtils.Dcs.isUnit(DcsEvent.initiator) then return end

        if DcsEvent.id == world.event.S_EVENT_UNIT_LOST
            and DcsEvent.initiator:getCoalition() ~= self.settings:getCoalition()
            and self:getBDA()
            then
                -- HOUND.Logger.trace("triggered S_EVENT_DEAD for " .. DcsEvent.initiator:getName())
                return self:markDeadContact(DcsEvent.initiator)
        end

        if not self:isRunning() then return end
        -- HOUND.Logger.debug(mist.utils.tableShow(DcsEvent))

        if (DcsEvent.id == world.event.S_EVENT_BIRTH)
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and HoundUtils.Dcs.isHuman(DcsEvent.initiator)
        then
            local _,catEx = DcsEvent.initiator:getCategory()
            if not HOUND.setContainsValue({Unit.Category.AIRPLANE,Unit.Category.HELICOPTER},catEx) then return end
            return self:populateRadioMenu()
        end

        if (DcsEvent.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT
            or DcsEvent.id == world.event.S_EVENT_PILOT_DEAD
            or DcsEvent.id == world.event.S_EVENT_EJECTION)
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and HoundUtils.Dcs.isHuman(DcsEvent.initiator)
        then
            local _,catEx = DcsEvent.initiator:getCategory()
            if not HOUND.setContainsValue({Unit.Category.AIRPLANE,Unit.Category.HELICOPTER},catEx) then return end
            return self:populateRadioMenu()
        end

        if DcsEvent.id == world.event.S_EVENT_SHOT
            and DcsEvent.initiator:getCoalition() ~= self.settings:getCoalition()
            and DcsEvent.initiator:hasAttribute("Air Defence")
            and DcsEvent.initiator:getCategory() == Object.Category.UNIT
        then
            local _,catEx = DcsEvent.initiator:getCategory()
            if not HOUND.setContainsValue({Unit.Category.GROUND_UNIT,Unit.Category.SHIP},catEx) then return end
            local grp = DcsEvent.initiator:getGroup()
            if HoundUtils.Dcs.isGroup(grp) then
                self.contacts:Sniff(grp:getName())
                if DcsEvent.weapon:getDesc().category ~= Weapon.Category.Missile then return end
                local tgtPos = nil
                local wpnTgt = DcsEvent.weapon:getTarget()
                if HoundUtils.Dcs.isUnit(wpnTgt) then
                  tgtPos = wpnTgt:getPoint()
                end
                if HoundUtils.Dcs.isPoint(tgtPos) then
                    HoundUtils.Geo.setPointHeight(tgtPos)
                end
                self.contacts:ensureSitePrimaryHasPos(grp:getName(),tgtPos)
                self:AlertOnLaunch(grp)
            end
        end
    end

    --- enable/disable Hound instance internal event handling
    -- @bool[opt] remove if true default event handler will be removed
    -- @local
    function HoundElint:defaultEventHandler(remove)
        if remove == false then
            HOUND.EventHandler.removeInternalEventHandler(self)
            world.removeEventHandler(self)
            return
        end
        HOUND.EventHandler.addInternalEventHandler(self)
        world.addEventHandler(self)
    end
end
