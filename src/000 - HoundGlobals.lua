--- Hound
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2024
-- @module HOUND

do
    if STTS ~= nil and STTS.DIRECTORY == "C:\\Users\\Ciaran\\Dropbox\\Dev\\DCS\\DCS-SRS\\install-build" then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    -- randomize the randomness.
    math.random(math.ceil(timer.getTime0()+timer.getTime()))
    for i=1,math.random(2,5) do
        math.random(math.random(math.floor(math.random()*300),300),math.random(math.floor(math.random()*10000),10000))
    end
end

do
    --- Global settings and paramters
    -- @table HOUND
    -- @field VERSION Hound Version
    -- @field DEBUG Hound will do extended debug output to log (for development)
    -- @field ELLIPSE_PERCENTILE Defines the percentile of datapoints used to calculate uncertenty ellipse
    -- @field DATAPOINTS_NUM Number of datapoints per platform a contact keeps (FIFO)
    -- @field DATAPOINTS_INTERVAL Time between stored data points
    -- @field CONTACT_TIMEOUT Timout for emitter to be silent before being dropped from contacts
    -- @field MAX_ANGULAR_RES_DEG The maximum (worst) platform angular resolution acceptable
    -- @field ANTENNA_FACTOR Global factor of antenna size (bigger antenna == better accuracy). Allows mission builder to quickly nerf or boost hound performace (default 1.0).
    -- @field MGRS_PRECISION Number of digits in MGRS conversion
    -- @field EXTENDED_INFO Hound will add more in depth uncertenty info to controller messages (default is true)
    -- @field FORCE_MANAGE_MARKERS Force Hound to use internal counter for markIds (default is true).
    -- @field USE_LEGACY_MARKERS Force Hound to use normal markers for radar positions (default is true)
    -- @field MARKER_MIN_ALPHA Minimum opacity for area markers
    -- @field MARKER_MAX_ALPHA Maximum opacity for area markers
    -- @field MARKER_LINE_OPACITY Opacity of the line around the area markers
    -- @field MARKER_TEXT_POINTER Char/string used as pointer on text markers
    -- @field TTS_ENGINE Hound will use the table to determin TTS engine priority
    -- @field MENU_PAGE_LENGTH Number of Items Hound will put in a menu before starting a new menu page
    HOUND = {
        VERSION = "0.4.1-TRUNK",
        DEBUG = true,
        ELLIPSE_PERCENTILE = 0.6,
        DATAPOINTS_NUM = 30,
        DATAPOINTS_INTERVAL = 30,
        CONTACT_TIMEOUT = 900,
        MAX_ANGULAR_RES_DEG = 20,
        ANTENNA_FACTOR = 1.0,
        MGRS_PRECISION = 5,
        EXTENDED_INFO = true,
        -- FORCE_MANAGE_MARKERS = true,
        USE_LEGACY_MARKERS = true,
        MARKER_MIN_ALPHA = 0.05,
        MARKER_MAX_ALPHA = 0.2,
        MARKER_LINE_OPACITY = 0.3,
        MARKER_TEXT_POINTER = "⇙ ", -- "¤ « "
        TTS_ENGINE = {'STTS','GRPC'},
        MENU_PAGE_LENGTH = 9,
        ENABLE_KALMAN = false,
    }

    --- Map Markers ENUM
    -- @table HOUND.MARKER
    -- @field NONE no markers are drawn
    -- @field SITE_ONLY only site markers are drawn
    -- @field POINT only draw point marker for emitters
    -- @field CIRCLE a circle of uncertenty will be drawn
    -- @field DIAMOND a diamond will be drawn with 4 points representing uncertenty ellipse
    -- @field OCTAGON ellipse will be drawn with 8 points (diamon with midpoints)
    -- @field POLYGON ellipse will be drawn as a 16 sides polygon
    HOUND.MARKER = {
        NONE = 0,
        SITE_ONLY = 1,
        POINT = 2,
        CIRCLE = 3,
        DIAMOND = 4,
        OCTAGON = 5,
        POLYGON = 6
    }

    --- Hound Events
    -- @table EVENTS
    -- @field NO_CHANGE nothing changed in the object
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
    -- @field SITE_CLASSIFIED Hound Event
    -- @field SITE_REMOVED Hound Event
    -- @field SITE_ALIVE Hound Event
    -- @field SITE_ASLEEP Hound Event
    -- @field SITE_LAUNCH Hound Event
    HOUND.EVENTS = {
        NO_CHANGE     = 0,
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
        SITE_NEW = 15,
        SITE_CREATED = 16,
        SITE_UPDATED = 17,
        SITE_CLASSIFIED = 18,
        SITE_REMOVED = 19,
        SITE_ALIVE = 20,
        SITE_ASLEEP = 21,
        SITE_LAUNCH = 22,
    }

    --- Event structure
    -- @table EVENTS.EVENT
    -- @field id event enum from HOUND.EVENTS
    -- @field houndId Hound Instace ID that emitted the event
    -- @field coalition coalition ID of the Hound Instance that emitted the event
    -- @field initiator DCS Unit or HoundContact Subclass that triggered the event
    -- @field time of event

    --- Hound Instances
    -- @section Instances

    --- Hound Instances
    -- every instance created will be added to this list with it's HoundId as key.
    HOUND.INSTANCES = {}

    --- Get instance
    -- get hound instance by ID
    -- @param[type=number] InstanceId instance ID to get
    -- @return Hound Instance object or nil
    function HOUND.getInstance(InstanceId)
        if HOUND.setContains(HOUND.INSTANCES,InstanceId) then
            return HOUND.INSTANCES[InstanceId]
        end
        return nil
    end


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
    function HOUND.inheritsFrom( baseClass )

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
    function HOUND.Length(T)
        local count = 0
        if T ~= nil then for _ in pairs(T) do count = count + 1 end end
        return count
    end

    --- check if set contains a provided key (case sensitive)
    -- @local
    -- @param set Hash table to check
    -- @param key to check
    -- @return[type=bool] True if key exists in set
    function HOUND.setContains(set, key)
        if not set or not key then return false end
        return set[key] ~= nil
    end

    --- check if table contains a provided
    -- @local
    -- @param set Table to check
    -- @param value Value to check
    -- @return[type=bool] True if value exists in set
    function HOUND.setContainsValue(set,value)
        if not set or not value then return false end
        for _,v in pairs(set) do
            if v == value then
                return true
            end
        end
        return false
    end

    --- return set intersection product
    -- @local
    -- @param a Table
    -- @param b Table
    -- @return Table
    function HOUND.setIntersection(a,b)
        local res = {}
        for k in pairs(a) do
          res[k] = b[k]
        end
        return res
      end

    --- return Gaussian random number
    -- @local
    -- @param mean Mean value (i.e center of the gausssian curve)
    -- @param sigma amount of variance in the random value
    -- @return random number in gaussian space
    function HOUND.Gaussian(mean, sigma)
        return math.sqrt(-2 * sigma * math.log(math.random())) *
                   math.cos(2 * math.pi * math.random()) + mean
    end

    --- reverse table lookup
    -- @local
    -- @param #tbl table
    -- @param value to search
    -- @return the key wher value was found
    function HOUND.reverseLookup(tbl,value)
        if type(tbl) ~= "table" or type(value) == "nil" then return end
        for k,v in pairs(tbl) do
            if v == value then return k end
        end
    end

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
