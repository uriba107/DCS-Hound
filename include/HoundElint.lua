env.info("Starting to load Hound ELINT...")

do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
end

do
    HOUND = {
        VERSION = "0.2.0-feature/radio_refactor",
        DEBUG = false,
        ELLIPSE_PERCENTILE = 0.6,
        NUM_DATAPOINTS = 15,
        CONTACT_TIMEOUT = 900,
        MGRS_PRECISION = 3,
        MIST_VERSION = tonumber(table.concat({mist.majorVersion,mist.minorVersion},"."))
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
        SITE_NEW = 15,
        SITE_CREATED = 16,
        SITE_UPDATED = 17,
        SITE_REMOVED = 18,
        SITE_ALIVE = 19,
        SITE_ASLEEP = 20
    }




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

    function Map(input, in_min, in_max, out_min, out_max)
        return (input - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
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

    HoundLogger = {
        level = 3
    }
    HoundLogger.__index = HoundLogger

    HoundLogger.LEVEL = {
        ["error"]=1,
        ["warning"]=2,
        ["info"]=3,
        ["debug"]=4,
        ["trace"]=5,
    }



    function HoundLogger.setBaseLevel(level)
        if setContainsValue(HoundLogger.LEVEL,level) then
            HoundLogger.level = level
        end
    end

    function HoundLogger.formatText(text, ...)
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

    function HoundLogger.print(level, text)
        local texts = {text}
        local levelChar = 'E'
        local logFunction = l_env.error
        if level == HoundLogger.LEVEL["warning"] then
            levelChar = 'W'
            logFunction = l_env.warning
        elseif level == HoundLogger.LEVEL["info"] then
            levelChar = 'I'
            logFunction = l_env.info
        elseif level == HoundLogger.LEVEL["debug"] then
            levelChar = 'D'
            logFunction = l_env.info
        elseif level == HoundLogger.LEVEL["trace"] then
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

    function HoundLogger.error(text, ...)
        if HoundLogger.level >= 1 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(1, text)
        end
    end

    function HoundLogger.warn(text, ...)
        if HoundLogger.level >= 2 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(2, text)
        end
    end

    function HoundLogger.info(text, ...)
        if HoundLogger.level >= 3 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(3, text)
        end
    end

    function HoundLogger.debug(text, ...)
        if HoundLogger.level >= 4 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(4, text)
        end
    end

    function HoundLogger.trace(text, ...)
        if HoundLogger.level >= 5 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(5, text)
        end
    end

    if HOUND.DEBUG then
        HoundLogger.setBaseLevel(HoundLogger.LEVEL.trace)
    end
end
HoundDB = {}
do
    HoundDB.Sam = {
        ['1L13 EWR'] = {
            ['Name'] = "Box Spring",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'A',
            ['Primary'] = false
        },
        ['55G6 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = {"EWR"},
            ['Role'] = {"EWR"},
            ['Band'] = 'A',
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
        ['SAM SA-5 S-200 "Square Pair" TR'] = {
            ['Name'] = "Square Pair",
            ['Assigned'] = "SA-5",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['SAM SA-5 S-200 ST-68U "Tin Shield" SR'] = {
            ['Name'] = "Tin Shield",
            ['Assigned'] = "SA-5",
            ['Role'] = "SR",
            ['Band'] = 'E'
        },
        ['RLS_19J6'] = {
            ['Name'] = "Tin Shield",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'E'
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
            ['Assigned'] = "NASAMS",
            ['Role'] = "SR",
            ['Band'] = 'I'
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
            ['Assigned'] = {"SA-20B"},
            ['Role'] = {"TR"},
            ['Band'] = 'I',
            ['Primary'] = true
        },
        ['S-300PMU2 64H6E2 sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-20B"},
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
        }
    }
end

do
    HoundDB.PHONETICS =  {
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
end

do
    HoundDB.useDecMin =  {
        ['F-16C_blk50'] = true,
        ['F-16C_50'] = true,
        ['M-2000C'] = true,
        ['A-10C'] = true,
        ['A-10C_2'] = true
    }
end

do

    HoundDB.Platform =  {
        [Object.Category.STATIC] = {['Comms tower M'] = {antenna = {size = 80, factor = 1}}},
        [Object.Category.UNIT] = {
            ['MLRS FDDM'] = {antenna = {size = 15, factor = 1}},
            ['SPK-11'] = {antenna = {size = 15, factor = 1}},
            ['CH-47D'] = {antenna = {size = 12, factor = 1}},
            ['CH-53E'] = {antenna = {size = 10, factor = 1}},
            ['MIL-26'] = {antenna = {size = 20, factor = 1}},
            ['SH-60B'] = {antenna = {size = 8, factor = 1}},
            ['UH-60A'] = {antenna = {size = 8, factor = 1}},
            ['Mi-8MT'] = {antenna = {size = 8, factor = 1}},
            ['UH-1H'] = {antenna = {size = 4, factor = 1}},
            ['KA-27'] = {antenna = {size = 4, factor = 1}},
            ['C-130'] = {antenna = {size = 35, factor = 1}},
            ['Hercules'] = {antenna = {size = 35, factor = 1}}, -- Anubis' C-130J
            ['C-17A'] = {antenna = {size = 50, factor = 1}},
            ['S-3B'] = {antenna = {size = 18, factor = 0.8}},
            ['E-3A'] = {antenna = {size = 9, factor = 0.5}},
            ['E-2D'] = {antenna = {size = 7, factor = 0.5}},
            ['Tu-95MS'] = {antenna = {size = 50, factor = 1}},
            ['Tu-142'] = {antenna = {size = 50, factor = 1}},
            ['IL-76MD'] = {antenna = {size = 48, factor = 0.8}},
            ['An-30M'] = {antenna = {size = 25, factor = 1}},
            ['A-50'] = {antenna = {size = 9, factor = 0.5}},
            ['An-26B'] = {antenna = {size = 26, factor = 0.9}},
            ['EA_6B'] = {antenna = {size = 9, factor = 1}}, -- VSN EA-6B
            ['Su-25T'] = {antenna = {size = 1.6, factor = 1}},
            ['AJS37'] = {antenna = {size = 1.6, factor = 1}}
        }
    }

    HoundDB.Bands =  {
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

    HoundDB.CALLSIGNS = {
        NATO = {
        "ABLOW", "ACTON", "AGRAM", "AMINO", "AWOKE", "BARB", "BART", "BAZOO",
        "BOGUE", "BOOT", "BRAY", "CAMAY", "CAPON", "CASEY", "CHIME", "CHISUM",
        "COBRA", "COSMO", "CRISP", "DAGDA", "DALLY", "DEVON", "DIVE", "DOZER",
        "DUPLE", "EXOR", "EXUDE", "EXULT", "FLOSS", "FLOUT", "FLUKY", "FURR",
        "GENUS", "GOBO", "GOLLY", "GOOFY", "GROUP", "HAKE", "HARMO", "HAWG",
        "HERMA", "HEXAD", "HOLE", "HURDS", "HYMN", "IOTA", "JOSS", "KELT", "LARVA",
        "LUMPY", "MAFIA", "MINE", "MORTY", "MURKY", "NEVIN", "NEWLY", "NORTH",
        "OLIVE", "ORKIN", "PARRY", "PATIO", "PATSY", "PATTY", "PERMA", "PITTS",
        "POKER", "POOK", "PRIME", "PYTHON", "RAGU", "REMUS", "RINGY", "RITZ",
        "RIVET", "RIVET", "ROSE", "RULE", "RUNNY", "SAME", "SAVOY", "SCENT",
        "SCROW", "SEAT", "SLAG", "SLOG", "SNOOP", "SPRY", "STINT", "STOB", "TAKE",
        "TALLY", "TAPE", "TOLL", "TONUS", "TOPCAT", "TORA", "TOTTY", "TOXIC",
        "TRIAL", "TRYST", "VALVO", "VEIN", "VELA", "VETCH", "VINE", "VULCAN",
        "WATT", "WORTH", "ZEPEL", "ZIPPY"},
        GENERIC = {
            "VACUUM", "HOOVER", "KIRBY","ROOMBA","DYSON","SHERLOCK","WATSON","GADGET",
            "HORATIO","CAINE","CHRISTIE","BENSON","GIBBS","COLOMBO","HOLT","DIAZ",
            "SCULLY","MULDER","MARVIN","MARS","MORNINGSTAR","STEELE","SHAFT","CASTEL","BECKETT","JONES",
            "LARA","CROFT","VENTURA","SCOOBY","SHAGGY","DANEEL","OLIVAW","BALEY","GISKARD"
        }
    }

end
do

    HoundConfig = {
        configMaps = {}
    }

    HoundConfig.__index = HoundConfig

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
            if type(value) == "number" then
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

        instance.getRadioMenu = function (self)
            if not self.radioMenu.root then
                self.radioMenu.root = missionCommands.addSubMenuForCoalition(
                    self:getCoalition(), 'ELINT',self:getRadioMenuParent())
            end
            return self.radioMenu.root
        end

        instance.removeRadioMenu = function (self)
            if self.radioMenu.root ~= nil then
                self.radioMenu.root = nil
                return true
            end
            return false
        end

        instance.getRadioMenuParent = function(self)
            return self.radioMenu.parent
        end

        instance.setRadioMenuParent = function (self,parent)
            if type(parent) == "table" then
                self.radioMenu.parent = parent
                return true
            end
            return false
        end

        HoundConfig.configMaps[HoundInstanceId] = instance

        return HoundConfig.configMaps[HoundInstanceId]
    end
end
do
    local l_mist = mist
    local l_math = math
    local pi_2 = 2*l_math.pi

    HoundUtils = {
        TTS = {},
        Text = {},
        Elint = {},
        Vector={},
        Polygon={},
        Cluster={},
        Sort = {},
        ReportId = nil,
        _MarkId = 0,
        _HoundId = 0
    }
    HoundUtils.__index = HoundUtils



    function HoundUtils.getHoundId()
        HoundUtils._HoundId = HoundUtils._HoundId + 1
        return HoundUtils._HoundId
    end

    function HoundUtils.getMarkId()
        if UTILS and UTILS.GetMarkID then
            HoundUtils._MarkId = UTILS.GetMarkID()
        elseif HOUND.MIST_VERSION >= 4.5 then
            HoundUtils._MarkId = l_mist.marker.getNextId()
        else
            HoundUtils._MarkId = HoundUtils._MarkId + 1
        end

        return HoundUtils._MarkId
    end



    function HoundUtils.absTimeDelta(t0, t1)
        if t1 == nil then t1 = timer.getAbsTime() end
        return t1 - t0
    end


    function HoundUtils.angleDeltaRad(rad1,rad2)
        if not rad1 or not rad2 then return end
        return l_math.pi - l_math.abs(l_math.pi - l_math.abs(rad1-rad2) % pi_2)
    end


    function HoundUtils.AzimuthAverage(azimuths)
        if not azimuths or Length(azimuths) == 0 then return nil end

        local sumSin = 0
        local sumCos = 0
        for i=1, Length(azimuths) do
            sumSin = sumSin + l_math.sin(azimuths[i])
            sumCos = sumCos + l_math.cos(azimuths[i])
        end
        return (l_math.atan2(sumSin,sumCos) + pi_2) % pi_2

    end

    function HoundUtils.PointClusterTilt(points,refPos)
        if not points or type(points) ~= "table" then return end
        if not refPos then
            refPos = l_mist.getAvgPoint(points)
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
        return l_math.atan2(biasVector.z,biasVector.x)
    end


    function HoundUtils.RandomAngle()
        return l_math.random() * 2 * l_math.pi
    end


    function HoundUtils.getSamMaxRange(DCS_Unit)
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


    function HoundUtils.getRadarDetectionRange(DCS_Unit)
        local detectionRange = 0
        local unit_sensors = DCS_Unit:getSensors()
        if not unit_sensors then return end
        for _,radar in pairs(unit_sensors[Unit.SensorType.RADAR]) do
            for _,aspects in pairs(radar["detectionDistanceAir"]) do
                for _,range in pairs(aspects) do
                    detectionRange = l_math.max(detectionRange,range)
                end
            end
        end
        return detectionRange
    end


    function HoundUtils.getRoundedElevationFt(elev)
        return HoundUtils.roundToNearest(l_mist.utils.metersToFeet(elev),50)
    end


    function HoundUtils.roundToNearest(input,nearest)
        return l_mist.utils.round(input/nearest) * nearest
    end


    function HoundUtils.getNormalAngularError(variance)
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = 2* math.pi * l_math.random()

        local epsilon = {
            az = Magnitude * l_math.cos(Theta),
            el = Magnitude * l_math.sin(Theta)
        }
        return epsilon
    end


    function HoundUtils.getControllerResponse()
        local response = {
            " ",
            "Good Luck!",
            "Happy Hunting!",
            "Please send my regards.",
            " "
        }
        return response[l_math.max(1,l_math.min(l_math.ceil(timer.getAbsTime() % Length(response)),Length(response)))]
    end


    function HoundUtils.getCoalitionString(coalitionID)
        local coalitionStr = "RED"
        if coalitionID == coalition.side.BLUE then
            coalitionStr = "BLUE"
        elseif coalitionID == coalition.side.NEUTRAL then
            coalitionStr = "NEUTRAL"
        end
        return coalitionStr
    end


    function HoundUtils.getHemispheres(lat,lon,fullText)
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


    function HoundUtils.getReportId(ReportId)
        local returnId
        if ReportId ~= nil then
            returnId =  string.byte(ReportId)
        else
            returnId = HoundUtils.ReportId
        end
        if returnId == nil or returnId == string.byte('Z') then
            returnId = string.byte('A')
        else
            returnId = returnId + 1
        end
        if not ReportId then
            HoundUtils.ReportId = returnId
        end

        return HoundDB.PHONETICS[string.char(returnId)],string.char(returnId)
    end


    function HoundUtils.DecToDMS(cood)
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


    function HoundUtils.getBR(src,dst)
        if not src or not dst then return end
        local BR = {}
        local dir = l_mist.utils.getDir(l_mist.vec.sub(dst,src),src) -- pass src to get magvar included
        BR.brg = l_mist.utils.round(l_mist.utils.toDegree( dir ))
        BR.brStr = string.format("%03d",BR.brg)
        BR.rng = l_mist.utils.round(l_mist.utils.metersToNM(l_mist.utils.get2DDist(dst,src)))
        return BR
    end


    function HoundUtils.checkLOS(pos0,pos1)
        if not pos0 or not pos1 then return false end
        local dist = l_mist.utils.get2DDist(pos0,pos1)
        local radarHorizon = HoundUtils.EarthLOS(pos0.y,pos1.y)
        return (dist <= radarHorizon*1.025 and land.isVisible(pos0,pos1))
    end


    function HoundUtils.EarthLOS(h0,h1)
        if not h0 then return 0 end
        local Re = 6371000 -- Radius of earth in M
        local d0 = l_math.sqrt(h0^2+2*Re*h0)
        local d1 = 0
        if h1 then d1 = l_math.sqrt(h1^2+2*Re*h1) end
        return d0+d1
    end

    function HoundUtils.getFormationCallsign(player,flightMember)
        local callsign = ""
        if type(player) ~= "table" then return callsign end
        callsign = string.gsub(player.callsign.name,"[%d%s]","") .. " " .. player.callsign[2]
        if flightMember then
            callsign = callsign .. " " .. player.callsign[3]
        end

        local DCS_Unit = Unit.getByName(player.unitName)
        if not DCS_Unit then return string.upper(callsign) end

        local playerName = DCS_Unit:getPlayerName()
        if playerName then
            if string.find(playerName,"|") then
                callsign = string.sub(playerName, 1, string.find(playerName,"|")-1)
                local base = string.match(callsign,"%a+")
                local num = string.match(callsign,"%d+")
                if string.find(callsign,"-") then
                    if flightMember then
                        callsign = string.gsub(callsign,"-"," ")
                    else
                        callsign = string.sub(callsign, 1,string.find(callsign,"-")-1)
                    end
                else
                    callsign = base
                    if flightMember and num ~= nil then
                        callsign = callsign .. " " .. num
                    end
                end
                return string.upper(callsign)
            end
        end
        return string.upper(callsign)
    end

    function HoundUtils.getHoundCallsign(namePool)
        local SelectedPool = HoundDB.CALLSIGNS[namePool] or HoundDB.CALLSIGNS.GENERIC
        return SelectedPool[l_math.random(1, Length(SelectedPool))]
    end

    function HoundUtils.isDMM(DCS_Unit)
        if not DCS_Unit then return false end
        local typeName = nil
        if type(DCS_Unit) == "string" then
            typeName = DCS_Unit
        end
        if type(DCS_Unit) == "Table" and DCS_Unit.getTypeName then
            typeName = DCS_Unit:getTypeName()
        end
        return setContains(HoundDB.useDecMin,typeName)
    end


    function HoundUtils.TTS.Transmit(msg,coalitionID,args,transmitterPos)

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


    function HoundUtils.TTS.getTtsTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        local hours = DHMS.h
        local minutes = DHMS.m
        if hours == 0 then
            hours = HoundDB.PHONETICS["0"]
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


    function HoundUtils.TTS.getVerbalConfidenceLevel(confidenceRadius)
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


    function HoundUtils.TTS.getVerbalContactAge(timestamp,isSimple,NATO)
        local ageSeconds = HoundUtils.absTimeDelta(timestamp,timer.getAbsTime())

        if isSimple then
            if NATO then
                if ageSeconds < 16 then return "Active" end
                return "Awake"
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


    function HoundUtils.TTS.DecToDMS(cood,minDec)
        local DMS = HoundUtils.DecToDMS(cood)
        if minDec == true then
            return l_math.abs(DMS.d) .. " degrees, " .. string.format("%02d",DMS.m) .. ", " .. HoundUtils.TTS.toPhonetic( "." .. string.format("%03d",DMS.sDec))..  " minutes"
        end
        return l_math.abs(DMS.d) .. " degrees, " .. string.format("%02d",DMS.m) .. " minutes, " .. string.format("%02d",DMS.s) .. " seconds"
    end


    function HoundUtils.TTS.getVerbalLL(lat,lon,minDec)
        minDec = minDec or false
        local hemi = HoundUtils.getHemispheres(lat,lon,true)
        return hemi.NS .. ", " .. HoundUtils.TTS.DecToDMS(lat,minDec)  ..  ", " .. hemi.EW .. ", " .. HoundUtils.TTS.DecToDMS(lon,minDec)
    end


    function HoundUtils.TTS.toPhonetic(str)
        local retval = ""
        str = string.upper(str)
        for i=1, string.len(str) do
            retval = retval .. HoundDB.PHONETICS[string.sub(str, i, i)] .. " "
        end
        return retval:match( "^%s*(.-)%s*$" ) -- return and strip trailing whitespaces
    end


    function HoundUtils.TTS.getReadTime(length,speed,isGoogle)
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


    function HoundUtils.TTS.simplfyDistance(distanceM)
        local distanceUnit = "meters"
        local distance = HoundUtils.roundToNearest(distanceM,50) or 0
        if distance >= 1000 then
            distance = string.format("%.1f",tostring(HoundUtils.roundToNearest(distanceM,100)/1000))
            distanceUnit = "kilometers"
        end
        return distance .. " " .. distanceUnit
    end


    function HoundUtils.Text.getLL(lat,lon,minDec)
        local hemi = HoundUtils.getHemispheres(lat,lon)
        lat = HoundUtils.DecToDMS(lat)
        lon = HoundUtils.DecToDMS(lon)
        if minDec == true then
            return hemi.NS .. l_math.abs(lat.d) .. "°" .. string.format("%.3f",lat.mDec) .. "'" ..  " " ..  hemi.EW  .. l_math.abs(lon.d) .. "°" .. string.format("%.3f",lon.mDec) .. "'"
        end
        return hemi.NS .. l_math.abs(lat.d) .. "°" .. string.format("%02d",lat.m) .. "'".. string.format("%02d",l_math.floor(lat.s)).."\"" ..  " " ..  hemi.EW  .. l_math.abs(lon.d) .. "°" .. string.format("%02d",lon.m) .. "'".. string.format("%02d",l_math.floor(lon.s)) .."\""
    end

    function HoundUtils.Text.getTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        return string.format("%02d",DHMS.h)  .. string.format("%02d",DHMS.m)
    end



    function HoundUtils.Elint.getDefraction(band,antenna_size)
        if band == nil or antenna_size == nil or antenna_size == 0 then return l_math.rad(30) end
        return HoundDB.Bands[band]/antenna_size
    end

    function HoundUtils.Elint.getApertureSize(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName or not DCS_Unit.getCategory then return 0 end
        local mainCategory = DCS_Unit:getCategory()
        local typeName = DCS_Unit:getTypeName()
        if setContains(HoundDB.Platform,mainCategory) then
            if setContains(HoundDB.Platform[mainCategory],typeName) then
                return HoundDB.Platform[mainCategory][typeName].antenna.size *  HoundDB.Platform[mainCategory][typeName].antenna.factor
            end
        end
        return 0
    end

    function HoundUtils.Elint.getEmitterBand(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName then return 'C' end
        local typeName = DCS_Unit:getTypeName()
        if setContains(HoundDB.Sam,typeName) then
            return HoundDB.Sam[typeName].Band
        end
        return 'C'
    end

    function HoundUtils.Elint.getSensorPrecision(platform,emitterBand)
        return  HoundUtils.Elint.getDefraction(emitterBand,HoundUtils.Elint.getApertureSize(platform)) or l_math.rad(20.0) -- precision
    end


    function HoundUtils.Elint.generateAngularError(variance)

        local vec2 = HoundUtils.Vector.getRandomVec2(variance)
        local epsilon = {
            az = vec2.x,
            el = vec2.z
        }
        return epsilon
    end


    function HoundUtils.Elint.getAzimuth(src, dst, sensorPrecision)
        local AngularErr = HoundUtils.Elint.generateAngularError(sensorPrecision)

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


    function HoundUtils.Elint.getActiveRadars(instanceCoalition)
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

    function HoundUtils.Elint.getRwrContacts(platform)
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


    function HoundUtils.Vector.getUnitVector(Theta,Phi)
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

    function HoundUtils.Vector.getRandomVec2(variance)
        if variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = 2* math.pi * l_math.random()

        local epsilon = HoundUtils.Vector.getUnitVector(Theta)
        for axis,value in pairs(epsilon) do
            epsilon[axis] = value * Magnitude
        end
        return epsilon
    end

    function HoundUtils.Vector.getRandomVec3(variance)
        if variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = 2* math.pi * l_math.random()
        local Phi = 2* math.pi * l_math.random()

        local epsilon = HoundUtils.Vector.getUnitVector(Theta,Phi)
        for axis,value in pairs(epsilon) do
            epsilon[axis] = value * Magnitude
        end
        return epsilon
    end


    function HoundUtils.Polygon.isDcsPoint(point)
        if type(point) ~= "table" then return false end
        return (point.x and type(point.x) == "number") and  (point.z and type(point.z) == "number")
    end

    function HoundUtils.Polygon.threatOnSector(polygon,point, radius)
        if type(polygon) ~= "table" or Length(polygon) < 3 or not HoundUtils.Polygon.isDcsPoint(l_mist.utils.makeVec3(polygon[1])) then
            return
        end
        if not HoundUtils.Polygon.isDcsPoint(point) then
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

    function HoundUtils.Polygon.clipPolygons(subjectPolygon, clipPolygon)
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
        return
    end

    function HoundUtils.Polygon.giftWrap(points)
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

    function HoundUtils.Polygon.circumcirclePoints(points)
        local function calcCircle(p1,p2,p3)
            local cx,cz, r
            if HoundUtils.Polygon.isDcsPoint(p1) and not p2 and not p3 then
                return {x = p1.x, z = p1.z,r = 0}
            end
            if HoundUtils.Polygon.isDcsPoint(p1) and HoundUtils.Polygon.isDcsPoint(p2) and not p3 then
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

    function HoundUtils.Polygon.getArea(polygon)
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

    function HoundUtils.Polygon.clipOrHull(polyA,polyB)
        if HoundUtils.Polygon.getArea(polyA) < HoundUtils.Polygon.getArea(polyB) then
            polyA,polyB = polyB,polyA
        end
        local polygon = HoundUtils.Polygon.clipPolygons(polyA,polyB)
        if Polygon == nil then
            local points = l_mist.utils.deepCopy(polyA)
            for _,point in pairs(polyB) do
                table.insert(points,l_mist.utils.deepCopy(point))
            end
            polygon = HoundUtils.Polygon.giftWrap(points)
        end
        return polygon
    end


    function HoundUtils.Cluster.getCentroids(contacts)
        local centroids = {}
        for _,contact in ipairs(contacts) do
            local centroid = {
                p = contact.pos.p,
                r = contact.uncertenty_radius.r,
                members = {}
            }
            table.insert(centroid.members,contact)
            table.insert(centroids,centroid)
        end
        return centroids
    end

    function HoundUtils.Cluster.meanShift(contacts,iterations)
        local kernel_bandwidth = 1000

        local function gaussianKernel(distance,bandwidth)
            return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((distance / bandwidth))^2)
        end

        local function findNeighbours(centroids,centroid,distance)
            if distance == nil then distance = centroid.r or kernel_bandwidth end
            local eligable = {}
            for _,candidate in ipairs(centroids) do
                local dist = l_mist.utils.get2DDist(candidate.p,centroid.p)
                if dist <= distance then
                    table.insert(eligable,candidate)
                end
            end
            return eligable
        end

        local function compareCentroids(item1,item2)
            if item1.p.x ~= item2.p.x or item1.p.z ~= item2.p.z or item1.r ~= item2.r then return false end
            if Length(item1.members) ~= Length(item2.members) then return false end
            return true
        end

        local function compareCentroidLists(t1,t2)
            if Length(t1) ~= Length(t2) then return false end
            for _,item1 in ipairs(t1) do
                for _,item2 in ipairs(t2) do
                    if not compareCentroids(item1,item2) then return false end
                end
            end
            return true
        end

        local function insertUniq(t,candidate)
            if type(t) ~= "table" or not candidate then return end
            for _,item in ipairs(t) do
                if not compareCentroids(item,candidate) then return end
            end
            env.info("Adding uniq: " .. candidate.p.x .. "/" .. candidate.p.z ..  " r=".. candidate.r .. " with " .. Length(candidate.members) .. " members")
            table.insert(t,candidate)
        end

        local centroids = {}
        for _,contact in ipairs(contacts) do
            local centroid = {
                p = contact.pos.p,
                r = l_math.min(contact.uncertenty_radius.r,kernel_bandwidth),
                members = {}
            }
            table.insert(centroid.members,contact)
            table.insert(centroids,centroid)
        end

        local past_centroieds = {}
        local converged = false
        local itr = 1
        while not converged do
            env.info("itteration " .. itr .. " starting with " .. Length(centroids) .. " centroids")
            local new_centroids = {}
            for _,centroid in ipairs(centroids) do
                local neighbours = findNeighbours(centroids,centroid)
                local num_z = 0
                local num_x = 0
                local num_r = 0
                local denominator = 0
                local new_members = {}
                for _,neighbour in ipairs(neighbours) do
                    local dist = l_mist.utils.get2DDist(neighbour.p,centroid.p)
                    local weight = gaussianKernel(dist,centroid.r)
                    num_z = num_z + (neighbour.p.z * weight)
                    num_x = num_x + (neighbour.p.x * weight)
                    num_r = num_r + (neighbour.r * weight)
                    denominator = denominator + weight
                    for _,memeber in ipairs(neighbour.members) do
                        table.insert(new_members,memeber)
                    end
                end
                local new_centroid = l_mist.utils.deepCopy(centroid)
                new_centroid.p.x = num_x/denominator
                new_centroid.p.z = num_z/denominator
                new_centroid.r = num_r/denominator
                new_centroid.members = new_members
                insertUniq(new_centroids,new_centroid)
            end
            past_centroieds = centroids
            centroids = new_centroids
            itr = itr + 1
            converged = (compareCentroidLists(centroids,past_centroieds) or (iterations ~= nil and iterations <= itr))
        end
        env.info("meanShift() converged")
        return centroids
    end


    function HoundUtils.Sort.ContactsByRange(a,b)
        if a.isEWR ~= b.isEWR then
          return b.isEWR and not a.isEWR
        end
        if a.maxWeaponsRange ~= b.maxWeaponsRange then
            return a.maxWeaponsRange > b.maxWeaponsRange
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

    function HoundUtils.Sort.ContactsById(a,b)
        if  a.uid ~= b.uid then
            return a.uid < b.uid
        end
        return a.maxWeaponsRange > b.maxWeaponsRange
    end

    function HoundUtils.Sort.sectorsByPriorityLowFirst(a,b)
        return a:getPriority() > b:getPriority()
    end

    function HoundUtils.Sort.sectorsByPriorityLowLast(a,b)
        return a:getPriority() < b:getPriority()
    end
end
do
    HoundEventHandler = {
        idx = 0,
        subscribers = {},
        _internalSubscribers = {}
    }

    HoundEventHandler.__index = HoundEventHandler

    function HoundEventHandler.addEventHandler(handler)
        HoundEventHandler.subscribers[handler] = handler
    end

    function HoundEventHandler.removeEventHandler(handler)
        HoundEventHandler.subscribers[handler] = nil
    end

    function HoundEventHandler.addInternalEventHandler(handler)
            HoundEventHandler._internalSubscribers[handler] = handler
    end

    function HoundEventHandler.removeInternalEventHandler(handler)
        if setContains(HoundEventHandler._internalSubscribers,handler) then
            HoundEventHandler._internalSubscribers[handler] = nil
        end
    end

    function HoundEventHandler.onHoundEvent(event)
        for _, handler in pairs(HoundEventHandler._internalSubscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                if handler and handler.settings then
                    handler:onHoundEvent(event)
                end
            end
        end
        for _, handler in pairs(HoundEventHandler.subscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                if handler then
                    handler:onHoundEvent(event)
                end
            end
        end
    end

    function HoundEventHandler.publishEvent(event)
        event.time = timer.getTime()
        HoundEventHandler.onHoundEvent(event)
    end

    function HoundEventHandler.getIdx()
        HoundEventHandler.idx = HoundEventHandler.idx + 1
        return  HoundEventHandler.idx
    end
end
do
    local l_math = math
    local PI_2 = 2*l_math.pi


    HoundDatapoint = {}
    HoundDatapoint.__index = HoundDatapoint

    function HoundDatapoint.New(platform0, p0, az0, el0, t0, angularResolution, isPlatformStatic)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HoundDatapoint)
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
        elintDatapoint.posPolygon["2D"],elintDatapoint.posPolygon["3D"] = elintDatapoint:calcPolygons()
        return elintDatapoint
    end

    function HoundDatapoint.isStatic(self)
        return self.platformStatic
    end

    function HoundDatapoint.getPos(self)
        return self.estimatedPos
    end

    function HoundDatapoint.get2dPoly(self)
        return self.posPolygon['2D']
    end

    function HoundDatapoint.get3dPoly(self)
        return self.posPolygon['3D']
    end

    function HoundDatapoint.estimatePos(self)
        if self.el == nil then return end
        local maxSlant = self.platformPos.y/l_math.abs(l_math.sin(self.el))
        local unitVector = HoundUtils.Vector.getUnitVector(self.az,self.el)
        local point =land.getIP(self.platformPos, unitVector , maxSlant+100 )
        return point
    end

    function HoundDatapoint.calcPolygons(self)
        if self.platformPrecision == 0 then return nil,nil end
        local maxSlant = HoundUtils.EarthLOS(self.platformPos.y)*1.2
        local poly2D = {}
        table.insert(poly2D,self.platformPos)
        for _,theta in ipairs({((self.az - self.platformPrecision + PI_2) % PI_2),((self.az + self.platformPrecision + PI_2) % PI_2) }) do
            local point = {}
            point.x = maxSlant*l_math.cos(theta) + self.platformPos.x
            point.z = maxSlant*l_math.sin(theta) + self.platformPos.z
            table.insert(poly2D,point)
        end

        if self.el == nil then return poly2D end
        local poly3D = {}

        local numSteps = 16
        local angleStep = PI_2/numSteps
        for i = 1,numSteps do
            local pointAngle = (i*angleStep)
            local azStep = self.az + (self.platformPrecision * l_math.sin(pointAngle))
            local elStep = self.el + (self.platformPrecision * l_math.cos(pointAngle))
            local point = land.getIP(self.platformPos, HoundUtils.Vector.getUnitVector(azStep,elStep) , maxSlant)
            if point then
                table.insert(poly3D,point)
            end
        end
        return poly2D,poly3D
    end
end
do
    HoundContact = {}
    HoundContact.__index = HoundContact

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    function HoundContact.New(DCS_Unit,HoundCoalition)
        if not DCS_Unit or type(DCS_Unit) ~= "table" or not DCS_Unit.getName or not HoundCoalition then
            HoundLogger.warn("failed to create HoundContact instance")
            return
        end
        local elintcontact = {}
        setmetatable(elintcontact, HoundContact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = DCS_Unit:getID()
        elintcontact.DCStypeName = DCS_Unit:getTypeName()
        elintcontact.typeName = DCS_Unit:getTypeName()
        elintcontact.isEWR = false
        elintcontact.typeAssigned = {"Unknown"}
        elintcontact.band = "C"

        local contactUnitCategory = DCS_Unit:getDesc()["category"]
        if contactUnitCategory and contactUnitCategory == Unit.Category.SHIP then
            elintcontact.band = "E"
            elintcontact.typeAssigned = {"Naval"}
        end

        if setContains(HoundDB.Sam,DCS_Unit:getTypeName())  then
            local unitName = DCS_Unit:getTypeName()
            elintcontact.typeName =  HoundDB.Sam[unitName].Name
            elintcontact.isEWR = setContainsValue(HoundDB.Sam[unitName].Role,"EWR")
            elintcontact.typeAssigned = HoundDB.Sam[unitName].Assigned
            elintcontact.band = HoundDB.Sam[unitName].Band
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
        elintcontact.maxWeaponsRange = HoundUtils.getSamMaxRange(DCS_Unit)
        elintcontact.detectionRange = HoundUtils.getRadarDetectionRange(DCS_Unit)
        elintcontact._dataPoints = {}
        elintcontact._markpointID = nil
        elintcontact._platformCoalition = HoundCoalition
        elintcontact.primarySector = "default"
        elintcontact.threatSectors = {
            default = true
        }
        elintcontact.state = HOUND.EVENTS.RADAR_NEW
        return elintcontact
    end

    function HoundContact:destroy()
        self:removeMarkers()
    end


    function HoundContact:getName()
        return self.typeName .. " " .. (self.uid%100)
    end

    function HoundContact:getType()
        return self.typeName
    end

    function HoundContact:getId()
        return self.uid%100
    end

    function HoundContact:getPos()
        return self.pos.p
    end

    function HoundContact:getMaxWeaponsRange()
        return self.maxWeaponsRange
    end

    function HoundContact:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end
    function HoundContact:isAlive()
        if self.unit:isExist() == false or self.unit:getLife() <= 1 then return false end
        return true
    end

    function HoundContact:isTimedout()
        return HoundUtils.absTimeDelta(timer.getAbsTime(), self.last_seen) > HOUND.CONTACT_TIMEOUT
    end

    function HoundContact:CleanTimedout()
        if self:isTimedout() then
            self._dataPoints = {}
            self.state = HOUND.EVENTS.RADAR_ASLEEP
        end
    end

    function HoundContact:countDatapoints()
        local count = 0
        for _,platformDataPoints in pairs(self.dataPoints) do
            count = count + Length(platformDataPoints)
        end
        return count
    end

    function HoundContact:AddPoint(datapoint)
        self.last_seen = datapoint.t
        if Length(self._dataPoints[datapoint.platformId]) == 0 then
            self._dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            if Length(self._dataPoints[datapoint.platformId]) > 0 then
                datapoint.az =  HoundUtils.AzimuthAverage({datapoint.az,self._dataPoints[datapoint.platformId][1].az})
            end
            self._dataPoints[datapoint.platformId] = {datapoint}
            return
        end

        if Length(self._dataPoints[datapoint.platformId]) < 2 then
            table.insert(self._dataPoints[datapoint.platformId], datapoint)
        else
            local LastElementIndex = Length(self._dataPoints[datapoint.platformId])
            local DeltaT = HoundUtils.absTimeDelta(self._dataPoints[datapoint.platformId][LastElementIndex - 1].t, datapoint.t)
            if  DeltaT >= 60 then
                table.insert(self._dataPoints[datapoint.platformId], datapoint)
            else
                self._dataPoints[datapoint.platformId][LastElementIndex] = datapoint
            end
            if Length(self._dataPoints[datapoint.platformId]) > HOUND.NUM_DATAPOINTS then
                table.remove(self._dataPoints[datapoint.platformId], 1)
            end
        end
    end

    function HoundContact.triangulatePoints(earlyPoint, latePoint)
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

    function HoundContact.getDeltaSubsetPercent(Table,referencePos,NthPercentile)
        local t = l_mist.utils.deepCopy(Table)
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(Length(t)*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,Length(t)),percentile)
        local RelativeToPos = {}
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,l_mist.vec.sub(t[i],referencePos))
        end

        return RelativeToPos
    end

    function HoundContact:calculateEllipse(estimatedPositions,Theta)

        local RelativeToPos = HoundContact.getDeltaSubsetPercent(estimatedPositions,self.pos.p,HOUND.ELLIPSE_PERCENTILE)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999





        if Theta == nil then
            Theta = HoundUtils.PointClusterTilt(RelativeToPos)
        end

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

        self.uncertenty_data = {}
        self.uncertenty_data.major = l_math.max(a,b)
        self.uncertenty_data.minor = l_math.min(a,b)
        self.uncertenty_data.az = l_mist.utils.round(l_math.deg((Theta + pi_2)%pi_2))
        self.uncertenty_data.r  = (a+b)/4

    end

    function HoundContact:calculatePos(estimatedPositions,converge)
        if estimatedPositions == nil then return end
        self.pos.p = l_mist.getAvgPoint(estimatedPositions)
        if converge then
            local subList = estimatedPositions
            local subsetPos = self.pos.p
            while (Length(subList) * HOUND.ELLIPSE_PERCENTILE) > 5 do
                local NewsubList = HoundContact.getDeltaSubsetPercent(subList,subsetPos,HOUND.ELLIPSE_PERCENTILE)
                subsetPos = l_mist.getAvgPoint(NewsubList)

                self.pos.p.x = self.pos.p.x + (subsetPos.x )
                self.pos.p.z = self.pos.p.z + (subsetPos.z )
                subList = NewsubList

            end
        end
        self.pos.p.y = land.getHeight({x=self.pos.p.x,y=self.pos.p.z})
        local bullsPos = coalition.getMainRefPoint(self._platformCoalition)
        self.pos.LL.lat, self.pos.LL.lon =  coord.LOtoLL(self.pos.p)
        self.pos.elev = self.pos.p.y
        self.pos.grid  = coord.LLtoMGRS(self.pos.LL.lat, self.pos.LL.lon)
        self.pos.be = HoundUtils.getBR(bullsPos,self.pos.p)

    end

    function HoundContact:processData()
        local newContact = (self.state == HOUND.EVENTS.RADAR_NEW)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}
        for _,platformDatapoints in pairs(self._dataPoints) do
            if Length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do
                    if datapoint.isReciverStatic then
                        table.insert(staticDataPoints,datapoint)
                    else
                        table.insert(mobileDataPoints,datapoint)
                    end
                    if datapoint.estimatedPos ~= nil then
                        table.insert(estimatePositions,datapoint.estimatedPos)
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
                    local err = (staticDataPoints[i].platformPrecision + staticDataPoints[j].platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoints[i].az,staticDataPoints[j].az) > err then
                        table.insert(estimatePositions,self.triangulatePoints(staticDataPoints[i],staticDataPoints[j]))
                    end
                end
            end
        end

        if numStaticPoints > 0  and numMobilepoints > 0 then
            for _,staticDataPoint in ipairs(staticDataPoints) do
                for _,mobileDataPoint in ipairs(mobileDataPoints) do
                    local err = (staticDataPoint.platformPrecision + mobileDataPoint.platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoint.az,mobileDataPoint.az) > err then
                        table.insert(estimatePositions,self.triangulatePoints(staticDataPoint,mobileDataPoint))
                    end
                end
            end
         end

        if numMobilepoints > 1 then
            for i=1,numMobilepoints-1 do
                for j=i+1,numMobilepoints do
                    if mobileDataPoints[i].platformPos  ~= mobileDataPoints[j].platformPos then
                        local err = (mobileDataPoints[i].platformPrecision + mobileDataPoints[j].platformPrecision)/2
                        if HoundUtils.angleDeltaRad(mobileDataPoints[i].az,mobileDataPoints[j].az) > err then
                            table.insert(estimatePositions,self.triangulatePoints(mobileDataPoints[i],mobileDataPoints[j]))
                        end
                    end
                end
            end
        end

        if Length(estimatePositions) > 2 then
            self:calculatePos(estimatePositions,true)
            self:calculateEllipse(estimatePositions)

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
        end

        return self.state
    end


    function HoundContact:removeMarkers()
        if self.markpointID ~= nil then
            for _ = 1, Length(self.markpointID) do
                trigger.action.removeMark(table.remove(self.markpointID))
            end
        end
    end

    function HoundContact:getMarkerId()
        if self.markpointID == nil then self.markpointID = {} end
        local idx = HoundUtils.getMarkId()
        table.insert(self.markpointID, idx)
        return idx
    end

    function HoundContact:drawAreaMarker(numPoints,debug)
        if numPoints == nil then numPoints = 1 end
        if numPoints ~= 1 and numPoints ~= 4 and numPoints ~=8 and numPoints ~= 16 then
            env.info("DCS limitation, only 1,4,8 or 16 points are allowed")
            numPoints = 1
            end

        local alpha = Map(l_math.floor(HoundUtils.absTimeDelta(self.last_seen)),0,HOUND.CONTACT_TIMEOUT,0.2,0.1)
        local fillcolor = {0,0,0,alpha}
        local linecolor = {0,0,0,alpha+0.15}
        if self._platformCoalition == coalition.side.BLUE then
            fillcolor[1] = 1
            linecolor[1] = 1
        end

        if self._platformCoalition == coalition.side.RED then
            fillcolor[3] = 1
            linecolor[3] = 1
        end

        if numPoints == 1 then
            trigger.action.circleToAll(self._platformCoalition,self:getMarkerId(),
            self.pos.p,self.uncertenty_data.r,linecolor,fillcolor,2,true)
            return
        end

        local angleStep = pi_2/numPoints
        local theta = l_math.rad(self.uncertenty_data.az)

        local polygonPoints = {}

        for i = 1, numPoints do
            local pointAngle = i * angleStep

            local point = {}
            point.x = self.uncertenty_data.major/2 * l_math.cos(pointAngle)
            point.z = self.uncertenty_data.minor/2 * l_math.sin(pointAngle)
            local x = point.x * l_math.cos(theta) - point.z * l_math.sin(theta)
            local z = point.x * l_math.sin(theta) + point.z * l_math.cos(theta)
            point.x = x + self.pos.p.x
            point.z = z + self.pos.p.z
            point.y = land.getHeight({x=point.x,y=point.z})+0.5

            table.insert(polygonPoints, point)
        end

        if numPoints == 4 then
            trigger.action.markupToAll(6,self._platformCoalition,self:getMarkerId(),
                polygonPoints[1], polygonPoints[2], polygonPoints[3], polygonPoints[4],
                linecolor,fillcolor,2,true)

        end
        if numPoints == 8 then
            trigger.action.markupToAll(7,self._platformCoalition,self:getMarkerId(),
                polygonPoints[1], polygonPoints[2], polygonPoints[3], polygonPoints[4],
                polygonPoints[5], polygonPoints[6], polygonPoints[7], polygonPoints[8],
                linecolor,fillcolor,2,true)
        end
        if numPoints == 16 then
            trigger.action.markupToAll(7,self._platformCoalition,self:getMarkerId(),
                polygonPoints[1], polygonPoints[2], polygonPoints[3], polygonPoints[4],
                polygonPoints[5], polygonPoints[6], polygonPoints[7], polygonPoints[8],
                polygonPoints[9], polygonPoints[10], polygonPoints[11], polygonPoints[12],
                polygonPoints[13], polygonPoints[14], polygonPoints[15], polygonPoints[16],
                linecolor,fillcolor,2,true)
        end
        if debug then
            return polygonPoints
        end
    end

    function HoundContact:updateMarker(MarkerType)
        if self.pos.p == nil or self.uncertenty_data == nil then return end

        self:removeMarkers()

        trigger.action.markToCoalition(self:getMarkerId(), self.typeName .. " " .. (self.uid%100) ..
                                " (" .. self.uncertenty_data.major .. "/" .. self.uncertenty_data.minor .. "@" .. self.uncertenty_data.az .. "|" ..
                                l_math.floor(HoundUtils.absTimeDelta(self.last_seen)) .. "s)",self.pos.p,self._platformCoalition,true)

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


    function HoundContact:getPrimarySector()
        return self.primarySector
    end

    function HoundContact:getSectors()
        return self.threatSectors
    end

    function HoundContact:isInSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    function HoundContact:updateDefaultSector()
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

    function HoundContact:updateSector(sectorName,inSector,threatsSector)
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

    function HoundContact:addSector(sectorName)
        self.threatSectors[sectorName] = true
        self:updateDefaultSector()
    end

    function HoundContact:removeSector(sectorName)
        if self.threatSectors[sectorName] then
            self.threatSectors[sectorName] = false
            self:updateDefaultSector()
        end
    end

    function HoundContact:isThreatsSector(sectorName)
        return self.threatSectors[sectorName] or false
    end


    function HoundContact:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DCSunitName = self.unit:getName()
        if self.pos.p ~= nil and self.uncertenty_data ~= nil then
            contact.pos = self.pos.p
            contact.accuracy = HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
            contact.uncertenty = {
                major = self.uncertenty_data.major,
                minor = self.uncertenty_data.minor,
                heading = self.uncertenty_data.az
            }
        end
        contact.maxWeaponsRange = self.maxWeaponsRange
        contact.last_seen = self.last_seen
        contact.detected_by = self.detected_by
        return contact
    end
end
do
    local l_math = math

    function HoundContact:getTextData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local GridPos = ""
        if utmZone then
            GridPos = GridPos .. self.pos.grid.UTMZone .. " "
        end
        GridPos = GridPos .. self.pos.grid.MGRSDigraph
        local BE = self.pos.be.brStr .. " for " .. self.pos.be.rng
        if MGRSdigits == nil then
            return GridPos,BE
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        GridPos = GridPos .. " " .. E .. " " .. N

        return GridPos,BE
    end

    function HoundContact:getTtsData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local phoneticGridPos = ""
        if utmZone then
            phoneticGridPos =  phoneticGridPos .. HoundUtils.TTS.toPhonetic(self.pos.grid.UTMZone) .. " "
        end

        phoneticGridPos =  phoneticGridPos ..  HoundUtils.TTS.toPhonetic(self.pos.grid.MGRSDigraph)
        local phoneticBulls = HoundUtils.TTS.toPhonetic(self.pos.be.brStr)
                                .. " for " .. self.pos.be.rng
        if MGRSdigits==nil then
            return phoneticGridPos,phoneticBulls
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        phoneticGridPos = phoneticGridPos .. " " .. HoundUtils.TTS.toPhonetic(E) .. "   " .. HoundUtils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end


    function HoundContact:generateTtsBrief(NATO)
        if self.pos.p == nil or self.uncertenty_data == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = string.gsub(self:getTypeAssigned(),"(SA)-",'')
            if reportedName == "Naval" then
                reportedName = self:getType()
            end
        end
        local str = reportedName .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos -- .. ", bullseye " .. phoneticBulls
        end
        str = str .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ) .. "."
        return str
    end

    function HoundContact:generateTtsReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,HOUND.MGRS_PRECISION)
        local msg =  self:getName() .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true)
        if BR ~= nil
            then
                msg = msg .. " from you " .. HoundUtils.TTS.toPhonetic(BR.brStr) .. " for " .. BR.rng
            else
                msg = msg .." at bullseye " .. phoneticBulls
        end
        local LLstr = HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon,useDMM)
        msg = msg .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
        msg = msg .. ", position " .. LLstr
        msg = msg .. ", I repeat " .. LLstr
        msg = msg .. ", MGRS " .. phoneticGridPos
        msg = msg .. ", elevation  " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. " feet MSL"
        msg = msg .. ", ellipse " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_data.major) .. " by " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_data.minor) .. ", aligned bearing " .. HoundUtils.TTS.toPhonetic(string.format("%03d",self.uncertenty_data.az))
        msg = msg .. ", Tracked for " .. HoundUtils.TTS.getVerbalContactAge(self.first_seen) .. ", last seen " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils.getControllerResponse()
        return msg
    end

    function HoundContact:generateTextReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local msg =  self:getName() .." (" .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true).. ")\n"
        msg = msg .. "Accuracy: " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ) .. "\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        if BR ~= nil then
            msg = msg .. "BR: " .. BR.brStr .. " for " .. BR.rng
        end
        msg = msg .. "LL: " .. HoundUtils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon,useDMM).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. "ft\n"
        msg = msg .. "Ellipse: " ..  self.uncertenty_data.major .. " by " ..  self.uncertenty_data.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_data.az) .. "\n"
        msg = msg .. "Tracked for: " .. HoundUtils.TTS.getVerbalContactAge(self.first_seen) .. " Last Contact: " ..  HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. "
        return msg
    end

    function HoundContact:generateRadioItemText()
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self:getName() .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end

    function HoundContact:generatePopUpReport(isTTS,sectorName)
        local msg = self:getName() .. " is now Alive"

        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            local GridPos,BePos
            if isTTS then
                GridPos,BePos = self:getTtsData(true,1)
                msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
            else
                GridPos,BePos = self:getTextData(true,1)
                msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
            end
        end
        return msg .. "."
    end

    function HoundContact:generateDeathReport(isTTS,sectorName)
        local msg = self:getName() .. " has been destroyed"
        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            local GridPos,BePos
            if isTTS then
                GridPos,BePos = self:getTtsData(true,1)
                msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
            else
                GridPos,BePos = self:getTextData(true,1)
                msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
            end
        end
        return msg .. "."
    end
