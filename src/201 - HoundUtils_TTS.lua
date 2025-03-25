        --- HOUND.Utils
    -- This class holds generic function used by all of Hound Components
    -- @module HOUND.Utils
do
    local l_mist = HOUND.Mist
    local l_math = math
    local l_grpc = GRPC
    local PI_2 = 2*l_math.pi

    HOUND.Utils.TTS = {}
    --- TTS Functions
    -- @section TTS

    --- Check if TTS agent is available (private)
    -- @return[type=Bool] True if TTS is available
    function HOUND.Utils.TTS.isAvailable()
        for _,engine in ipairs(HOUND.TTS_ENGINE) do
            if engine == "GRPC" and (l_grpc ~= nil and type(l_grpc.tts) == "function") then return true end
            if engine == "STTS" and STTS ~= nil then return true end
        end
        return false
    end

    --- Return default Modulation based on frequency
    -- @param freq The frequency in Mhz, Hz or table of frequencies
    -- @return Modulation string "AM" or "FM"
    function HOUND.Utils.TTS.getdefaultModulation(freq)
        if not freq then return "AM" end
        if tonumber(freq) ~= nil then
            freq = tonumber(freq)
            if freq < 90 or (freq > 1000000 and freq < (90 * 1000000)) then
                return "FM"
            else
                return "AM"
            end
        end
        if type(freq) == "string" then
            freq = string.split(freq,",")
        end
        if type(freq) == "table" then
            local retval = {}
            for _,frequency in ipairs(freq) do
                table.insert(retval,HOUND.Utils.TTS.getdefaultModulation(tonumber(frequency)))
            end
            return table.concat(retval,",")
        end
        return "AM"
    end
    --- Transmit message using STTS (private)
    -- @param msg The message to transmit
    -- @param coalitionID Coalition to recive transmission
    -- @param args STTS settings in hash table (minimum required is {freq=})
    -- @param[opt] transmitterPos DCS Position point for transmitter
    -- @return STTS.TextToSpeech return value recived from STTS, currently estimated speechTime

    function HOUND.Utils.TTS.Transmit(msg,coalitionID,args,transmitterPos)
        if not HOUND.Utils.TTS.isAvailable() then return end
        if msg == nil then return end
        if coalitionID == nil then return end

        if args.freq == nil then return end
        args.volume = args.volume or "1.0"
        args.name = args.name or "Hound"
        args.gender = args.gender or "female"
        if type(args.engine) ~= "string" or not HOUND.setContainsValue(HOUND.TTS_ENGINE,args.engine) then
            for _,engine in ipairs(HOUND.TTS_ENGINE) do
                if engine == "GRPC" and (l_grpc ~= nil and type(l_grpc.tts) == "function") then
                    -- HOUND.Logger.debug("gRPC TTS message: "..msg)
                    args.engine = engine
                    break
                end
                if engine == "STTS" and STTS ~= nil then
                    args.engine = engine
                    break
                end
            end
        end
        if args.engine == "STTS" then
            return HOUND.Utils.TTS.TransmitSTTS(msg,coalitionID,args,transmitterPos)
        end
        if args.engine == "GRPC" then
            return HOUND.Utils.TTS.TransmitGRPC(msg,coalitionID,args,transmitterPos)
        end
    end

    --- Transmit message using STTS
    -- @local
    -- @param msg The message to transmit
    -- @param coalitionID Coalition to recive transmission
    -- @param args STTS settings in hash table (minimum required is {freq=})
    -- @param[opt] transmitterPos DCS Position point for transmitter
    -- @return currently estimated speechTime
    function HOUND.Utils.TTS.TransmitSTTS(msg,coalitionID,args,transmitterPos)
        args.modulation = args.modulation or HOUND.Utils.TTS.getdefaultModulation(args.freq)
        args.culture = args.culture or "en-US"
        return STTS.TextToSpeech(msg,args.freq,args.modulation,args.volume,args.name,coalitionID,transmitterPos,args.speed,args.gender,args.culture,args.voice,args.googletts,args.azurecreds)
    end

    --- Transmit message using gRPC.tts
    -- @local
    -- @param msg The message to transmit
    -- @param coalitionID Coalition to recive transmission
    -- @param args STTS settings in hash table (minimum required is {freq=})
    -- @param[opt] transmitterPos DCS Position point for transmitter
    -- @return currently estimated speechTime
    function HOUND.Utils.TTS.TransmitGRPC(msg,coalitionID,args,transmitterPos)
        local VOLUME = {"default","x-slow", "slow", "medium", "fast", "x-fast"}
        local ssml_msg = msg

        local grpc_ttsArgs = {
            srsClientName = args.name,
            coalition = HOUND.Utils.getCoalitionString(coalitionID):lower(),
        }
        if type(transmitterPos) == "table" then
            grpc_ttsArgs.position = {}
            grpc_ttsArgs.position.lat, grpc_ttsArgs.position.lon, grpc_ttsArgs.position.alt = coord.LOtoLL( transmitterPos )
        end
        if type(args.provider) == "table" then
            grpc_ttsArgs.provider = args.provider
        end

        local readSpeed = 1.0
        if args.speed ~= 0 then
            if args.speed > 10 then
                readSpeed = HOUND.Utils.Mapping.linear(args.speed,50,250,0.5,2.5,true)
            else
                if args.speed > 0 then
                    -- 250% = 10
                    readSpeed = HOUND.Utils.Mapping.linear(args.speed,0,10,1.0,2.5,true)
                else
                    -- 50% = -10
                    readSpeed = HOUND.Utils.Mapping.linear(args.speed,-10,0,0.5,1.0,true)
                end
            end
        end

        local ssml_prosody = ""
        if readSpeed ~= 1.0  then
            ssml_prosody = ssml_prosody .. " rate='"..readSpeed.."'"
        end

        if args.volume ~= 1.0 then
            local volume = ""

            if HOUND.setContainsValue(VOLUME,args.volume) then
                volume = args.volume
            end

            if type(args.volume)=="number" then
                if args.volume ~= 0 then
                    volume = (args.volume*100)-100 .. "%"
                    if args.volume > 1 then
                        volume = "+" .. volume
                    end
                else
                    volume = "slient"
                end
            end

            if string.len(volume) > 0 then
                ssml_prosody = ssml_prosody .. " volume='"..volume.."'"
            end
        end
        if string.len(ssml_prosody) > 0 then
            ssml_msg = table.concat({"<prosody",ssml_prosody,">",ssml_msg,"</prosody>"},"")
        end

        local ssml_voice = ""
        if args.voice then
            ssml_voice = ssml_voice.." name='"..args.voice.."'"
        else
            if args.gender then
                ssml_voice = ssml_voice.." gender='"..args.gender.."'"
            end
            if args.culture then
                ssml_voice = ssml_voice.." language='"..args.culture.."'"
            end
        end

        if string.len(ssml_voice) > 0 then
            ssml_msg = table.concat({"<voice",ssml_voice,">",ssml_msg,"</voice>"},"")
        end

        local freqs = string.split(args.freq,",")

        for _,freq in ipairs(freqs) do
            freq = math.ceil(freq * 1000000)
            l_grpc.tts(ssml_msg, freq, grpc_ttsArgs)
        end
        return HOUND.Utils.TTS.getReadTime(msg) / readSpeed -- read speed > 1.0 is fast
    end

    --- returns current DCS time in military time string for TTS
    -- @param[opt] timestamp DCS time in seconds (timer.getAbsTime()) - if not arg provided will return for current game time
    -- @return timeString e.g. "14 30 local", "08 hundred local"

    function HOUND.Utils.TTS.getTtsTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        local hours = DHMS.h
        local minutes = DHMS.m
        -- local seconds = DHMS.s
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

    --- return verbal accuracy description
    -- in 500 meters interval
    -- @param confidenceRadius meters
    -- @return (string) Description of accuracy e.g "Very High","High","Low"...

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

    --- Get Verbal description of contact age
    -- has multiple "modes of operation"
    -- @param timestamp dcs time in seconds of last time a target was seen
    -- @param[opt] isSimple (bool) switch between output modes. true: "Active", "recent"... False: "3 seconds","5 minutes"
    -- @param[opt] NATO (bool) requires isSimple=true, will return only "Active" or "Awake" as per NATO Lowdown
    -- @return string of time passed based on selected flags.

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

    -- TTS Function - convert Decimal degrees to DMS/DM.M speech string
    -- @param cood (float) input coordinate arg in decimal deg (e.g "32.443232", "-144.3432")
    -- @param[opt] minDec (bool) if true output will return in DM.M else in DMS
    -- @param[opt] padDeg (Bool) if true degrees will be zero padded. (32 -> 032 )
    -- @return TTS ready stings. e.g "32 degrees, 15 mintes, 6 seconds", "32 degrees, 15.100 seconds"

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
        -- return degStr .. ", " .. minStr .. ", " .. secStr
        return table.concat(strTab,", ")
    end

    --- convert LL to TTS string
    -- @param lat Latitude in decimal degrees ("32.343","-14.44333")
    -- @param lon Longitude in decimal degrees ("42.343","-144.432")
    -- @param[opt] minDec (bool) if true, function will return LL in DM.M format
    -- @return LL string.
    -- eg. "North, 33 degrees, 15 minutes, 12 seconds, East, 42 degrees, 10 minutes, 45 seconds "

    function HOUND.Utils.TTS.getVerbalLL(lat,lon,minDec)
        minDec = minDec or false
        local hemi = HOUND.Utils.getHemispheres(lat,lon,true)
        return hemi.NS .. ", " .. HOUND.Utils.TTS.DecToDMS(lat,minDec)  ..  ", " .. hemi.EW .. ", " .. HOUND.Utils.TTS.DecToDMS(lon,minDec,true)
    end

    --- Convert string to phonetic text
    -- @param str String to convert
    -- @return string broken up to phonetics
    -- @usage HOUND.Utils.TTS.toPhonetic("B29") will return "Bravo Two Niner"

    function HOUND.Utils.TTS.toPhonetic(str)
        local retval = ""
        str = string.upper(tostring(str))
        for i=1, string.len(str) do
            local char = HOUND.DB.PHONETICS[string.sub(str, i, i)] or ""
            retval = retval .. char .. " "
        end
        return retval:match( "^%s*(.-)%s*$" ) -- return and strip trailing whitespaces
    end

    --- get estimated message read time
    -- returns estimated time in seconds STTS will need to read a message
    -- @param length length of string to estimate (also except the string itself)
    -- @param[opt] speed speed setting for reading them message
    -- @param[opt] googleTTS Bool, if true calculation will be done for GoogleTTS engine
    -- @return estimated message read time in seconds

    function HOUND.Utils.TTS.getReadTime(length,speed,googleTTS)
        -- Assumptions for time calc: 100 Words per min, avarage of 5 letters for english word
        -- so 5 chars * 100wpm = 500 characters per min = 8.3 chars per second
        -- so lengh of msg / 8.3 = number of seconds needed to read it. rounded down to 8 chars per sec
        -- map function:  (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        if length == nil then return nil end
        local maxRateRatio = 3 -- can be chaned to 5 if windows TTSrate is up to 5x not 4x

        speed = speed or 1.0
        googleTTS = googleTTS or false

        local speedFactor = 1.0
        if googleTTS then
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

    --- simplify distance
    -- @param distanceM Distance in meters to simplify
    -- @return Simplified distance
    -- below 1km function will return number in meters
    -- eg. 140m => 150m, 520m => 500m, 4539m => 4.5km

    function HOUND.Utils.TTS.simplfyDistance(distanceM)
        local distanceUnit = "meters"
        local distance = HOUND.Utils.roundToNearest(distanceM,50) or 0
        if distance >= 1000 then
            distance = string.format("%.1f",tostring(HOUND.Utils.roundToNearest(distanceM,100)/1000))
            distanceUnit = "kilometers"
        end
        return distance .. " " .. distanceUnit
    end
end