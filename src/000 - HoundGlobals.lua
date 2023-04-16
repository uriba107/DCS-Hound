--- Hound
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2021
-- @module HOUND

do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    -- randomize the randomness.
    math.random()
    for i=1,math.random(2,5) do
        math.random(math.random(math.floor(math.random()*300),300),math.random(math.floor(math.random()*10000),10000))
    end
end

do
    --- HOUND global settings
    -- Global settings and paramters
    -- @table HOUND
    -- @field VERSION Hound Version
    -- @field DEBUG Hound will do extended debug output to log (for development)
    -- @field ELLIPSE_PERCENTILE Defines the percentile of datapoints used to calculate uncertenty ellipse
    -- @field DATAPOINTS_NUM Number of datapoints per platform a contact keeps (FIFO)
    -- @field DATAPOINTS_INTERVAL Time between stored data points
    -- @field CONTACT_TIMEOUT Timout for emitter to be silent before being dropped from contacts
    -- @field MGRS_PRECISION Number of digits in MGRS conversion
    -- @field EXTENDED_INFO Hound will add more in depth uncertenty info to controller messages (default is true)
    -- @field FORCE_MANAGE_MARKERS Force Hound to use internal counter for markIds (default is false).
    -- @field USE_LEGACY_MARKERS Force Hound to use normal markers for radar positions (default is true)
    -- @field PREFER_GRPC_TTS Hound will prefer DCS-gRPC as a TTS engine (default is true)
    HOUND = {
        VERSION = "0.4.0-TRUNK",
        DEBUG = true,
        ELLIPSE_PERCENTILE = 0.6,
        DATAPOINTS_NUM = 30,
        DATAPOINTS_INTERVAL = 30,
        CONTACT_TIMEOUT = 900,
        MGRS_PRECISION = 5,
        EXTENDED_INFO = true,
        MIST_VERSION = tonumber(table.concat({mist.majorVersion,mist.minorVersion},".")),
        FORCE_MANAGE_MARKERS = false,
        USE_LEGACY_MARKERS = true,
        PREFER_GRPC_TTS = true
    }

    --- Map Markers ENUM
    -- @table HOUND.MARKER
    -- @field NONE no ellipse is drawn
    -- @field CIRCLE a circle of uncertenty will be drawn
    -- @field DIAMOND a diamond will be drawn with 4 points representing uncertenty ellipse
    -- @field OCTAGON ellipse will be drawn with 8 points (diamon with midpoints)
    -- @field POLYGON ellipse will be drawn as a 16 sides polygon
    HOUND.MARKER = {
        NONE = 0,
        CIRCLE = 1,
        DIAMOND = 2,
        OCTAGON = 3,
        POLYGON = 4
    }

    --- Hound Events
    -- @table EVENTS
    -- @field HOUND_ENABLED Hound Event
    -- @field HOUND_DISABLED Hound Event
    -- @field PLATFORM_ADDED Hound Event
    -- @field PLATFORM_REMOVED Hound Event
    -- @field PLATFORM_DESTROYED Hound Event
    -- @field RADAR_NEW Hound Event
    -- @field RADAR_DETECTED Hound Event
    -- @field RADAR_UPDATED Hound Event
    -- @field RADAR_DESTROYED Hound Event
    -- @field RADAR_ALIVE Hound Event
    -- @field RADAR_ASLEEP Hound Event
    -- @field SITE_NEW Hound Event
    -- @field SITE_CREATED Hound Event
    -- @field SITE_UPDATED Hound Event
    -- @field SITE_REMOVED Hound Event
    -- @field SITE_ALIVE Hound Event
    -- @field SITE_ASLEEP Hound Event
    HOUND.EVENTS = {
        HOUND_ENABLED = 1,
        HOUND_DISABLED = 2,
        PLATFORM_ADDED = 3,
        PLATFORM_REMOVED = 4,
        PLATFORM_DESTROYED = 5,
        TRANSMITTER_ADDED = 6,
        TRANSMITTER_REMOVED = 7,
        TRANSMITTER_DESTROYED = 8,
        RADAR_NEW = 9,
        RADAR_DETECTED = 10,
        RADAR_UPDATED = 11,
        RADAR_DESTROYED = 12,
        RADAR_ALIVE = 13,
        RADAR_ASLEEP = 14,
        SITE_NEW = 15,      -- Placeholder
        SITE_CREATED = 16,  -- Placeholder
        SITE_UPDATED = 17,  -- Placeholder
        SITE_REMOVED = 18,  -- Placeholder
        SITE_ALIVE = 19,    -- Placeholder
        SITE_ASLEEP = 20    -- Placeholder
    }

    --- Event structure
    -- @table EVENTS.EVENT
    -- @field id event enum from HOUND.EVENTS
    -- @field houndId Hound Instace ID that emitted the event
    -- @field coalition coalition ID of the Hound Instance that emitted the event
    -- @field initiator DCS Unit or HoundContact Subclass that triggered the event
    -- @field time of event

    --- Global functions
    -- @section globals

    --- set default MGRS presicion for grid calls
    -- @param value (Int) Requested value. allowed values 1-5, default is 3
    function HOUND.setMgrsPresicion(value)
        if type(value) == "number" then
            HOUND.MGRS_PRECISION = math.min(1,math.max(5,math.floor(value)))
        end
    end

    --- set detailed messages to include or exclude extended tracking data
    -- if true, will read and display extended ellipse info and tracking times. (default)
    -- if false, will skip that information. only the shortened info will be used
    -- @param value (Bool) Requested state
    function HOUND.showExtendedInfo(value)
        if type(value) == "boolean" then
            HOUND.EXTENDED_INFO = value
        end
    end

    --- register new event handler (global)
    -- @param handler handler to register
    -- @see HOUND.EVENTS
    function HOUND.addEventHandler(handler)
        HOUND.EventHandler.addEventHandler(handler)
    end

    --- deregister event handler (global)
    -- @param handler handler to remove
    -- @see HOUND.EVENTS
    function HOUND.removeEventHandler(handler)
        HOUND.EventHandler.removeEventHandler(handler)
    end

    -- setup for inheritance classes
    HOUND.Contact = {}
    HOUND.Comms = {}

    --- helper code for class inheritance
    -- @local
    -- @param baseClass Base class to inherit from
    function inheritsFrom( baseClass )

        local new_class = {}
        local class_mt = { __index = new_class }

        function new_class:create()
            local newinst = {}
            setmetatable( newinst, class_mt )
            return newinst
        end

        if nil ~= baseClass then
            setmetatable( new_class, { __index = baseClass } )
        end

        -- Implementation of additional OO properties starts here --

        -- Return the class object of the instance
        function new_class:class()
            return new_class
        end

        -- Return the super class object of the instance
        function new_class:superClass()
            return baseClass
        end

        -- Return true if the caller is an instance of theClass
        function new_class:isa( theClass )
            local b_isa = false
            local cur_class = new_class

            while ( nil ~= cur_class ) and ( false == b_isa ) do
                if cur_class == theClass then
                    b_isa = true
                else
                    cur_class = cur_class:superClass()
                end
            end
            return b_isa
        end
        return new_class
    end

    --- get Length of a table
    -- @local
    -- @param T table
    -- @return length of T
    function Length(T)
        local count = 0
        if T ~= nil then for _ in pairs(T) do count = count + 1 end end
        return count
    end

    --- check if set contains a provided key
    -- @local
    -- @param set Hash table to check
    -- @param key to check
    -- @return Bool. True if key exists in set
    function setContains(set, key)
        if not set or not key then return false end
        return set[key] ~= nil
    end

    --- check if table contains a provided
    -- @local
    -- @param set Table to check
    -- @param value Value to check
    -- @return Bool. True if value exists in set
    function setContainsValue(set,value)
        if not set or not value then return false end
        for _,v in pairs(set) do
            if v == value then
                return true
            end
        end
        return false
    end

    --- return Gaussian random number
    -- @local
    -- @param mean Mean value (i.e center of the gausssian curve)
    -- @param sigma amount of variance in the random value
    -- @return random number in gaussian space
    function Gaussian(mean, sigma)
        return math.sqrt(-2 * sigma * math.log(math.random())) *
                   math.cos(2 * math.pi * math.random()) + mean
    end

    -- function StDev()
    --     local sum, sumsq, k = 0, 0, 0
    --     return function(n)
    --         sum, sumsq, k = sum + n, sumsq + n ^ 2, k + 1
    --         return math.sqrt((sumsq / k) - (sum / k) ^ 2)
    --     end
    -- end

    --- Split String on delimited
    -- @local
    -- @param str Input string
    -- @param[opt] delim Delimited (default is space)
    -- @return table of substrings
    function string.split(str, delim)
        if not str or type(str) ~= "string" then return {str} end
        if not delim then
            delim = "%S"
        end
        local chunks = {}
        for substring in str:gmatch("[^" .. delim .. "]+") do
            table.insert(chunks, substring)
        end
        return chunks
    end
end
