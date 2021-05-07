-- --------------------------------------
do 
    HoundUtils = {}
    HoundUtils.__index = HoundUtils

    HoundUtils.TTS = {}
    HoundUtils.Text = {}
    HoundUtils.ReportId = nil


--[[ 
    ----- TTS Functions ----
--]]    
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

        STTS.TextToSpeech(msg,args.freq,args.modulation,args.volume,args.name,coalitionID,transmitterPos,args.speed,args.gender,args.culture,args.voice,args.googleTTS)
        return true
    end

    function HoundUtils.TTS.getTtsTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = mist.time.getDHMS(timestamp)
        local hours = DHMS.h
        local minutes = DHMS.m
        local seconds = DHMS.s
        if hours == 0 then
            hours = PHONETIC["0"]
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
            "Very High",
            "High",
            "Medium",
            "Low",
            "Very Low"
        }
        return score[math.min(#score,math.max(1,math.ceil(confidenceRadius/500)))]
    end

    function HoundUtils.TTS.getVerbalContactAge(timestamp,isSimple)
        local ageSeconds = HoundUtils:timeDelta(timestamp,timer.getAbsTime())

        if isSimple then 
            if ageSeconds < 16 then return "Active" end
            if ageSeconds < 90 then return "very recent" end
            if ageSeconds < 180 then return "recent" end
            if ageSeconds < 300 then return "relevant" end
            return "stale"
        end
        if ageSeconds < 60 then return tostring(math.floor(ageSeconds)) .. " seconds" end
        return tostring(math.floor(ageSeconds/60)) .. " minutes"
    end

    function HoundUtils.TTS.DecToDMS(cood,minDec)
        local DMS = HoundUtils.DecToDMS(cood)
        if minDec == true then
            return DMS.d .. " Degrees, " .. DMS.mDec .. " Minutes"
        end
        return DMS.d .. " Degrees, " .. DMS.m .. " Minutes, " .. DMS.s .. " Seconds"
    end

    function HoundUtils.TTS.getVerbalLL(lat,lon)
        local hemi = HoundUtils.getHemispheres(lat,lon,true)
        return hemi.NS .. ", " .. HoundUtils.TTS.DecToDMS(lat)  ..  ", " .. hemi.EW .. ", " .. HoundUtils.TTS.DecToDMS(lon)
    end


    function HoundUtils.TTS.toPhonetic(str) 
        local retval = ""
        str = string.upper(str)
        for i=1, string.len(str) do
            retval = retval .. PHONETIC[string.sub(str, i, i)] .. " "
        end
        return retval:match( "^%s*(.-)%s*$" ) -- return and strip trailing whitespaces
    end

    function HoundUtils.TTS.getReadTime(length,speed,isGoogle)
        -- Assumptions for time calc: 100 Words per min, avarage of 5 letters for english word
        -- so 5 chars * 100wpm = 500 characters per min = 8.3 chars per second
        -- so lengh of msg / 8.3 = number of seconds needed to read it. rounded down to 8 chars per sec
        -- map function:  (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        if length == nil then return nil end
        local maxRateRatio = 3 -- can be chaned to 5 if windows TTSrate is up to 5x not 4x

        speed = speed or 1.0
        isGoogle = isGoogle or false

        local speedFactor = 1.0
        if isGoogle then
            speedFactor = speed
        else
            if speed ~= 0 then
                speedFactor = math.abs(speed) * (maxRateRatio - 1) / 10 + 1
            end
            if speed < 0 then
                speedFactor = 1/speedFactor
            end
        end

        local wpm = math.ceil(100 * speedFactor)
        local cps = math.floor((wpm * 5)/60)

        if type(length) == "string" then
            length = string.len(length)
        end

        return math.ceil(length/cps)
    end


    function HoundUtils.TTS.simplfyDistance(distanceM) 
        local distanceUnit = "meters"
        local distance = 0
        if distanceM < 1000 then
            distance = HoundUtils.roundToNearest(distanceM,50)
        else
            distance = mist.utils.round(distanceM / 1000,1)
            distanceUnit = "kilometers"
        end
        return distance .. " " .. distanceUnit
    end

--[[ 
    ----- Text Functions ----
--]]

    function HoundUtils.Text.getLL(lat,lon,minDec)
        local hemi = HoundUtils.getHemispheres(lat,lon)
        local lat = HoundUtils.DecToDMS(lat)
        local lon = HoundUtils.DecToDMS(lon)
        if minDec == true then
            return hemi.NS .. lat.d .. "°" .. lat.mDec .. "'".."\"" ..  " " ..  hemi.EW  .. lon.d .. "°" .. lon.mDec .. "'" .."\"" 

        end
        return hemi.NS .. lat.d .. "°" .. lat.m .. "'".. lat.s.."\"" ..  " " ..  hemi.EW  .. lon.d .. "°" .. lon.m .. "'".. lon.s .."\"" 
    end

    function HoundUtils.Text.getTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = mist.time.getDHMS(timestamp)
        return string.format("%02d",DHMS.h)  .. string.format("%02d",DHMS.m)
    end

--[[ 
    ----- Generic Functions ----
--]]
    function HoundUtils.getControllerResponse()
        local response = {
            " ",
            "Good Luck!",
            "Happy Hunting!",
            "Please send my regards.",
            " "
        }
        return response[math.max(1,math.min(math.floor(timer.getAbsTime() % length(response)),length(response)))]
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

    function HoundUtils.DecToDMS(cood)
        local deg = math.floor(cood)
        local minutes = math.floor((cood - deg) * 60)
        local sec = math.floor(((cood-deg) * 3600) % 60)
        local dec = (cood-deg) * 60

        return {
            d = deg,
            m = minutes,
            s = sec,
            mDec = mist.utils.round(dec ,3)
        }
    end

    function HoundUtils.TTS.getReportId()
        if HoundUtils.ReportId == nil or HoundUtils.ReportId == string.byte('Z') then
            HoundUtils.ReportId = string.byte('A')
        else
            HoundUtils.ReportId = HoundUtils.ReportId + 1
        end
        return PHONETIC[string.char(HoundUtils.ReportId)]
    end

-- more functions
    function HoundUtils:timeDelta(t0, t1)
        if t1 == nil then t1 = timer.getAbsTime() end
        return t1 - t0
    end

    function HoundUtils.angleDeltaRad(rad1,rad2)
        return math.abs(math.abs(rad1-math.pi)-math.abs(rad2-math.pi))
    end

    function HoundUtils.AzimuthAverage(azimuths)

        local biasVector = nil
        for i=1, length(azimuths) do
            local V = {}
            V.x = math.cos(azimuths[i])
            V.z = math.sin(azimuths[i])
            V.y = 0
            if biasVector == nil then biasVector = V else biasVector = mist.vec.add(biasVector,V) end
        end
        local pi_2 = 2*math.pi

        return  (math.atan2(biasVector.z/length(azimuths), biasVector.x/length(azimuths))+pi_2) % pi_2
    end

    function HoundUtils.RandomAngle()
        return math.random() * 2 * math.pi
    end

    function HoundUtils.getSamMaxRange(emitter)
        local maxRng = 0
        if emitter ~= nil then
            local units = emitter:getGroup():getUnits()
            for i, unit in ipairs(units) do
                local weapons = unit:getAmmo()
                if weapons ~= nil then
                    for j, ammo in ipairs(weapons) do
                        -- env.info(mist.utils.tableShow(ammo))
                        if ammo.desc.category == Weapon.Category.MISSILE and ammo.desc.missileCategory == Weapon.MissileCategory.SAM then
                            maxRng = math.max(math.max(ammo.desc.rangeMaxAltMax,ammo.desc.rangeMaxAltMin),maxRng)
                        end
                    end
                end
            end
        end
        -- env.info("uid: " .. emitter:getID() .. " maxRNG: " .. maxRng)
        return maxRng
    end

    function HoundUtils.getRoundedElevationFt(elev)
        return HoundUtils.roundToNearest(mist.utils.metersToFeet(elev),50)
    end

    function HoundUtils.roundToNearest(input,nearest)
        return mist.utils.round(input/nearest) * nearest
    end
end