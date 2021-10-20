--- Hound Notifier
-- @module HoundController

do
    --- Hound Notifier (extends HoundCommsManager )
    -- @see HoundCommsManager
    HoundNotifier = {}
    HoundNotifier = inheritsFrom(HoundCommsManager)

    --- Hound Notifier Create
    -- @string sector name of parent sector
    -- @param houndConfig HoundConfig instance
    -- @tab[opt] settings table containing comms instance settings
    -- @return HoundNotifier Instance
    function HoundNotifier:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, self)
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
