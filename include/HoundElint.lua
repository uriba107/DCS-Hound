
do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    math.random()
    for i=1,math.random(2,5) do
        math.random(math.random(math.floor(math.random()*300),300),math.random(math.floor(math.random()*10000),10000))
    end
end

do
    HOUND = {
        VERSION = "0.3.1",
        DEBUG = false,
        ELLIPSE_PERCENTILE = 0.6,
        DATAPOINTS_NUM = 30,
        DATAPOINTS_INTERVAL = 30,
        CONTACT_TIMEOUT = 900,
        MGRS_PRECISION = 5,
        EXTENDED_INFO = true,
        MIST_VERSION = tonumber(table.concat({mist.majorVersion,mist.minorVersion},".")),
        FORCE_MANAGE_MARKERS = false
    }

    HOUND.MARKER = {
        NONE = 0,
        CIRCLE = 1,
        DIAMOND = 2,
        OCTAGON = 3,
        POLYGON = 4
    }

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

    function HOUND.setMgrsPresicion(value)
        if type(value) == "number" then
            HOUND.MGRS_PRECISION = math.min(1,math.max(5,math.floor(value)))
        end
    end

    function HOUND.showExtendedInfo(value)
        if type(value) == "boolean" then
            HOUND.EXTENDED_INFO = value
        end
    end

    function HOUND.addEventHandler(handler)
        HOUND.EventHandler.addEventHandler(handler)
    end

    function HOUND.removeEventHandler(handler)
        HOUND.EventHandler.removeEventHandler(handler)
    end

    HOUND.Comms = {}

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

        function new_class:class()
            return new_class
        end

        function new_class:superClass()
            return baseClass
        end

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

    function Length(T)
        local count = 0
        if T ~= nil then for _ in pairs(T) do count = count + 1 end end
        return count
    end

    function setContains(set, key)
        if not set or not key then return false end
        return set[key] ~= nil
    end

    function setContainsValue(set,value)
        if not set or not value then return false end
        for _,v in pairs(set) do
            if v == value then
                return true
            end
        end
        return false
    end

    function Gaussian(mean, sigma)
        return math.sqrt(-2 * sigma * math.log(math.random())) *
                   math.cos(2 * math.pi * math.random()) + mean
    end

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
do
    local l_env = env

    HOUND.Logger = {
        level = 3
    }
    HOUND.Logger.__index = HOUND.Logger

    HOUND.Logger.LEVEL = {
        ["error"]=1,
        ["warning"]=2,
        ["info"]=3,
        ["debug"]=4,
        ["trace"]=5,
    }

    function HOUND.Logger.setBaseLevel(level)
        if setContainsValue(HOUND.Logger.LEVEL,level) then
            HOUND.Logger.level = level
        end
    end

    function HOUND.Logger.formatText(text, ...)
        if not text then
            return ""
        end
        if type(text) ~= 'string' then
            text = tostring(text)
        else
            if arg and arg.n and arg.n > 0 then
                local pArgs = {}
                for index,value in ipairs(arg) do
                    pArgs[index] = tostring(value)
                end
                text = text:format(unpack(pArgs))
            end
        end
        local fName = nil
        local cLine = nil
        if debug then
            local dInfo = debug.getinfo(3)
            fName = dInfo.name
            cLine = dInfo.currentline
        end
        if fName and cLine then
            return fName .. '|' .. cLine .. ': ' .. text
        elseif cLine then
            return cLine .. ': ' .. text
        else
            return ' ' .. text
        end
    end

    function HOUND.Logger.print(level, text)
        local texts = {text}
        local levelChar = 'E'
        local logFunction = l_env.error
        if level == HOUND.Logger.LEVEL["warning"] then
            levelChar = 'W'
            logFunction = l_env.warning
        elseif level == HOUND.Logger.LEVEL["info"] then
            levelChar = 'I'
            logFunction = l_env.info
        elseif level == HOUND.Logger.LEVEL["debug"] then
            levelChar = 'D'
            logFunction = l_env.info
        elseif level == HOUND.Logger.LEVEL["trace"] then
            levelChar = 'T'
            logFunction = l_env.info
        end
        for i = 1, #texts do
            if i == 1 then
                logFunction('[Hound](' .. levelChar.. ') - ' .. texts[i])
            else
                logFunction(texts[i])
            end
        end
    end

    function HOUND.Logger.error(text, ...)
        if HOUND.Logger.level >= 1 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(1, text)
        end
    end

    function HOUND.Logger.warn(text, ...)
        if HOUND.Logger.level >= 2 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(2, text)
        end
    end

    function HOUND.Logger.info(text, ...)
        if HOUND.Logger.level >= 3 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(3, text)
        end
    end

    function HOUND.Logger.debug(text, ...)
        if HOUND.Logger.level >= 4 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(4, text)
        end
    end

    function HOUND.Logger.trace(text, ...)
        if HOUND.Logger.level >= 5 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(5, text)
        end
    end

    function HOUND.Logger.onScreenDebug(text,time)
        if type(text) ~= "string" then return end
        if type(time) ~= "number" then
            time = 15
        end
        trigger.action.outText(text,math.ceil(time))
    end

    if HOUND.DEBUG then
        HOUND.Logger.setBaseLevel(HOUND.Logger.LEVEL.trace)
    end
end

