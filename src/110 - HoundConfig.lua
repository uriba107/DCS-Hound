--- HoundConfig
-- Hound config singleton
-- @local
-- @module HoundConfig
do

    -- @field HoundConfig
    HoundConfig = {
        configMaps = {}
    }

    HoundConfig.__index = HoundConfig

    --- return config for specific Hound instance
    -- @param HoundInstanceId Hound instance ID
    -- @return config map for specific hound instace
    -- @within HoundConfig
    function HoundConfig.get(HoundInstanceId)
        HoundInstanceId = HoundInstanceId or Length(HoundConfig.configMaps)+1

        if HoundConfig.configMaps[HoundInstanceId] then
            return HoundConfig.configMaps[HoundInstanceId]
        end

        local instance = {}
        instance.mainInterval = 15
        instance.processInterval = 60
        instance.barkInterval = 120
        instance.preferences = {
            useMarkers = true,
            markerType = HOUND.MARKER.DIAMOND,
            hardcore = false,
            detectDeadRadars = true,
            NatoBrevity = false,
            platformPosErr = 0,
            useNatoCallsigns = false,
            AtisUpdateInterval = 300
        }
        instance.coalitionId = nil
        instance.id = HoundInstanceId
        instance.callsigns = {}
        instance.radioMenu = {
            root = nil,
            parent = nil
        }

        --- get hound ID
        -- @within HoundConfig.instance
        -- @return Int Hound instance Id
        instance.getId = function (self)
            return self.id
        end

        --- get hound coalition ID
        -- @within HoundConfig.instance
        -- @return Int Hound instance coalition Id
        instance.getCoalition = function(self)
            return self.coalitionId
        end

        --- set hound coalition ID
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @param coalitionId coalition enum
        -- @return Bool True if coalition was changed
        instance.setCoalition = function(self,coalitionId)
            if self.coalitionId ~= nil then
                env.info("[Hound] - coalition already set for Instance Id " .. self.id)
                return false
            end
            if setContainsValue(coalition.side,coalitionId) then
                self.coalitionId = coalitionId
                return true
            end
            return false
        end

        --- get marker type
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return ENUM markerType
        -- @see HOUND.MARKER
        instance.getMarkerType = function (self)
            return self.preferences.markerType
        end

        --- set marker type
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @param markerType MarkerType enum
        -- @return Bool True if change was made
        -- @see HOUND.MARKER
        instance.setMarkerType = function (self,markerType)
            if setContainsValue(HOUND.MARKER,markerType) then
                self.preferences.markerType = markerType
                return true
            end
            return false
        end

        --- use marker getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Bool True if markers to be used
        instance.getUseMarkers = function (self)
            return self.preferences.useMarkers
        end

        --- use markers setter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @bool value set this value
        -- @return Bool True if change was made
        instance.setUseMarkers = function(self,value)
            if type(value) == "boolean" then
                self.preferences.useMarkers = value
                return true
            end
            return false
        end

        --- BDA getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Bool True if BDA will be done
        instance.getBDA = function(self)
            return self.preferences.detectDeadRadars
        end

        --- BDA setter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @bool value set this value
        -- @return Bool True if change was made
        instance.setBDA = function(self,value)
            if type(value) == "boolean" then
                self.preferences.detectDeadRadars = value
                return true
            end
            return false
        end

        --- NATO getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Bool true if NATO brevity is used
        instance.getNATO = function(self)
            return self.preferences.NatoBrevity
        end

        --- NATO setter
        -- @param self config instance
        -- @bool value set this value
        -- @return Bool True if change was made
        instance.setNATO = function(self,value)
            if type(value) == "boolean" then
                self.preferences.NatoBrevity = value
                return true
            end
            return false
        end

        --- NATO callsign getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Bool true if NATO callsignes will be used
        instance.getUseNATOCallsigns = function(self)
            return self.preferences.useNatoCallsigns
        end

        --- NATO callsign setter
        -- @param self config instance
        -- @bool value set this value
        -- @return Bool True if change was made
        instance.setUseNATOCallsigns = function(self,value)
            if type(value) == "boolean" then
                self.preferences.useNatoCallsigns = value
                return true
            end
            return false
        end

        --- Atis Update Interval getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Int current AtisUpdateInterval
        instance.getAtisUpdateInterval = function(self)
            return self.preferences.AtisUpdateInterval
        end

        --- Atis Update Interval setter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @int value set update interval in seconds
        -- @return Bool True if change was made
        instance.setAtisUpdateInterval = function(self,value)
            if type(value) == "number" then
                self.preferences.AtisUpdateInterval = value
                return true
            end
            return false
        end

        --- Position error getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Int desired error in meters
        instance.getPosErr = function(self)
            return self.preferences.platformPosErr
        end

        --- Platform Position error setter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @int value set error radius in meters
        -- @return Bool True if change was made
        instance.setPosErr = function(self,value)
            if type(value) == "number" then
                self.preferences.platformPosErr = value
                return true
            end
            return false
        end

        --- Platform Hardcore mode getter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return Bool true if enabled
        instance.getHardcore = function(self)
            return self.preferences.hardcore
        end

        --- Platform Hardcore mode setter
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @bool value desired state
        -- @return Bool True if change was made
        instance.setHardcore = function(self,value)
            if type(value) == "boolean" then
                self.preferences.hardcore = value
                return true
            end
            return false
        end

        --- return root radio menu for hound instance
        -- will create one if needed
        -- @within HoundConfig.instance
        -- @param self config instance
        -- @return root menu entity
        instance.getRadioMenu = function (self)
            if not self.radioMenu.root then
                self.radioMenu.root = missionCommands.addSubMenuForCoalition(
                    self:getCoalition(), 'ELINT',self:getRadioMenuParent())
                -- self.radioMenu.root = missionCommands.addSubMenu('ELINT',self:getRadioMenuParent())
            end
            return self.radioMenu.root
        end

        --- Remove radio menu root
        -- @within HoundConfig.instance
        -- @param self HoundConfig instance
        -- @return Bool True if menu was removed
        instance.removeRadioMenu = function (self)
            if self.radioMenu.root ~= nil then
                missionCommands.removeItem(self.radioMenu.root)
                self.radioMenu.root = nil
                return true
            end
            return false
        end

        --- return parent for the root menu
        -- @within HoundConfig.instance
        -- @return parent menu or nil if none set (root menu will be in root F10 meun)
        instance.getRadioMenuParent = function(self)
            return self.radioMenu.parent
        end

        --- set user defined parent menu for Hound instance
        -- must be set <b>BEFORE</b> calling <code>getRadioMenu()</code>
        -- @within HoundConfig.instance
        -- @param self HoundConfig instance
        -- @param parent desired parent menu
        -- @usage
        -- local servicesMenu =missionCommands.addSubMenuForCoalition(
        --          coalition.side.BLUE, 'AWACS, Tankers and ELINT..')
        -- HoundConfig:setRadioMenuParent(servicesMenu)
        instance.setRadioMenuParent = function (self,parent)
            if type(parent) == "table" or (parent == nil and self.radioMenu.parent) then
                self:removeRadioMenu()
                self.radioMenu.parent = parent
                return true
            end
            return false
        end

        HoundConfig.configMaps[HoundInstanceId] = instance

        return HoundConfig.configMaps[HoundInstanceId]
    end
end
