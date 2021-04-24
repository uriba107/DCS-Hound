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
    function HoundUtils.TTS.Transmit(msg,coalitionID,args)

        if STTS == nil then return end
        if msg == nil then return end
        if coalitionID == nil then return end

        if args.freq == nil then return end
        if args.modulation == nil then args.modulation = "AM" end
        if args.volume == nil then args.volume = "1.0" end
        if args.name == nil then args.name = "Hound" end
        if args.gender == nil then args.gender = "female" end
        if args.locale == nil then args.locale = "en-US" end

        STTS.TextToSpeech(msg,args.freq,args.modulation,args.volume,args.name,coalitionID,args.gender,args.locale)
        return true
    end

    function HoundUtils.TTS.getTtsTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = mist.time.getDHMS(timestamp)
        local hours = DHMS.h
        local minutes = DHMS.m
        local seconds = DHMS.s
        -- env.info(hours..":"..minutes..":"..seconds)
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
        if confidenceRadius <= 500 then return "Very High" end 
        if confidenceRadius <= 1000 then return "High" end 
        if confidenceRadius <= 2000 then return "Medium" end 
        return "low"
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

    function HoundUtils.TTS.DecToDMS(cood)
        local DMS = HoundUtils.DecToDMS(cood)
        return DMS.d .. " Degrees " .. DMS.m .. " Minutes " .. DMS.s .. " Seconds"
    end

    function HoundUtils.TTS.getVerbalLL(lat,lon)
        local hemi = HoundUtils.getHemispheres(lat,lon,true)
        return HoundUtils.TTS.DecToDMS(lat) .. " " .. hemi.NS .. ", " .. HoundUtils.TTS.DecToDMS(lon) .. " " .. hemi.EW  
    end


    function HoundUtils.TTS.toPhonetic(str) 
        local retval = ""
        str = string.upper(str)
        for i=1, string.len(str) do
            retval = retval .. PHONETIC[string.sub(str, i, i)] .. " "
        end
        return retval:match( "^%s*(.-)%s*$" ) -- return and strip trailing whitespaces
    end

    function HoundUtils.TTS.getReadTime(length)
        -- Assumptions for time calc: 150 Words per min, avarage of 5 letters for english word
        -- so 5 chars = 750 characters per min = 12.5 chars per second
        -- so lengh of msg / 12.5 = number of seconds needed to read it. rounded down to 10 chars per sec
        if type(length) == "string" then
            return math.ceil((string.len(length)/10))
        end
        return math.ceil(length/10)
    end


    function HoundUtils.TTS.simplfyDistance(distanceM) 
        local distanceUnit = "meters"
        local distance = 0
        if distanceM < 1000 then
            distance = mist.utils.round(distanceM / 50) * 50
        else
            distance = mist.utils.round(distanceM / 1000,1)
            distanceUnit = "kilometers"
        end
        return distance .. " " .. distanceUnit
    end

--[[ 
    ----- Text Functions ----
--]]

    function HoundUtils.Text.getLL(lat,lon)
        local hemi = HoundUtils.getHemispheres(lat,lon)
        local lat = HoundUtils.DecToDMS(lat)
        local lon = HoundUtils.DecToDMS(lon)
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
            mDec = dec
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
                            maxRng = math.max( math.max(ammo.desc.rangeMaxAltMax,ammo.desc.rangeMaxAltMin),maxRng)
                        end
                    end
                end
            end
        end
        env.info("uid: " .. emitter:getID() .. " maxRNG: " .. maxRng)

        return maxRng
    end
end