end
do
    HoundCommsManager = {}
    HoundCommsManager.__index = HoundCommsManager

    function HoundCommsManager:create(sector,houndConfig,settings)
        if (not houndConfig and type(houndConfig) ~= "table") or
            (not sector and type(sector) ~= "string") then
                env.info("[Hound] - Comm Controller could not be initilized, missing params")
                return nil
        end
        local CommsManager = {}
        setmetatable(CommsManager, HoundCommsManager)
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


    function HoundCommsManager:updateSettings(settings)
        for k,v in pairs(settings) do
            local k0 = tostring(k):lower()
            if setContainsValue({"enabletts","enabletext","alerts"},k0) then
                self.preferences[k0] = v
            else
                self.settings[k0] = v
            end
        end
    end
    function HoundCommsManager:enable()
        self.enabled = true
        if self.scheduler == nil then
            self.scheduler = timer.scheduleFunction(self.TransmitFromQueue, self, timer.getTime() + self.settings.interval)
        end
        self:startCallbackLoop()
    end

    function HoundCommsManager:disable()
        if self.scheduler then
            timer.removeFunction(self.scheduler)
            self.scheduler = nil
        end
        self:stopCallbackLoop()
        self.enabled = false
    end


    function HoundCommsManager:isEnabled()
        return self.enabled
    end

    function HoundCommsManager:getSettings(key)
        local k0 = tostring(key):lower()
        if setContainsValue({"enabletts","enabletext","alerts"},k0) then
            return self.preferences[tostring(key):lower()]
        else
            return self.settings[tostring(key):lower()]
        end
    end

    function HoundCommsManager:setSettings(key,value)
        local k0 = tostring(key):lower()
        if setContainsValue({"enabletts","enabletext","alerts"},k0) then
            self.preferences[k0] = value
        else
            self.settings[k0] = value
        end
    end

    function HoundCommsManager:enableText()
        self:setSettings("enableText",true)
    end

    function HoundCommsManager:disableText()
        self:setSettings("enableText",false)
    end

    function HoundCommsManager:enableTTS()
        if STTS ~= nil then
            self:setSettings("enableTTS",true)
        end
    end

    function HoundCommsManager:disableTTS()
        self:setSettings("enableTTS",false)
    end

    function HoundCommsManager:enableAlerts()
        self:setSettings("alerts",true)
    end

    function HoundCommsManager:disableAlerts()
        self:setSettings("alerts",false)
    end

    function HoundCommsManager:setTransmitter(transmitterName)
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
            HoundEventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_ADDED,
                    houndId = self.houndConfig:getId(),
                    initiator = self.sector,
                    transmitter = candidate
                })
        end
    end

    function HoundCommsManager:removeTransmitter()
        if self.transmitter ~= nil then
            self.transmitter = nil
            HoundEventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_REMOVED,
                    houndId = self.houndConfig:getId(),
                    initiator = self.sector
                })
        end
    end

    function HoundCommsManager:getCallsign()
        return self:getSettings("name")
    end

    function HoundCommsManager:setCallsign(callsign)
        if type(callsign) == "string" then
            self:setSettings("name",callsign)
        end
    end

    function HoundCommsManager:getFreq()
        return self:getFreqs()[1]
    end

    function HoundCommsManager:getFreqs()
        local freqs = string.split(self.settings.freq,",")
        local mod = string.split(self.settings.modulation,",")
        local retval = {}

        for i,freq in ipairs(freqs) do
            local str = string.format("%.3f",tonumber(freq)) .. " " .. (mod[i] or "AM")
            table.insert(retval,str)
        end
        return retval
    end


    function HoundCommsManager:addMessageObj(obj)
        if obj.coalition == nil or not self.enabled then return end
        if obj.txt == nil and obj.tts == nil then return end
        if obj.priority == nil or obj.priority > 3 then obj.priority = 3 end
        if obj.priority == "loop" then
            self.loop.msg = obj
            return
        end
        table.insert(self._queue[obj.priority],obj)
    end

    function HoundCommsManager:addMessage(coalition,msg,prio)
        if msg == nil or coalition == nil or ( type(msg) ~= "string" and string.len(tostring(msg)) <= 0) or not self.enabled then return end
        if prio == nil or prio > 3 then prio = 3 end

        local obj = {
            coalition = coalition,
            priority = prio,
            tts = msg
        }

        self:addMessageObj(obj)
    end

    function HoundCommsManager:addTxtMsg(coalition,msg,prio)
        if msg == nil or string.len(tostring(msg)) == 0 or coalition == nil  or not self.enabled then return end
        if prio == nil then prio = 1 end
        local obj = {
            coalition = coalition,
            priority = prio,
            txt = msg
        }
        self:addMessageObj(obj)
    end

    function HoundCommsManager:getNextMsg()
        for i,v in ipairs(self._queue) do
            if #v > 0 then return table.remove(self._queue[i],1) end
        end
    end

    function HoundCommsManager:getTransmitterPos()
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

    function HoundCommsManager.TransmitFromQueue(gSelf)
        local msgObj = gSelf:getNextMsg()
        local readTime = gSelf.settings.interval
        if msgObj == nil then return timer.getTime() + readTime end
        local transmitterPos = gSelf:getTransmitterPos()

        if transmitterPos == false then
            env.info("[Hound] - Transmitter destroyed")
            HoundEventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_DESTROYED,
                    houndId = gSelf.houndConfig:getId(),
                    initiator = gSelf.sector,
                    transmitter = gSelf.transmitter
                })

            return timer.getTime() + 10
        end

        if gSelf.enabled and STTS ~= nil and msgObj.tts ~= nil and gSelf.preferences.enabletts then
            HoundUtils.TTS.Transmit(msgObj.tts,msgObj.coalition,gSelf.settings,transmitterPos)
            readTime = HoundUtils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed)
        end

        if gSelf.enabled and gSelf.preferences.enabletext and msgObj.txt ~= nil then
            readTime =  HoundUtils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed) or HoundUtils.TTS.getReadTime(msgObj.txt,gSelf.settings.speed)
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


    function HoundCommsManager:startCallbackLoop()
        return
    end

    function HoundCommsManager:stopCallbackLoop()
        return
    end

    function HoundCommsManager:SetMsgCallback()
        return
    end

    function HoundCommsManager:runCallback()
        return
    end
