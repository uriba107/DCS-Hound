--- Hound Controller
-- @module HoundController

do
    --- Hound Controller (extends HoundCommsManager )
    -- @see HoundCommsManager

    HoundController = {}
    HoundController = inheritsFrom(HoundCommsManager)

    --- Hound Controller Create
    -- @string sector name of parent sector
    -- @param houndConfig HoundConfig instance
    -- @tab[opt] settings table containing comms instance settings
    -- @return HoundController Instance
    function HoundController:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, self)
        self.__index = self

        instance.preferences.alerts = true

        if settings and type(settings) == "table" then
            instance:updateSettings(settings)
        end

        return instance
    end
end
