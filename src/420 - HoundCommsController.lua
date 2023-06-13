--- Hound Controller  (extends HOUND.Comms.Manager)
-- @module HOUND.Comms.Controller

do
    --- Hound Controller (extends HOUND.Comms.Manager)
    -- @see HOUND.Comms.Manager

    HOUND.Comms.Controller = {}
    HOUND.Comms.Controller = HOUND.inheritsFrom(HOUND.Comms.Manager)

    --- Hound Controller Create
    -- @string sector name of parent sector
    -- @param houndConfig HoundConfig instance
    -- @tab[opt] settings table containing comms instance settings
    -- @return HOUND.Comms.Controller Instance
    function HOUND.Comms.Controller:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, HOUND.Comms.Controller)
        self.__index = self

        instance.preferences.alerts = true

        if settings and type(settings) == "table" then
            instance:updateSettings(settings)
        end

        return instance
    end
end
