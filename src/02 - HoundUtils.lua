-- --------------------------------------
do 
    local l_mist = mist
    local l_math = math
    local pi_2 = 2*l_math.pi

    HoundUtils = {}
    HoundUtils.__index = HoundUtils

    HoundUtils.TTS = {}
    HoundUtils.Text = {}
    HoundUtils.ELINT = {}
    HoundUtils.ReportId = nil

    -- Markers handling --
    HoundUtils._MarkId = 1

    function HoundUtils.getMarkId()
        if UTILS and UTILS.GetMarkID 
            then HoundUtils._MarkId = UTILS.GetMarkID()
            else HoundUtils._MarkId = HoundUtils._MarkId + 1 
            end
        return HoundUtils._MarkId
    end

    --[[ 
    ----- Generic Functions ----
    --]]

    function HoundUtils:timeDelta(t0, t1)
        if t1 == nil then t1 = timer.getAbsTime() end
        return t1 - t0
    end

    function HoundUtils.angleDeltaRad(rad1,rad2)
        return l_math.abs(l_math.abs(rad1-l_math.pi)-l_math.abs(rad2-l_math.pi))
    end

    function HoundUtils.AzimuthAverage(azimuths)

        local biasVector = nil
        for i=1, length(azimuths) do
            local V = {}
            V.x = l_math.cos(azimuths[i])
            V.z = l_math.sin(azimuths[i])
            V.y = 0
            if biasVector == nil then biasVector = V else biasVector = l_mist.vec.add(biasVector,V) end
        end
        return  (l_math.atan2( (biasVector.z/length(azimuths)) , (biasVector.x/length(azimuths)))  + pi_2 ) % pi_2
    end

    function HoundUtils.RandomAngle()
        -- actuallu a map
        return l_math.random() * 2 * l_math.pi
    end

    function HoundUtils.getSamMaxRange(emitter)
        local maxRng = 0
        if emitter ~= nil then
            local units = emitter:getGroup():getUnits()
            for i, unit in ipairs(units) do
                local weapons = unit:getAmmo()
                if weapons ~= nil then
                    for j, ammo in ipairs(weapons) do
                        if ammo.desc.category == Weapon.Category.MISSILE and ammo.desc.missileCategory == Weapon.MissileCategory.SAM then
                            maxRng = l_math.max(l_math.max(ammo.desc.rangeMaxAltMax,ammo.desc.rangeMaxAltMin),maxRng)
                        end
                    end
                end
            end
        end
        return maxRng
    end

    function HoundUtils.getRoundedElevationFt(elev)
        return HoundUtils.roundToNearest(l_mist.utils.metersToFeet(elev),50)
    end

    function HoundUtils.roundToNearest(input,nearest)
        return l_mist.utils.round(input/nearest) * nearest
    end

    function HoundUtils.getDefraction(band,antenna_size)
        if band == nil or antenna_size == nil or antenna_size == 0 then return 30 end
        return HoundDB.Bands[band]/antenna_size
    end

    
    function HoundUtils.getAngularError(sigma)
        local MAG = gaussianRandom(0, sigma)
        local ROT = l_math.random() * l_math.pi
        -- env.info("MAG is " .. MAG .. " which is " .. l_math.deg(MAG))
        local epsilon = {}
        epsilon.az = MAG*l_math.sin(ROT)
        epsilon.el = MAG*l_math.cos(ROT)
        -- epsilon.az = 0
        -- epsilon.el = 0
        return epsilon
    end

    function HoundUtils.getNormalAngularError(variance)
        -- https://en.m.wikipedia.org/wiki/Box%E2%80%93Muller_transform
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = 2* math.pi * l_math.random()

        -- from radius and angle you can get the point on the circles
        local epsilon = {
            az = Magnitude * l_math.cos(Theta),
            el = Magnitude * l_math.sin(Theta)
        }
        -- epsilon.az = 0
        -- epsilon.el = 0

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
        return response[l_math.max(1,l_math.min(l_math.ceil(timer.getAbsTime() % length(response)),length(response)))]
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

    function HoundUtils.getReportId()
        if HoundUtils.ReportId == nil or HoundUtils.ReportId == string.byte('Z') then
            HoundUtils.ReportId = string.byte('A')
        else
            HoundUtils.ReportId = HoundUtils.ReportId + 1
        end
        return PHONETIC[string.char(HoundUtils.ReportId)]
    end

    function HoundUtils.DecToDMS(cood)
        local deg = l_math.floor(cood)
        local minutes = l_math.floor((cood - deg) * 60)
        local sec = l_math.floor(((cood-deg) * 3600) % 60)
        local dec = (cood-deg) * 60

        return {
            d = deg,
            m = minutes,
            s = sec,
            mDec = l_mist.utils.round(dec ,3)
        }
    end

    function HoundUtils.getBR(src,dst)
        if not src or not dst then return end
        local BR = {}
        local dir = l_mist.utils.getDir(l_mist.vec.sub(dst,src),src) -- pass src to get magvar included
        -- local magvar = l_mist.getNorthCorrection(src)
        BR.brg = l_mist.utils.round(l_mist.utils.toDegree( dir ))
        BR.brStr = string.format("%03d",BR.brg)
        BR.rng = l_mist.utils.round(l_mist.utils.metersToNM(l_mist.utils.get2DDist(dst,src)))
        -- env.info("getBR: " .. dir .. "|".. magvar .. "="..BR.brg)
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

    function HoundUtils.gaussianWeight(distance,bandwidth)
        local val = (1/(bandwidth*l_math.sqrt(pi_2))) * l_math.exp(-0.5*((distance / bandwidth)^2))
        -- env.info("gaussian " .. val)
        return val
    end
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
        local DHMS = l_mist.time.getDHMS(timestamp)
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
        return score[l_math.min(#score,l_math.max(1,l_math.ceil(confidenceRadius/500)))]
    end

    function HoundUtils.TTS.getVerbalContactAge(timestamp,isSimple,NATO)
        local ageSeconds = HoundUtils:timeDelta(timestamp,timer.getAbsTime())

        if isSimple then 
            if NATO then
                if ageSeconds < 16 then return "Active" end
                return "Awake"
            end
            if ageSeconds < 16 then return "Active" end
            if ageSeconds < 90 then return "very recent" end
            if ageSeconds < 180 then return "recent" end
            if ageSeconds < 300 then return "relevant" end
            return "stale"
        end
        if ageSeconds < 60 then return tostring(l_math.floor(ageSeconds)) .. " seconds" end
        return tostring(l_math.floor(ageSeconds/60)) .. " minutes"
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
        local distance = 0
        if distanceM < 1000 then
            distance = HoundUtils.roundToNearest(distanceM,50)
        else
            distance = l_mist.utils.round(distanceM / 1000,1)
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
        local DHMS = l_mist.time.getDHMS(timestamp)
        return string.format("%02d",DHMS.h)  .. string.format("%02d",DHMS.m)
    end
end