end

do

    HoundInformationSystem = {}
    HoundInformationSystem = inheritsFrom(HoundCommsManager)

    function HoundInformationSystem:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, self)
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


    function HoundInformationSystem:reportEWR(state)
        if type(state) == "boolean" then
            self:setSettings("reportEWR",state)
        end
    end


    function HoundInformationSystem:startCallbackLoop()
        if self.enabled and not self.callback.scheduler then
            self.callback.scheduler = timer.scheduleFunction(self.runCallback, self, timer.getTime()+0.1)
        end
    end

    function HoundInformationSystem:stopCallbackLoop()
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

    function HoundInformationSystem:SetMsgCallback(callback,args)
        if callback ~= nil and type(callback) == "function" then
            self.callback.func = callback
            self.callback.args = args
            self.callback.interval = self.houndConfig:getAtisUpdateInterval()
        end
        if self.callback.scheduler == nil and self.scheduler ~= nil then
            self.startCallbackLoop()
        end
    end

    function HoundInformationSystem:runCallback()
        local nextDelay = self.callback.interval or 300
        if self.callback ~= nil and type(self.callback.func) == "function"  then
            self.callback.func(self.callback.args,self.loop,self.preferences)
        end
        return timer.getTime() + nextDelay
    end

    function HoundInformationSystem:getNextMsg()
        if self.loop and not self.loop.msg then
            self:runCallback()
        end
        if self.loop and self.loop.msg and self.loop.msg.tts ~= nil and (string.len(self.loop.msg.tts) > 0 or string.len(self.loop.msg.txt) > 0) then
            return self.loop.msg
        end
    end