do
    HOUND.DB = {}

    local l_mist = mist
    local l_math = math

    HOUND.DB.Radars = {
        ['1L13 EWR'] = {
            ['Name'] = "Box Spring",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'A',
            ['Primary'] = false
        },
        ['55G6 EWR'] = {
            ['Name'] = "Tall Rack",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'A',
            ['Primary'] = false
        },
        ['FPS-117'] = {
            ['Name'] = "Seek Igloo",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'D',
            ['Primary'] = false
        },
        ['FPS-117 Dome'] = {
            ['Name'] = "Seek Igloo",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'D',
            ['Primary'] = false
        },
        ['p-19 s-125 sr'] = {
            ['Name'] = "Flat Face",
            ['Assigned'] = {"SA-2","SA-3"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['SNR_75V'] = {
            ['Name'] = "Fan-song",
            ['Assigned'] = {"SA-2"},
            ['Role'] = {"TR"},
            ['Band'] = 'G',
            ['Primary'] = true
        },
        ['snr s-125 tr'] = {
            ['Name'] = "Low Blow",
            ['Assigned'] = {"SA-3"},
            ['Role'] = {"TR"},
            ['Band'] = 'I',
            ['Primary'] = true
        },
        ['Kub 1S91 str'] = {
            ['Name'] = "Straight Flush",
            ['Assigned'] = {"SA-6"},
            ['Role'] = {"SR","TR"},
            ['Band'] = 'G',
            ['Primary'] = true
        },
        ['Osa 9A33 ln'] = {
            ['Name'] = "Osa",
            ['Assigned'] = {"SA-8"},
            ['Role'] = {"SR","TR"},
            ['Band'] = 'H',
            ['Primary'] = true
        },
        ['S-300PS 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"SR"},
            ['Band'] = 'I',
            ['Primary'] = false
        },
        ['S-300PS 64H6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['RLS_19J6'] = {
            ['Name'] = "Tin Shield",
            ['Assigned'] = {"SA-5"},
            ['Role'] = {"SR"},
            ['Band'] = 'E',
            ['Primary'] = false
        },
        ['S-300PS 40B6M tr'] = {
            ['Name'] = "Tomb Stone",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['SA-11 Buk SR 9S18M1'] = {
            ['Name'] = "Snow Drift",
            ['Assigned'] = {"SA-11","SA-17"},
            ['Role'] = {"SR"},
            ['Band'] = 'G',
            ['Primary'] = true
        },
        ['SA-11 Buk LN 9A310M1'] = {
            ['Name'] = "Fire Dome",
            ['Assigned'] = {"SA-11"},
            ['Role'] = {"TR"},
            ['Band'] = 'H',
            ['Primary'] = false
        },
        ['Tor 9A331'] = {
            ['Name'] = "Tor",
            ['Assigned'] = {"SA-15"},
            ['Role'] = {"SR","TR"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['Strela-1 9P31'] = {
            ['Name'] = "SA-9",
            ['Assigned'] = {"SA-9"},
            ['Role'] = {"RF"},
            ['Band'] = 'K',
            ['Primary'] = false
        },
        ['Strela-10M3'] = {
            ['Name'] = "SA-13",
            ['Assigned'] = {"SA-13"},
            ['Role'] = {"RF"},
            ['Band'] = 'J',
            ['Primary'] = false
        },
        ['Patriot str'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = {"Patriot"},
            ['Role'] = {"SR","TR"},
            ['Band'] = 'K',
            ['Primary'] = true
        },
        ['Hawk sr'] = {
            ['Name'] = "Hawk SR",
            ['Assigned'] = {"Hawk"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['Hawk tr'] = {
            ['Name'] = "Hawk TR",
            ['Assigned'] = {"Hawk"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['Hawk cwar'] = {
            ['Name'] = "Hawk CWAR",
            ['Assigned'] = {"Hawk"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = false
        },
        ['RPC_5N62V'] = {
            ['Name'] = "Square Pair",
            ['Assigned'] = {"SA-5"},
            ['Role'] = {"TR"},
            ['Band'] = 'H',
            ['Primary'] = true
        },
        ['Roland ADS'] = {
            ['Name'] = "Roland TR",
            ['Assigned'] = {"Roland"},
            ['Role'] = {"TR"},
            ['Band'] = 'H',
            ['Primary'] = true
        },
        ['Roland Radar'] = {
            ['Name'] = "Roland SR",
            ['Assigned'] = {"Roland"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['Gepard'] = {
            ['Name'] = "Gepard",
            ['Assigned'] = {"Gepard"},
            ['Role'] = {"SR","TR"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['rapier_fsa_blindfire_radar'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = {"Rapier"},
            ['Role'] = {"TR"},
            ['Band'] = 'D',
            ['Primary'] = true
        },
        ['rapier_fsa_launcher'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = {"Rapier"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = false
        },
        ['NASAMS_Radar_MPQ64F1'] = {
            ['Name'] = "Sentinel",
            ['Assigned'] = {"NASAMS"},
            ['Role'] = {"SR"},
            ['Band'] = 'I',
            ['Primary'] = true
        },
        ['HQ-7_STR_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = {"HQ-7"},
            ['Role'] = {"SR"},
            ['Band'] = 'F',
            ['Primary'] = false
        },
        ['HQ-7_LN_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = {"HQ-7"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['2S6 Tunguska'] = {
            ['Name'] = "Tunguska",
            ['Assigned'] = {"Tunguska"},
            ['Role'] = {"SR","TR"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['ZSU-23-4 Shilka'] = {
            ['Name'] = "Shilka",
            ['Assigned'] = {"Shilka"},
            ['Role'] = {"RF"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['Dog Ear radar'] = {
            ['Name'] = "Dog Ear",
            ['Assigned'] = {"AAA"},
            ['Role'] = {"SR"},
            ['Band'] = 'G',
            ['Primary'] = true
        },
        ['SON_9'] = {
            ['Name'] = "Fire Can",
            ['Assigned'] = {"AAA"},
            ['Role'] = {"TR"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['Silkworm_SR'] = {
            ['Name'] = "Silkworm",
            ['Assigned'] = {"Silkworm"},
            ['Role'] = {"AS"},
            ['Band'] = 'K',
            ['Primary'] = true
        },
        ['FuSe-65'] = {
            ['Name'] = "Würzburg",
            ['Assigned'] = {"AAA"},
            ['Role'] = {"TR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['FuMG-401'] = {
            ['Name'] = "EWR",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'B',
            ['Primary'] = false
        },
        ['Flakscheinwerfer_37'] = {
            ['Name'] = "AAA Searchlight",
            ['Assigned'] = {"AAA"},
            ['Role'] = {"None"},
            ['Band'] = 'L',
            ['Primary'] = false
        },
        ['S-300PS 64H6E TRAILER sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['S-300PS SA-10B 40B6MD MAST sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"SR"},
            ['Band'] = 'I',
            ['Primary'] = false
        },
        ['S-300PS 40B6M MAST tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['S-300PS 30H6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['S-300PS 30N6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['S-300PMU1 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"SR"},
            ['Band'] = 'I',
            ['Primary'] = false
        },
        ['S-300PMU1 64N6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['S-300PMU1 30N6E tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['S-300PMU1 40B6M tr'] = {
            ['Name'] = "Grave Stone",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['S-300V 9S15 sr'] = {
            ['Name'] = 'Bill Board',
            ['Assigned'] = {"SA-12"},
            ['Role'] = {"SR"},
            ['Band'] = 'E',
            ['Primary'] = false
        },
        ['S-300V 9S19 sr'] = {
            ['Name'] = 'High Screen',
            ['Assigned'] = {"SA-12"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['S-300V 9S32 tr'] = {
            ['Name'] = 'Grill Pan',
            ['Assigned'] = {"SA-12"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['S-300PMU2 92H6E tr'] = {
            ['Name'] = 'Grave Stone',
            ['Assigned'] = {"SA-20"},
            ['Role'] = {"TR"},
            ['Band'] = 'I',
            ['Primary'] = true
        },
        ['S-300PMU2 64H6E2 sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-20"},
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['S-300VM 9S15M2 sr'] = {
            ['Name'] = 'Bill Board M',
            ['Assigned'] = {"SA-23"},
            ['Role'] = {"SR"},
            ['Band'] = 'E',
            ['Primary'] = false
        },
        ['S-300VM 9S19M2 sr'] = {
            ['Name'] = 'High Screen M',
            ['Assigned'] = "SA-23",
            ['Role'] = {"SR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['S-300VM 9S32ME tr'] = {
            ['Name'] = 'Grill Pan M',
            ['Assigned'] = {"SA-23"},
            ['Role'] = {"TR"},
            ['Band'] = 'K',
            ['Primary'] = true
        },
        ['SA-17 Buk M1-2 LN 9A310M1-2'] = {
            ['Name'] = "Fire Dome M",
            ['Assigned'] = {"SA-17"},
            ['Role'] = {"TR"},
            ['Band'] = 'H',
            ['Primary'] = false
        },
        ['34Ya6E Gazetchik E decoy'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {"TR"},
            ['Band'] = 'J',
            ['Primary'] = true
        },
        ['Fire Can radar'] = {
            ['Name'] = "Fire Can",
            ['Assigned'] = {"AAA"},
            ['Role'] = {"TR"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['EWR 55G6U NEBO-U'] = {
            ['Name'] = "Tall Rack",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'A',
            ['Primary'] = false
        },
        ['EWR P-37 BAR LOCK'] = {
            ['Name'] = "Bar lock",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"SA-5","EWR"},
            ['Band'] = 'E',
            ['Primary'] = false
        },
        ['EWR 1L119 Nebo-SVU'] = {
            ['Name'] = "Nebo-SVU",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'A',
            ['Primary'] = false
        },
        ['EWR Generic radar tower'] = {
            ['Name'] = "Civilian Radar",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'C',
            ['Primary'] = false
        },
        ['Type_052B'] = {
            ['Name'] = "Type 052B",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['Type_052C'] = {
            ['Name'] = "Type 052C",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['Type_054A'] = {
            ['Name'] = "Type 054A",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['Type_071'] = {
            ['Name'] = "Type 071",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['Type_093'] = {
            ['Name'] = "Type 093",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['USS_Arleigh_Burke_IIa'] = {
            ['Name'] = "Arleigh Burke",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['CV_1143_5'] = {
            ['Name'] = "Kuznetsov",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['KUZNECOW'] = {
            ['Name'] = "Kuznetsov",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['Forrestal'] = {
            ['Name'] = "Forrestal",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['VINSON'] = {
            ['Name'] = "Nimitz",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['CVN_71'] = {
            ['Name'] = "Nimitz",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['CVN_72'] = {
            ['Name'] = "Nimitz",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['CVN_73'] = {
            ['Name'] = "Nimitz",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['Stennis'] = {
            ['Name'] = "Nimitz",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['CVN_75'] = {
            ['Name'] = "Nimitz",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['La_Combattante_II'] = {
            ['Name'] = "La Combattante",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['ALBATROS'] = {
            ['Name'] = "Grisha",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['MOLNIYA'] = {
            ['Name'] = "Molniya",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['MOSCOW'] = {
            ['Name'] = "Moskva",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['NEUSTRASH'] = {
            ['Name'] = "Neustrashimy",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['PERRY'] = {
            ['Name'] = "Oliver H. Perry",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['PIOTR'] = {
            ['Name'] = "Kirov",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['REZKY'] = {
            ['Name'] = "Krivak",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['LHA_Tarawa'] = {
            ['Name'] = "Tarawa",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['TICONDEROG'] = {
            ['Name'] = "Ticonderoga",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['hms_invincible'] = {
            ['Name'] = "Invincible",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'E',
            ['Primary'] = true
        },
        ['leander-gun-achilles'] = {
            ['Name'] = "Leander",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['leander-gun-andromeda'] = {
            ['Name'] = "Leander",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['leander-gun-ariadne'] = {
            ['Name'] = "Leander",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'F',
            ['Primary'] = true
        },
        ['leander-gun-condell'] = {
            ['Name'] = "Condell",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'K',
            ['Primary'] = true
        },
        ['leander-gun-lynch'] = {
            ['Name'] = "Condell",
            ['Assigned'] = {"Naval"},
            ['Role'] = {"Naval"},
            ['Band'] = 'K',
            ['Primary'] = true
        }
    }

    HOUND.DB.PHONETICS =  {
        ['A'] = "Alpha",
        ['B'] = "Bravo",
        ['C'] = "Charlie",
        ['D'] = "Delta",
        ['E'] = "Echo",
        ['F'] = "Foxtrot",
        ['G'] = "Golf",
        ['H'] = "Hotel",
        ['I'] = "India",
        ['J'] = "Juliette",
        ['K'] = "Kilo",
        ['L'] = "Lima",
        ['M'] = "Mike",
        ['N'] = "November",
        ['O'] = "Oscar",
        ['P'] = "Papa",
        ['Q'] = "Quebec",
        ['R'] = "Romeo",
        ['S'] = "Sierra",
        ['T'] = "Tango",
        ['U'] = "Uniform",
        ['V'] = "Victor",
        ['W'] = "Whiskey",
        ['X'] = "X ray",
        ['Y'] = "Yankee",
        ['Z'] = "Zulu",
        ['1'] = "One",
        ['2'] = "Two",
        ['3'] = "Three",
        ['4'] = "Four",
        ['5'] = "Five",
        ['6'] = "Six",
        ['7'] = "Seven",
        ['8'] = "Eight",
        ['9'] = "Niner",
        ['0'] = "Zero",
        [' '] = ",",
        ['.'] = "Decimal"
    }

    HOUND.DB.useDecMin =  {
        ['F-16C_blk50'] = true,
        ['F-16C_50'] = true,
        ['M-2000C'] = true,
        ['A-10C'] = true,
        ['A-10C_2'] = true,
        ['AH-64D_BLK_II'] = true,
    }

    HOUND.DB.Platform =  {
        [Object.Category.STATIC] = {
            ['Comms tower M'] = {antenna = {size = 80, factor = 1},ins_error=0},
            ['Cow'] = {antenna = {size = 1000, factor = 10},ins_error=0}
        },
        [Object.Category.UNIT] = {
            ['MLRS FDDM'] = {antenna = {size = 15, factor = 1},ins_error=0},
            ['SPK-11'] = {antenna = {size = 15, factor = 1},ins_error=0},
            ['CH-47D'] = {antenna = {size = 12, factor = 1},ins_error=0},
            ['CH-53E'] = {antenna = {size = 10, factor = 1},ins_error=0},
            ['MIL-26'] = {antenna = {size = 20, factor = 1},ins_error=50},
            ['SH-60B'] = {antenna = {size = 8, factor = 1},ins_error=0},
            ['UH-60A'] = {antenna = {size = 8, factor = 1},ins_error=0},
            ['UH-60L'] = {antenna = {size = 8, factor = 1},ins_error=0}, -- community UH-69L
            ['Mi-8MT'] = {antenna = {size = 8, factor = 1},ins_error=0},
            ['UH-1H'] = {antenna = {size = 4, factor = 1},ins_error=50},
            ['KA-27'] = {antenna = {size = 4, factor = 1},ins_error=50},
            ['C-130'] = {antenna = {size = 35, factor = 1},ins_error=0},
            ['Hercules'] = {antenna = {size = 35, factor = 1},ins_error=0}, -- Anubis' C-130J
            ['EC130'] = {antenna = {size = 35, factor = 1},ins_error=0},  -- Secret Squirrel EC-130
            ['RC135RJ'] = {antenna = {size = 40, factor = 1},ins_error=0}, -- Secret Squirrel RC-135
            ['C-17A'] = {antenna = {size = 40, factor = 1},ins_error=0}, -- stand-in for RC-135, tuned antenna size to match
            ['S-3B'] = {antenna = {size = 18, factor = 0.8},ins_error=0},
            ['E-3A'] = {antenna = {size = 9, factor = 0.5},ins_error=0},
            ['E-2C'] = {antenna = {size = 7, factor = 0.5},ins_error=0},
            ['Tu-95MS'] = {antenna = {size = 50, factor = 1},ins_error=50},
            ['Tu-142'] = {antenna = {size = 50, factor = 1},ins_error=0},
            ['IL-76MD'] = {antenna = {size = 48, factor = 0.8},ins_error=50},
            ['H-6J'] = {antenna = {size = 3.5, factor = 1},ins_error=100},
            ['An-30M'] = {antenna = {size = 25, factor = 1},ins_error=50},
            ['A-50'] = {antenna = {size = 9, factor = 0.5},ins_error=0},
            ['An-26B'] = {antenna = {size = 26, factor = 1},ins_error=100},
            ['C-47'] = {antenna = {size = 12, factor = 1},ins_error=100},
            ['EA_6B'] = {antenna = {size = 9, factor = 1},ins_error=0}, -- VSN EA-6B
            ['Su-25T'] = {antenna = {size = 3.5, factor = 1}, require = {CLSID='{Fantasmagoria}'},ins_error=50},
            ['AJS37'] = {antenna = {size = 4.5, factor = 1}, require = {CLSID='{U22A}'},ins_error=50},
            ['F-16C_50'] = {antenna = {size = 1.45, factor = 1},require = {CLSID='{AN_ASQ_213}'},ins_error=0},
            ['JF-17'] = {antenna = {size = 3.25, factor = 1}, require = {CLSID='{DIS_SPJ_POD}'},ins_error=0},
            ['Mirage-F1CE'] = {antenna = {size = 3.7, factor = 1}, require = {CLSID='{TMV_018_Syrel_POD}'},ins_error=100}, -- temporary for intial release, CE had not INS, therefor could do ELINT.
            ['Mirage-F1EE'] = {antenna = {size = 3.7, factor = 1}, require = {CLSID='{TMV_018_Syrel_POD}'},ins_error=50}, -- does not reflect features in actual released product
            ['Mirage-F1M-CE'] = {antenna = {size = 3.7, factor = 1}, require = {CLSID='{TMV_018_Syrel_POD}'},ins_error=0}, -- does not reflect features in actual released product
            ['Mirage-F1M-EE'] = {antenna = {size = 3.7, factor = 1}, require = {CLSID='{TMV_018_Syrel_POD}'},ins_error=0}, -- does not reflect features in actual released product
            ['Mirage-F1CR'] = {antenna = {size = 4, factor = 1}, require = {CLSID='{ASTAC_POD}'},ins_error=0}, -- AI only (FAF)
            ['Mirage-F1EQ'] = {antenna = {size = 3.7, factor = 1}, require = {CLSID='{TMV_018_Syrel_POD}'},ins_error=50}, -- AI only (Iraq)
            ['Mirage-F1EDA'] = {antenna = {size = 3.7, factor = 1}, require = {CLSID='{TMV_018_Syrel_POD}'},ins_error=50}, -- AI only (Qatar)

        }
    }

    HOUND.DB.Bands =  {
        ['A'] = 1.713100,
        ['B'] = 0.799447,
        ['C'] = 0.399723,
        ['D'] = 0.199862,
        ['E'] = 0.119917,
        ['F'] = 0.085655,
        ['G'] = 0.059958,
        ['H'] = 0.042827,
        ['I'] = 0.033310,
        ['J'] = 0.019986,
        ['K'] = 0.009993,
        ['L'] = 0.005996,
    }

    HOUND.DB.CALLSIGNS = {
        NATO = {
            "ABLOW", "ACTON", "AGRAM", "AMINO", "AWOKE", "BARB", "BART", "BAZOO",
            "BOGUE", "BOOT", "BRAY", "CAMAY", "CAPON", "CASEY", "CHIME", "CHISUM",
            "COBRA", "COSMO", "CRISP", "DAGDA", "DALLY", "DEVON", "DIVE", "DOZER",
            "DUPLE", "EXOR", "EXUDE", "EXULT", "FLOSS", "FLOUT", "FLUKY", "FURR",
            "GENUS", "GOBO", "GOLLY", "GOOFY", "GROUP", "HAKE", "HARMO",
            "HERMA", "HEXAD", "HOLE", "HURDS", "HYMN", "IOTA", "JOSS", "KELT", "LARVA",
            "LUMPY", "MAFIA", "MINE", "MORTY", "MURKY", "NEVIN", "NEWLY", "NORTH",
            "OLIVE", "ORKIN", "PARRY", "PATIO", "PATSY", "PATTY", "PERMA", "PITTS",
            "POKER", "POOK", "PRIME", "PYTHON", "RAGU", "REMUS", "RINGY", "RITZ",
            "RIVET", "ROSE", "RULE", "RUNNY", "SAME", "SAVOY", "SCENT",
            "SCROW", "SEAT", "SLAG", "SLOG", "SNOOP", "SPRY", "STINT", "STOB", "TAKE",
            "TALLY", "TAPE", "TOLL", "TONUS", "TOPCAT", "TORA", "TOTTY", "TOXIC",
            "TRIAL", "TRYST", "VALVO", "VEIN", "VELA", "VETCH", "VINE", "VULCAN",
            "WATT", "WORTH", "ZEPEL", "ZIPPY"
        },
        GENERIC = {
            "VACUUM", "HOOVER", "KIRBY","ROOMBA","DYSON","SHERLOCK","WATSON","GADGET",
            "HORATIO","CAINE","CHRISTIE","BENSON","GIBBS","COLOMBO","HOLT","DIAZ",
            "SCULLY","MULDER","MARVIN","MARS","MORNINGSTAR","STEELE","CASTEL","BECKETT",
            "INDIANA","JONES","LARA","CROFT","VENTURA","SCOOBY","SHAGGY"
        }
    }

    function HOUND.DB.getRadarData(typeName)
        if not HOUND.DB.Radars[typeName] then return end
        local data = l_mist.utils.deepCopy(HOUND.DB.Radars[typeName])
        data.isEWR = setContainsValue(data.Role,"EWR")
        return data
    end

    function HOUND.DB.isValidPlatform(candidate)
        if type(candidate) ~= "table" or type(candidate.isExist) ~= "function" or not candidate:isExist()
             then return false
        end

        local isValid = false
        local mainCategory = candidate:getCategory()
        local type = candidate:getTypeName()

        if setContains(HOUND.DB.Platform,mainCategory) then
            if setContains(HOUND.DB.Platform[mainCategory],type) then
                if HOUND.DB.Platform[mainCategory][type]['require'] then
                    local platformData = HOUND.DB.Platform[mainCategory][type]
                    if setContains(platformData['require'],'CLSID') then
                        local required = platformData['require']['CLSID']
                        isValid = HOUND.Utils.hasPayload(candidate,required)
                    end
                    if setContains(platformData['require'],'TASK') then
                        local required = platformData['require']['TASK']
                        isValid = not HOUND.Utils.hasTask(candidate,required)
                    end
                else
                    isValid = true
                end
            end
        end
        return isValid
    end

    function HOUND.DB.getPlatformData(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName or not DCS_Unit.getCategory then return end

        local platformData={
            pos = l_mist.utils.deepCopy(DCS_Unit:getPosition().p),
            isStatic = false,
            isAerial = false,
        }

        local mainCategory = DCS_Unit:getCategory()
        local typeName = DCS_Unit:getTypeName()
        local DbInfo = HOUND.DB.Platform[mainCategory][typeName]

        local errorDist = DbInfo.ins_error or 0
        platformData.posErr = HOUND.Utils.Vector.getRandomVec2(errorDist)
        platformData.posErr.y = 0
        platformData.ApertureSize = (DbInfo.antenna.size * DbInfo.antenna.factor) or 0

        if DCS_Unit:getCategory() == Object.Category.STATIC then
            platformData.isStatic = true
        else
            local PlatformUnitCategory = DCS_Unit:getDesc()["category"]
            if PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE then
                platformData.isAerial = true
            end
        end
        if not platformData.isAerial then
            platformData.pos.y = platformData.pos.y + DCS_Unit:getDesc()["box"]["max"]["y"]
        end
        return platformData
    end

    function HOUND.DB.getDefraction(band,antenna_size)
        if band == nil or antenna_size == nil or antenna_size == 0 then return l_math.rad(30) end
        return HOUND.DB.Bands[band]/antenna_size
    end

    function HOUND.DB.getApertureSize(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName or not DCS_Unit.getCategory then return 0 end
        local mainCategory = DCS_Unit:getCategory()
        local typeName = DCS_Unit:getTypeName()
        if setContains(HOUND.DB.Platform,mainCategory) then
            if setContains(HOUND.DB.Platform[mainCategory],typeName) then
                return HOUND.DB.Platform[mainCategory][typeName].antenna.size *  HOUND.DB.Platform[mainCategory][typeName].antenna.factor
            end
        end
        return 0
    end

    function HOUND.DB.getEmitterBand(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName then return 'C' end
        local typeName = DCS_Unit:getTypeName()
        if setContains(HOUND.DB.Radars,typeName) then
            return HOUND.DB.Radars[typeName].Band
        end
        return 'C'
    end

    function HOUND.DB.getSensorPrecision(platform,emitterBand)
        return HOUND.DB.getDefraction(emitterBand,HOUND.DB.getApertureSize(platform)) or l_math.rad(20.0) -- precision
    end
end
do

    HOUND.Config = {
        configMaps = {}
    }

    HOUND.Config.__index = HOUND.Config

    function HOUND.Config.get(HoundInstanceId)
        HoundInstanceId = HoundInstanceId or Length(HOUND.Config.configMaps)+1

        if HOUND.Config.configMaps[HoundInstanceId] then
            return HOUND.Config.configMaps[HoundInstanceId]
        end

        local instance = {}
        instance.intervals = {
            scan = 10,
            process = 30,
            menus = 60,
            markers = 120,

        }
        instance.preferences = {
            useMarkers = true,
            markerType = HOUND.MARKER.DIAMOND,
            hardcore = false,
            detectDeadRadars = true,
            NatoBrevity = false,
            platformPosErr = false,
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
        instance.onScreenDebug = false

        instance.getId = function (self)
            return self.id
        end

        instance.getCoalition = function(self)
            return self.coalitionId
        end

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

        instance.setInterval = function (self,intervalName,setVal)
            if setContains(self.intervals,intervalName) and type(setVal) == "number" then
                self.intervals[intervalName] = setVal
                return true
            end
            return false
        end

        instance.getMarkerType = function (self)
            return self.preferences.markerType
        end

        instance.setMarkerType = function (self,markerType)
            if setContainsValue(HOUND.MARKER,markerType) then
                self.preferences.markerType = markerType
                return true
            end
            return false
        end

        instance.getUseMarkers = function (self)
            return self.preferences.useMarkers
        end

        instance.setUseMarkers = function(self,value)
            if type(value) == "boolean" then
                self.preferences.useMarkers = value
                return true
            end
            return false
        end

        instance.getBDA = function(self)
            return self.preferences.detectDeadRadars
        end

        instance.setBDA = function(self,value)
            if type(value) == "boolean" then
                self.preferences.detectDeadRadars = value
                return true
            end
            return false
        end

        instance.getNATO = function(self)
            return self.preferences.NatoBrevity
        end

        instance.setNATO = function(self,value)
            if type(value) == "boolean" then
                self.preferences.NatoBrevity = value
                return true
            end
            return false
        end

        instance.getUseNATOCallsigns = function(self)
            return self.preferences.useNatoCallsigns
        end

        instance.setUseNATOCallsigns = function(self,value)
            if type(value) == "boolean" then
                self.preferences.useNatoCallsigns = value
                return true
            end
            return false
        end

        instance.getAtisUpdateInterval = function(self)
            return self.preferences.AtisUpdateInterval
        end

        instance.setAtisUpdateInterval = function(self,value)
            if type(value) == "number" then
                self.preferences.AtisUpdateInterval = value
                return true
            end
            return false
        end

        instance.getPosErr = function(self)
            return self.preferences.platformPosErr
        end

        instance.setPosErr = function(self,value)
            if type(value) == "boolean" then
                self.preferences.platformPosErr = value
                return true
            end
            return false
        end

        instance.getHardcore = function(self)
            return self.preferences.hardcore
        end

        instance.setHardcore = function(self,value)
            if type(value) == "boolean" then
                self.preferences.hardcore = value
                return true
            end
            return false
        end

        instance.getOnScreenDebug = function(self)
            return self.onScreenDebug
        end

        instance.setOnScreenDebug = function(self,value)
            if type(value) == "boolean" then
                self.onScreenDebug = value
                return true
            end
            return false
        end

        instance.getRadioMenu = function (self)
            if not self.radioMenu.root then
                self.radioMenu.root = missionCommands.addSubMenuForCoalition(
                    self:getCoalition(), 'ELINT',self:getRadioMenuParent())
            end
            return self.radioMenu.root
        end

        instance.removeRadioMenu = function (self)
            if self.radioMenu.root ~= nil then
                missionCommands.removeItem(self.radioMenu.root)
                self.radioMenu.root = nil
                return true
            end
            return false
        end

        instance.getRadioMenuParent = function(self)
            return self.radioMenu.parent
        end

        instance.setRadioMenuParent = function (self,parent)
            if type(parent) == "table" or (parent == nil and self.radioMenu.parent) then
                self:removeRadioMenu()
                self.radioMenu.parent = parent
                return true
            end
            return false
        end

        HOUND.Config.configMaps[HoundInstanceId] = instance

        return HOUND.Config.configMaps[HoundInstanceId]
    end
end
do
    local l_mist = mist
    local l_math = math
    local pi_2 = 2*l_math.pi

    HOUND.Utils = {
        Mapping = {},
        Geo     = {},
        Marker  = {},
        TTS     = {},
        Text    = {},
        Elint   = {},
        Vector  = {},
        Zone    = {},
        Polygon = {},
        Cluster = {},
        Sort    = {},
        Filter  = {},
        ReportId = nil,
        _HoundId = 0
    }
    HOUND.Utils.__index = HOUND.Utils

    function HOUND.Utils.getHoundId()
        HOUND.Utils._HoundId = HOUND.Utils._HoundId + 1
        return HOUND.Utils._HoundId
    end

    function HOUND.Utils.getMarkId()
        return HOUND.Utils.Marker.getId()
    end

    function HOUND.Utils.setInitialMarkId(startId)
        return HOUND.Utils.Marker.setInitialId(startId)
    end

    function HOUND.Utils.absTimeDelta(t0, t1)
        if t1 == nil then t1 = timer.getAbsTime() end
        return t1 - t0
    end

    function HOUND.Utils.angleDeltaRad(rad1,rad2)
        if not rad1 or not rad2 then return end
        return l_math.pi - l_math.abs(l_math.pi - l_math.abs(rad1-rad2) % pi_2)
    end

    function HOUND.Utils.AzimuthAverage(azimuths)
        if not azimuths or Length(azimuths) == 0 then return nil end

        local sumSin = 0
        local sumCos = 0
        for i=1, Length(azimuths) do
            sumSin = sumSin + l_math.sin(azimuths[i])
            sumCos = sumCos + l_math.cos(azimuths[i])
        end
        return (l_math.atan2(sumSin,sumCos) + pi_2) % pi_2
    end

    function HOUND.Utils.PointClusterTilt(points,MagNorth,refPos)
        if not points or type(points) ~= "table" then return end
        if not refPos then
            refPos = l_mist.getAvgPoint(points)
        end
        local magVar = 0
        if MagNorth then
            magVar = l_mist.getNorthCorrection(refPos)
        end
        local biasVector = nil
        for _,point in pairs(points) do
            local V = {
                y = 0
            }
            V.x = point.x - refPos.x
            V.z = point.z - refPos.z
            if V.x < 0 then
                V.x = -V.x
                V.z = -V.z
            end
            if biasVector == nil then biasVector = V else biasVector = l_mist.vec.add(biasVector,V) end
        end
        return (l_math.atan2(biasVector.z,biasVector.x) + magVar) % pi_2
    end

    function HOUND.Utils.RandomAngle()
        return l_math.random() * 2 * l_math.pi
    end

    function HOUND.Utils.getSamMaxRange(DCS_Unit)
        local maxRng = 0
        if DCS_Unit ~= nil then
            local units = DCS_Unit:getGroup():getUnits()
            for _, unit in ipairs(units) do
                local weapons = unit:getAmmo()
                if weapons ~= nil then
                    for _, ammo in ipairs(weapons) do
                        if ammo.desc.category == Weapon.Category.MISSILE and ammo.desc.missileCategory == Weapon.MissileCategory.SAM then
                            maxRng = l_math.max(l_math.max(ammo.desc.rangeMaxAltMax,ammo.desc.rangeMaxAltMin),maxRng)
                        end
                    end
                end
            end
        end
        return maxRng
    end

    function HOUND.Utils.getRadarDetectionRange(DCS_Unit)
        local detectionRange = 0
        local unit_sensors = DCS_Unit:getSensors()
        if not unit_sensors then return detectionRange end
        if not setContains(unit_sensors,Unit.SensorType.RADAR) then return detectionRange end
        for _,radar in pairs(unit_sensors[Unit.SensorType.RADAR]) do
            if setContains(radar,"detectionDistanceAir") then
                for _,aspects in pairs(radar["detectionDistanceAir"]) do
                    for _,range in pairs(aspects) do
                        detectionRange = l_math.max(detectionRange,range)
                    end
                end
            end
        end
        return detectionRange
    end

    function HOUND.Utils.getRoundedElevationFt(elev,resolution)
        if not resolution then
            resolution = 50
        end
        return HOUND.Utils.roundToNearest(l_mist.utils.metersToFeet(elev),resolution)
    end

    function HOUND.Utils.roundToNearest(input,nearest)
        return l_mist.utils.round(input/nearest) * nearest
    end

    function HOUND.Utils.getNormalAngularError(variance)
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = 2* math.pi * l_math.random()

        local epsilon = {
            az = Magnitude * l_math.cos(Theta),
            el = Magnitude * l_math.sin(Theta)
        }
        return epsilon
    end

    function HOUND.Utils.getControllerResponse()
        local response = {
            " ",
            "Good Luck!",
            "Happy Hunting!",
            "Please send my regards.",
            " "
        }
        return response[l_math.max(1,l_math.min(l_math.ceil(timer.getAbsTime() % Length(response)),Length(response)))]
    end

    function HOUND.Utils.getCoalitionString(coalitionID)
        local coalitionStr = "RED"
        if coalitionID == coalition.side.BLUE then
            coalitionStr = "BLUE"
        elseif coalitionID == coalition.side.NEUTRAL then
            coalitionStr = "NEUTRAL"
        end
        return coalitionStr
    end

    function HOUND.Utils.getHemispheres(lat,lon,fullText)
        local hemi = {
            NS = "North",
            EW = "East"
        }
        if lat < 0 then hemi.NS = "South" end
        if lon < 0 then hemi.EW = "West" end
        if fullText == nil or fullText == false then
            hemi.NS = string.sub(hemi.NS, 1, 1)
            hemi.EW = string.sub(hemi.EW, 1, 1)
        end
        return hemi
    end

    function HOUND.Utils.getReportId(ReportId)
        local returnId
        if ReportId ~= nil then
            returnId =  string.byte(ReportId)
        else
            returnId = HOUND.Utils.ReportId
        end
        if returnId == nil or returnId == string.byte('Z') then
            returnId = string.byte('A')
        else
            returnId = returnId + 1
        end
        if not ReportId then
            HOUND.Utils.ReportId = returnId
        end

        return HOUND.DB.PHONETICS[string.char(returnId)],string.char(returnId)
    end

    function HOUND.Utils.DecToDMS(cood)
        local deg = l_math.floor(cood)
        if cood < 0 then
            deg = l_math.ceil(cood)
        end
        local minutes = l_math.floor(l_math.abs(cood - deg) * 60)
        local sec = l_math.floor((l_math.abs(cood-deg) * 3600) % 60)
        local dec = l_math.abs(cood-deg) * 60

        return {
            d = deg,
            m = minutes,
            s = sec,
            mDec = l_mist.utils.round(dec ,3),
            sDec = l_mist.utils.round((l_mist.utils.round(dec,3)*1000)-(minutes*1000))
        }
    end

    function HOUND.Utils.getBR(src,dst)
        if not src or not dst then return end
        local BR = {}
        local dir = l_mist.utils.getDir(l_mist.vec.sub(dst,src),src) -- pass src to get magvar included
        BR.brg = l_mist.utils.round(l_mist.utils.toDegree( dir ))
        BR.brStr = string.format("%03d",BR.brg)
        BR.rng = l_mist.utils.round(l_mist.utils.metersToNM(l_mist.utils.get2DDist(dst,src)))
        return BR
    end

    function HOUND.Utils.getFormationCallsign(player,flightMember)
        local callsign = ""
        if type(player) ~= "table" then return callsign end
        callsign = string.gsub(player.callsign.name,"[%d%s]","") .. " " .. player.callsign[2]
        if flightMember then
            callsign = callsign .. " " .. player.callsign[3]
        end

        local DCS_Unit = Unit.getByName(player.unitName)
        if not DCS_Unit then return string.upper(callsign:match( "^%s*(.-)%s*$" )) end

        local playerName = DCS_Unit:getPlayerName()
        playerName = playerName:match("%a+%s%d+[?%p%s*]%d*")
        if playerName then
            callsign = playerName
            local base = string.match(callsign,"%a+")
            local num = tonumber(string.match(callsign,"%d+"))
            local memberNum = string.gsub(callsign,"%a+%s%d+[%p%s*]","")
            if memberNum:len() > 0 then
                memberNum = tonumber(memberNum:match("%d+"))
            else
                memberNum = nil
            end

            callsign = base
            if type(num) == "number" and type(memberNum) == "number" then
                callsign = callsign .. " " .. num
            end

            if flightMember then
                if type(memberNum) == "number" then
                    callsign = callsign .. " " .. memberNum
                end
                if type(num) == "number" and type(memberNum) == "nil" then
                    callsign = callsign .. " " .. num
                end
            end
            return string.upper(callsign:match( "^%s*(.-)%s*$" ))
        end
        return string.upper(callsign:match( "^%s*(.-)%s*$" ))
    end

    function HOUND.Utils.getHoundCallsign(namePool)
        local SelectedPool = HOUND.DB.CALLSIGNS[namePool] or HOUND.DB.CALLSIGNS.GENERIC
        return SelectedPool[l_math.random(1, Length(SelectedPool))]
    end

    function HOUND.Utils.isDMM(DCS_Unit)
        if not DCS_Unit then return false end
        local typeName = nil
        if type(DCS_Unit) == "string" then
            typeName = DCS_Unit
        end
        if type(DCS_Unit) == "Table" and DCS_Unit.getTypeName then
            typeName = DCS_Unit:getTypeName()
        end
        return setContains(HOUND.DB.useDecMin,typeName)
    end

    function HOUND.Utils.hasPayload(DCS_Unit,payloadName)
        return true
    end

    function HOUND.Utils.hasTask(DCS_Unit,taskName)
        return true
    end

    HOUND.Utils.Mapping.CURVES = {
        RETAIL = 0,
        WINDOWS = 1,
        HERRA9 = 2,
        HERRA45 = 3,
        EXPONENTIAL = 4,
        MIXED = 5,
        POWER = 6
    }

    function HOUND.Utils.Mapping.linear(input, in_min, in_max, out_min, out_max,clamp)
        local mapValue = (input - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        if clamp then
            if out_min < out_max then
                return l_math.max(out_min,l_math.min(out_max,mapValue))
            else
                return l_math.max(out_max,l_math.min(out_min,mapValue))
            end
        end
        return mapValue
    end

    function HOUND.Utils.Mapping.nonLinear(value,in_min,in_max,out_min,out_max,sensitivity,curve_type)

        if type(sensitivity) ~= "number" then
            sensitivity = 9
        end
        sensitivity=l_math.min(0,l_math.max(9,sensitivity))
        local relativePos = HOUND.Utils.Mapping.linear(value,in_min,in_max,0,1)
        local mappedIn = relativePos*(sensitivity/9)+(relativePos^5)*(9-sensitivity)/9
        if type(curve_type) == "number" then
            if curve_type == 1 then
                mappedIn = relativePos^(3-(sensitivity/4.5))
            elseif curve_type == 2 then
                mappedIn = relativePos^(sensitivity/9)*((1-l_math.cos(relativePos*l_math.pi))/2)^((9-sensitivity)/9)
            elseif curve_type == 3 then
                mappedIn = relativePos^(sensitivity/9)*((1-l_math.cos(relativePos*l_math.pi))/2)^((9-sensitivity)/4.5)
            elseif curve_type == 4 then
                mappedIn = (l_math.exp((10-sensitivity)*relativePos)-1)/(l_math.exp(10-sensitivity)-1)
            elseif curve_type == 5 then
                mappedIn = relativePos^(1+((5-sensitivity)/9))
            elseif curve_type == 6 then
                mappedIn = relativePos*relativePos^((9-sensitivity)/9)
            end
        end

        if type(out_min) == "number" and type(out_max) == "number" then
            return HOUND.Utils.Mapping.linear(mappedIn,0,1,out_min,out_max)
        end
        return mappedIn
    end

    function HOUND.Utils.Geo.checkLOS(pos0,pos1)
        if not pos0 or not pos1 then return false end
        local dist = l_mist.utils.get2DDist(pos0,pos1)
        local radarHorizon = HOUND.Utils.Geo.EarthLOS(pos0.y,pos1.y)
        return (dist <= radarHorizon*1.025 and land.isVisible(pos0,pos1))
    end

    function HOUND.Utils.Geo.EarthLOS(h0,h1)
        if not h0 then return 0 end
        local Re = 6367444 -- Radius of earth in M (avarage radius of WGS84)
        local d0 = l_math.sqrt(h0^2+2*Re*h0)
        local d1 = 0
        if h1 then d1 = l_math.sqrt(h1^2+2*Re*h1) end
        return d0+d1
    end

    function HOUND.Utils.Geo.isDcsPoint(point)
        if type(point) ~= "table" then return false end
        return (type(point.x) == "number") and (type(point.z) == "number")
    end

    function HOUND.Utils.Geo.getProjectedIP(p0,az,el)
        if not HOUND.Utils.Geo.isDcsPoint(p0) or type(az) ~= "number" or type(el) ~= "number" then return end
        local maxSlant = HOUND.Utils.Geo.EarthLOS(p0.y)*1.2

        local unitVector = HOUND.Utils.Vector.getUnitVector(az,el)
        return land.getIP(p0, unitVector , maxSlant )
    end

    function HOUND.Utils.Geo.setPointHeight(point)
        if HOUND.Utils.Geo.isDcsPoint(point) and type(point.y) ~= "number" then
            point.y = land.getHeight({x=point.x,y=point.z})
        end
        return point
    end

    function HOUND.Utils.Geo.setHeight(point)
        if type(point) == "table" then
            if HOUND.Utils.Geo.isDcsPoint(point) then
                return HOUND.Utils.Geo.setPointHeight(point)
            end
            for _,pt in pairs(point) do
                pt = HOUND.Utils.Geo.setPointHeight(pt)
            end
        end
        return point
    end

    HOUND.Utils.Marker._MarkId = 9999
    HOUND.Utils.Marker.Type = {
        NONE = 0,
        POINT = 1,
        CIRCLE = 2,
        FREEFORM = 3
    }

    function HOUND.Utils.Marker.getId()
        if HOUND.FORCE_MANAGE_MARKERS then
            HOUND.Utils.Marker._MarkId = HOUND.Utils.Marker._MarkId + 1
        elseif UTILS and UTILS.GetMarkID then
            HOUND.Utils.Marker._MarkId = UTILS.GetMarkID()
        elseif HOUND.MIST_VERSION >= 4.5 then
            HOUND.Utils.Marker._MarkId = l_mist.marker.getNextId()
        else
            HOUND.Utils.Marker._MarkId = HOUND.Utils.Marker._MarkId + 1
        end
        return HOUND.Utils.Marker._MarkId
    end

    function HOUND.Utils.Marker.setInitialId(startId)
        if type(startId) ~= "number" then
            HOUND.Logger.error("Failed to set Initial marker Id. Value provided was not a number")
            return false
        end
        if HOUND.Utils.Marker._MarkID ~= 0 then
            HOUND.Logger.error("Initial MarkId not updated because markers have already been drawn")
            return false
        end
        HOUND.Utils.Marker._MarkId = startId
        return true
    end

    function HOUND.Utils.Marker.create(args)
        local instance = {}
        instance.id = -1
        instance.type = HOUND.Utils.Marker.Type.NONE

        instance.setPos = function(self,pos)
            if self.type == HOUND.Utils.Marker.Type.FREEFORM then return end
            if HOUND.Utils.Geo.isDcsPoint(pos) then
                trigger.action.setMarkupPositionStart(self.id,pos)
            end
        end

        instance.setText = function(self,text)
            if type(text) == "string" and self.id > 0 then
                trigger.action.setMarkupText(self.id,text)
            end
        end

        instance.setRadius = function(self,radius)
            if type(radius) == "number" and self.type == HOUND.Utils.Marker.Type.CIRCLE and self.id > 0 then
                trigger.action.setMarkupRadius(self.id,radius)
            end
        end

        instance.setFillColor = function(self,color)
            if self.id > 0 and self.type ~= HOUND.Utils.Marker.Type.FREEFORM and type(color) == "table" then
                trigger.action.setMarkupColorFill(self.id,color)
            end
        end

        instance.setLineColor = function(self,color)
            if self.id > 0 and self.type ~= HOUND.Utils.Marker.Type.FREEFORM and type(color) == "table" then
                trigger.action.setMarkupColor(self.id,color)
            end
        end

        instance.isDrawn = function(self)
            return (self.id > 0)
        end

        instance.remove = function(self)
            if self.id > 0 then
                trigger.action.removeMark(self.id)
                if self.id % 500 == 0 then
                    collectgarbage("collect")
                end
                self.id = -1
                self.type = HOUND.Utils.Marker.Type.NONE
            end
        end

        instance._new = function(self,args)
            if type(args) ~= "table" then return false end
            local coalition = args.coalition
            local pos = args.pos
            local text = args.text
            local lineColor = args.lineColor
            local fillColor = args.fillColor
            self.id = HOUND.Utils.Marker.getId()

            if HOUND.Utils.Geo.isDcsPoint(pos) then
                self.type = HOUND.Utils.Marker.Type.POINT
                trigger.action.markToCoalition(self.id, text, pos, coalition,true)
                return true
            end

            if Length(pos) == 2 and HOUND.Utils.Geo.isDcsPoint(pos.p) and type(pos.r) == "number" then
                self.type = HOUND.Utils.Marker.Type.CIRCLE
                trigger.action.circleToAll(coalition,self.id, pos.p,pos.r,lineColor,fillColor,2,true)
                return true
            end

            if Length(pos) == 4 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(6,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    lineColor,fillColor,2,true)

            end
            if Length(pos) == 8 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(7,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    pos[5], pos[6], pos[7], pos[8],
                    lineColor,fillColor,2,true)
            end
            if Length(pos) == 16 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(7,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    pos[5], pos[6], pos[7], pos[8],
                    pos[9], pos[10], pos[11], pos[12],
                    pos[13], pos[14], pos[15], pos[16],
                    lineColor,fillColor,2,true)
            end
        end

        instance._replace = function(self,args)
            self:remove()
            return self:_new(args)
        end

        instance.update = function(self,args)
            if type(args.coalition) ~= "number" then return false end
            if self.id < 0 then
                return self:_new(args)
            end
            if self.id > 0 and self.type ~= HOUND.Utils.Marker.Type.NONE then
                    return self:_replace(args)
            end
        end
        if type(args) == "table" then
            instance.update(instance,args)
        end
        return instance
    end

    function HOUND.Utils.TTS.Transmit(msg,coalitionID,args,transmitterPos)

        if STTS == nil then return end
        if msg == nil then return end
        if coalitionID == nil then return end

        if args.freq == nil then return end
        args.modulation = args.modulation or "AM"
        args.volume = args.volume or "1.0"
        args.name = args.name or "Hound"
        args.gender = args.gender or "female"
        args.culture = args.culture or "en-US"

        return STTS.TextToSpeech(msg,args.freq,args.modulation,args.volume,args.name,coalitionID,transmitterPos,args.speed,args.gender,args.culture,args.voice,args.googleTTS)
    end

    function HOUND.Utils.TTS.getTtsTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        local hours = DHMS.h
        local minutes = DHMS.m
        if hours == 0 then
            hours = HOUND.DB.PHONETICS["0"]
        else
            hours = string.format("%02d",hours)
        end

        if minutes == 0 then
            minutes = "hundred"
        else
            minutes = string.format("%02d",minutes)
        end

        return hours .. " " .. minutes .. " Local"
    end

    function HOUND.Utils.TTS.getVerbalConfidenceLevel(confidenceRadius)
        if confidenceRadius == 0.1 then return "Precise" end

        local score={
            "Very High", -- 500
            "High", -- 1000
            "Medium", -- 1500
            "Low", -- 2000
            "Low", -- 2500
            "Very Low", -- 3000
            "Very Low", -- 3500
            "Very Low", -- 4000
            "Very Low", -- 4500
            "Unactionable", -- 5000
        }
        return score[l_math.min(#score,l_math.max(1,l_math.floor(confidenceRadius/500)+1))]
    end

    function HOUND.Utils.TTS.getVerbalContactAge(timestamp,isSimple,NATO)
        local ageSeconds = HOUND.Utils.absTimeDelta(timestamp,timer.getAbsTime())

        if isSimple then
            if NATO then
                if ageSeconds < 16 then return "Active" end
                if ageSeconds < HOUND.CONTACT_TIMEOUT then return "Down" end
                return "Asleep"
            end
            if ageSeconds < 16 then return "Active" end
            if ageSeconds <= 90 then return "very recent" end
            if ageSeconds <= 180 then return "recent" end
            if ageSeconds <= 300 then return "relevant" end
            return "stale"
        end
        local DHMS = l_mist.time.getDHMS(ageSeconds)
        if ageSeconds < 60 then return tostring(l_math.floor(DHMS.s)) .. " seconds" end
        if ageSeconds < 7200 then return tostring(l_math.floor(DHMS.h)*60+l_math.floor(DHMS.m)) .. " minutes" end
        return tostring(l_math.floor(DHMS.h)) .. " hours, " .. tostring(l_math.floor(DHMS.m)) .. " minutes"
    end

    function HOUND.Utils.TTS.DecToDMS(cood,minDec,padDeg)
        local DMS = HOUND.Utils.DecToDMS(cood)
        local strTab = {
            l_math.abs(DMS.d) .. " degrees",
            string.format("%02d",DMS.m) .. " minutes",
            string.format("%02d",DMS.s) .. " seconds"
        }
        if padDeg == true then
            strTab[1] = string.format("%03d",l_math.abs(DMS.d)) .. " degrees"
        end
        if minDec == true then
            strTab[2] = string.format("%02d",DMS.m)
            strTab[3] = HOUND.Utils.TTS.toPhonetic( "." .. string.format("%03d",DMS.sDec)) .. " minutes"
        end
        return table.concat(strTab,", ")
    end

    function HOUND.Utils.TTS.getVerbalLL(lat,lon,minDec)
        minDec = minDec or false
        local hemi = HOUND.Utils.getHemispheres(lat,lon,true)
        return hemi.NS .. ", " .. HOUND.Utils.TTS.DecToDMS(lat,minDec)  ..  ", " .. hemi.EW .. ", " .. HOUND.Utils.TTS.DecToDMS(lon,minDec,true)
    end

    function HOUND.Utils.TTS.toPhonetic(str)
        local retval = ""
        str = string.upper(tostring(str))
        for i=1, string.len(str) do
            retval = retval .. HOUND.DB.PHONETICS[string.sub(str, i, i)] .. " "
        end
        return retval:match( "^%s*(.-)%s*$" ) -- return and strip trailing whitespaces
    end

    function HOUND.Utils.TTS.getReadTime(length,speed,isGoogle)
        if length == nil then return nil end
        local maxRateRatio = 3 -- can be chaned to 5 if windows TTSrate is up to 5x not 4x

        speed = speed or 1.0
        isGoogle = isGoogle or false

        local speedFactor = 1.0
        if isGoogle then
            speedFactor = speed
        else
            if speed ~= 0 then
                speedFactor = l_math.abs(speed) * (maxRateRatio - 1) / 10 + 1
            end
            if speed < 0 then
                speedFactor = 1/speedFactor
            end
        end

        local wpm = l_math.ceil(100 * speedFactor)
        local cps = l_math.floor((wpm * 5)/60)

        if type(length) == "string" then
            length = string.len(length)
        end

        return l_math.ceil(length/cps)
    end

    function HOUND.Utils.TTS.simplfyDistance(distanceM)
        local distanceUnit = "meters"
        local distance = HOUND.Utils.roundToNearest(distanceM,50) or 0
        if distance >= 1000 then
            distance = string.format("%.1f",tostring(HOUND.Utils.roundToNearest(distanceM,100)/1000))
            distanceUnit = "kilometers"
        end
        return distance .. " " .. distanceUnit
    end

    function HOUND.Utils.Text.getLL(lat,lon,minDec)
        local hemi = HOUND.Utils.getHemispheres(lat,lon)
        lat = HOUND.Utils.DecToDMS(lat)
        lon = HOUND.Utils.DecToDMS(lon)
        if minDec == true then
            return hemi.NS .. l_math.abs(lat.d) .. "°" .. string.format("%.3f",lat.mDec) .. "'" ..  " " ..  hemi.EW  .. l_math.abs(lon.d) .. "°" .. string.format("%.3f",lon.mDec) .. "'"
        end
        return hemi.NS .. l_math.abs(lat.d) .. "°" .. string.format("%02d",lat.m) .. "'".. string.format("%02d",l_math.floor(lat.s)).."\"" ..  " " ..  hemi.EW  .. l_math.abs(lon.d) .. "°" .. string.format("%02d",lon.m) .. "'".. string.format("%02d",l_math.floor(lon.s)) .."\""
    end

    function HOUND.Utils.Text.getTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        return string.format("%02d",DHMS.h)  .. string.format("%02d",DHMS.m)
    end

    function HOUND.Utils.Elint.generateAngularError(variance)
        local vec2 = HOUND.Utils.Vector.getRandomVec2(variance)
        local epsilon = {
            az = vec2.x,
            el = vec2.z
        }
        return epsilon
    end

    function HOUND.Utils.Elint.getAzimuth(src, dst, sensorPrecision)
        local AngularErr = HOUND.Utils.Elint.generateAngularError(sensorPrecision)

        local vec = l_mist.vec.sub(dst, src)
        local az = l_math.atan2(vec.z,vec.x) + AngularErr.az
        if az < 0 then
            az = az + pi_2
        end
        if az > pi_2 then
            az = az - pi_2
        end

        local el = (l_math.atan(vec.y/l_math.sqrt(vec.x^2 + vec.z^2)) + AngularErr.el)

        return az,el
    end

    function HOUND.Utils.Elint.getActiveRadars(instanceCoalition)
        if instanceCoalition == nil then return end
        local Radars = {}

        for _,coalitionName in pairs(coalition.side) do
            if coalitionName ~= instanceCoalition then
                for _,CategoryId in pairs({Group.Category.GROUND,Group.Category.SHIP}) do
                    for _,group in pairs(coalition.getGroups(coalitionName, CategoryId)) do
                        for _,unit in pairs(group:getUnits()) do
                            if (unit:isExist() and unit:isActive() and unit:getRadar()) then
                                table.insert(Radars, unit:getName()) -- insert the name
                            end
                        end
                    end
                end
            end
        end
        return Radars
    end

    function HOUND.Utils.Elint.getRwrContacts(platform)
        local radars = {}
        local platformCoalition = platform:getCoalition()
        if not platform:hasSensors(Unit.SensorType.RWR) then return radars end
        local contacts = platform:getController():getDetectedTargets(Controller.Detection.RWR)
        for _,unit in contacts do
            if unit:getCoalition() ~= platformCoalition and unit:getRadar() then
                table.insert(radars,unit:getName())
            end
        end
        return radars
    end

    function HOUND.Utils.Vector.getUnitVector(Theta,Phi)
        if not Theta then
            return {x=0,y=0,z=0}
        end
        Phi = Phi or 0
        local unitVector = {
                x = l_math.cos(Phi)*l_math.cos(Theta),
                z = l_math.cos(Phi)*l_math.sin(Theta),
                y = l_math.sin(Phi)
            }
        return unitVector
    end

    function HOUND.Utils.Vector.getRandomVec2(variance)
        if variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = pi_2 * l_math.random()
        local epsilon = HOUND.Utils.Vector.getUnitVector(Theta)
        for axis,value in pairs(epsilon) do
            epsilon[axis] = value * Magnitude
        end
        return epsilon
    end

    function HOUND.Utils.Vector.getRandomVec3(variance)
        if variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = pi_2 * l_math.random()
        local Phi = pi_2 * l_math.random()

        local epsilon = HOUND.Utils.Vector.getUnitVector(Theta,Phi)
        for axis,value in pairs(epsilon) do
            epsilon[axis] = value * Magnitude
        end
        return epsilon
    end

    function HOUND.Utils.Zone.listDrawnZones()
        local zoneNames = {}
        local base = _G.env.mission
        if not base or not base.drawings or not base.drawings.layers then return zoneNames end
        for _,drawLayer in pairs(base.drawings.layers) do
            if type(drawLayer["objects"]) == "table" then
                for _,drawObject in pairs(drawLayer["objects"]) do
                    if drawObject["primitiveType"] == "Polygon" and (setContainsValue({"free","rect","oval"},drawObject["polygonMode"])) then
                        table.insert(zoneNames,drawObject["name"])
                    end
                end
            end
        end
        return zoneNames
    end

    function HOUND.Utils.Zone.getDrawnZone(zoneName)
        if type(zoneName) ~= "string" then return nil end
        if not _G.env.mission.drawings or not _G.env.mission.drawings.layers then return nil end
        for _,drawLayer in pairs(_G.env.mission.drawings.layers) do
            if type(drawLayer["objects"]) == "table" then
                for _,drawObject in pairs(drawLayer["objects"]) do
                    if drawObject["name"] == zoneName and drawObject["primitiveType"] == "Polygon" then
                        local points = {}
                        local theta = nil
                        if drawObject["polygonMode"] == "free" and Length(drawObject["points"]) >2 then
                            points = l_mist.utils.deepCopy(drawObject["points"])
                            table.remove(points)
                        end
                        if drawObject["polygonMode"] == "rect" then
                            theta = l_math.rad(drawObject["angle"])
                            local w,h = drawObject["width"],drawObject["height"]

                            table.insert(points,{x=h/2,y=w/2})
                            table.insert(points,{x=-h/2,y=w/2})
                            table.insert(points,{x=-h/2,y=-w/2})
                            table.insert(points,{x=h/2,y=-w/2})
                        end
                        if drawObject["polygonMode"] == "oval" then
                            theta = l_math.rad(drawObject["angle"])
                            local r1,r2 = drawObject["r1"],drawObject["r2"]
                            local numPoints = 16
                            local angleStep = pi_2/numPoints

                            for i = 1, numPoints do
                                local pointAngle = i * angleStep
                                local x = r1 * l_math.cos(pointAngle)
                                local y = r2 * l_math.sin(pointAngle)
                                table.insert(points,{x=x,y=y})
                            end
                        end
                        if theta then
                            for _,point in pairs(points) do
                                local x = point.x
                                local y = point.y
                                point.x = x * l_math.cos(theta) - y * l_math.sin(theta)
                                point.y = x * l_math.sin(theta) + y * l_math.cos(theta)
                            end
                        end
                        if Length(points) < 3 then return nil end
                        local objectX,objecty = drawObject["mapX"],drawObject["mapY"]
                        for _,point in pairs(points) do
                            point.x = point.x + objectX
                            point.y = point.y + objecty
                        end
                        return points
                    end
                end
            end
        end
        return nil
    end

    function HOUND.Utils.Polygon.threatOnSector(polygon,point, radius)
        if type(polygon) ~= "table" or Length(polygon) < 3 or not HOUND.Utils.Geo.isDcsPoint(l_mist.utils.makeVec3(polygon[1])) then
            return
        end
        if not HOUND.Utils.Geo.isDcsPoint(point) then
            return
        end
        local inPolygon = l_mist.pointInPolygon(point,polygon)
        local intersectsPolygon = inPolygon

        if radius ~= nil and radius > 0 and l_mist.shape ~= nil then
            local circle={point=point,radius=radius}
            intersectsPolygon = l_mist.shape.insideShape(circle,polygon)
        end
        return inPolygon,intersectsPolygon
    end

    function HOUND.Utils.Polygon.filterPointsByPolygon(points,polygon)
        local filteredPoints = {}
        if type(points) ~= "table" or type(polygon) ~= "table" then return filteredPoints end

        for _,point in pairs(points) do
            if l_mist.pointInPolygon(point,polygon) then
                table.insert(filteredPoints,point)
            end
        end
        return filteredPoints
    end

    function HOUND.Utils.Polygon.clipPolygons(subjectPolygon, clipPolygon)
        local function inside (p, cp1, cp2)
            return (cp2.x-cp1.x)*(p.z-cp1.z) > (cp2.z-cp1.z)*(p.x-cp1.x)
        end

        local function intersection (cp1, cp2, s, e)
            local dcx, dcz = cp1.x-cp2.x, cp1.z-cp2.z
            local dpx, dpz = s.x-e.x, s.z-e.z
            local n1 = cp1.x*cp2.z - cp1.z*cp2.x
            local n2 = s.x*e.z - s.z*e.x
            local n3 = 1 / (dcx*dpz - dcz*dpx)
            local x = (n1*dpx - n2*dcx) * n3
            local z = (n1*dpz - n2*dcz) * n3
            return {x=x, z=z}
        end

        if type(subjectPolygon) ~= "table" or type(clipPolygon) ~= "table" then return end

        local outputList = subjectPolygon
        local cp1 = clipPolygon[#clipPolygon]
        for _, cp2 in ipairs(clipPolygon) do  -- WP clipEdge is cp1,cp2 here
        local inputList = outputList
        outputList = {}
        local s = inputList[#inputList]
        for _, e in ipairs(inputList) do
            if inside(e, cp1, cp2) then
            if not inside(s, cp1, cp2) then
                outputList[#outputList+1] = intersection(cp1, cp2, s, e)
            end
            outputList[#outputList+1] = e
            elseif inside(s, cp1, cp2) then
            outputList[#outputList+1] = intersection(cp1, cp2, s, e)
            end
            s = e
        end
        cp1 = cp2
        end
        if Length(outputList) > 0 then
            return outputList
        end
        return nil
    end

    function HOUND.Utils.Polygon.giftWrap(points)
        local function signedArea(p, q, r)
            local cross = (q.z - p.z) * (r.x - q.x)
                        - (q.x - p.x) * (r.z - q.z)
            return cross
        end
        local function isCCW(p, q, r) return signedArea(p, q, r) < 0 end

        local numPoints = #points
        if numPoints < 3 then
            return
        end

        local leftMostPointIndex = 1
        for i = 1, numPoints do
            if points[i].x < points[leftMostPointIndex].x then
                leftMostPointIndex = i
            end
        end

        local p = leftMostPointIndex
        local hull = {} -- The convex hull to be returned

        repeat
            local q = points[p + 1] and p + 1 or 1
            for i = 1, numPoints, 1 do
                if isCCW(points[p], points[i], points[q]) then q = i end
            end

            table.insert(hull, points[q]) -- Save q to the hull
            p = q  -- p is now q for the next iteration
        until (p == leftMostPointIndex)

        return hull
    end

    function HOUND.Utils.Polygon.circumcirclePoints(points)
        local function calcCircle(p1,p2,p3)
            local cx,cz, r
            if HOUND.Utils.Geo.isDcsPoint(p1) and not p2 and not p3 then
                return {x = p1.x, z = p1.z,r = 0}
            end
            if HOUND.Utils.Geo.isDcsPoint(p1) and HOUND.Utils.Geo.isDcsPoint(p2) and not p3 then
                cx = 0.5 * (p1.x + p2.x)
                cz = 0.5 * (p1.z + p2.z)
            else
                local a = p2.x - p1.x
                local b = p2.z - p1.z
                local c = p3.x - p1.x
                local d = p3.z - p1.z
                local e = a * (p2.x + p1.x) * 0.5 + b * (p2.z + p1.z) * 0.5
                local f = c * (p3.x + p1.x) * 0.5 + d * (p3.z + p1.z) * 0.5
                local det = a * d - b * c

                cx = (d * e - b * f) / det
                cz = (-c * e + a * f) / det
            end

            r = l_math.sqrt((p1.x - cx) * (p1.x - cx) + (p1.z - cz) * (p1.z - cz))
            return {x=cx,z=cz,r=r}
        end

        local function isInCircle(p,c)
            return ((c.x - p.x) * (c.x - p.x) + (c.z - p.z) * (c.z - p.z) <= c.r * c.r)
        end

        local function shuffle(a)
            for i = #a, 2, -1 do
                local j = l_math.random(i)
                a[i], a[j] = a[j], a[i]
            end
            return a
        end

        local function mec(pts,n,boundary,b)
            local circle
            if b == 3 then
                circle = calcCircle(boundary[1],boundary[2],boundary[3])
            elseif (n == 1) and (b == 0) then circle = calcCircle(pts[1])
            elseif (n == 0) and (b == 2) then circle = calcCircle(boundary[1], boundary[2])
            elseif (n == 1) and (b == 1) then circle = calcCircle(boundary[1], pts[1])
            else
                circle = mec(pts, n-1, boundary, #boundary)
                if ( not isInCircle(pts[n], circle)) then
                    boundary[b+1] = pts[n]
                    circle = mec(pts, n-1, boundary, #boundary)
                end
            end
            return circle
        end

        local clonedPoints = l_mist.utils.deepCopy(points)
        shuffle(clonedPoints)
        return mec(clonedPoints, #points, {}, 0)
    end

    function HOUND.Utils.Polygon.getArea(polygon)
        if not polygon or type(polygon) ~= "table" or Length(polygon) < 2 then return 0 end
        local a,b = 0,0
        for i=1,Length(polygon)-1 do
            a = a + polygon[i].x * polygon[i+1].z
            b = b + polygon[i].z * polygon[i+1].x
        end
        a = a + polygon[Length(polygon)].x * polygon[1].z
        b = b + polygon[Length(polygon)].z * polygon[1].x
        return l_math.abs((a-b)/2)
    end

    function HOUND.Utils.Polygon.clipOrHull(polyA,polyB)
        if HOUND.Utils.Polygon.getArea(polyA) < HOUND.Utils.Polygon.getArea(polyB) then
            polyA,polyB = polyB,polyA
        end
        local polygon = HOUND.Utils.Polygon.clipPolygons(polyA,polyB)
        if Polygon == nil then
            local points = l_mist.utils.deepCopy(polyA)
            for _,point in pairs(polyB) do
                table.insert(points,l_mist.utils.deepCopy(point))
            end
            polygon = HOUND.Utils.Polygon.giftWrap(points)
        end
        return polygon
    end

    function HOUND.Utils.Polygon.azMinMax(poly,refPos)
        if not HOUND.Utils.Geo.isDcsPoint(refPos) or type(poly) ~= "table" or Length(poly) < 2 or l_mist.pointInPolygon(refPos,poly) then
            return
        end

        local points = l_mist.utils.deepCopy(poly)
        for _,pt in pairs(points) do
            pt.refAz = l_mist.utils.getDir(l_mist.vec.sub(pt,refPos))
        end

        table.sort(points,function (a,b) return (a.refAz+pi_2) < (b.refAz+pi_2) end)
        local leftMost = table.remove(points,1)
        local rightMost = table.remove(points)
        return HOUND.Utils.angleDeltaRad(leftMost.refAz,rightMost.refAz),(leftMost),(rightMost)
    end

    function HOUND.Utils.Cluster.gaussianKernel(value,bandwidth)
        return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((value / bandwidth))^2)
    end

    function HOUND.Utils.Cluster.stdDev()
        local instance = {}
        instance.count = 0
        instance.mean = 0
        instance.M2 = 0
        instance.update = function(self,value)
            self.count = self.count + 1
            local delta = value - self.mean
            self.mean = self.mean + (delta / self.count)
            local delta2 = value - self.mean
            self.M2 = self.M2 + (delta * delta2)
        end
        instance.get = function (self)
            if self.count < 2 then return nil end
            return {
                mean = self.mean,
                variance = (self.M2/self.count),
                sampleVariance = (self.M2/(self.count-1))
            }
        end
        return instance
    end

    function HOUND.Utils.Cluster.weightedMean(origPoints,initPos,threashold,maxIttr)
        if type(origPoints) ~= "table" or not HOUND.Utils.Geo.isDcsPoint(origPoints[1]) then return end
        local points = HOUND.Utils.Geo.setHeight(l_mist.utils.deepCopy(origPoints))

        local current_mean = initPos
        if type(current_mean) == "boolean" and current_mean then
            current_mean = points[l_math.random(Length(points))]
        end
        if not HOUND.Utils.Geo.isDcsPoint(current_mean) then
            current_mean = l_mist.getAvgPoint(origPoints)
        end
        if not HOUND.Utils.Geo.isDcsPoint(current_mean) then return end
        threashold = threashold or 1
        maxIttr = maxIttr or 100
        local last_mean
        local ittr = 0
        local converged = false

        while not converged do
            last_mean = l_mist.utils.deepCopy(current_mean)
            local totalDist = 0
            local totalInvWeight = 0
            for _,point in pairs(points) do
                point.dist = l_mist.utils.get2DDist(last_mean,point)
                totalDist = totalDist + point.dist
            end
            for _,point in pairs(points) do
                point.w = 1/(point.dist/totalDist)
                totalInvWeight = totalInvWeight + point.w
            end

            for _,point in pairs(points) do
                local weight = point.w/totalInvWeight
                current_mean = l_mist.vec.add(current_mean,l_mist.vec.scalar_mult(l_mist.vec.sub(point,current_mean),weight))
            end
            ittr = ittr + 1
            converged = l_mist.utils.get2DDist(last_mean,current_mean) < threashold or ittr == maxIttr
        end
        HOUND.Utils.Geo.setHeight(current_mean)
        return l_mist.utils.deepCopy(current_mean)
    end

    function HOUND.Utils.Cluster.kmeans(data, nclusters, init)
        assert(nclusters > 0)
        assert(#data > nclusters)
        assert(init == "kmeans++" or init == "random")

        local diss = function(p, q)
          return math.pow(p.x - q.x, 2) + math.pow(p.z - q.z, 2)
        end

        local centers = {} -- clusters centroids
        if init == "kmeans++" then
          local K = 1

          local i = math.random(1, #data)
          centers[K] = {x = data[i].x, z = data[i].z}
          local D = {}

          while K < nclusters do

            local sum_D = 0.0
            for i = 1,#data do
              local min_d = D[i]
              local d = diss(data[i], centers[K])
              if min_d == nil or d < min_d then
                  min_d = d
              end
              D[i] = min_d
              sum_D = sum_D + min_d
            end

            sum_D = math.random() * sum_D
            for i = 1,#data do
              sum_D = sum_D - D[i]

              if sum_D <= 0 then
                K = K + 1
                centers[K] = {x = data[i].x, z = data[i].z}
                break
              end
            end
          end
        elseif init == "random" then
          for k = 1,nclusters do
            local i = math.random(1, #data)
            centers[k] = {x = data[i].x, z = data[i].z}
          end
        end

        local cluster = {} -- k-partition
        for i = 1,#data do cluster[i] = 0 end

        local J = function()
          local loss = 0.0
          for i = 1,#data do
            loss = loss + diss(data[i], centers[cluster[i]])
          end
          return loss
        end

        local updated = false
        repeat
          local card = {}
          for k = 1,nclusters do
            card[k] = 0.0
          end

          updated = false
          for i = 1,#data do
            local min_d, min_k = nil, nil

            for k = 1,nclusters do
              local d = diss(data[i], centers[k])

              if min_d == nil or d < min_d then
                min_d, min_k = d, k
              end
            end

            if min_k ~= cluster[i] then updated = true end

            cluster[i]  = min_k
            card[min_k] = card[min_k] + 1.0
          end

          for k = 1,nclusters do
            centers[k].x = 0.0
            centers[k].z = 0.0
          end

          for i = 1,#data do
            local k = cluster[i]

            centers[k].x = centers[k].x + (data[i].x / card[k])
            centers[k].z = centers[k].z + (data[i].z / card[k])
          end
        until updated == false
        HOUND.Utils.Geo.setHeight(centers)
        return centers, cluster, J()
      end

    function HOUND.Utils.Sort.ContactsByRange(a,b)
        if a.isEWR ~= b.isEWR then
          return b.isEWR and not a.isEWR
        end
        if a.maxWeaponsRange ~= b.maxWeaponsRange then
            return a.maxWeaponsRange > b.maxWeaponsRange
        end
        if a.detectionRange ~= b.detectionRange then
            return a.detectionRange > b.detectionRange
        end
        if a.typeAssigned ~= b.typeAssigned then
            return table.concat(a.typeAssigned) < table.concat(b.typeAssigned)
        end
        if a.typeName ~= b.typeName then
            return a.typeName < b.typeName
        end
        if a.first_seen ~= b.first_seen then
            return a.first_seen > b.first_seen
        end
        return a.uid < b.uid
    end

    function HOUND.Utils.Sort.ContactsById(a,b)
        if  a.uid ~= b.uid then
            return a.uid < b.uid
        end
        return a.maxWeaponsRange > b.maxWeaponsRange
    end

    function HOUND.Utils.Sort.sectorsByPriorityLowFirst(a,b)
        return a:getPriority() > b:getPriority()
    end

    function HOUND.Utils.Sort.sectorsByPriorityLowLast(a,b)
        return a:getPriority() < b:getPriority()
    end

    function HOUND.Utils.Filter.groupsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local groups = {}
        for groupName, groupData in pairs(l_mist.DBs.groupsByName) do
            local pos = string.find(groupName, prefix, 1, true)
            if pos and pos == 1 then
                local dcsObject = Group.getByName(groupName)
                if dcsObject then
                    groups[groupName] = dcsObject
                end
            end
        end
        return groups
    end

    function HOUND.Utils.Filter.unitsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local units = {}
        for unitName, unit in pairs(l_mist.DBs.unitsByName) do
            local pos = string.find(unitName, prefix, 1, true)
            local dcsUnit = Unit.getByName(unitName)
            if pos and pos == 1 and dcsUnit then
                units[unitName] = dcsUnit
            end
        end
        return units
    end

    function HOUND.Utils.Filter.staticObjectsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local objects = {}
        for objectName, unit in pairs(l_mist.DBs.unitsByName) do
            local pos = string.find(objectName, prefix, 1, true)
            local dcsObject = StaticObject.getByName(objectName)
            if pos and pos == 1 and dcsObject then
                objects[objectName] = dcsObject
            end
        end
        return objects
    end
end
do
    HOUND.EventHandler = {
        idx = 0,
        subscribers = {},
        _internalSubscribers = {}
    }

    HOUND.EventHandler.__index = HOUND.EventHandler

    function HOUND.EventHandler.addEventHandler(handler)
        if type(handler) == "table" then
            HOUND.EventHandler.subscribers[handler] = handler
        end
    end

    function HOUND.EventHandler.removeEventHandler(handler)
        HOUND.EventHandler.subscribers[handler] = nil
    end

    function HOUND.EventHandler.addInternalEventHandler(handler)
        if type(handler) == "table" then
            HOUND.EventHandler._internalSubscribers[handler] = handler
        end
    end

    function HOUND.EventHandler.removeInternalEventHandler(handler)
        if setContains(HOUND.EventHandler._internalSubscribers,handler) then
            HOUND.EventHandler._internalSubscribers[handler] = nil
        end
    end

    function HOUND.EventHandler.onHoundEvent(event)
        for _, handler in pairs(HOUND.EventHandler._internalSubscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                if handler and handler.settings then
                    handler:onHoundEvent(event)
                end
            end
        end
        for _, handler in pairs(HOUND.EventHandler.subscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                handler:onHoundEvent(event)
            end
        end
    end

    function HOUND.EventHandler.publishEvent(event)
        event.time = timer.getTime()
        HOUND.EventHandler.onHoundEvent(event)
    end

    function HOUND.EventHandler.getIdx()
        HOUND.EventHandler.idx = HOUND.EventHandler.idx + 1
        return  HOUND.EventHandler.idx
    end
end
do
    local l_math = math
    local PI_2 = 2*l_math.pi

    HOUND.Estimator = {}
    HOUND.Estimator.__index = HOUND.Estimator
    HOUND.Estimator.Kalman = {}

    function HOUND.Estimator.accuracyScore(err)
        local score = 0
        if type(err) == "number" then
            score = HOUND.Utils.Mapping.linear(err,0,100000,1,0,true)
            score = HOUND.Utils.Cluster.gaussianKernel(score,0.2)
        end
        if type(score) == "number" then
            return score
        else
            return 0
        end
    end

    function HOUND.Estimator.Kalman.posFilter()
        local Kalman = {}

        Kalman.P = {
            x = 0.5,
            z = 0.5
        }

        Kalman.estimated = {}

        Kalman.update = function(self,datapoint)
            if type(self.estimated.p) ~= "table" and HOUND.Utils.Geo.isDcsPoint(datapoint) then
                self.estimated.p = {
                    x = datapoint.x,
                    z = datapoint.z,
                    y = datapoint.y
                }
            end

            if type(datapoint.err.score) ~= "table" then
                return self.estimated.p
            end
            self.P.x = self.P.x + math.sqrt(datapoint.err.score.x)
            self.P.z = self.P.z + math.sqrt(datapoint.err.score.z)

            local Kx = self.P.x / (self.P.x+(datapoint.err.score.x))
            local Kz = self.P.z / (self.P.z+(datapoint.err.score.z))

            self.estimated.p.x = self.estimated.p.x + (Kx * (datapoint.x-self.estimated.p.x))
            self.estimated.p.z = self.estimated.p.z + (Kz * (datapoint.z-self.estimated.p.z))

            self.P.x = (1-Kx) * self.P.x
            self.P.z = (1-Kz) * self.P.z

            self.estimated.p = HOUND.Utils.Geo.setHeight(self.estimated.p)
            return self.estimated.p
        end

        Kalman.get = function(self)
            return self.estimated.p
        end

        return Kalman
    end

    function HOUND.Estimator.Kalman.AzFilter(noise)
        local Kalman = {}
        Kalman.P = 0.5
        Kalman.noise = noise

        Kalman.estimated = nil

        Kalman.update = function (self,newAz,predictedAz,processNoise)
            if not self.estimated then
                self.estimated = newAz
            end
            local predAz = self.estimated
            local noiseP = self.noise
            if type(predictedAz) == "number" then
                predAz = predictedAz
            end
            if type(processNoise) == "number" then
                noiseP = processNoise
            end

            self.P = self.P + l_math.sqrt(noiseP) -- add "process noise" in the form of standard diviation
            local K = self.P / (self.P+self.noise)
            local deltaAz = newAz-predAz
            self.estimated = ((self.estimated + K * (deltaAz)) + PI_2) % PI_2
            self.P = (1-K) * self.P
        end

        Kalman.get = function (self)
            return self.estimated
        end

        return Kalman
    end

    function HOUND.Estimator.Kalman.AzElFilter()
        local Kalman = {}
        Kalman.K = {
            Az = 0,
            El = 0
        }
        Kalman.P = {
            Az = 1,
            El = 1
        }
        Kalman.estimated = {
            pos = nil,
            Az = nil,
            El = nil
        }

        Kalman.reset = function(self)
            self.P = {
                Az = 1,
                El = 1
            }
        end

        Kalman.update = function(self,datapoint)
            if not self.estimated.pos and datapoint:getPos() then
                self.estimated.Az = (1/self.P.Az) * datapoint.az
                self.estimated.El = (1/self.P.El) * datapoint.el
                self.estimated.pos = HOUND.Utils.Geo.getProjectedIP(datapoint.platformPos,self.estimated.Az,self.estimated.El)
                return self.estimated
            end
            local prediction = self:predict(datapoint)

            local errEstimate = {
                Az = datapoint.platformPrecision,
                El = datapoint.platformPrecision
            }

            self.K.Az = self.P.Az / (self.P.Az+errEstimate.Az)
            self.K.El = self.P.El / (self.P.El+errEstimate.El)

            self.estimated.Az = self.estimated.Az + (self.K.Az * (datapoint.az-prediction.Az))
            self.estimated.El = self.estimated.El + (self.K.El * (datapoint.el-prediction.El))
            self.estimated.pos = HOUND.Utils.Geo.getProjectedIP(datapoint.platformPos,self.estimated.Az,self.estimated.El)

            self.P.Az = (1-self.K.Az)
            self.P.El = (1-self.K.El)

            return self.estimated
        end

        Kalman.predict = function(self,datapoint)
            local prediction = {}
            prediction.Az,prediction.El = HOUND.Utils.Elint.getAzimuth( datapoint.platformPos , self.estimated.pos, 0 )
            return prediction
        end

        Kalman.getValue = function(self)
            return self.estimated
        end

        return Kalman
    end
end
do
    local l_math = math
    local l_mist = mist
    local PI_2 = 2*l_math.pi

    HOUND.Datapoint = {}
    HOUND.Datapoint.__index = HOUND.Datapoint
    HOUND.Datapoint.DataPointId = 0

    function HOUND.Datapoint.New(platform0, p0, az0, el0, t0, angularResolution, isPlatformStatic)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HOUND.Datapoint)
        elintDatapoint.platformPos = p0
        elintDatapoint.az = az0
        elintDatapoint.el = el0
        elintDatapoint.t = tonumber(t0)
        elintDatapoint.platformId = platform0:getID()
        elintDatapoint.platformName = platform0:getName()
        elintDatapoint.platformStatic = isPlatformStatic or false
        elintDatapoint.platformPrecision = angularResolution or l_math.rad(20)
        elintDatapoint.estimatedPos = elintDatapoint:estimatePos()
        elintDatapoint.posPolygon = {}
        elintDatapoint.posPolygon["2D"],elintDatapoint.posPolygon["3D"],elintDatapoint.posPolygon["EllipseParams"] = elintDatapoint:calcPolygons()
        elintDatapoint.kalman = nil
        elintDatapoint.processed = false
        if elintDatapoint.platformStatic then
            elintDatapoint.kalman = HOUND.Estimator.Kalman.AzFilter(elintDatapoint.platformPrecision)
            elintDatapoint:update(elintDatapoint.az)
        end
        if HOUND.DEBUG then
            elintDatapoint.id = elintDatapoint.getId()
        end
        return elintDatapoint
    end

    function HOUND.Datapoint.isStatic(self)
        return self.platformStatic
    end

    function HOUND.Datapoint.getPos(self)
        return self.estimatedPos
    end

    function HOUND.Datapoint.getAge(self)
        return HOUND.Utils.absTimeDelta(self.t)
    end

    function HOUND.Datapoint.get2dPoly(self)
        return self.posPolygon['2D']
    end

    function HOUND.Datapoint.get3dPoly(self)
        return self.posPolygon['3D']
    end

    function HOUND.Datapoint.getEllipseParams(self)
        return self.posPolygon['EllipseParams']
    end

    function HOUND.Datapoint.getErrors(self)
        if type(self.err) ~= "table" then
            self:calcError()
        end
        return self.err
    end

    function HOUND.Datapoint.estimatePos(self)
        if self.el == nil or l_math.abs(self.el) <= self.platformPrecision then return end
        return HOUND.Utils.Geo.getProjectedIP(self.platformPos,self.az,self.el)
    end

    function HOUND.Datapoint.calcPolygons(self)
        if self.platformPrecision == 0 then return nil,nil end
        local maxSlant = HOUND.Utils.Geo.EarthLOS(self.platformPos.y)*1.2
        local poly2D = {}
        table.insert(poly2D,self.platformPos)
        for _,theta in ipairs({((self.az - self.platformPrecision + PI_2) % PI_2),((self.az + self.platformPrecision + PI_2) % PI_2) }) do
            local point = {}
            point.x = maxSlant*l_math.cos(theta) + self.platformPos.x
            point.z = maxSlant*l_math.sin(theta) + self.platformPos.z
            table.insert(poly2D,point)
        end
        HOUND.Utils.Geo.setHeight(poly2D)

        if self.el == nil then return poly2D end
        local poly3D = {}
        local ellipse = {
            theta = self.az
        }

        local numSteps = 16
        local angleStep = PI_2/numSteps
        for i = 1,numSteps do
            local pointAngle = (i*angleStep)
            local azStep = self.az + (self.platformPrecision * l_math.sin(pointAngle))
            local elStep = self.el + (self.platformPrecision * l_math.cos(pointAngle))
            local point = HOUND.Utils.Geo.getProjectedIP(self.platformPos, azStep,elStep) or {x=maxSlant*l_math.cos(azStep) + self.platformPos.x,z=maxSlant*l_math.sin(azStep) + self.platformPos.z}
            if not point.y then
                point = HOUND.Utils.Geo.setHeight(point)
            end

            if HOUND.Utils.Geo.isDcsPoint(point) and HOUND.Utils.Geo.isDcsPoint(self:getPos()) then
                table.insert(poly3D,point)
                if i == numSteps/4 then
                    ellipse.minor = point
                elseif i == numSteps/2 then
                    ellipse.major = point
                    ellipse.majorCG = l_mist.utils.get2DDist(self:getPos(),point)
                elseif i == 3*(numSteps/4) then
                    if HOUND.Utils.Geo.isDcsPoint(ellipse.minor) then
                        ellipse.minor = l_mist.utils.get2DDist(ellipse.minor,point)
                    end
                elseif i == numSteps then
                    if HOUND.Utils.Geo.isDcsPoint(ellipse.major) then
                        ellipse.major = l_mist.utils.get2DDist(ellipse.major,point)
                        ellipse.majorCG = ellipse.majorCG / (ellipse.majorCG + l_mist.utils.get2DDist(self:getPos(),point))
                    end
                end
            end
        end
        if type(ellipse.minor) ~= "number" or type(ellipse.major) ~= "number" then
            ellipse = {}
        end
        return poly2D,poly3D,ellipse
    end

    function HOUND.Datapoint.calcError(self)
        if type(self.posPolygon["EllipseParams"]) == "table" and self.posPolygon["EllipseParams"].theta then
        local ellipse = self.posPolygon['EllipseParams']
        if ellipse.theta then
            local sinTheta = l_math.sin(ellipse.theta)
            local cosTheta = l_math.cos(ellipse.theta)
            self.err = {
                x = l_math.max(l_math.abs(ellipse.minor/2*cosTheta), l_math.abs(-ellipse.major/2*sinTheta)),
                z = l_math.max(l_math.abs(ellipse.minor/2*sinTheta), l_math.abs(ellipse.major/2*cosTheta))
            }
            self.err.score = {
                x = HOUND.Estimator.accuracyScore(self.err.x),
                z = HOUND.Estimator.accuracyScore(self.err.z)
            }
        end

        end
    end
    function HOUND.Datapoint.update(self,newAz,predictedAz,processNoise)
        if not self.platformPrecision and not self.platformStatic then return end
        self.kalman:update(newAz,nil,processNoise)
        self.az = self.kalman:get()
        self.posPolygon["2D"],self.posPolygon["3D"] = self:calcPolygons()
        return self.az
    end

    function HOUND.Datapoint.getId()
        HOUND.Datapoint.DataPointId = HOUND.Datapoint.DataPointId + 1
        return HOUND.Datapoint.DataPointId
    end
end
do
    HOUND.Contact = {}
    HOUND.Contact.__index = HOUND.Contact

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    function HOUND.Contact.New(DCS_Unit,HoundCoalition,ContactId)
        if not DCS_Unit or type(DCS_Unit) ~= "table" or not DCS_Unit.getName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact instance")
            return
        end
        local elintcontact = {}
        setmetatable(elintcontact, HOUND.Contact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = ContactId or DCS_Unit:getID()
        elintcontact.DCStypeName = DCS_Unit:getTypeName()
        elintcontact.DCSgroupName = Group.getName(DCS_Unit:getGroup())
        elintcontact.DCSunitName = DCS_Unit:getName()
        elintcontact.typeName = DCS_Unit:getTypeName()
        elintcontact.isEWR = false
        elintcontact.typeAssigned = {"Unknown"}
        elintcontact.band = "C"

        local contactUnitCategory = DCS_Unit:getDesc()["category"]
        if contactUnitCategory and contactUnitCategory == Unit.Category.SHIP then
            elintcontact.band = "E"
            elintcontact.typeAssigned = {"Naval"}
        end

        local contactData = HOUND.DB.getRadarData(elintcontact.DCStypeName)
        if contactData  then
            elintcontact.typeName =  contactData.Name
            elintcontact.isEWR = contactData.isEWR
            elintcontact.typeAssigned = contactData.Assigned
            elintcontact.band = contactData.Band
        end

        elintcontact.pos = {
            p = nil,
            grid = nil,
            LL = {
                lat = nil,
                lon = nil,
            },
            be = {
                brg = nil,
                rng = nil
            }
        }
        elintcontact.uncertenty_data = nil
        elintcontact.last_seen = timer.getAbsTime()
        elintcontact.first_seen = timer.getAbsTime()
        elintcontact.maxWeaponsRange = HOUND.Utils.getSamMaxRange(DCS_Unit)
        elintcontact.detectionRange = HOUND.Utils.getRadarDetectionRange(DCS_Unit)
        elintcontact._dataPoints = {}
        elintcontact._markpoints = {
            p = HOUND.Utils.Marker.create(),
            u = HOUND.Utils.Marker.create()
        }
        elintcontact._platformCoalition = HoundCoalition
        elintcontact.primarySector = "default"
        elintcontact.threatSectors = {
            default = true
        }
        elintcontact.detected_by = {}
        elintcontact.state = HOUND.EVENTS.RADAR_NEW
        elintcontact.preBriefed = false
        elintcontact.unitAlive = true
        elintcontact._kalman = HOUND.Estimator.Kalman.posFilter()
        return elintcontact
    end

    function HOUND.Contact:destroy()
        self:removeMarkers()
    end

    function HOUND.Contact:getName()
        return self:getType() .. " " .. self:getId()
    end

    function HOUND.Contact:getType()
        return self.typeName
    end

    function HOUND.Contact:getId()
        return self.uid%100
    end

    function HOUND.Contact:getGroupName()
        return self.DCSgroupName
    end

    function HOUND.Contact:getDcsName()
        return self.DCSunitName
    end

    function HOUND.Contact:getDCSObject()
        return self.unit or self.DCSunitName
    end
    function HOUND.Contact:getLastSeen()
        return HOUND.Utils.absTimeDelta(self.last_seen)
    end
    function HOUND.Contact:getTrackId()
        local trackType = 'E'
        if self.preBriefed then
            trackType = 'I'
        end
        return string.format("%s-%d",trackType,self.uid)
    end
    function HOUND.Contact:getNatoDesignation()
        local natoDesignation = string.gsub(self:getTypeAssigned(),"(SA)-",'')
            if natoDesignation == "Naval" then
                natoDesignation = self:getType()
            end
        return natoDesignation
    end

    function HOUND.Contact:getPos()
        return self.pos.p
    end

    function HOUND.Contact:getElev()
        if not self:hasPos() then return 0 end
        local step = 50
        if self:isAccurate() then
            step = 1
        end
        return HOUND.Utils.getRoundedElevationFt(self.pos.elev,step)
    end

    function HOUND.Contact:getUnit()
        return self.unit
    end
    function HOUND.Contact:hasPos()
        return HOUND.Utils.Geo.isDcsPoint(self.pos.p)
    end

    function HOUND.Contact:getMaxWeaponsRange()
        return self.maxWeaponsRange
    end

    function HOUND.Contact:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end

    function HOUND.Contact:getLife()
        if self:isAlive() and (not self.unit or not self.unit.getLife) then
            HOUND.Logger.error("something is wrong with the object for " .. self.DCSunitName)
            self:updateDeadDCSObject()
        end
        if type(self.unit) == "table" and self.unit.getLife then
            return self.unit:getLife()
        end
        return 0
    end
    function HOUND.Contact:isAlive()
        return self.unitAlive
    end

    function HOUND.Contact:setDead()
        self.unitAlive = false
        self:updateDeadDCSObject()
    end

    function HOUND.Contact:updateDeadDCSObject()
        self.unit = Unit.getByName(self.DCSunitName) or Object.getByName(self.DCSunitName)
        if not self.unit then
            self.unit = self.DCSunitName
        end
    end

    function HOUND.Contact:isActive()
        return self:getLastSeen()/16 < 1.0
    end

    function HOUND.Contact:isRecent()
        return self:getLastSeen()/120 < 1.0
    end

    function HOUND.Contact:isAccurate()
        return self.preBriefed
    end

    function HOUND.Contact:isTimedout()
        return self:getLastSeen() > HOUND.CONTACT_TIMEOUT
    end

    function HOUND.Contact:getState()
        return self.state
    end

    function HOUND.Contact:CleanTimedout()
        if self:isTimedout() then
            self._dataPoints = {}
            self.state = HOUND.EVENTS.RADAR_ASLEEP
        end
        return self.state
    end

    function HOUND.Contact:countPlatforms(skipStatic)
        local count = 0
        if Length(self._dataPoints) == 0 then return count end
        for _,platformDataPoints in pairs(self._dataPoints) do
            if not platformDataPoints[1].staticPlatform or (not skipStatic and platformDataPoints[1].staticPlatform) then
                count = count + 1
            end
        end
        return count
    end

    function HOUND.Contact:countDatapoints()
        local count = 0
        if Length(self._dataPoints) == 0 then return count end
        for _,platformDataPoints in pairs(self._dataPoints) do
            count = count + Length(platformDataPoints)
        end
        return count
    end

    function HOUND.Contact:AddPoint(datapoint)
        self.last_seen = datapoint.t
        if Length(self._dataPoints[datapoint.platformId]) == 0 then
            self._dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            if Length(self._dataPoints[datapoint.platformId]) == 0 then
                self._dataPoints[datapoint.platformId] = {datapoint}
                return
            end
            local predicted = {}
            if HOUND.Utils.Geo.isDcsPoint(self.pos.p) then
                predicted.az,predicted.el = HOUND.Utils.Elint.getAzimuth( datapoint.platformPos , self.pos.p, 0.0 )
                if type(self.uncertenty_data) == "table" and self.uncertenty_data.minor and self.uncertenty_data.major and self.uncertenty_data.az then
                    predicted.err = HOUND.Utils.Polygon.azMinMax(HOUND.Contact.calculatePoly(self.uncertenty_data,8,self.pos.p),datapoint.platformPos)
                end
            end
            self._dataPoints[datapoint.platformId][1]:update(datapoint.az,predicted.az,predicted.err)
            return
        end

        if Length(self._dataPoints[datapoint.platformId]) < 2 then
            table.insert(self._dataPoints[datapoint.platformId], 1, datapoint)
            return
        else
            local DeltaT = self._dataPoints[datapoint.platformId][2]:getAge() - datapoint:getAge()
            if  DeltaT >= HOUND.DATAPOINTS_INTERVAL then
                table.insert(self._dataPoints[datapoint.platformId], 1, datapoint)
            else
                self._dataPoints[datapoint.platformId][1] = datapoint
            end
        end

        for i=Length(self._dataPoints[datapoint.platformId]),1,-1 do
            if self._dataPoints[datapoint.platformId][i]:getAge() > HOUND.CONTACT_TIMEOUT then
                table.remove(self._dataPoints[datapoint.platformId])
            else
                i=1
            end
        end
        local pointsPerPlatform = l_math.ceil(HOUND.DATAPOINTS_NUM/self:countPlatforms(true))
        while Length(self._dataPoints[datapoint.platformId]) > pointsPerPlatform do
            table.remove(self._dataPoints[datapoint.platformId])
        end
    end

    function HOUND.Contact.triangulatePoints(earlyPoint, latePoint)
        local p1 = earlyPoint.platformPos
        local p2 = latePoint.platformPos

        local m1 = l_math.tan(earlyPoint.az)
        local m2 = l_math.tan(latePoint.az)

        local b1 = -m1 * p1.x + p1.z
        local b2 = -m2 * p2.x + p2.z

        local Easting = (b2 - b1) / (m1 - m2)
        local Northing = m1 * Easting + b1

        local pos = {}
        pos.x = Easting
        pos.z = Northing
        pos.y = land.getHeight({x=pos.x,y=pos.z})

        return pos
    end

    function HOUND.Contact.getDeltaSubsetPercent(Table,referencePos,NthPercentile)
        local t = l_mist.utils.deepCopy(Table)
        local len_t = Length(t)
        t = HOUND.Utils.Geo.setHeight(t)
        if not referencePos then
            referencePos = l_mist.getAvgPoint(t)
        end
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(len_t*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,len_t),percentile)
        local RelativeToPos = {}
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,l_mist.vec.sub(t[i],referencePos))
        end

        return RelativeToPos
    end

    function HOUND.Contact.calculateEllipse(estimatedPositions,giftWrapped,refPos)
        local percentile = HOUND.ELLIPSE_PERCENTILE
        if giftWrapped then percentile = 1.0 end
        local RelativeToPos = HOUND.Contact.getDeltaSubsetPercent(estimatedPositions,refPos,percentile)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        Theta = HOUND.Utils.PointClusterTilt(RelativeToPos)

        local sinTheta = l_math.sin(-Theta)
        local cosTheta = l_math.cos(-Theta)

        for k,pos in ipairs(RelativeToPos) do
            local newPos = {}
            newPos.x = pos.x*cosTheta - pos.z*sinTheta
            newPos.z = pos.x*sinTheta + pos.z*cosTheta
            newPos.y = pos.y

            min.x = l_math.min(min.x,newPos.x)
            max.x = l_math.max(max.x,newPos.x)
            min.y = l_math.min(min.y,newPos.z)
            max.y = l_math.max(max.y,newPos.z)

            RelativeToPos[k] = newPos
        end

        local a = l_mist.utils.round(l_math.abs(min.x)+l_math.abs(max.x))
        local b = l_mist.utils.round(l_math.abs(min.y)+l_math.abs(max.y))

        local uncertenty_data = {}
        uncertenty_data.major = l_math.max(a,b)
        uncertenty_data.minor = l_math.min(a,b)
        uncertenty_data.theta = (Theta + pi_2) % pi_2
        uncertenty_data.az = l_mist.utils.round(l_math.deg(uncertenty_data.theta))
        uncertenty_data.r  = (a+b)/4

        return uncertenty_data
    end

    function HOUND.Contact.calculateEllipseErrors(uncertenty_ellipse)
        if not uncertenty_ellipse.theta then return end
        local err = {}

        local sinTheta = l_math.sin(uncertenty_ellipse.theta)
        local cosTheta = l_math.cos(uncertenty_ellipse.theta)

        err.x = l_math.max(l_math.abs(uncertenty_ellipse.minor/2*cosTheta), l_math.abs(-uncertenty_ellipse.major/2*sinTheta))
        err.z = l_math.max(l_math.abs(uncertenty_ellipse.minor/2*sinTheta), l_math.abs(uncertenty_ellipse.major/2*cosTheta))

        err.score = {}
        err.score.x = HOUND.Estimator.accuracyScore(err.x)
        err.score.z = HOUND.Estimator.accuracyScore(err.z)
        return err
    end

    function HOUND.Contact.calculatePos(estimatedPositions,converge)
        if type(estimatedPositions) ~= "table" or Length(estimatedPositions) == 0 then return end
        local pos = l_mist.getAvgPoint(estimatedPositions)
        if converge then
            local subList = estimatedPositions
            local subsetPos = pos
            while (Length(subList) * HOUND.ELLIPSE_PERCENTILE) > 5 do
                local NewsubList = HOUND.Contact.getDeltaSubsetPercent(subList,subsetPos,HOUND.ELLIPSE_PERCENTILE)
                subsetPos = l_mist.getAvgPoint(NewsubList)

                pos.x = pos.x + (subsetPos.x )
                pos.z = pos.z + (subsetPos.z )
                subList = NewsubList
            end
        end
        pos.y = land.getHeight({x=pos.x,y=pos.z})
        return pos
    end

    function HOUND.Contact:calculatePosExtras(pos)
        if type(pos.p) == "table" and HOUND.Utils.Geo.isDcsPoint(pos.p) then
            local bullsPos = coalition.getMainRefPoint(self._platformCoalition)
            pos.LL = {}
            pos.LL.lat, pos.LL.lon = coord.LOtoLL(pos.p)
            pos.elev = pos.p.y
            pos.grid  = coord.LLtoMGRS(pos.LL.lat, pos.LL.lon)
            pos.be = HOUND.Utils.getBR(bullsPos,pos.p)
        end
        return pos
    end

    function HOUND.Contact:processIntersection(targetTable,point1,point2)
        local err = (point1.platformPrecision + point2.platformPrecision)/2
        if HOUND.Utils.angleDeltaRad(point1.az,point2.az) < err then return end
        local intersection = self.triangulatePoints(point1,point2)
        if not HOUND.Utils.Geo.isDcsPoint(intersection) then return end
        table.insert(targetTable,intersection)
    end

    function HOUND.Contact:processData()
        if self.preBriefed then
            if type(self.unit) == "table" and self.unit.isExist and self.unit:isExist() then
                local unitPos = self.unit:getPosition()
                if l_mist.utils.get3DDist(unitPos.p,self.pos.p) < 0.25 then return end
                self.preBriefed = false
            else return end
        end

        if not self:isRecent() then
            return self.state
        end

        local newContact = (self.state == HOUND.EVENTS.RADAR_NEW)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}
        local staticPlatformsOnly = true
        local staticClipPolygon2D = nil

        for _,platformDatapoints in pairs(self._dataPoints) do
            if Length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do
                    if datapoint:isStatic() then
                        table.insert(staticDataPoints,datapoint)
                        if type(datapoint:get2dPoly()) == "table" then
                            staticClipPolygon2D = HOUND.Utils.Polygon.clipPolygons(staticClipPolygon2D,datapoint:get2dPoly()) or datapoint:get2dPoly()
                        end
                    else
                        staticPlatformsOnly = false
                        table.insert(mobileDataPoints,datapoint)
                    end
                    if HOUND.Utils.Geo.isDcsPoint(datapoint:getPos()) then
                        local point = l_mist.utils.deepCopy(datapoint:getPos())
                        table.insert(estimatePositions,point)
                    end
                    platforms[datapoint.platformName] = 1
                end
            end
        end
        local numMobilepoints = Length(mobileDataPoints)
        local numStaticPoints = Length(staticDataPoints)

        if numMobilepoints+numStaticPoints < 2 and Length(estimatePositions) == 0 then return end
        if numStaticPoints > 1 then
            for i=1,numStaticPoints-1 do
                for j=i+1,numStaticPoints do
                    self:processIntersection(estimatePositions,staticDataPoints[i],staticDataPoints[j])
                end
            end
        end

        if numStaticPoints > 0  and numMobilepoints > 0 then
            for _,staticDataPoint in ipairs(staticDataPoints) do
                for _,mobileDataPoint in ipairs(mobileDataPoints) do
                    self:processIntersection(estimatePositions,staticDataPoint,mobileDataPoint)
                end
            end
         end

        if numMobilepoints > 1 then
            for i=1,numMobilepoints-1 do
                for j=i+1,numMobilepoints do
                    if mobileDataPoints[i].platformPos ~= mobileDataPoints[j].platformPos then
                        self:processIntersection(estimatePositions,mobileDataPoints[i],mobileDataPoints[j])
                    end
                end
                mobileDataPoints[i].processed = true
            end
        end

        if Length(estimatePositions) > 2 or (Length(estimatePositions) > 0 and staticPlatformsOnly) then
            self.pos.p = HOUND.Utils.Cluster.weightedMean(estimatePositions)
            self.uncertenty_data = self.calculateEllipse(estimatePositions,false,self.pos.p)

            if type(staticClipPolygon2D) == "table" and ( staticPlatformsOnly) then
                self.uncertenty_data = self.calculateEllipse(staticClipPolygon2D,true,self.pos.p)
            end

            self.uncertenty_data.az = l_mist.utils.round(l_math.deg((self.uncertenty_data.theta+l_mist.getNorthCorrection(self.pos.p)+pi_2)%pi_2))

            self:calculatePosExtras(self.pos)

            if self.state == HOUND.EVENTS.RADAR_ASLEEP then
                self.state = HOUND.EVENTS.SITE_ALIVE
            else
                self.state = HOUND.EVENTS.RADAR_UPDATED
            end

            local detected_by = {}

            for key,_ in pairs(platforms) do
                table.insert(detected_by,key)
            end
            self.detected_by = detected_by
        end

        if newContact and self.pos.p ~= nil and self.isEWR == false then
            self.state = HOUND.EVENTS.RADAR_DETECTED
            self:calculatePosExtras(self.pos)
        end

        return self.state
    end

    function HOUND.Contact:removeMarkers()
        for _,marker in pairs(self._markpoints) do
            marker:remove()
        end
    end

    function HOUND.Contact.calculatePoly(uncertenty_data,numPoints,refPos)
        local polygonPoints = {}
        if type(uncertenty_data) ~= "table" or not uncertenty_data.major or not uncertenty_data.minor or not uncertenty_data.az then
            return polygonPoints
        end
        if type(numPoints) ~= "number" then
            numPoints = 8
        end
        if not HOUND.Utils.Geo.isDcsPoint(refPos) then
            refPos = {x=0,y=0,z=0}
        end
        local angleStep = pi_2/numPoints
        local theta = l_math.rad(uncertenty_data.az)

        for i = 1, numPoints do
            local pointAngle = i * angleStep
            local point = {}
            point.x = uncertenty_data.major/2 * l_math.cos(pointAngle)
            point.z = uncertenty_data.minor/2 * l_math.sin(pointAngle)
            local x = point.x * l_math.cos(theta) - point.z * l_math.sin(theta)
            local z = point.x * l_math.sin(theta) + point.z * l_math.cos(theta)
            point.x = x + refPos.x
            point.z = z + refPos.z

            table.insert(polygonPoints, point)
        end
        HOUND.Utils.Geo.setHeight(polygonPoints)

        return polygonPoints

    end

    function HOUND.Contact:drawAreaMarker(numPoints)
        if numPoints == nil then numPoints = 1 end
        if numPoints ~= 1 and numPoints ~= 4 and numPoints ~=8 and numPoints ~= 16 then
            HOUND.Logger.error("DCS limitation, only 1,4,8 or 16 points are allowed")
            numPoints = 1
            end

        local alpha = HOUND.Utils.Mapping.linear(l_math.floor(HOUND.Utils.absTimeDelta(self.last_seen)),0,HOUND.CONTACT_TIMEOUT,0.2,0.05,true)
        local fillColor = {0,0,0,alpha}
        local lineColor = {0,0,0,0.30}
        if self._platformCoalition == coalition.side.BLUE then
            fillColor[1] = 1
            lineColor[1] = 1
        end

        if self._platformCoalition == coalition.side.RED then
            fillColor[3] = 1
            lineColor[3] = 1
        end

        local markArgs = {
            fillColor = fillColor,
            lineColor = lineColor,
            coalition = self._platformCoalition
        }
        if numPoints == 1 then
            markArgs.pos = {
                p = self.pos.p,
                r = self.uncertenty_data.r
            }
        else
            markArgs.pos = HOUND.Contact.calculatePoly(self.uncertenty_data,numPoints,self.pos.p)
        end
        return self._markpoints.u:update(markArgs)
    end

    function HOUND.Contact:updateMarker(MarkerType)
        if not self:hasPos() or self.uncertenty_data == nil or not self:isRecent() then return end
        if self:isAccurate() and self._markpoints.p:isDrawn() then return end
        local markerArgs = {
            text = self.typeName .. " " .. (self.uid%100),
            pos = self.pos.p,
            coalition = self._platformCoalition
        }
        if not self:isAccurate() then
            markerArgs.text = markerArgs.text .. " (" .. self.uncertenty_data.major .. "/" .. self.uncertenty_data.minor .. "@" .. self.uncertenty_data.az .. ")"
        end
        self._markpoints.p:update(markerArgs)

        if MarkerType == HOUND.MARKER.NONE or self:isAccurate() then
            if self._markpoints.u:isDrawn() then
                self._markpoints.u:remove()
            end
            return
        end

        if MarkerType == HOUND.MARKER.CIRCLE then
            self:drawAreaMarker()
        end

        if MarkerType == HOUND.MARKER.DIAMOND then
            self:drawAreaMarker(4)
        end

        if MarkerType == HOUND.MARKER.OCTAGON then
            self:drawAreaMarker(8)
        end

        if MarkerType == HOUND.MARKER.POLYGON then
            self:drawAreaMarker(16)
        end
    end

    function HOUND.Contact:getPrimarySector()
        return self.primarySector
    end

    function HOUND.Contact:getSectors()
        return self.threatSectors
    end

    function HOUND.Contact:isInSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    function HOUND.Contact:updateDefaultSector()
        self.threatSectors[self.primarySector] = true
        if self.primarySector == "default" then return end
        for k,v in pairs(self.threatSectors) do
            if k ~= "default" and v == true then
                self.threatSectors["default"] = false
                return
            end
        end
        self.threatSectors["default"] = true
    end

    function HOUND.Contact:updateSector(sectorName,inSector,threatsSector)
        if inSector == nil and threatsSector == nil then
            return
        end
        self.threatSectors[sectorName] = threatsSector or false

        if inSector and self.primarySector ~= sectorName then
            self.primarySector = sectorName
            self.threatSectors[sectorName] = true
        end
        self:updateDefaultSector()
    end

    function HOUND.Contact:addSector(sectorName)
        self.threatSectors[sectorName] = true
        self:updateDefaultSector()
    end

    function HOUND.Contact:removeSector(sectorName)
        if self.threatSectors[sectorName] then
            self.threatSectors[sectorName] = false
            self:updateDefaultSector()
        end
    end

    function HOUND.Contact:isThreatsSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    function HOUND.Contact:useUnitPos()
        if not self.unit:isExist() then
            HOUND.Logger.info("PB failed - unit does not exist")
            return
        end
        self.state = HOUND.EVENTS.RADAR_DETECTED
        if type(self.pos.p) == "table" then
            self.state = HOUND.EVENTS.RADAR_UPDATED
        end
        local unitPos = self.unit:getPosition()
        self.preBriefed = true

        self.pos.p = unitPos.p
        self:calculatePosExtras(self.pos)

        self.uncertenty_data = {}
        self.uncertenty_data.major = 0.1
        self.uncertenty_data.minor = 0.1
        self.uncertenty_data.az = 0
        self.uncertenty_data.r  = 0.1

        table.insert(self.detected_by,"External")
        self:updateMarker(HOUND.MARKER.NONE)
        return self.state
    end

    function HOUND.Contact:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DCSunitName = self.unit:getName()
        if self.pos.p ~= nil and self.uncertenty_data ~= nil then
            contact.pos = self.pos.p
            contact.LL = self.pos.LL

            contact.accuracy = HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
            contact.uncertenty = {
                major = self.uncertenty_data.major,
                minor = self.uncertenty_data.minor,
                heading = self.uncertenty_data.az
            }
        end
        contact.maxWeaponsRange = self.maxWeaponsRange
        contact.last_seen = self.last_seen
        contact.detected_by = self.detected_by
        return l_mist.utils.deepCopy(contact)
    end
end
do
    local l_math = math

    function HOUND.Contact:getTextData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local GridPos = ""
        if utmZone then
            GridPos = GridPos .. self.pos.grid.UTMZone .. " "
        end
        GridPos = GridPos .. self.pos.grid.MGRSDigraph
        local BE = self.pos.be.brStr .. "/" .. self.pos.be.rng
        if MGRSdigits == nil then
            return GridPos,BE
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        GridPos = GridPos .. " " .. E .. " " .. N

        return GridPos,BE
    end

    function HOUND.Contact:getTtsData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local phoneticGridPos = ""
        if utmZone then
            phoneticGridPos =  phoneticGridPos .. HOUND.Utils.TTS.toPhonetic(self.pos.grid.UTMZone) .. " "
        end

        phoneticGridPos =  phoneticGridPos ..  HOUND.Utils.TTS.toPhonetic(self.pos.grid.MGRSDigraph)
        local phoneticBulls = HOUND.Utils.TTS.toPhonetic(self.pos.be.brStr)
                                .. "  " .. self.pos.be.rng
        if MGRSdigits==nil then
            return phoneticGridPos,phoneticBulls
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        phoneticGridPos = phoneticGridPos .. " " .. HOUND.Utils.TTS.toPhonetic(E) .. "   " .. HOUND.Utils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end

    function HOUND.Contact:generateTtsBrief(NATO)
        if self.pos.p == nil or self.uncertenty_data == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = self:getNatoDesignation()
        end
        local str = reportedName
        if self:isAccurate() then
            str = str .. ", reported"
        else
            str = str .. ", " .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        end
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos
        end
        if not self:isAccurate() then
            str = str .. ", accuracy " .. HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
        end
        str = str .. "."
        return str
    end

    function HOUND.Contact:generateTtsReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HOUND.Utils.getBR(self.pos.p,refPos)
        end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,HOUND.MGRS_PRECISION)
        local msg =  self:getName()
        if self:isAccurate()
            then
                msg = msg .. ", reported"
            else
               msg = msg .. ", " .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true)
        end
        if BR ~= nil
            then
                msg = msg .. " from you " .. HOUND.Utils.TTS.toPhonetic(BR.brStr) .. " for " .. BR.rng
            else
                msg = msg .." at bullseye " .. phoneticBulls
        end
        local LLstr = HOUND.Utils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon,useDMM)
        msg = msg .. ", accuracy " .. HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
        msg = msg .. ", position " .. LLstr
        msg = msg .. ", I say again " .. LLstr
        msg = msg .. ", MGRS " .. phoneticGridPos
        msg = msg .. ", elevation  " .. self:getElev() .. " feet MSL"

        if HOUND.EXTENDED_INFO then
            if self:isAccurate()
                then
                    msg = msg .. ", Reported " .. HOUND.Utils.TTS.getVerbalContactAge(self.first_seen) .. " ago"
                else
                    msg = msg .. ", ellipse " ..  HOUND.Utils.TTS.simplfyDistance(self.uncertenty_data.major) .. " by " ..  HOUND.Utils.TTS.simplfyDistance(self.uncertenty_data.minor) .. ", aligned bearing " .. HOUND.Utils.TTS.toPhonetic(string.format("%03d",self.uncertenty_data.az))
                    msg = msg .. ", Tracked for " .. HOUND.Utils.TTS.getVerbalContactAge(self.first_seen) .. ", last seen " .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen) .. " ago"
                end
        end
        msg = msg .. ". " .. HOUND.Utils.getControllerResponse()
        return msg
    end

    function HOUND.Contact:generateTextReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HOUND.Utils.getBR(self.pos.p,refPos)
        end
        local msg =  self:getName()
        if self:isAccurate()
            then
                msg = msg .." (Reported)\n"
            else
                msg = msg .." (" .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true).. ")\n"
        end
        msg = msg .. "Accuracy: " .. HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ) .. "\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        if BR ~= nil then
            msg = msg .. "BR: " .. BR.brStr .. " for " .. BR.rng
        end
        msg = msg .. "LL: " .. HOUND.Utils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon,useDMM).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. self:getElev() .. "ft"
        if HOUND.EXTENDED_INFO then
            if self:isAccurate() then
                msg = msg .. "\nReported " .. HOUND.Utils.TTS.getVerbalContactAge(self.first_seen) .. " ago. "
            else
                msg = msg .. "\nEllipse: " ..  self.uncertenty_data.major .. " by " ..  self.uncertenty_data.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_data.az) .. "\n"
                msg = msg .. "Tracked for: " .. HOUND.Utils.TTS.getVerbalContactAge(self.first_seen) .. " Last Contact: " ..  HOUND.Utils.TTS.getVerbalContactAge(self.last_seen) .. " ago. "
            end
        end
        return msg
    end

    function HOUND.Contact:generateRadioItemText()
        if not self:hasPos() then return end
        local GridPos,BePos = self:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self:getName() .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end

    function HOUND.Contact:generatePopUpReport(isTTS,sectorName)
        local msg = self:getName() .. " is now Alive"

        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            if self:hasPos() then
                local GridPos,BePos
                if isTTS then
                    GridPos,BePos = self:getTtsData(true,1)
                    msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
                else
                    GridPos,BePos = self:getTextData(true,1)
                    msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
                end
            end
        end
        return msg .. "."
    end

    function HOUND.Contact:generateDeathReport(isTTS,sectorName)
        local msg = self:getName() .. " has been destroyed"
        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            if self:hasPos() then
                local GridPos,BePos
                if isTTS then
                    GridPos,BePos = self:getTtsData(true,1)
                    msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
                else
                    GridPos,BePos = self:getTextData(true,1)
                    msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
                end
            end
        end
        return msg .. "."
    end

    function HOUND.Contact:generateIntelBrief()
        local msg = ""
        if self:hasPos() then
            local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
            msg = {
                self:getTrackId(),self:getNatoDesignation(),self:getType(),
                HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true,true),
                BePos,string.format("%02.6f",self.pos.LL.lat),string.format("%03.6f",self.pos.LL.lon), GridPos,
                HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ),
                HOUND.Utils.Text.getTime(self.last_seen),self.DCStypeName,self.DCSunitName,self.DCSgroupName
            }
            msg = table.concat(msg,",")
        end
        return msg
    end
end
do
    HOUND.Comms.Manager = {}
    HOUND.Comms.Manager.__index = HOUND.Comms.Manager

    function HOUND.Comms.Manager:create(sector,houndConfig,settings)
        if (not houndConfig and type(houndConfig) ~= "table") or
            (not sector and type(sector) ~= "string") then
                HOUND.Logger.warn("[Hound] - Comm Controller could not be initilized, missing params")
                return nil
        end
        local CommsManager = {}
        setmetatable(CommsManager, HOUND.Comms.Manager)
        CommsManager.enabled = false
        CommsManager.transmitter = nil
        CommsManager.sector = nil
        CommsManager.houndConfig = houndConfig

        CommsManager._queue = {
            {},{},{}
        }

        CommsManager.settings = {
            freq = 250.000,
            modulation = "AM",
            volume = "1.0",
            name = "Hound",
            speed = 0,
            voice = nil,
            gender = nil,
            culture = nil,
            interval = 0.5
        }

        CommsManager.preferences = {
            enabletts = true,
            enabletext = false
        }

        if not STTS then
            CommsManager.preferences.enabletts = false
        end

        CommsManager.scheduler = nil

        if type(settings) == "table" and Length(settings) > 0 then
            CommsManager:updateSettings(settings)
        end
        return CommsManager
    end

    function HOUND.Comms.Manager:updateSettings(settings)
        for k,v in pairs(settings) do
            local k0 = tostring(k):lower()
            if setContainsValue({"enabletts","enabletext","alerts"},k0) then
                self.preferences[k0] = v
            else
                self.settings[k0] = v
            end
        end
    end
    function HOUND.Comms.Manager:enable()
        self.enabled = true
        if self.scheduler == nil then
            self.scheduler = timer.scheduleFunction(self.TransmitFromQueue, self, timer.getTime() + self.settings.interval)
        end
        self:startCallbackLoop()
    end

    function HOUND.Comms.Manager:disable()
        if self.scheduler then
            timer.removeFunction(self.scheduler)
            self.scheduler = nil
        end
        self:stopCallbackLoop()
        self.enabled = false
    end

    function HOUND.Comms.Manager:isEnabled()
        return self.enabled
    end

    function HOUND.Comms.Manager:getSettings(key)
        local k0 = tostring(key):lower()
        if setContainsValue({"enabletts","enabletext","alerts"},k0) then
            return self.preferences[tostring(key):lower()]
        else
            return self.settings[tostring(key):lower()]
        end
    end

    function HOUND.Comms.Manager:setSettings(key,value)
        local k0 = tostring(key):lower()
        if setContainsValue({"enabletts","enabletext","alerts"},k0) then
            self.preferences[k0] = value
        else
            self.settings[k0] = value
        end
    end

    function HOUND.Comms.Manager:enableText()
        self:setSettings("enableText",true)
    end

    function HOUND.Comms.Manager:disableText()
        self:setSettings("enableText",false)
    end

    function HOUND.Comms.Manager:enableTTS()
        if STTS ~= nil then
            self:setSettings("enableTTS",true)
        end
    end

    function HOUND.Comms.Manager:disableTTS()
        self:setSettings("enableTTS",false)
    end

    function HOUND.Comms.Manager:enableAlerts()
        self:setSettings("alerts",true)
    end

    function HOUND.Comms.Manager:disableAlerts()
        self:setSettings("alerts",false)
    end

    function HOUND.Comms.Manager:setTransmitter(transmitterName)
        if not transmitterName then transmitterName = "" end
        local candidate = Unit.getByName(transmitterName)
        if candidate == nil then
            candidate = StaticObject.getByName(transmitterName)
        end
        if candidate == nil and self.transmitter then
            self:removeTransmitter()
            return
        end
        if self.transmitter ~= candidate then
            self.transmitter = candidate
            HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_ADDED,
                    houndId = self.houndConfig:getId(),
                    initiator = self.sector,
                    transmitter = candidate
                })
        end
    end

    function HOUND.Comms.Manager:removeTransmitter()
        if self.transmitter ~= nil then
            self.transmitter = nil
            HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_REMOVED,
                    houndId = self.houndConfig:getId(),
                    initiator = self.sector
                })
        end
    end

    function HOUND.Comms.Manager:getCallsign()
        return self:getSettings("name")
    end

    function HOUND.Comms.Manager:setCallsign(callsign)
        if type(callsign) == "string" then
            self:setSettings("name",callsign)
        end
    end

    function HOUND.Comms.Manager:getFreq()
        return self:getFreqs()[1]
    end

    function HOUND.Comms.Manager:getFreqs()
        local freqs = string.split(self.settings.freq,",")
        local mod = string.split(self.settings.modulation,",")
        local retval = {}

        for i,freq in ipairs(freqs) do
            local str = string.format("%.3f",tonumber(freq)) .. " " .. (mod[i] or "AM")
            table.insert(retval,str)
        end
        return retval
    end

    function HOUND.Comms.Manager:addMessageObj(obj)
        if obj.coalition == nil or not self.enabled then return end
        if obj.txt == nil and obj.tts == nil then return end
        if obj.priority == nil or obj.priority > 3 then obj.priority = 3 end
        if obj.priority == "loop" then
            self.loop.msg = obj
            return
        end
        table.insert(self._queue[obj.priority],obj)
    end

    function HOUND.Comms.Manager:addMessage(coalition,msg,prio)
        if msg == nil or coalition == nil or ( type(msg) ~= "string" and string.len(tostring(msg)) <= 0) or not self.enabled then return end
        if prio == nil or prio > 3 then prio = 3 end

        local obj = {
            coalition = coalition,
            priority = prio,
            tts = msg
        }

        self:addMessageObj(obj)
    end

    function HOUND.Comms.Manager:addTxtMsg(coalition,msg,prio)
        if msg == nil or string.len(tostring(msg)) == 0 or coalition == nil  or not self.enabled then return end
        if prio == nil then prio = 1 end
        local obj = {
            coalition = coalition,
            priority = prio,
            txt = msg
        }
        self:addMessageObj(obj)
    end

    function HOUND.Comms.Manager:getNextMsg()
        for i,v in ipairs(self._queue) do
            if #v > 0 then return table.remove(self._queue[i],1) end
        end
    end

    function HOUND.Comms.Manager:getTransmitterPos()
        if self.transmitter == nil then return nil end
        if self.transmitter ~= nil and (self.transmitter:isExist() == false or self.transmitter:getLife() < 1) then
            return false
        end
        local pos = self.transmitter:getPoint()
        if self.transmitter:getCategory() == Object.Category.STATIC or self.transmitter:getDesc()["category"] == Unit.Category.GROUND_UNIT then
            pos.y = pos.y + self.transmitter:getDesc()["box"]["max"]["y"] + 5
        end
        return pos
    end

    function HOUND.Comms.Manager.TransmitFromQueue(gSelf)
        local msgObj = gSelf:getNextMsg()
        local readTime = gSelf.settings.interval
        if msgObj == nil then return timer.getTime() + readTime end
        local transmitterPos = gSelf:getTransmitterPos()

        if transmitterPos == false then
            env.info("[Hound] - Transmitter destroyed")
            HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_DESTROYED,
                    houndId = gSelf.houndConfig:getId(),
                    initiator = gSelf.sector,
                    transmitter = gSelf.transmitter
                })

            return timer.getTime() + 10
        end

        if gSelf.enabled and STTS ~= nil and msgObj.tts ~= nil and gSelf.preferences.enabletts then
            HOUND.Utils.TTS.Transmit(msgObj.tts,msgObj.coalition,gSelf.settings,transmitterPos)
            readTime = HOUND.Utils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed)
        end

        if gSelf.enabled and gSelf.preferences.enabletext and msgObj.txt ~= nil then
            readTime =  HOUND.Utils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed) or HOUND.Utils.TTS.getReadTime(msgObj.txt,gSelf.settings.speed)
            if msgObj.gid then
                if type(msgObj.gid) == "table" then
                    for _,gid in ipairs(msgObj.gid) do
                        trigger.action.outTextForGroup(gid,msgObj.txt,readTime+2)
                    end
                else
                    trigger.action.outTextForGroup(msgObj.gid,msgObj.txt,readTime+2)
                end
            else
                trigger.action.outTextForCoalition(msgObj.coalition,msgObj.txt,readTime+2)
            end
        end
        return timer.getTime() + readTime + gSelf.settings.interval
    end

    function HOUND.Comms.Manager:startCallbackLoop()
        return nil
    end

    function HOUND.Comms.Manager:stopCallbackLoop()
        return nil
    end

    function HOUND.Comms.Manager:SetMsgCallback()
        return nil
    end

    function HOUND.Comms.Manager:runCallback()
        return nil
    end
end

do

    HOUND.Comms.InformationSystem = {}
    HOUND.Comms.InformationSystem = inheritsFrom(HOUND.Comms.Manager)

    function HOUND.Comms.InformationSystem:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, HOUND.Comms.InformationSystem)
        self.__index = self

        instance.settings.freq = 250.500
        instance.settings.interval = 4
        instance.settings.speed = 1
        instance.preferences.reportewr = false

        if settings and type(settings) == "table" then
            instance:updateSettings(settings)
        end

        instance.callback = {
            scheduler = nil,
            func = nil,
            args = nil,
            interval = 300
        }

        instance.loop = {
            body = "",
            msg = nil,
            reportIdx = 'Z'
        }

        return instance
    end

    function HOUND.Comms.InformationSystem:reportEWR(state)
        if type(state) == "boolean" then
            self:setSettings("reportEWR",state)
        end
    end

    function HOUND.Comms.InformationSystem:startCallbackLoop()
        if self.enabled and not self.callback.scheduler then
            self.callback.scheduler = timer.scheduleFunction(self.runCallback, self, timer.getTime()+0.1)
        end
    end

    function HOUND.Comms.InformationSystem:stopCallbackLoop()
        if self.callback.scheduler then
            timer.removeFunction(self.callback.scheduler)
            self.callback.scheduler = nil
        end
        self.loop.msg = nil
        self.loop.header = ""
        self.loop.body = ""
        self.loop.footer = ""
        self.callback = {}
    end

    function HOUND.Comms.InformationSystem:SetMsgCallback(callback,args)
        if callback ~= nil and type(callback) == "function" then
            self.callback.func = callback
            self.callback.args = args
            self.callback.interval = self.houndConfig:getAtisUpdateInterval()
        end
        if self.callback.scheduler == nil and self.scheduler ~= nil then
            self.startCallbackLoop()
        end
    end

    function HOUND.Comms.InformationSystem:runCallback()
        local nextDelay = self.callback.interval or 300
        if self.callback ~= nil and type(self.callback.func) == "function"  then
            self.callback.func(self.callback.args,self.loop,self.preferences)
        end
        return timer.getTime() + nextDelay
    end

    function HOUND.Comms.InformationSystem:getNextMsg()
        if self.loop and not self.loop.msg then
            self:runCallback()
        end
        if self.loop and self.loop.msg and self.loop.msg.tts ~= nil and (string.len(self.loop.msg.tts) > 0 or string.len(self.loop.msg.txt) > 0) then
            return self.loop.msg
        end
    end
end

do

    HOUND.Comms.Controller = {}
    HOUND.Comms.Controller = inheritsFrom(HOUND.Comms.Manager)

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
do
    HOUND.Comms.Notifier = {}
    HOUND.Comms.Notifier = inheritsFrom(HOUND.Comms.Manager)

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
do
    HOUND.ElintWorker = {}
    HOUND.ElintWorker.__index = HOUND.ElintWorker

    local l_math = math
    function HOUND.ElintWorker.create(HoundInstanceId)
        local instance = {}
        instance.contacts = {}
        instance.platforms = {}
        instance.settings =  HOUND.Config.get(HoundInstanceId)
        instance.coalitionId = nil
        instance.TrackIdCounter = 0
        setmetatable(instance, HOUND.ElintWorker)
        return instance
    end

    function HOUND.ElintWorker:setCoalition(coalitionId)
        if not coalitionId then return false end
        if not self.settings:getCoalition() then
            self.settings:setCoalition(coalitionId)
            return true
        end
        return false
    end

    function HOUND.ElintWorker:getCoalition()
        return self.settings:getCoalition()
    end

    function HOUND.ElintWorker:addPlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if self:getCoalition() == nil and candidate ~= nil then
            self:setCoalition(candidate:getCoalition())
        end

        if candidate ~= nil and candidate:getCoalition() == self:getCoalition()
            and not setContainsValue(self.platforms,candidate) and HOUND.DB.isValidPlatform(candidate) then
                table.insert(self.platforms, candidate)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_ADDED,
                    initiator = candidate,
                    houndId = self.settings:getId(),
                    coalition = self.settings:getCoalition()
                })
                return true
        end
        HOUND.Logger.warn("[Hound] - Failed to add platform "..platformName..". Make sure you use unit name and that all requirments are met.")
        return false
    end

    function HOUND.ElintWorker:removePlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if candidate ~= nil then
            for k,v in ipairs(self.platforms) do
                if v == candidate then
                    table.remove(self.platforms, k)
                    HOUND.EventHandler.publishEvent({
                        id = HOUND.EVENTS.PLATFORM_REMOVED,
                        initiator = candidate,
                        houndId = self.settings:getId(),
                        coalition = self.settings:getCoalition()
                    })
                    return true
                end
            end
        end
        return false
    end

    function HOUND.ElintWorker:platformRefresh()
        if Length(self.platforms) < 1 then return end
        for id,platform in ipairs(self.platforms) do
            if platform:isExist() == false or platform:getLife() <1 then
                table.remove(self.platforms, id)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self.settings:getId(),
                    coalition = self.settings:getCoalition()
                })
            end
        end
    end

    function HOUND.ElintWorker:removeDeadPlatforms()
        if Length(self.platforms) < 1 then return end
        for id,platform in ipairs(self.platforms) do
            if platform:isExist() == false or platform:getLife() <1  or (platform:getCategory() ~= Object.Category.STATIC and platform:isActive() == false) then
                table.remove(self.platforms, id)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self.settings:getId(),
                    coalition = self.settings:getCoalition()
                })
            end
        end
    end

    function HOUND.ElintWorker:countPlatforms()
        return Length(self.platforms)
    end

    function HOUND.ElintWorker:listPlatforms()
        local platforms = {}
        for _,platform in ipairs(self.platforms) do
            table.insert(platforms,platform:getName())
        end
        return platforms
    end

    function HOUND.ElintWorker:getNewTrackId()
        self.TrackIdCounter = self.TrackIdCounter + 1
        return self.TrackIdCounter
    end

    function HOUND.ElintWorker:isContact(emitter)
        if emitter == nil then return false end
        local emitterName = nil
        if type(emitter) == "string" then
            emitterName = emitter
        end
        if type(emitter) == "table" and emitter.getName ~= nil then
            emitterName = emitter:getName()
        end
        return setContains(self.contacts,emitterName)
    end

    function HOUND.ElintWorker:addContact(emitter)
        if emitter == nil or emitter.getName == nil then return end
        local emitterName = emitter:getName()
        if self.contacts[emitterName] ~= nil then return emitterName end
        self.contacts[emitterName] = HOUND.Contact.New(emitter, self:getCoalition(), self:getNewTrackId())
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.RADAR_NEW,
            initiator = emitter,
            houndId = self.settings:getId(),
            coalition = self.settings:getCoalition()
        })
        return emitterName
    end

    function HOUND.ElintWorker:getContact(emitter,getOnly)
        if emitter == nil then return nil end
        local emitterName = nil
        if type(emitter) == "string" then
            emitterName = emitter
        end
        if type(emitter) == "table" and emitter.getName ~= nil then
            emitterName = emitter:getName()
        end

        if emitterName ~= nil and self.contacts[emitterName] ~= nil then return self.contacts[emitterName] end
        if not self.contacts[emitterName] and type(emitter) == "table" and not getOnly then
            self:addContact(emitter)
            return self.contacts[emitterName]
        end
        return nil
    end

    function HOUND.ElintWorker:removeContact(emitterName)
        if not type(emitterName) == "string" then return false end
        if self.contacts[emitterName] then
            self.contacts[emitterName]:updateDeadDCSObject()
            HOUND.EventHandler.publishEvent({
                id = HOUND.EVENTS.RADAR_DESTROYED,
                initiator = self.contacts[emitterName],
                houndId = self.settings:getId(),
                coalition = self.settings:getCoalition()
            })
        end

        self.contacts[emitterName] = nil
        return true
    end

    function HOUND.ElintWorker:setPreBriefedContact(emitter)
        if not emitter:isExist() then return end
        local contact = self:getContact(emitter)
        local contactState = contact:useUnitPos()
        if contactState then
            HOUND.EventHandler.publishEvent({
                id = contactState,
                initiator = contact,
                houndId = self.settings:getId(),
                coalition = self.settings:getCoalition()
            })
        end
    end

    function HOUND.ElintWorker:setDead(emitter)
        local contact = self:getContact(emitter,true)
        if contact then contact:setDead() end
    end
    function HOUND.ElintWorker:isTracked(emitter)
        if emitter == nil then return false end
        if type(emitter) =="string" and self.contacts[emitter] ~= nil then return true end
        if type(emitter) == "table" and emitter.getName ~= nil and self.contacts[emitter:getName()] ~= nil then return true end
        return false
    end

    function HOUND.ElintWorker:addDatapointToEmitter(emitter,datapoint)
        if not self:isTracked(emitter) then
            self:addContact(emitter)
        end
        local HoundContact = self:getContact(emitter)
        HoundContact:AddPoint(datapoint)
    end

    function HOUND.ElintWorker:listInSector(sectorName)
        local emitters = {}
        for _,emitter in ipairs(self.contacts) do
            if emitter:isInSector(sectorName) then
                table.insert(emitters,emitter)
            end
        end
        table.sort(emitters,HOUND.Utils.Sort.ContactsByRange)
        return emitters
    end

    function HOUND.ElintWorker:UpdateMarkers()
        if self.settings:getUseMarkers() then
            for _, contact in pairs(self.contacts) do
                contact:updateMarker(self.settings:getMarkerType())
            end
        end
    end

    function HOUND.ElintWorker:listAll(sectorName)
        if sectorName then
            local contacts = {}
            for _,emitter in pairs(self.contacts) do
                if emitter:isInSector(sectorName) then
                        table.insert(contacts,emitter)
                end
            end
            return contacts
        end
        return self.contacts
    end

    function HOUND.ElintWorker:listAllbyRange(sectorName)
        return self:sortContacts(HOUND.Utils.Sort.ContactsByRange,sectorName)
    end

    function HOUND.ElintWorker:countContacts(sectorName)
        if sectorName then
            local contacts = 0
            for _,contact in pairs(self.contacts) do
                if contact:isInSector(sectorName) then
                    contacts = contacts + 1
                end
            end
            return contacts
        end
        return Length(self.contacts)
    end

    function HOUND.ElintWorker:getContacts(sectorName)
        local contacts = {}
        for _,emitter in pairs(self.contacts) do
            if sectorName then
                if emitter:isInSector(sectorName) then
                    table.insert(contacts,emitter)
                end
            else
                table.insert(contacts,emitter)
            end
        end
        return contacts
    end

    function HOUND.ElintWorker:sortContacts(sortFunc,sectorName)
        if type(sortFunc) ~= "function" then return end
        local sorted = self:getContacts(sectorName)
        table.sort(sorted, sortFunc)
        return sorted
    end

    function HOUND.ElintWorker:Sniff()
        self:removeDeadPlatforms()

        if Length(self.platforms) == 0 then return end

        local Radars = HOUND.Utils.Elint.getActiveRadars(self:getCoalition())

        if Length(Radars) == 0 then return end
        for _,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + radar:getDesc()["box"]["max"]["y"] -- use vehicle bounting box for height

            for _,platform in ipairs(self.platforms) do
                local platformData = HOUND.DB.getPlatformData(platform)

                if HOUND.Utils.Geo.checkLOS(platformData.pos, radarPos) then
                    local contact = self:getContact(radar)
                    local sampleAngularResolution = HOUND.DB.getSensorPrecision(platform,contact.band)
                    if sampleAngularResolution < l_math.rad(10.0) then
                        local az,el = HOUND.Utils.Elint.getAzimuth( platformData.pos, radarPos, sampleAngularResolution )
                        if not platformData.isAerial then
                            el = nil
                        end

                        if not platform.isStatic and self.settings:getPosErr() then
                            for axis,value in pairs(platformData.pos) do
                                platformData.pos[axis] = value + platformData.posErr[axis]
                            end

                        end

                        local datapoint = HOUND.Datapoint.New(platform,platformData.pos, az, el, timer.getAbsTime(),sampleAngularResolution,platformData.isStatic)
                        contact:AddPoint(datapoint)
                    end
                end
            end
        end
    end

    function HOUND.ElintWorker:Process()
        if Length(self.contacts) < 1 then return end
        for contactName, contact in pairs(self.contacts) do
            if contact ~= nil then
                local contactState = contact:processData()

                if contactState == HOUND.EVENTS.RADAR_DETECTED then
                    if self.settings:getUseMarkers() then contact:updateMarker(self.settings:getMarkerType()) end
                end

                if contact:isTimedout() then
                    contactState = contact:CleanTimedout()
                end
                if self.settings:getBDA() and contact:isAlive() and contact:getLife() < 1 then
                    contact:setDead()
                end
                if not contact:isAlive() and contact:getLastSeen() > 60 then
                    self:removeContact(contactName)
                    contact:destroy()
                    return
                end

                if contactState then
                    HOUND.EventHandler.publishEvent({
                        id = contactState,
                        initiator = contact,
                        houndId = self.settings:getId(),
                        coalition = self.settings:getCoalition()
                    })
                end
            end
        end
    end
end
do
    HOUND.ContactManager = {
        _workers = {}
    }

    HOUND.ContactManager.__index = HOUND.ContactManager

    function HOUND.ContactManager.get(HoundInstanceId)
        if HOUND.ContactManager._workers[HoundInstanceId] then
            return HOUND.ContactManager._workers[HoundInstanceId]
        end

        local worker = HOUND.ElintWorker.create(HoundInstanceId)
        HOUND.ContactManager._workers[HoundInstanceId] = worker

        return HOUND.ContactManager._workers[HoundInstanceId]
    end
end
do
    local l_mist = mist
    local l_math = math
    HOUND.Sector = {}
    HOUND.Sector.__index = HOUND.Sector

    function HOUND.Sector.create(HoundId, name, settings, priority)
        if type(HoundId) ~= "number" or type(name) ~= "string" then
            HOUND.Logger.warn("[Hound] - HOUND.Sector.create() missing params")
            return
        end

        local instance = {}
        setmetatable(instance, HOUND.Sector)
        instance.name = name
        instance._hSettings = HOUND.Config.get(HoundId)
        instance._contacts = HOUND.ContactManager.get(HoundId)
        instance.callsign = "HOUND"
        instance.settings = {
            controller = nil,
            atis = nil,
            notifier = nil,
            transmitter = nil,
            zone = nil,
            hound_menu = nil
        }
        instance.comms = {
            controller = nil,
            atis = nil,
            notifier = nil,
            menu = {
                root = nil , enrolled = {}, check_in = {}, data = {},noData = nil
            }
        }
        instance.priority = priority or 10

        if settings ~= nil and type(settings) == "table" and Length(settings) > 0 then
            instance:updateSettings(settings)
        end
        if instance.name ~= "default" then
            instance:setCallsign(instance._hSettings:getUseNATOCallsigns())
        end
        return instance
    end

    function HOUND.Sector:updateSettings(settings)
        for k, v in pairs(settings) do
            local k0 = tostring(k):lower()
            if type(v) == "table" and
                setContainsValue({"controller", "atis", "notifier"}, k0) then
                if not self.settings[k0] then
                    self.settings[k0] = {}
                end
                for k1, v1 in pairs(v) do
                    self.settings[k0][tostring(k1):lower()] = v1
                end
                self.settings[k0]["name"] = self.callsign
            else
                self.settings[k0] = v
            end
        end
        self:updateServices()
    end

    function HOUND.Sector:destroy()
        self:removeRadioMenu()
        for _,contact in pairs(self._contacts:listAll()) do
            contact:removeSector(self.name)
        end
        return
    end

    function HOUND.Sector:updateServices()
        if type(self.settings.controller) == "table" then
            if not self.comms.controller then
                self.settings.controller.name = self.callsign
                self.comms.controller = HOUND.Comms.Controller:create(self.name,self._hSettings,self.settings.controller)
            else
                self.settings.controller.name = self.callsign
                self.comms.controller:updateSettings(self.settings.controller)
                self.comms.controller:setCallsign(self.callsign)

            end
        end
        if type(self.settings.atis) == "table" then
            if not self.comms.atis then
                self.settings.atis.name = self.callsign
                self.comms.atis = HOUND.Comms.InformationSystem:create(self.name,self._hSettings,self.settings.atis)
            else
                self.settings.atis.name = self.callsign
                self.comms.atis:updateSettings(self.settings.atis)
                self.comms.atis:setCallsign(self.callsign)
            end
        end
        if type(self.settings.notifier) == "table" then
            if not self.comms.notifier then
                self.settings.notifier.name = self.callsign
                self.comms.notifier = HOUND.Comms.Notifier:create(self.name,self._hSettings,self.settings.notifier)
            else
                self.settings.notifier.name = self.callsign
                self.comms.notifier:updateSettings(self.settings.notifier)
                self.comms.notifier:setCallsign(self.callsign)
            end
        end
        if self.settings.zone and type(self.settings.zone) ~= "table" then
            self:setZone(self.settings.zone)
        end
        if self.settings.transmitter then
            self:updateTransmitter()
        end
    end

    function HOUND.Sector:getName()
        return self.name
    end

    function HOUND.Sector:getPriority()
        return self.priority
    end

    function HOUND.Sector:setCallsign(callsign, NATO)
        local namePool = "GENERIC"
        if callsign ~= nil and type(callsign) == "boolean" then
            NATO = callsign
            callsign = nil
        end
        if NATO == true then namePool = "NATO" end

        callsign = string.upper(callsign or HOUND.Utils.getHoundCallsign(namePool))

        while setContainsValue(self._hSettings.callsigns, callsign) do
            callsign = HOUND.Utils.getHoundCallsign(namePool)
        end

        if self.callsign ~= nil or self.callsign ~= "HOUND" then
            for k, v in ipairs(self._hSettings.callsigns) do
                if v == self.callsign then
                    table.remove(self._hSettings.callsigns, k)
                end
            end
        end
        table.insert(self._hSettings.callsigns, callsign)
        self.callsign = callsign
        self:updateServices()
    end

    function HOUND.Sector:getCallsign()
        return self.callsign
    end

    function HOUND.Sector:getZone()
        return self.settings.zone
    end

    function HOUND.Sector:hasZone()
        return self:getZone() ~= nil
    end

    function HOUND.Sector:setZone(zonecandidate)
        if self.name == "default" then
            HOUND.Logger.warn("[Hound] - cannot set zone to default sector")
            return
        end
        if type(zonecandidate) == "string" then
            local zone = HOUND.Utils.Zone.getDrawnZone(zonecandidate)
            if not zone and (Group.getByName(zonecandidate)) then
                zone = mist.getGroupPoints(zonecandidate)
            end
            self.settings.zone = zone
            return
        end
        if not zonecandidate then
            local zone = HOUND.Utils.Zone.getDrawnZone(self.name .. " Sector")
            if zone then
                self.settings.zone = zone
            end
        end
    end

    function HOUND.Sector:removeZone() self.settings.zone = nil end

    function HOUND.Sector:setTransmitter(userTransmitter)
        if not userTransmitter then return end
        self.settings.transmitter = userTransmitter
        self:updateTransmitter()
    end

    function HOUND.Sector:updateTransmitter()
        for k, v in pairs(self.comms) do
            if k ~= "menu" and v.setTransmitter then v:setTransmitter(self.settings.transmitter) end
        end
    end

    function HOUND.Sector:removeTransmitter()
        self.settings.transmitter = nil
        for k, v in pairs(self.comms) do
            if k ~= "menu" then v:removeTransmitter() end
        end
    end

    function HOUND.Sector:enableController(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { controller = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.controller:enable()
        self:populateRadioMenu()
    end

    function HOUND.Sector:disableController()
        if self.comms.controller then
            self:removeRadioMenu()
            self.comms.controller:disable()
        end
    end

    function HOUND.Sector:removeController()
        self.settings.controller = nil
        if self.comms.controller then
            self:disableController()
            self.comms.controller = nil
        end
    end

    function HOUND.Sector:getControllerFreq()
        if self.comms.controller then
            return self.comms.controller:getFreqs()
        end
        return {}
    end

    function HOUND.Sector:hasController() return self.comms.controller ~= nil end

    function HOUND.Sector:isControllerEnabled()
        return self.comms.controller ~= nil and self.comms.controller:isEnabled()
    end

    function HOUND.Sector:transmitOnController(msg)
        if not self.comms.controller or not self.comms.controller:isEnabled() then return end
        if type(msg) ~= "string" then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition()}
        msgObj.tts = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end

    function HOUND.Sector:enableText()
        if self.comms.controller then self.comms.controller:enableText() end
    end

    function HOUND.Sector:disableText()
        if self.comms.controller then self.comms.controller:disableText() end
    end

    function HOUND.Sector:enableAlerts()
        if self.comms.controller then self.comms.controller:enableAlerts() end
    end

    function HOUND.Sector:disableAlerts()
        if self.comms.controller then self.comms.controller:disableAlerts() end
    end

    function HOUND.Sector:enableTTS()
        if self.comms.controller then self.comms.controller:enableTTS() end
    end

    function HOUND.Sector:disableTTS()
        if self.comms.controller then self.comms.controller:disableTTS() end
    end

    function HOUND.Sector:enableAtis(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { atis = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.atis:SetMsgCallback(HOUND.Sector.generateAtis, self)
        self.comms.atis:enable()
    end

    function HOUND.Sector:disableAtis()
        if self.comms.atis then self.comms.atis:disable() end
    end

    function HOUND.Sector:removeAtis()
        self.settings.atis = nil
        if self.comms.atis then
            self:disableAtis()
            self.comms.atis = nil
        end
    end

    function HOUND.Sector:getAtisFreq()
        if self.comms.atis then
            return self.comms.atis:getFreqs()
        end
        return {}
    end

    function HOUND.Sector:reportEWR(state)
        if self.comms.atis then self.comms.atis:reportEWR(state) end
    end

    function HOUND.Sector:hasAtis() return self.comms.atis ~= nil end

    function HOUND.Sector:isAtisEnabled()
        return self.comms.atis ~= nil and self.comms.atis:isEnabled()
    end

    function HOUND.Sector:enableNotifier(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { notifier = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.notifier:enable()
    end

    function HOUND.Sector:disableNotifier()
        if self.comms.notifier then self.comms.notifier:disable() end
    end

    function HOUND.Sector:removeNotifier()
        self.settings.notifier = nil
        if self.comms.notifier then
            self:disableNotifier()
            self.comms.notifier = nil
        end
    end

    function HOUND.Sector:getNotifierFreq()
        if self.comms.notifier then
            return self.comms.notifier:getFreqs()
        end
        return {}
    end

    function HOUND.Sector:hasNotifier()
        return self.comms.notifier ~= nil
    end

    function HOUND.Sector:isNotifierEnabled()
        return self.comms.notifier ~= nil and self.comms.notifier:isEnabled()
    end

    function HOUND.Sector:getContacts()
        local effectiveSectorName = self.name
        if not self:getZone() then
            effectiveSectorName = "default"
        end
        return self._contacts:listAllbyRange(effectiveSectorName)
    end

    function HOUND.Sector:countContacts()
        local effectiveSectorName = self.name
        if not self:getZone() then
            effectiveSectorName = "default"
        end
        return self._contacts:countContacts(effectiveSectorName)
    end

    function HOUND.Sector:updateSectorMembership(contact)
        local inSector, threatsSector = HOUND.Utils.Polygon.threatOnSector(self.settings.zone,contact:getPos(),contact:getMaxWeaponsRange())
        contact:updateSector(self.name, inSector, threatsSector)
    end

    function HOUND.Sector.removeRadioMenu(self)
        for _,menu in pairs(self.comms.menu.data) do
            if menu ~= nil then
                missionCommands.removeItem(menu)
            end
        end
        for _,menu in pairs(self.comms.menu.check_in) do
            if menu ~= nil then
                missionCommands.removeItem(menu)
            end
        end
        if self.comms.menu.root ~= nil then
            missionCommands.removeItem(self.comms.menu.root)
        end
        self.comms.menu.root = nil
        self.comms.enrolled = {}
        self.comms.menu.data = {}
        self.comms.menu.check_in = {}
    end

    function HOUND.Sector:findGrpInPlayerList(grpId,playersList)
        if not playersList or type(playersList) ~= "table" then
            playersList = self.comms.menu.enrolled
        end
        local playersInGrp = {}
        for _,player in pairs(playersList) do
            if player.groupId == grpId then
                table.insert(playersInGrp,player)
            end
        end
        return playersInGrp
    end

    function HOUND.Sector:getSubscribedGroups()
        local subscribedGid = {}
        for _,player in pairs(self.comms.menu.enrolled) do
            local grpId = player.groupId
            if not setContainsValue(subscribedGid,grpId) then
                table.insert(subscribedGid,grpId)
            end
        end
        return subscribedGid
    end

    function HOUND.Sector:validateEnrolled()
        if Length(self.comms.menu.enrolled) == 0 then return end
        for _, player in pairs(self.comms.menu.enrolled) do
            local playerUnit = Unit.getByName(player.unitName)
            if not playerUnit or not playerUnit:getPlayerName() then
                self.comms.menu.enrolled[player] = nil
            end
        end
    end

    function HOUND.Sector.checkIn(args,skipAck)
        local gSelf = args["self"]
        local player = args["player"]
        if not setContains(gSelf.comms.menu.enrolled, player) then
            gSelf.comms.menu.enrolled[player] = player
        end
        for _,otherPlayer in pairs(gSelf:findGrpInPlayerList(player.groupId,l_mist.DBs.humansByName)) do
            gSelf.comms.menu.enrolled[otherPlayer] = otherPlayer
        end
        gSelf:populateRadioMenu()
        if not skipAck then
            gSelf:TransmitCheckInAck(player)
        end
    end

    function HOUND.Sector.checkOut(args,skipAck,onlyPlayer)
        local gSelf = args["self"]
        local player = args["player"]
        gSelf.comms.menu.enrolled[player] = nil

        if not onlyPlayer then
            for _,otherPlayer in pairs(gSelf:findGrpInPlayerList(player.groupId)) do
                gSelf.comms.menu.enrolled[otherPlayer] = nil
            end
        end
        gSelf:populateRadioMenu()
        if not skipAck then
            gSelf:TransmitCheckOutAck(player)
        end
    end

    function HOUND.Sector:createCheckIn()
        for _,player in pairs(self.comms.menu.enrolled) do
            local playerUnit = Unit.getByName(player.unitName)
            if playerUnit then
                local humanOccupied = playerUnit:getPlayerName()
                if not humanOccupied then
                    self.comms.menu.enrolled[player] = nil
                end
            end
        end
        grpMenuDone = {}
        for _,player in pairs(l_mist.DBs.humansByName) do
            local grpId = player.groupId
            local playerUnit = Unit.getByName(player.unitName)
            if playerUnit and not grpMenuDone[grpId] and playerUnit:getCoalition() == self._hSettings:getCoalition() then
                grpMenuDone[grpId] = true

                if not self.comms.menu[player] then
                    self.comms.menu[player] = {
                        check_in = nil,
                        data = nil,
                        noData = nil
                    }
                end

                local grpMenu = self.comms.menu[player]
                if grpMenu.check_in ~= nil then
                    grpMenu.check_in = missionCommands.removeItemForGroup(grpId,grpMenu.check_in)
                end
                if setContains(self.comms.menu.enrolled, player) then
                    grpMenu.check_in =
                        missionCommands.addCommandForGroup(grpId,
                                            self.comms.controller:getCallsign() .. " (" ..
                                            self.comms.controller:getFreq() ..") - Check out",
                                            self.comms.menu.root,HOUND.Sector.checkOut,
                                            {
                                                self = self,
                                                player = player
                                            })
                else
                    grpMenu.check_in =
                        missionCommands.addCommandForGroup(grpId,
                                                        self.comms.controller:getCallsign() ..
                                                            " (" ..
                                                            self.comms.controller:getFreq() ..
                                                            ") - Check In",
                                                            self.comms.menu.root,
                                                        HOUND.Sector.checkIn, {
                            self = self,
                            player = player
                        })
                end
            end
        end

    end

    function HOUND.Sector:populateRadioMenu()
        if self.comms.menu.root ~= nil then
            self.comms.menu.root =
                missionCommands.removeItemForCoalition(self._hSettings:getCoalition(),self.comms.menu.root)
                self.comms.menu.root = nil
        end

        if not self.comms.controller or not self.comms.controller:isEnabled() then return end
        local contacts = self:getContacts()

        if not self.comms.menu.root then
            self.comms.menu.root =
            missionCommands.addSubMenuForCoalition(self._hSettings:getCoalition(),
                                               self.name,
                                               self._hSettings:getRadioMenu())
        end

        self:createCheckIn()

        if Length(contacts) == 0 then
            if not self.comms.menu.noData then
                self.comms.menu.noData = missionCommands.addCommandForCoalition(self._hSettings:getCoalition(),
                            "No radars are currently tracked",
                            self.comms.menu.root, timer.getAbsTime)
            end
        end

        if Length(contacts) > 0 then
            if self.comms.menu.noData ~= nil then
                missionCommands.removeItemForCoalition(self._hSettings:getCoalition(),
                self.comms.menu.noData)
                self.comms.menu.noData = nil
            end
        end

        local grpMenuDone = {}
        self:validateEnrolled()
        if Length(self.comms.menu.enrolled) > 0 then
            for _, player in pairs(self.comms.menu.enrolled) do
                local grpId = player.groupId
                local grpMenu = self.comms.menu[player]

                if not grpMenuDone[grpId] and grpMenu ~= nil then
                    grpMenuDone[grpId] = true

                    if not grpMenu.data then
                        grpMenu.data = {}
                        grpMenu.data.gid = grpId
                        grpMenu.data.player = player
                        grpMenu.data.useDMM = HOUND.Utils.isDMM(player.type)
                        grpMenu.data.menus = {}
                    end
                    for _,typeAssigned in pairs(grpMenu.data.menus) do
                        typeAssigned.counter = 0
                        if typeAssigned.root ~= nil then
                            typeAssigned.root = missionCommands.removeItemForGroup(grpId,typeAssigned.root)
                        end
                    end
                    local dataMenu = grpMenu.data
                    for _, contact in ipairs(contacts) do
                        local typeAssigned = contact:getTypeAssigned()
                        if contact.pos.p ~= nil then
                            if not dataMenu.menus[typeAssigned] then
                                dataMenu.menus[typeAssigned] = {}

                                dataMenu.menus[typeAssigned].data = {}
                                dataMenu.menus[typeAssigned].menus = {}
                                dataMenu.menus[typeAssigned].counter = 0
                            end
                            if not dataMenu.menus[typeAssigned].root then
                                dataMenu.menus[typeAssigned].root =
                                missionCommands.addSubMenuForGroup(grpId,typeAssigned,
                                                                    self.comms.menu.root)
                            end

                            self:removeRadarRadioItem(dataMenu,contact)
                            self:addRadarRadioItem(dataMenu,contact)
                        end
                    end
                end
            end
        end
    end

    function HOUND.Sector:addRadarRadioItem(dataMenu,contact)
        local assigned = contact:getTypeAssigned()
        local uid = contact.uid
        local menuText = contact:generateRadioItemText()

        dataMenu.menus[assigned].counter = dataMenu.menus[assigned].counter + 1

        if dataMenu.menus[assigned].counter == 1 then
            for k,v in pairs(dataMenu.menus[assigned].menus) do
                dataMenu.menus[assigned].menus[k] = missionCommands.removeItemForGroup(dataMenu.gid,v)
            end
        end

        local submenu = 0
        if dataMenu.menus[assigned].counter > 9 then
            submenu = l_math.floor((dataMenu.menus[assigned].counter+1)/10)
        end
        if submenu == 0 then
            dataMenu.menus[assigned].data[uid] = missionCommands.addCommandForGroup(dataMenu.gid, menuText, dataMenu.menus[assigned].root, self.TransmitSamReport,{self=self,contact=contact,requester=dataMenu.player})
        end
        if submenu > 0 then
            if dataMenu.menus[assigned].menus[submenu] == nil then
                if submenu == 1 then
                    dataMenu.menus[assigned].menus[submenu] = missionCommands.addSubMenuForGroup(dataMenu.gid, "More (Page " .. submenu+1 .. ")", dataMenu.menus[assigned].root)
                else
                    dataMenu.menus[assigned].menus[submenu] = missionCommands.addSubMenuForGroup(dataMenu.gid, "More (Page " .. submenu+1 .. ")", dataMenu.menus[assigned].menus[submenu-1])
                end
            end
            dataMenu.menus[assigned].data[uid] = missionCommands.addCommandForGroup(dataMenu.gid, menuText, dataMenu.menus[assigned].menus[submenu], self.TransmitSamReport,{self=self,contact=contact,requester=dataMenu.player})
        end
    end

    function HOUND.Sector:removeRadarRadioItem(dataMenu,contact)
        local assigned = contact:getTypeAssigned()
        local uid = contact.uid
        if not self.comms.controller or not self.comms.controller:isEnabled() or dataMenu.menus[assigned] == nil then
            return
        end

        if setContains(dataMenu.menus[assigned].data,uid) then
            dataMenu.menus[assigned].data[uid] = missionCommands.removeItemForGroup(dataMenu.gid, dataMenu.menus[assigned].data[uid])
        end
    end

    function HOUND.Sector:getTransmissionAnnounce(index)
        local messages = {
            "Attention All Aircraft! This is " .. self.callsign .. ". ",
            "All Aircraft, " .. self.callsign .. ". ",
            "This is " .. self.callsign .. ". "
        }
        local retIndex = l_math.random(1,#messages)
        if type(index) == "number" then
            retIndex = l_math.max(1,l_math.min(#messages,index))
        end
        return messages[retIndex]
    end

    function HOUND.Sector:notifyDeadEmitter(contact)
        local controller = self.comms.controller
        local notifier = self.comms.notifier
        if not controller and not notifier then return end
        if (not controller or not controller:getSettings("alerts") or not controller:isEnabled()) and (not notifier or not notifier:isEnabled())
             then return end

        local contactPrimarySector = contact:getPrimarySector()
        if self.name ~= "default" and self.name ~= contactPrimarySector then return end

        if self.name == contactPrimarySector then
            contactPrimarySector = nil
        end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition =  self._hSettings:getCoalition(), priority = 3, gid=enrolledGid}
        if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = contact:generateDeathReport(false,contactPrimarySector)
        end
        if (controller and controller:getSettings("enableTTS")) or (notifier and notifier:getSettings("enableTTS")) then
            msg.tts = announce .. contact:generateDeathReport(true,contactPrimarySector)
        end
        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end
        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end
    end

    function HOUND.Sector:notifyNewEmitter(contact)
        local controller = self.comms.controller
        local notifier = self.comms.notifier

        if not controller and not notifier then return end
        if (not controller or not controller:isEnabled() or not controller:getSettings("alerts")) and (not notifier or not notifier:isEnabled())
             then return end

        local contactPrimarySector = contact:getPrimarySector()
        if self.name ~= "default" and self.name ~= contactPrimarySector then return end

        if self.name == contactPrimarySector then
            contactPrimarySector = nil
        end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 2 , gid=enrolledGid}
        if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = self.callsign .. " Reports " .. contact:generatePopUpReport(false,contactPrimarySector)
        end
        if (controller and controller:getSettings("enableTTS")) or (notifier and notifier:getSettings("enableTTS")) then
            msg.tts = announce .. contact:generatePopUpReport(true,contactPrimarySector)
        end

        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end

        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end
    end

    function HOUND.Sector:generateAtis(loopData,AtisPreferences)
        local body = ""
        local numberEWR = 0
        local contactCount = self:countContacts()
        if contactCount > 0 then
            local sortedContacts = self:getContacts()

            for _, emitter in pairs(sortedContacts) do
                if emitter.pos.p ~= nil then
                    if not emitter.isEWR or
                        (AtisPreferences.reportewr and emitter.isEWR) then
                        body = body ..
                                    emitter:generateTtsBrief(
                                        self._hSettings:getNATO()) .. " "
                    end
                    if (not AtisPreferences.reportewr and emitter.isEWR) then
                        numberEWR = numberEWR + 1
                    end
                end
            end
            if numberEWR > 0 then
                body = body .. numberEWR .. " EWRs are tracked. "
            end
        end

        if body == "" then
            if self._hSettings:getNATO() then
                body = ". EMPTY. "
            else
                body = "No threats had been detected "
            end
        end

        if loopData.body == body then return end
        loopData.body = body

        local reportId
        reportId, loopData.reportIdx =
            HOUND.Utils.getReportId(loopData.reportIdx)

        local header = self.callsign
        local footer = reportId .. "."

        if self._hSettings:getNATO() then
            header = header .. " Lowdown "
            footer = "Lowdown " .. footer
        else
            header = header .. " SAM information "
            footer = "you have " .. footer
        end
        header = header .. reportId .. " " ..
                                    HOUND.Utils.TTS.getTtsTime() .. ". "

        local msgObj = {
            coalition = self._hSettings:getCoalition(),
            priority = "loop",
            updateTime = timer.getAbsTime(),
            tts = header .. loopData.body .. footer
        }
        loopData.msg = msgObj
    end

    function HOUND.Sector.TransmitSamReport(args)
        local gSelf = args["self"]
        local contact = args["contact"]
        local requester = args["requester"]
        local coalitionId = gSelf._hSettings:getCoalition()
        local msgObj = {coalition = coalitionId, priority = 1}
        local useDMM = false
        if contact.isEWR then msgObj.priority = 2 end

        if requester ~= nil then
            msgObj.gid = requester.groupId
            useDMM =  HOUND.Utils.isDMM(requester.type)
        end

        if gSelf.comms.controller:isEnabled() then
            msgObj.tts = contact:generateTtsReport(useDMM)
            if requester ~= nil then
                msgObj.tts = HOUND.Utils.getFormationCallsign(requester) .. ", " .. gSelf.callsign .. ", " ..
                                 msgObj.tts
            end
            if gSelf.comms.controller:getSettings("enableText") == true then
                msgObj.txt = contact:generateTextReport(useDMM)
            end
            gSelf.comms.controller:addMessageObj(msgObj)
        end
    end

    function HOUND.Sector:TransmitCheckInAck(player)
        if not player then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition(), gid = player.groupId}
        local msg = HOUND.Utils.getFormationCallsign(player) .. ", " .. self.callsign .. ", Roger. "
        if self:countContacts() > 0 then
            msg = msg .. "Tasking is available."
        else
            msg = msg .. "No known threats."
        end
        msgObj.tts = msg
        msgObj.txt = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end

    function HOUND.Sector:TransmitCheckOutAck(player)
        if not player then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition(), gid = player.groupId}
        local msg = HOUND.Utils.getFormationCallsign(player) .. ", " .. self.callsign .. ", copy checking out. "
        msgObj.tts = msg .. "Frequency change approved."
        msgObj.txt = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end
end
do
    HoundElint = {}
    HoundElint.__index = HoundElint

    function HoundElint:create(platformName)
        if not platformName then
            HOUND.Logger.error("Failed to initialize Hound instace. Please provide coalition")
            return
        end
        local elint = {}
        setmetatable(elint, HoundElint)
        elint.settings = HOUND.Config.get()
        elint.HoundId = elint.settings:getId()
        elint.contacts = HOUND.ContactManager.get(elint.HoundId)
        elint.elintTaskID = nil
        elint.radioAdminMenu = nil
        elint.coalitionId = nil

        elint.timingCounters = {}

        if platformName ~= nil then
            if type(platformName) == "string" then
                elint:addPlatform(platformName)
            else
                elint:setCoalition(platformName)
            end
        end

        elint.sectors = {
            default = HOUND.Sector.create(elint.HoundId,"default",nil,100)
        }
        elint:defaultEventHandler()
        return elint
    end

    function HoundElint:destroy()
        self:systemOff(false)
        self:defaultEventHandler(false)

        for name,sector in pairs(self.sectors) do
            self.sectors[name] = sector:destroy()
        end
        self:purgeRadioMenu()
        self.contacts = nil
        self.settings = nil
        collectgarbage("collect")
        return nil
    end

    function HoundElint:getId()
        return self.settings:getId()
    end

    function HoundElint:getCoalition()
        return self.settings:getCoalition()
    end

    function HoundElint:setCoalition(side)
        if side == coalition.side.BLUE or side == coalition.side.RED then
            return self.settings:setCoalition(side)
        end
        return false
    end

    function HoundElint:onScreenDebug(value)
        return self.settings:setOnScreenDebug(value)
    end

    function HoundElint:addPlatform(platformName)
        return self.contacts:addPlatform(platformName)
    end

    function HoundElint:removePlatform(platformName)
        return self.contacts:removePlatform(platformName)
    end

    function HoundElint:countPlatforms()
        return self.contacts:countPlatforms()
    end

    function HoundElint:listPlatforms()
        return self.contacts:listPlatforms()
    end

    function HoundElint:countContacts(sectorName)
        return self.contacts:countContacts(sectorName)
    end

    function HoundElint:countActiveContacts(sectorName)
        local activeContactCount = 0
        local contacts =  self.contacts:getContacts(sectorName)
        for _,contact in pairs(contacts) do
            if contact:isActive() then
                activeContactCount = activeContactCount +1
            end
        end
        return activeContactCount
    end

    function HoundElint:countPreBriefedContacts(sectorName)
        local pbContactCount = 0
        local contacts =  self.contacts:getContacts(sectorName)
        for _,contact in pairs(contacts) do
            if contact:isAccurate() then
                pbContactCount = pbContactCount +1
            end
        end
        return pbContactCount
    end

    function HoundElint:preBriefedContact(DCS_Object_Name)
        if type(DCS_Object_Name) ~= "string" then return end
        local units = {}
        local obj = Group.getByName(DCS_Object_Name) or Unit.getByName(DCS_Object_Name)
        if obj and obj.getUnits then
            units = obj:getUnits()
        elseif obj and obj.getGroup then
            table.insert(units,obj)
        end
        if not obj then
            HOUND.Logger.info("Cannot pre-brief " .. DCS_Object_Name .. ": object does not exist.")
            return
        end
        for _,unit in pairs(units) do
            if unit:getCoalition() ~= self.settings:getCoalition() and unit:isExist() and setContains(HOUND.DB.Radars,unit:getTypeName()) then
                self.contacts:setPreBriefedContact(unit)
            end
        end
    end

    function HoundElint:markDeadContact(radarUnit)
        local units={}
        local obj = radarUnit
        if type(radarUnit) == "string" then
            obj = Group.getByName(radarUnit) or Unit.getByName(radarUnit)
        end
        if obj and obj.getUnits then
            units = obj:getUnits()
            for _,unit in pairs(units) do
                unit = unit:getName()
            end
        elseif obj and obj.getGroup then
            table.insert(units,obj:getName())
        end
        if not obj then
            if type(radarUnit) == "string" then
                table.insert(units,radarUnit)
            else
                HOUND.Logger.info("Cannot mark as dead: object does not exist.")
                return
            end
        end
        for _,unit in pairs(units) do
            if self.contacts:isContact(unit) then
                self.contacts:setDead(unit)
            end
        end

    end

    function HoundElint:addSector(sectorName,sectorSettings,priority)
        if type(sectorName) ~= "string" then return false end
        if string.lower(sectorName) == "default" or string.lower(sectorName) == "all" then
            HOUND.Logger.info(sectorName.. " is a reserved sector name")
            return nil
        end
        priority = priority or 50
        if not self.sectors[sectorName] then
            self.sectors[sectorName] = HOUND.Sector.create(self.settings:getId(),sectorName,sectorSettings,priority)
            if self.settings:getOnScreenDebug() then
                HOUND.Logger.onScreenDebug("Sector " .. sectorName  .. " was added to Hound instance ".. self:getId(),10)
            end
            return self.sectors[sectorName]
        end

        return nil
    end

    function HoundElint:removeSector(sectorName)
        if sectorName == nil then return false end
        self.sectors[sectorName] = self.sectors[sectorName]:destroy()
        if self.settings:getOnScreenDebug() then
            HOUND.Logger.onScreenDebug("Sector " .. sectorName .. " was removed from Hound instance ".. self:getId(),10)
        end
        return true
    end

    function HoundElint:updateSectorSettings(sectorName,sectorSettings,subSettingName)
        if sectorName == nil then sectorName = "default" end
        if not self.sectors[sectorName] then
            env.warn("No sector named ".. sectorName .." was found.")
            return false
        end
        if sectorSettings == nil or type(sectorSettings) ~= "table" then return false end
        local sector = self.sectors[sectorName]
        if subSettingName ~= nil and type(subSettingName) == "string" then
            local subSetting = string.lower(subSettingName)
            if subSetting == "controller" or subSetting == "atis" or subSetting == "notifier" then
                local generatedSettings = {}
                generatedSettings[subSetting] = sectorSettings
                sector:updateSettings(generatedSettings)
                return true
            end
        end
        sector:updateSettings(sectorSettings)
        return true
    end

    function HoundElint:listSectors(element)
        local sectors = {}
        for name,sector in pairs(self.sectors) do
            local addToList = true
            if element then
                if string.lower(element) == "controller" then
                    addToList=sector:hasController()
                end
                if string.lower(element) == "atis" then
                    addToList=sector:hasAtis()
                end
                if string.lower(element) == "notifier" then
                    addToList=sector:hasNotifier()
                end
                if string.lower(element) == "zone" then
                    addToList=sector:hasZone()
                end
            end

            if addToList then
                table.insert(sectors,name)
            end
        end
        return sectors
    end

    function HoundElint:getSectors(element)
        local sectors = {}
        for _,sector in pairs(self.sectors) do
            local addToList = true
            if element then
                if string.lower(element) == "controller" then
                    addToList=sector:hasController()
                end
                if string.lower(element) == "atis" then
                    addToList=sector:hasAtis()
                end
                if string.lower(element) == "notifier" then
                    addToList=sector:hasNotifier()
                end
                if string.lower(element) == "zone" then
                    addToList=sector:hasZone()
                end
            end

            if addToList then
                table.insert(sectors,sector)
            end
        end
        return sectors
    end

    function HoundElint:countSectors(element)
        return Length(self:listSectors(element))
    end

    function HoundElint:getSector(sectorName)
        if setContains(self.sectors,sectorName) then
            return self.sectors[sectorName]
        end
    end

    function HoundElint:enableController(sectorName,settings)
        if type(sectorName) == "table" and settings == nil then
            settings  = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:enableController(settings)
            return
        end
        if string.lower(sectorName) == "all" and settings == nil then
            for _,sector in pairs(self.sectors) do
                sector:enableController()
            end
        end

    end

    function HoundElint:disableController(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableController()
        end
        if sectorName:lower() == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableController()
            end
        end
    end

    function HoundElint:removeController(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName:lower() == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeController()
            end
        elseif self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeController()
        end
    end

    function HoundElint:configureController(sectorName,settings)
        if sectorName == nil and settings == nil then return end
        if sectorName == nil and type(settings) == "table" then
            sectorName = "default"
        end
        if type(sectorName) =="table" and settings == nil then
            settings = sectorName
            sectorName = "default"
        end
        local controllerSettings = { controller = settings}
        if self.sectors[sectorName] == nil then
            self:addSector(sectorName,controllerSettings)
        elseif self.sectors[sectorName] then
            self.sectors[sectorName]:updateSettings(controllerSettings)
        end
    end

    function HoundElint:getControllerFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getControllerFreq() or {}
    end

    function HoundElint:getControllerState(sectorName)
        sectorName = sectorName or "default"

        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isControllerEnabled())
        end
        return false
    end

    function HoundElint:transmitOnController(sectorName,msg)
        if not sectorName or not msg then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:transmitOnController(msg)
            return
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:transmitOnController(msg)
            end
        end
    end

    function HoundElint:enableAtis(sectorName,settings)
        if type(sectorName) == "table" and settings == nil then
            settings  = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableAtis()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:enableAtis(settings)
        end
    end

    function HoundElint:disableAtis(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableAtis()
            return
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableAtis()
            end
        end
    end

    function HoundElint:removeAtis(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeAtis()
            end
        elseif self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeAtis()
        end
    end

    function HoundElint:configureAtis(sectorName,settings)
        if sectorName == nil and settings == nil then return end
        if sectorName == nil and type(settings) == "table" then
            sectorName = "default"
        end
        if type(sectorName) =="table" and settings == nil then
            settings = sectorName
            sectorName = "default"
        end
        local userSettings = { atis = settings}
        if self.sectors[sectorName] == nil then
            self:addSector(sectorName,userSettings)
        elseif self.sectors[sectorName] then
            self.sectors[sectorName]:updateSettings(userSettings)
        end
    end

    function HoundElint:getAtisFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getAtisFreq() or {}
    end

    function HoundElint:reportEWR(name,state)
        if type(name) == "boolean" then
            state = name
            name = "default"
        end
        if self.sectors[name] then
            self.sectors[name]:reportEWR(state)
            return
        end
        if name == "all" then
            for _,sector in pairs(self.sectors) do
                sector:reportEWR(state)
            end
        end
    end

    function HoundElint:getAtisState(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isAtisEnabled())
        end
        return false
    end

    function HoundElint:enableNotifier(sectorName,settings)
        if type(sectorName) == "table" and settings == nil then
            settings  = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:enableNotifier(settings)
        end
    end

    function HoundElint:disableNotifier(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableNotifier()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableNotifier()
        end
    end

    function HoundElint:removeNotifier(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeNotifier()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeNotifier()
        end
    end

    function HoundElint:configureNotifier(sectorName,settings)
        if sectorName == nil and settings == nil then return end
        if sectorName == nil and type(settings) == "table" then
            sectorName = "default"
        end
        if type(sectorName) =="table" and settings == nil then
            settings = sectorName
            sectorName = "default"
        end
        local notifierSettings = { notifier = settings}
        if self.sectors[sectorName] == nil then
            self:addSector(sectorName,notifierSettings)
        elseif self.sectors[sectorName] then
            self.sectors[sectorName]:updateSettings(notifierSettings)
        end
    end

    function HoundElint:getNotifierFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getNotifierFreq() or {}
    end

    function HoundElint:getNotifierState(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isNotifierEnabled())
        end
        return false
    end

    function HoundElint:enableText(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableText()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableText()
            end
        end

    end

    function HoundElint:disableText(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableText()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableText()
            end
        end
    end

    function HoundElint:enableTTS(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableTTS()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableTTS()
            end
        end
    end

    function HoundElint:disableTTS(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableTTS()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableTTS()
            end
        end
    end

    function HoundElint:enableAlerts(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableAlerts()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableAlerts()
            end
        end

    end

    function HoundElint:disableAlerts(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableAlerts()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableAlerts()
            end
        end
    end

    function HoundElint:setCallsign(sectorName,sectorCallsign)
        if not sectorName then return false end
        local NATO = self.settings:getUseNATOCallsigns()
        if sectorCallsign == "NATO" then
            sectorCallsign = true
        end
        if type(sectorCallsign) == "boolean" then
            NATO = sectorCallsign
            sectorCallsign = nil
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setCallsign(sectorCallsign,NATO)
            return true
        end
        return false
    end

    function HoundElint:getCallsign(sectorName)
        if not sectorName then return "" end
        if self.sectors[sectorName] then
            return self.sectors[sectorName]:getCallsign()
        end
        return ""
    end

    function HoundElint:setTransmitter(sectorName,transmitter)
        if not sectorName and not transmitter then return end
        if sectorName and not transmitter then
            transmitter = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:setTransmitter(transmitter)
            end
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setTransmitter(transmitter)
        end
    end

    function HoundElint:removeTransmitter(sectorName)
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeTransmitter()
            end
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:removeTransmitter()
        end
    end

    function HoundElint:getZone(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return self.sectors[sectorName]:getZone()
        end
    end

    function HoundElint:setZone(sectorName,zoneCandidate)
        if type(sectorName) ~= "string" then return end
        if type(zoneCandidate) ~= "string" and zoneCandidate ~= nil then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setZone(zoneCandidate)
        end
        self:updateSectorMembership()
    end

    function HoundElint:removeZone(sectorName)
        if self.sectors[sectorName] then
            self.sectors[sectorName]:removeZone()
        end
        self:updateSectorMembership()
    end

    function HoundElint:updateSectorMembership()
        local sectors = self:getSectors()
        table.sort(sectors,HOUND.Utils.Sort.sectorsByPriorityLowFirst)
        for _,contact in ipairs(self.contacts:listAll()) do
            for _,sector in pairs(sectors) do
                sector:updateSectorMembership(contact)
            end
        end
    end

    function HoundElint:enableMarkers(markerType)
        if markerType and setContainsValue(HOUND.MARKER,markerType) then
            self:setMarkerType(markerType)
        end
        return self.settings:setUseMarkers(true)
    end

    function HoundElint:disableMarkers()
        return self.settings:setUseMarkers(false)
    end

    function HoundElint:setMarkerType(markerType)
        if markerType and setContainsValue(HOUND.MARKER,markerType) then
            return self.settings:setMarkerType(markerType)
        end
        return false
    end

    function HoundElint:setTimerInterval(setIntervalName,setValue)
        if self.settings and setContains(self.settings.intervals,string.lower(setIntervalName)) then
            return self.settings:setInterval(setIntervalName,setValue)
        end
        return false
    end

    function HoundElint:enablePlatformPosErrors()
        return self.settings:setPosErr(true)
    end

    function HoundElint:disablePlatformPosErrors()
        return self.settings:setPosErr(false)
    end

    function HoundElint:getBDA()
        return self.settings:getBDA()
    end

    function HoundElint:enableBDA()
        return self.settings:setBDA(true)
    end

    function HoundElint:disableBDA()
        return self.settings:setBDA(false)
    end

    function HoundElint:getNATO()
        return self.settings:getNATO()
    end

    function HoundElint:enableNATO()
        return self.settings:setNATO(true)
    end

    function HoundElint:disableNATO()
        return self.settings:setNATO(false)
    end

    function HoundElint:useNATOCallsignes(value)
        if type(value) ~= "boolean" then return false end
        return self.settings:setUseNATOCallsigns(value)
    end

    function HoundElint:setAtisUpdateInterval(value)
        return self.settings:setAtisUpdateInterval(value)
    end

    function HoundElint:setRadioMenuParent(parent)
        local retval = self.settings:setRadioMenuParent(parent)
        if retval == true then
            self:populateRadioMenu()
        end
        return retval or false
    end

    function HoundElint.runCycle(self)
        local runTime = timer.getAbsTime()
        local nextRun = timer.getTime() + Gaussian(self.settings.intervals.scan,self.settings.intervals.scan/10)
        if self.settings:getCoalition() == nil then return nextRun end
        if not self.contacts then return nextRun end

        self.contacts:platformRefresh()
        self.contacts:Sniff()

        if self.contacts:countContacts() > 0 then
            local doProcess = true
            local doMenus = false
            local doMarkers = false
            if self.timingCounters.lastProcess then
                doProcess = ((HOUND.Utils.absTimeDelta(self.timingCounters.lastProcess,runTime)/self.settings.intervals.process) > 0.99)
            end
            if self.timingCounters.lastMenus then
                doMenus = ((HOUND.Utils.absTimeDelta(self.timingCounters.lastMenus,runTime)/self.settings.intervals.menus) > 0.99)
            end
            if self.timingCounters.lastMarkers then
                doMarkers = ((HOUND.Utils.absTimeDelta(self.timingCounters.lastMarkers,runTime)/self.settings.intervals.markers) > 0.99)
            end

            if doProcess then
                self.contacts:Process()
                self:updateSectorMembership()

                self.timingCounters.lastProcess = runTime
                if not self.timingCounters.lastMarkers then
                    self.timingCounters.lastMarkers = runTime
                end
                if not self.timingCounters.lastMenus then
                    self.timingCounters.lastMenus = runTime
                end
            end

            if doMenus then
                self:populateRadioMenu()
                self.timingCounters.lastMenus = runTime
            end

            if doMarkers then
                self.contacts:UpdateMarkers()
                self.timingCounters.lastMarkers = runTime
            end
        end
        if self.settings:getOnScreenDebug() then
            HOUND.Logger.onScreenDebug(self:printDebugging(),self.settings.intervals.scan*0.75)
        end
        return nextRun
    end

    function HoundElint:purgeRadioMenu()
        for _,sector in pairs(self:getSectors()) do
            sector:removeRadioMenu()
        end
        self.settings:removeRadioMenu()
    end

    function HoundElint:populateRadioMenu()
        if not self.contacts or self.contacts:countContacts() == 0 or self.settings:getCoalition() == nil then
            return
        end
        local sectors = self:getSectors()
        table.sort(sectors,HOUND.Utils.Sort.sectorsByPriorityLowLast)
        for _,sector in pairs(sectors) do
            sector:populateRadioMenu()
        end
    end

    function HoundElint.updateSystemState(params)
        local state = params.state
        local self = params.self
        if state == true then
            self:systemOn()
        elseif state == false then
            self:systemOff()
        end
    end

    function HoundElint:systemOn(notify)
        if self.settings:getCoalition() == nil then
            HOUND.Logger.warn("failed to start. no coalition found.")
            return false
        end
        self:systemOff(false)

        self.elintTaskID = timer.scheduleFunction(self.runCycle, self, timer.getTime() + self.settings.intervals.scan)
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Operating", 10)
        end
        env.info("Hound is now on")
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.HOUND_ENABLED,
            houndId = self.settings:getId(),
            coalition = self.settings:getCoalition()
        })
        return true
    end

    function HoundElint:systemOff(notify)
        if self.elintTaskID ~= nil then
            timer.removeFunction(self.elintTaskID)
        end
        self:purgeRadioMenu()
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Offline", 10)
        end
        env.info("Hound is now off")
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.HOUND_DISABLED,
            houndId = self.settings:getId(),
            coalition = self.settings:getCoalition()
        })
        return true
    end

    function HoundElint:isRunning()
        return (self.elintTaskID ~= nil)
    end

    function HoundElint:getContacts()
        local contacts = {
            ewr = { contacts = {}
                },
            sam = {
                    contacts = {}
                }
        }
        for _,emitter in pairs(self.contacts:listAll()) do
            local contact = emitter:export()
            if contact ~= nil then
                if emitter.isEWR then
                    table.insert(contacts.ewr.contacts,contact)
                else
                    table.insert(contacts.sam.contacts,contact)
                end
            end
        end
        contacts.ewr.count = #contacts.ewr.contacts or 0
        contacts.sam.count = #contacts.sam.contacts or 0
        return contacts
    end

    function HoundElint:dumpIntelBrief(filename)
        if lfs == nil or io == nil then
            HOUND.Logger.info("cannot write CSV. please desanitize lfs and io")
            return
        end
        if not filename then
            filename = string.format("hound_contacts_%d.csv",self:getId())
        end
        local currentGameTime = HOUND.Utils.Text.getTime()
        local csvFile = io.open(lfs.writedir() .. filename, "w+")
        csvFile:write("TrackId,NatoDesignation,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DCStype,DCSunit,DCSgroup,ReportGenerated\n")
        csvFile:flush()
        for _,emitter in pairs(self.contacts:listAllbyRange()) do
            local entry = emitter:generateIntelBrief()
            if entry ~= "" then
                csvFile:write(entry .. "," .. currentGameTime .."\n")
                csvFile:flush()
            end
        end
        csvFile:close()
    end

    function HoundElint:printDebugging()
        local debugMsg = "Hound instace " .. self:getId() .. " (".. HOUND.Utils.getCoalitionString(self:getCoalition()) .. ")\n"
        debugMsg = debugMsg .. "-----------------------------\n"
        debugMsg = debugMsg .. "Platforms: " .. self:countPlatforms() .. " | sectors: " .. self:countSectors()
        debugMsg = debugMsg .. " (Z:"..self:countSectors("zone").." ,C:"..self:countSectors("controller").." ,A: " .. self:countSectors("atis") .. " ,N:"..self:countSectors("notifier") ..") | "
        debugMsg = debugMsg .. "Contacts: ".. self:countContacts() .. " (A:" .. self:countActiveContacts() .. " ,PB:" .. self:countPreBriefedContacts() .. ")"
        return debugMsg
    end

    function HoundElint:onHoundEvent(houndEvent)
        if houndEvent.houndId ~= self.settings:getId() then return end
        if houndEvent.id == HOUND.EVENTS.HOUND_DISABLED then return end

        local sectors = self:getSectors()
        table.sort(sectors,HOUND.Utils.Sort.sectorsByPriorityLowFirst)

        if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
            for _,sector in pairs(sectors) do
                sector:updateSectorMembership(houndEvent.initiator)
            end
            if self:isRunning() then
                for _,sector in pairs(sectors) do
                    sector:notifyNewEmitter(houndEvent.initiator)
                end
            end
        end

        if houndEvent.id == HOUND.EVENTS.RADAR_DESTROYED then
            if self:isRunning() then
                for _,sector in pairs(sectors) do
                    sector:notifyDeadEmitter(houndEvent.initiator)
                end
            end
        end
    end

    function HoundElint:onEvent(DcsEvent)
        if not DcsEvent.initiator or type(DcsEvent.initiator) ~= "table" then return end
        if type(DcsEvent.initiator.getCoalition) ~= "function" then return end

        if DcsEvent.id == world.event.S_EVENT_DEAD
            and DcsEvent.initiator:getCoalition() ~= self.settings:getCoalition()
            and self:getBDA()
            then
                return self:markDeadContact(DcsEvent.initiator)
        end

        if not self:isRunning() then return end

        if DcsEvent.id == world.event.S_EVENT_BIRTH
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and DcsEvent.initiator:getPlayerName() ~= nil
            and setContains(mist.DBs.humansByName,DcsEvent.initiator:getName())
            then return self:populateRadioMenu()
        end

        if (DcsEvent.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT
            or DcsEvent.id == world.event.S_EVENT_PILOT_DEAD
            or DcsEvent.id == world.event.S_EVENT_EJECTION)
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and type(DcsEvent.initiator.getName) == "function"
            and setContains(mist.DBs.humansByName,DcsEvent.initiator:getName())
                then return self:populateRadioMenu()
        end
    end

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
do
    trigger.action.outText("Hound ELINT ("..HOUND.VERSION..") is loaded.", 15)
    env.info("[Hound] - finished loading (".. HOUND.VERSION..")")
end
-- Hound version 0.3.1 - Compiled on 2022-07-24 11:35
