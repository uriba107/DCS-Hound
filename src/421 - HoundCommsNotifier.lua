--- Hound Notifier (extends HOUND.Comms.Manager)
-- @module HOUND.Comms.Notifier
-- @see HOUND.Comms.Manager
do
    --- Hound Notifier (extends HOUND.Comms.Manager)
    -- @see HOUND.Comms.Manager
    HOUND.Comms.Notifier = {}
    HOUND.Comms.Notifier = HOUND.inheritsFrom(HOUND.Comms.Manager)

    --- Hound Notifier Create
    -- @string sector name of parent sector
    -- @param houndConfig HoundConfig instance
    -- @tab[opt] settings table containing comms instance settings
    -- @return HOUND.Comms.Notifier Instance
    function HOUND.Comms.Notifier:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, HOUND.Comms.Notifier)
        self.__index = self

        instance.settings.freq = "243.000,121.500"
        instance.settings.modulation = "AM,AM"
        instance.settings.speed = 1

        instance.preferences.alerts = true

        if settings and type(settings) == "table" then
            instance:updateSettings(settings)
        end
        return instance
    end
end