end

do

    HoundController = {}
    HoundController = inheritsFrom(HoundCommsManager)

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

do
    HoundNotifier = {}
    HoundNotifier = inheritsFrom(HoundCommsManager)

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
do
    HoundElintWorker = {}
    HoundElintWorker.__index = HoundElintWorker

    local l_math = math
    function HoundElintWorker.create(HoundInstanceId)
        local instance = {}
        instance._contacts = {}
        instance._platforms = {}
        instance._settings =  HoundConfig.get(HoundInstanceId)
        instance.coalitionId = nil
        setmetatable(instance, HoundElintWorker)
        return instance
    end

    function HoundElintWorker:setCoalition(coalitionId)
        if not coalitionId then return false end
        if not self._settings:getCoalition() then
            self._settings:setCoalition(coalitionId)
            return true
        end
        return false
    end

    function HoundElintWorker:getCoalition()
        return self._settings:getCoalition()
    end

    function HoundElintWorker:addPlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if self:getCoalition() == nil and candidate ~= nil then
            self:setCoalition(candidate:getCoalition())
        end

        if candidate ~= nil and candidate:getCoalition() == self:getCoalition() then
            local mainCategory = candidate:getCategory()
            local type = candidate:getTypeName()

            if setContains(HoundDB.Platform,mainCategory) then
                if setContains(HoundDB.Platform[mainCategory],type) then
                    for _,v in pairs(self._platforms) do
                        if v == candidate then
                            return
                        end
                    end
                    table.insert(self._platforms, candidate)
                    HoundEventHandler.publishEvent({
                        id = HOUND.EVENTS.PLATFORM_ADDED,
                        initiator = candidate,
                        houndId = self._settings:getId(),
                        coalition = self._settings:getCoalition()
                    })
                    return true
                end
            end
        end
        env.info("[Hound] - Failed to add platform "..platformName..". Make sure you use unit name.")
        return false
    end

    function HoundElintWorker:removePlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if candidate ~= nil then
            for k,v in ipairs(self._platforms) do
                if v == candidate then
                    table.remove(self._platforms, k)
                    HoundEventHandler.publishEvent({
                        id = HOUND.EVENTS.PLATFORM_REMOVED,
                        initiator = candidate,
                        houndId = self._settings:getId(),
                        coalition = self._settings:getCoalition()
                    })
                    return true
                end
            end
        end
        return false
    end

    function HoundElintWorker:platformRefresh()
        if Length(self._platforms) < 1 then return end
        for id,platform in ipairs(self._platforms) do
            if platform:isExist() == false or platform:getLife() <1 then
                table.remove(self._platforms, id)
                HoundEventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self._settings:getId(),
                    coalition = self._settings:getCoalition()
                })
            end
        end
    end

    function HoundElintWorker:removeDeadPlatforms()
        if Length(self._platforms) < 1 then return end
        for id,platform in ipairs(self._platforms) do
            if platform:isExist() == false or platform:getLife() <1  or (platform:getCategory() ~= Object.Category.STATIC and platform:isActive() == false) then
                table.remove(self._platforms, id)
                HoundEventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self._settings:getId(),
                    coalition = self._settings:getCoalition()
                })
            end
        end
    end

    function HoundElintWorker:countPlatforms()
        return Length(self._platforms)
    end

    function HoundElintWorker:listPlatforms()
        local platforms = {}
        for _,platform in ipairs(self._platforms) do
            table.insert(platforms,platform:getName())
        end
        return platforms
    end

    function HoundElintWorker:addContact(emitter)
        if emitter == nil or emitter.getID == nil then return end
        local uid = emitter:getID()
        if self._contacts[uid] ~= nil then return uid end
        self._contacts[uid] = HoundContact.New(emitter, self:getCoalition())
        HoundEventHandler.publishEvent({
            id = HOUND.EVENTS.RADAR_NEW,
            initiator = emitter,
            houndId = self._settings:getId(),
            coalition = self._settings:getCoalition()
        })
        return uid
    end

    function HoundElintWorker:getContact(emitter)
        if emitter == nil then return nil end
        local uid = nil
        if type(emitter) =="number" then
            uid = emitter
        end
        if type(emitter) == "table" and emitter.getID ~= nil then
            uid = emitter:getID()
        end

        if uid ~= nil and self._contacts[uid] ~= nil then return self._contacts[uid] end
        if not self._contacts[uid] and type(emitter) == "table" then
            self:addContact(emitter)
            return self._contacts[uid]
        end
        return nil
    end

    function HoundElintWorker:removeContact(uid)
        if not uid then return false end
        HoundEventHandler.publishEvent({
            id = HOUND.EVENTS.RADAR_DESTROYED,
            initiator = self._contacts[uid],
            houndId = self._settings:getId(),
            coalition = self._settings:getCoalition()
        })

        self._contacts[uid] = nil
        return true
    end

    function HoundElintWorker:isTracked(emitter)
        if emitter == nil then return false end
        if type(emitter) =="number" and self._contacts[emitter] ~= nil then return true end
        if type(emitter) == "table" and emitter.getID ~= nil and self._contacts[emitter:getID()] ~= nil then return true end
        return false
    end

    function HoundElintWorker:addDatapointToEmitter(emitter,datapoint)
        if not self:isTracked(emitter) then
            self:addContact(emitter)
        end
        local HoundContact = self:getContact(emitter)
        HoundContact:AddPoint(datapoint)
    end

    function HoundElintWorker:listInSector(sectorName)
        local emitters = {}
        for _,emitter in ipairs(self._contacts) do
            if emitter:isInSector(sectorName) then
                table.insert(emitters,emitter)
            end
        end
        table.sort(emitters,HoundUtils.Sort.ContactsByRange)
        return emitters
    end

    function HoundElintWorker:UpdateMarkers()
        if self._settings:getUseMarkers() then
            for _, contact in pairs(self._contacts) do
                contact:updateMarker(self._settings:getMarkerType())
            end
        end
    end

    function HoundElintWorker:listAll(sectorName)
        if sectorName then
            local contacts = {}
            for _,emitter in pairs(self._contacts) do
                if emitter:isInSector(sectorName) then
                        table.insert(contacts,emitter)
                end
            end
            return contacts
        end
        return self._contacts
    end

    function HoundElintWorker:listAllbyRange(sectorName)
        return self:sortContacts(HoundUtils.Sort.ContactsByRange,sectorName)
    end

    function HoundElintWorker:countContacts(sectorName)
        if sectorName then
            local contacts = 0
            for _,contact in pairs(self._contacts) do
                if contact:isInSector(sectorName) then
                    contacts = contacts + 1
                end
            end
            return contacts
        end
        return Length(self._contacts)
    end

    function HoundElintWorker:sortContacts(sortFunc,sectorName)
        if type(sortFunc) ~= "function" then return end
        local sorted = {}
        for _,emitter in pairs(self._contacts) do
            if sectorName then
                if emitter:isInSector(sectorName) then
                    table.insert(sorted,emitter)
                end
            else
                table.insert(sorted,emitter)
            end
        end
        table.sort(sorted, sortFunc)
        return sorted
    end

    function HoundElintWorker:Sniff()
        self:removeDeadPlatforms()

        if Length(self._platforms) == 0 then
            env.info("no active platform")
            return
        end

        local Radars = HoundUtils.Elint.getActiveRadars(self:getCoalition())

        if Length(Radars) == 0 then
            env.info("No Transmitting Radars")
            return
        end
        for _,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + radar:getDesc()["box"]["max"]["y"] -- use vehicle bounting box for height

            for _,platform in ipairs(self._platforms) do
                local platformPos = platform:getPosition().p
                local platformIsStatic = false
                local isAerialUnit = false
                local posErr = {x = 0, z = 0, y = 0 }

                if platform:getCategory() == Object.Category.STATIC then
                    platformIsStatic = true
                    platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                else
                    local PlatformUnitCategory = platform:getDesc()["category"]
                    if PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE then
                        isAerialUnit = true
                        posErr = HoundUtils.Vector.getRandomVec3(self._settings:getPosErr())
                    end

                    if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
                        platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                    end
                end

                if HoundUtils.checkLOS(platformPos, radarPos) then
                    local contact = self:getContact(radar)
                    local sampleAngularResolution = HoundUtils.Elint.getSensorPrecision(platform,contact.band)
                    if sampleAngularResolution < l_math.rad(15.0) then
                        local az,el = HoundUtils.Elint.getAzimuth( platformPos, radarPos, sampleAngularResolution )
                        if not isAerialUnit then
                            el = nil
                        else
                            for axis,value in pairs(platformPos) do
                                platformPos[axis] = value + posErr[axis]
                            end
                        end

                        local datapoint = HoundDatapoint.New(platform,platformPos, az, el, timer.getAbsTime(),sampleAngularResolution,platformIsStatic)
                        contact:AddPoint(datapoint)
                    end
                end
            end
        end
    end

    function HoundElintWorker:Process()
        if Length(self._contacts) < 1 then return end
        for uid, contact in pairs(self._contacts) do
            if contact ~= nil then
                local contactState = contact:processData()
                if contactState == HOUND.EVENTS.RADAR_DETECTED then
                    if self._settings:getUseMarkers() then contact:updateMarker(self._settings:getMarkerType()) end
                end
                if contact:isTimedout() then
                    contact:CleanTimedout()
                    contactState = HOUND.EVENTS.RADAR_ASLEEP
                end
                if self._settings:getBDA() and contact:isAlive() == false and HoundUtils.absTimeDelta(contact.last_seen, timer.getAbsTime()) > 60 then
                    contact:destroy()
                    self:removeContact(uid)

                else
                    HoundEventHandler.publishEvent({
                        id = contactState,
                        initiator = contact,
                        houndId = self._settings:getId(),
                        coalition = self._settings:getCoalition()
                    })
                end
            end
        end
    end
end
do
    HoundContactManager = {
        _workers = {}
    }

    HoundContactManager.__index = HoundContactManager

    function HoundContactManager.get(HoundInstanceId)
        if HoundContactManager._workers[HoundInstanceId] then
            return HoundContactManager._workers[HoundInstanceId]
        end

        local worker = HoundElintWorker.create(HoundInstanceId)
        HoundContactManager._workers[HoundInstanceId] = worker

        return HoundContactManager._workers[HoundInstanceId]
    end
end
do
    local l_mist = mist
    local l_math = math
    HoundSector = {}
    HoundSector.__index = HoundSector

    function HoundSector.create(HoundId, name, settings, priority)
        if type(HoundId) ~= "number" or type(name) ~= "string" then
            HoundLogger.warn("[Hound] - HoundSector.create() missing params")
            return
        end

        local instance = {}
        setmetatable(instance, HoundSector)
        instance.name = name
        instance._hSettings = HoundConfig.get(HoundId)
        instance._contacts = HoundContactManager.get(HoundId)
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

    function HoundSector:updateSettings(settings)
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

    function HoundSector:destroy()
        self:removeRadioMenu()
        for _,contact in pairs(self._contacts:listAll()) do
            contact:removeSector(self.name)
        end
        return
    end

    function HoundSector:updateServices()
        if type(self.settings.controller) == "table" then
            if not self.comms.controller then
                self.settings.controller.name = self.callsign
                self.comms.controller = HoundController:create(self.name,self._hSettings,self.settings.controller)
            else
                self.settings.controller.name = self.callsign
                self.comms.controller:updateSettings(self.settings.controller)
                self.comms.controller:setCallsign(self.callsign)

            end
        end
        if type(self.settings.atis) == "table" then
            if not self.comms.atis then
                self.settings.atis.name = self.callsign
                self.comms.atis = HoundInformationSystem:create(self.name,self._hSettings,self.settings.atis)
            else
                self.settings.atis.name = self.callsign
                self.comms.atis:updateSettings(self.settings.atis)
                self.comms.atis:setCallsign(self.callsign)
            end
        end
        if type(self.settings.notifier) == "table" then
            if not self.comms.notifier then
                self.settings.notifier.name = self.callsign
                self.comms.notifier = HoundNotifier:create(self.name,self._hSettings,self.settings.notifier)
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

    function HoundSector:getName()
        return self.name
    end

    function HoundSector:getPriority()
        return self.priority
    end

    function HoundSector:setCallsign(callsign, NATO)
        local namePool = "GENERIC"
        if callsign ~= nil and type(callsign) == "boolean" then
            NATO = callsign
            callsign = nil
        end
        if NATO == true then namePool = "NATO" end

        callsign = string.upper(callsign or HoundUtils.getHoundCallsign(namePool))
        while setContains(self._hSettings.callsigns, callsign) do
            callsign = HoundUtils.getHoundCallsign(namePool)
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

    function HoundSector:getCallsign()
        return self.callsign
    end

    function HoundSector:getZone()
        return self.settings.zone
    end

    function HoundSector:setZone(zonecandidate)
        if self.name == "default" then
            HoundLogger.warn("[Hound] - cannot set zone to default sector")
            return
        end
        if zonecandidate and Group.getByName(zonecandidate) then
            self.settings.zone = mist.getGroupPoints(zonecandidate)
        end
    end

    function HoundSector:removeZone() self.settings.zone = nil end

    function HoundSector:setTransmitter(userTransmitter)
        if not userTransmitter then return end
        self.settings.transmitter = userTransmitter
        self:updateTransmitter()
    end

    function HoundSector:updateTransmitter()
        for k, v in pairs(self.comms) do
            if k ~= "menu" and v.setTransmitter then v:setTransmitter(self.settings.transmitter) end
        end
    end

    function HoundSector:removeTransmitter()
        self.settings.transmitter = nil
        for k, v in pairs(self.comms) do
            if k ~= "menu" then v:removeTransmitter() end
        end
    end

    function HoundSector:updateSectorMembership(contact)
        local inSector, threatsSector = HoundUtils.Polygon.threatOnSector(self.settings.zone,contact:getPos(),contact:getMaxWeaponsRange())
        HoundLogger.trace(tostring(inSector) .. " " .. tostring(threatsSector))
        contact:updateSector(self.name, inSector, threatsSector)
    end

    function HoundSector:enableController(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { controller = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.controller:enable()
        self:populateRadioMenu()
    end

    function HoundSector:disableController()
        if self.comms.controller then
            self:removeRadioMenu()
            self.comms.controller:disable()
        end
    end

    function HoundSector:removeController()
        self.settings.controller = nil
        if self.comms.controller then
            self:disableController()
            self.comms.controller = nil
        end
    end

    function HoundSector:getControllerFreq()
        if self.comms.controller then
            return self.comms.controller:getFreqs()
        end
        return {}
    end

    function HoundSector:transmitOnController(msg)
        if not self.comms.controller or not self.comms.controller:isEnabled() then return end
        if type(msg) ~= "string" then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition()}
        msgObj.tts = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end

    function HoundSector:enableText()
        if self.comms.controller then self.comms.controller:enableText() end
    end

    function HoundSector:disableText()
        if self.comms.controller then self.comms.controller:disableText() end
    end

    function HoundSector:enableAlerts()
        if self.comms.controller then self.comms.controller:enableAlerts() end
    end

    function HoundSector:disableAlerts()
        if self.comms.controller then self.comms.controller:disableAlerts() end
    end

    function HoundSector:enableTTS()
        if self.comms.controller then self.comms.controller:enableTTS() end
    end

    function HoundSector:disableTTS()
        if self.comms.controller then self.comms.controller:disableTTS() end
    end

    function HoundSector:enableAtis(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { atis = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.atis:SetMsgCallback(HoundSector.generateAtis, self)
        self.comms.atis:enable()
    end

    function HoundSector:disableAtis()
        if self.comms.atis then self.comms.atis:disable() end
    end

    function HoundSector:removeAtis()
        self.settings.atis = nil
        if self.comms.atis then
            self:disableAtis()
            self.comms.atis = nil
        end
    end

    function HoundSector:getAtisFreq()
        if self.comms.atis then
            return self.comms.atis:getFreqs()
        end
        return {}
    end

    function HoundSector:reportEWR(state)
        if self.comms.atis then self.comms.atis:reportEWR(state) end
    end

    function HoundSector:hasAtis() return self.comms.atis ~= nil end

    function HoundSector:isAtisEnabled()
        return self.comms.atis ~= nil and self.comms.atis:isEnabled()
    end

    function HoundSector:hasController() return self.comms.controller ~= nil end

    function HoundSector:isControllerEnabled()
        return self.comms.controller ~= nil and self.comms.controller:isEnabled()
    end

    function HoundSector:enableNotifier(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { notifier = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.notifier:enable()
    end

    function HoundSector:disableNotifier()
        if self.comms.notifier then self.comms.notifier:disable() end
    end

    function HoundSector:removeNotifier()
        self.settings.notifier = nil
        if self.comms.notifier then
            self:disableNotifier()
            self.comms.notifier = nil
        end
    end

    function HoundSector:getNotifierFreq()
        if self.comms.notifier then
            return self.comms.notifier:getFreqs()
        end
        return {}
    end

    function HoundSector:hasNotifier()
        return self.comms.notifier ~= nil
    end

    function HoundSector:isNotifierEnabled()
        return self.comms.notifier ~= nil and self.comms.notifier:isEnabled()
    end

    function HoundSector:getContacts()
        local effectiveSectorName = self.name
        if not self:getZone() then
            effectiveSectorName = "default"
        end
        return self._contacts:listAllbyRange(effectiveSectorName)
    end

    function HoundSector:countContacts()
        local effectiveSectorName = self.name
        if not self:getZone() then
            effectiveSectorName = "default"
        end
        return self._contacts:countContacts(effectiveSectorName)
    end

    function HoundSector.removeRadioMenu(self)
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

    function HoundSector:findGrpInPlayerList(grpId,playersList)
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

    function HoundSector:getSubscribedGroups()
        local subscribedGid = {}
        for _,player in pairs(self.comms.menu.enrolled) do
            local grpId = player.groupId
            if not setContainsValue(subscribedGid,grpId) then
                table.insert(subscribedGid,grpId)
            end
        end
        return subscribedGid
    end

    function HoundSector:validateEnrolled()
        if Length(self.comms.menu.enrolled) == 0 then return end
        for _, player in pairs(self.comms.menu.enrolled) do
            local playerUnit = Unit.getByName(player.unitName)
            if not playerUnit or not playerUnit:getPlayerName() then
                self.comms.menu.enrolled[player] = nil
            end
        end
    end

    function HoundSector.checkIn(args,skipAck)
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

    function HoundSector.checkOut(args,skipAck)
        local gSelf = args["self"]
        local player = args["player"]
        gSelf.comms.menu.enrolled[player] = nil
        for _,otherPlayer in pairs(gSelf:findGrpInPlayerList(player.groupId)) do
            gSelf.comms.menu.enrolled[otherPlayer] = nil
        end
        gSelf:populateRadioMenu()
        if not skipAck then
            gSelf:TransmitCheckOutAck(player)
        end
    end

    function HoundSector:createCheckIn()
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
                                            self.comms.menu.root,HoundSector.checkOut,
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
                                                        HoundSector.checkIn, {
                            self = self,
                            player = player
                        })
                end
            end
        end
    end

    function HoundSector:populateRadioMenu()
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

                if not grpMenuDone[grpId] then
                    grpMenuDone[grpId] = true

                    if not grpMenu.data then
                        grpMenu.data = {}
                        grpMenu.data.gid = grpId
                        grpMenu.data.player = player
                        grpMenu.data.useDMM = HoundUtils.isDMM(player.type)
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

    function HoundSector:addRadarRadioItem(dataMenu,contact)
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

    function HoundSector:removeRadarRadioItem(dataMenu,contact)
        local assigned = contact:getTypeAssigned()
        local uid = contact.uid
        if not self.comms.controller or not self.comms.controller:isEnabled() or dataMenu.menus[assigned] == nil then
            return
        end

        if setContains(dataMenu.menus[assigned].data,uid) then
            dataMenu.menus[assigned].data[uid] = missionCommands.removeItemForGroup(dataMenu.gid, dataMenu.menus[assigned].data[uid])
        end
    end


    function HoundSector:notifyDeadEmitter(contact)
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

        local announce = "All Aircraft, " .. self.callsign .. ". "
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

    function HoundSector:notifyNewEmitter(contact)
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

        local announce = "Attention All Aircraft! This is " .. self.callsign .. ". New threat detected! "
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 2 , gid=enrolledGid}
        if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = "New threat detected! " .. contact:generatePopUpReport(false,contactPrimarySector)
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

    function HoundSector:generateAtis(loopData,AtisPreferences)
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
            HoundUtils.getReportId(loopData.reportIdx)
        local header = self.callsign
        if self._hSettings:getNATO() then
            header = header .. " Lowdown "
        else
            header = header .. " SAM information "
        end
        header = header .. reportId .. " " ..
                                    HoundUtils.TTS.getTtsTime() .. ". "
        local footer = "you have " .. reportId .. "."

        local msgObj = {
            coalition = self._hSettings:getCoalition(),
            priority = "loop",
            updateTime = timer.getAbsTime(),
            tts = header .. loopData.body .. footer
        }
        loopData.msg = msgObj
    end

    function HoundSector.TransmitSamReport(args)
        local gSelf = args["self"]
        local contact = args["contact"]
        local requester = args["requester"]
        local coalitionId = gSelf._hSettings:getCoalition()
        local msgObj = {coalition = coalitionId, priority = 1}
        local useDMM = false
        if contact.isEWR then msgObj.priority = 2 end

        if requester ~= nil then
            msgObj.gid = requester.groupId
            useDMM =  HoundUtils.isDMM(requester.type)
        end

        if gSelf.comms.controller:isEnabled() then
            msgObj.tts = contact:generateTtsReport(useDMM)
            if requester ~= nil then
                msgObj.tts = HoundUtils.getFormationCallsign(requester) .. ", " .. gSelf.callsign .. ", " ..
                                 msgObj.tts
            end
            if gSelf.comms.controller:getSettings("enableText") == true then
                msgObj.txt = contact:generateTextReport(useDMM)
            end
            gSelf.comms.controller:addMessageObj(msgObj)
        end
    end

    function HoundSector:TransmitCheckInAck(player)
        if not player then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition(), gid = player.groupId}
        local msg = HoundUtils.getFormationCallsign(player) .. ", " .. self.callsign .. ", Roger. "
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

    function HoundSector:TransmitCheckOutAck(player)
        if not player then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition(), gid = player.groupId}
        local msg = HoundUtils.getFormationCallsign(player) .. ", " .. self.callsign .. ", copy checking out. "
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
            HoundLogger.error("Failed to initialize Hound instace. Please provide coalition")
            return
        end
        local elint = {}
        setmetatable(elint, HoundElint)
        elint.settings = HoundConfig.get()
        elint.HoundId = elint.settings:getId()
        elint.contacts = HoundContactManager.get(elint.HoundId)
        elint.elintTaskID = nil
        elint.radioAdminMenu = nil
        elint.coalitionId = nil

        elint.timingCounters = {
            short = false,
            long = 0
        }

        if platformName ~= nil then
            if type(platformName) == "string" then
                elint:addPlatform(platformName)
            else
                elint:setCoalition(platformName)
            end
        end

        elint.sectors = {
            default = HoundSector.create(elint.HoundId,"default",nil,100)
        }
        return elint
    end

    function HoundElint:destroy()
        self:systemOff(false)
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


    function HoundElint:countContacts()
        return self.contacts:countContacts()
    end


    function HoundElint:addSector(sectorName,sectorSettings,priority)
        if type(sectorName) ~= "string" then return false end
        if string.lower(sectorName) == "default" or string.lower(sectorName) == "all" then
            HoundLogger.info(sectorName.. " is a reserved sector name")
            return nil
        end
        priority = priority or 50
        if not self.sectors[sectorName] then
            self.sectors[sectorName] = HoundSector.create(self.settings:getId(),sectorName,sectorSettings,priority)
            return self.sectors[sectorName]
        end

        return nil
    end

    function HoundElint:removeSector(sectorName)
        if sectorName == nil then return false end
        self.sectors[sectorName] = self.sectors[sectorName]:destroy()
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
            end

            if addToList then
                table.insert(sectors,sector)
            end
        end
        return sectors
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

    function HoundElint:setSectorCallsign(sectorName,sectorCallsign)
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

    function HoundElint:getSectorCallsign(sectorName)
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
        if type(zoneCandidate) ~= "string" then return end
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
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowFirst)
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
        return self.settings:setRadioMenuParent(parent) or false
    end



    function HoundElint.runCycle(self)
        local nextRun = timer.getTime() + Gaussian(self.settings.mainInterval,3)
        if self.settings:getCoalition() == nil then return nextRun end
        if not self.contacts then return nextRun end

        self.contacts:platformRefresh()
        self.contacts:Sniff()

        if self.contacts:countContacts() > 0 then
            self.timingCounters.short = not self.timingCounters.short
            if self.timingCounters.short then
                self.contacts:Process()
                self.timingCounters.long = self.timingCounters.long + 1
                for sectorName,_ in pairs(self.sectors) do
                    HoundLogger.trace(sectorName .. " has " .. self.contacts:countContacts(sectorName).. "Contacts")
                end
            end
            if self.timingCounters.long == 2 then
                self:populateRadioMenu()
                self.contacts:UpdateMarkers()
                self:updateSectorMembership()
                self.timingCounters.long = 0
            end
        end
        return nextRun
    end

    function HoundElint:purgeRadioMenu()
        for _,sectorName in pairs(self.sectors) do
            self.sectors[sectorName]:removeRadioMenu()
        end
        self.settings:removeRadioMenu()
    end

    function HoundElint:populateRadioMenu()
        if not self.contacts or self.contacts:countContacts() == 0 or self.settings:getCoalition() == nil then
            return
        end
        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowLast)
        for _,sector in pairs(sectors) do
            sector:populateRadioMenu()
        end
        return nextRun
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
            HoundLogger.warn("failed to start. no coalition found.")
            return false
        end
        self:systemOff(false)

        self.elintTaskID = timer.scheduleFunction(self.runCycle, self, timer.getTime() + self.settings.mainInterval)
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Operating", 10)
        end
        self:defaultEventHandler()
        env.info("Hound is now on")
        HoundEventHandler.publishEvent({id=HOUND.EVENTS.HOUND_ENABLED, houndId = self.settings:getId(), coalition = self.settings:getCoalition()})
        return true
    end

    function HoundElint:systemOff(notify)
        self:defaultEventHandler(false)
        if self.elintTaskID ~= nil then
            timer.removeFunction(self.elintTaskID)
        end
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Offline", 10)
        end
        env.info("Hound is now off")
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


    function HoundElint:onHoundEvent(houndEvent)
        if houndEvent.id == HOUND.EVENTS.HOUND_DISABLED then return end
        if houndEvent.houndId ~= self.settings:getId() then
            return
        end
        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowFirst)

        if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then

            for _,sector in pairs(sectors) do
                sector:updateSectorMembership(houndEvent.initiator)
            end
            for _,sector in pairs(sectors) do
                sector:notifyNewEmitter(houndEvent.initiator)
            end
        end

        if houndEvent.id == HOUND.EVENTS.RADAR_DESTROYED and self.settings:getBDA() then
            for _,sector in pairs(sectors) do
                sector:notifyDeadEmitter(houndEvent.initiator)
            end
        end
    end

    function HoundElint:onEvent(DcsEvent)
        if DcsEvent.id == world.event.S_EVENT_BIRTH
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and setContains(mist.DBs.humansByName,DcsEvent.initiator:getName())
            then
                self:populateRadioMenu()
        end
    end

    function HoundElint:defaultEventHandler(remove)
        if remove == false then
            HoundEventHandler.removeInternalEventHandler(self)
            world.removeEventHandler(self)
            return
        end
        HoundEventHandler.addInternalEventHandler(self)
        world.addEventHandler(self)
    end

    function HoundElint:addEventHandler(handler)
        HoundEventHandler.addEventHandler(handler)
    end

    function HoundElint:removeEventHandler(handler)
        HoundEventHandler.removeEventHandler(handler)
    end
end
do
    trigger.action.outText("Hound ELINT ("..HOUND.VERSION..") is loaded.", 15)
    env.info("[Hound] - finished loading (".. HOUND.VERSION..")")
end
-- Hound version 0.2.0-feature/radio_refactor - Compiled on 2021-10-20 21:30
