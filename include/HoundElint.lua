env.info("Hound ELINT Loading...")
HOUND = {
    VERSION="0.1.2",
    PERCENTILE = 0.60,
    MARKER = {
        NONE = 0,
        CIRCLE = 1,
        DIAMOND = 2,
        POLYGON = 3
    },
}
HoundDB = {}
do
    HoundDB.Sam = {
        ['p-19 s-125 sr'] = {
            ['Name'] = "Flat Face",
            ['Assigned'] = "SA-2 or SA-3",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['1L13 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'A'
        },
        ['55G6 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'A'
        },
        ['SNR_75V'] = {
            ['Name'] = "Fan-song",
            ['Assigned'] = "SA-2",
            ['Role'] = "SNR",
            ['Band'] = 'G'
        },
        ['snr s-125 tr'] = {
            ['Name'] = "Low Blow",
            ['Assigned'] = "SA-3",
            ['Role'] = "TR",
            ['Band'] = 'I'
        },
        ['Kub 1S91 str'] = {
            ['Name'] = "Straight Flush",
            ['Assigned'] = "SA-6",
            ['Role'] = "STR",
            ['Band'] = 'G'
        },
        ['Osa 9A33 ln'] = {
            ['Name'] = "Osa",
            ['Assigned'] = "SA-8",
            ['Role'] = "STR",
            ['Band'] = 'H'
        },
        ['S-300PS 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['S-300PS 64H6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['RLS_19J6'] = {
            ['Name'] = "Tin Shield",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'E'
        },
        ['S-300PS 40B6M tr'] = {
            ['Name'] = "Tomb Stone",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['SA-11 Buk SR 9S18M1'] = {
            ['Name'] = "Snow Drift",
            ['Assigned'] = "SA-11",
            ['Role'] = "SR",
            ['Band'] = 'G'
        },
        ['SA-11 Buk LN 9A310M1'] = {
            ['Name'] = "Fire Dome",
            ['Assigned'] = "SA-11",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['Tor 9A331'] = {
            ['Name'] = "Tor",
            ['Assigned'] = "SA-15",
            ['Role'] = "STR",
            ['Band'] = 'F'
        },
        ['Strela-1 9P31'] = {
            ['Name'] = "SA-9",
            ['Assigned'] = "SA-9",
            ['Role'] = "TR",
            ['Band'] = 'K'
        },
        ['Strela-10M3'] = {
            ['Name'] = "SA-13",
            ['Assigned'] = "SA-13",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Patriot str'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = "Patriot",
            ['Role'] = "STR",
            ['Band'] = 'K'
        },
        ['Hawk sr'] = {
            ['Name'] = "Hawk SR",
            ['Assigned'] = "Hawk",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['Hawk tr'] = {
            ['Name'] = "Hawk TR",
            ['Assigned'] = "Hawk",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Hawk cwar'] = {
            ['Name'] = "Hawk CWAR",
            ['Assigned'] = "Hawk",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Roland ADS'] = {
            ['Name'] = "Roland TR",
            ['Assigned'] = "Roland",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['Roland Radar'] = {
            ['Name'] = "Roland SR",
            ['Assigned'] = "Roland",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['Gepard'] = {
            ['Name'] = "Gepard",
            ['Assigned'] = "Gepard",
            ['Role'] = "STR",
            ['Band'] = 'E'
        },
        ['rapier_fsa_blindfire_radar'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = "Rapier",
            ['Role'] = "TR",
            ['Band'] = 'D'
        },
        ['rapier_fsa_launcher'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = "Rapier",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['NASAMS_Radar_MPQ64F1'] = {
            ['Name'] = "Sentinel",
            ['Assigned'] = "NASAMS",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['HQ-7_STR_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = "HQ-7",
            ['Role'] = "SR",
            ['Band'] = 'F'
        },
        ['HQ-7_LN_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = "HQ-7",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['2S6 Tunguska'] = {
            ['Name'] = "Tunguska",
            ['Assigned'] = "Tunguska",
            ['Role'] = "STR",
            ['Band'] = 'F'
        },
        ['ZSU-23-4 Shilka'] = {
            ['Name'] = "Shilka",
            ['Assigned'] = "Shilka",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Dog Ear radar'] = {
            ['Name'] = "AAA SR",
            ['Assigned'] = "AAA",
            ['Role'] = "SR",
            ['Band'] = 'G'
        },
        ['S-300PS 64H6E TRAILER sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300PS SA-10B 40B6MD MAST sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['S-300PS 40B6M MAST tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PS 30H6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PS 30N6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PMU1 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['S-300PMU1 64N6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300PMU1 30N6E tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PMU1 40B6M tr'] = {
            ['Name'] = "Grave Stone",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300V 9S15 sr'] = {
            ['Name'] = 'Bill Board',
            ['Assigned'] = "SA-12",
            ['Role'] = "SR",
            ['Band'] = 'E'
        },
        ['S-300V 9S19 sr'] = {
            ['Name'] = 'High Screen',
            ['Assigned'] = "SA-12",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300V 9S32 tr'] = {
            ['Name'] = 'Grill Pan',
            ['Assigned'] = "SA-12",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PMU2 92H6E tr'] = {
            ['Name'] = 'Grave Stone',
            ['Assigned'] = "SA-20B",
            ['Role'] = "TR",
            ['Band'] = 'I'
        },
        ['S-300PMU2 64H6E2 sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-20B",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300VM 9S15M2 sr'] = {
            ['Name'] = 'Bill Board M',
            ['Assigned'] = "SA-23",
            ['Role'] = "SR",
            ['Band'] = 'E'
        },
        ['S-300VM 9S19M2 sr'] = {
            ['Name'] = 'High Screen M',
            ['Assigned'] = "SA-23",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300VM 9S32ME tr'] = {
            ['Name'] = 'Grill Pan M',
            ['Assigned'] = "SA-23",
            ['Role'] = "TR",
            ['Band'] = 'K'
        },
        ['SA-17 Buk M1-2 LN 9A310M1-2'] = {
            ['Name'] = "Fire Dome M",
            ['Assigned'] = "SA-17",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['34Ya6E Gazetchik E decoy'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "Decoy",
            ['Band'] = 'J'
        },
        ['EWR 55G6U NEBO-U'] = {
            ['Name'] = "Tall Rack",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'A'
        },
        ['EWR P-37 Bar Lock'] = {
            ['Name'] = "Bar lock",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'E'
        },
        ['EWR 1L119 Nebo-SVU'] = {
            ['Name'] = "Nebo-SVU",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'A' 
        },
        ['EWR Generic radar tower'] = {
            ['Name'] = "Civilian Radar",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'C' 
        }
    }
end

do
    PHONETIC = {
        ["A"] = "Alpha",
        ["B"] = "Bravo",
        ["C"] = "Charlie",
        ["D"] = "Delta",
        ["E"] = "Echo",
        ["F"] = "Foxtrot",
        ["G"] = "Golf",
        ["H"] = "Hotel",
        ["I"] = "India",
        ["J"] = "Juliette",
        ["K"] = "Kilo",
        ["L"] = "Lima",
        ["M"] = "Mike",
        ["N"] = "November",
        ["O"] = "Oscar",
        ["P"] = "Papa",
        ["Q"] = "Quebec",
        ["R"] = "Romeo",
        ["S"] = "Sierra",
        ["T"] = "Tango",
        ["U"] = "Uniform",
        ["V"] = "Victor",
        ["W"] = "Whiskey",
        ["X"] = "X ray",
        ["Y"] = "Yankee",
        ["Z"] = "Zulu",
        ["1"] = "One",
        ["2"] = "two",
        ["3"] = "three",
        ["4"] = "four",
        ["5"] = "five",
        ["6"] = "six",
        ["7"] = "seven",
        ["8"] = "eight",
        ["9"] = "Niner",
        ["0"] = "zero"
    }
end

do useDecMin = {["F-16C_blk50"] = true, ["A-10C"] = true} end

do
    HoundDB.Platform = {
        [Object.Category.STATIC] = {["Comms tower M"] = {precision = 0.15, antenna = {size = 80, factor = 1}}},
        [Object.Category.UNIT] = {
            ["MLRS FDDM"] = {antenna = {size = 15, factor = 1}},
            ["SPK-11"] = {antenna = {size = 15, factor = 1}},
            ["CH-47D"] = {antenna = {size = 12, factor = 1}},
            ["CH-53E"] = {antenna = {size = 10, factor = 1}},
            ["MIL-26"] = {antenna = {size = 20, factor = 1}},
            ["SH-60B"] = {antenna = {size = 8, factor = 1}},
            ["UH-60A"] = {antenna = {size = 8, factor = 1}},
            ["Mi-8MT"] = {antenna = {size = 8, factor = 1}},
            ["UH-1H"] = {antenna = {size = 4, factor = 1}},
            ["KA-27"] = {antenna = {size = 4, factor = 1}},
            ["C-130"] = {antenna = {size = 35, factor = 1}},
            ["Hercules"] = {antenna = {size = 35, factor = 1}}, -- Anubis' C-130J
            ["C-17A"] = {antenna = {size = 50, factor = 1}},
            ["S-3B"] = {antenna = {size = 18, factor = 0.8}},
            ["E-3A"] = {antenna = {size = 9, factor = 0.5}},
            ["E-2D"] = {antenna = {size = 7, factor = 0.5}},
            ["Tu-95MS"] = {antenna = {size = 50, factor = 1}},
            ["Tu-142"] = {antenna = {size = 50, factor = 1}},
            ["IL-76MD"] = {antenna = {size = 48, factor = 0.8}},
            ["An-30M"] = {antenna = {size = 25, factor = 1}},
            ["A-50"] = {antenna = {size = 9, factor = 0.5}},
            ["An-26B"] = {antenna = {size = 26, factor = 0.9}},
            ["EA_6B"] = {antenna = {size = 9, factor = 1}}, -- VSN EA-6B
            ["Su-25T"] = {antenna = {size = 1.6, factor = 1}},
            ["AJS37"] = {antenna = {size = 1.6, factor = 1}}
        }
    }

    HoundDB.Bands = {
        ["A"] = 1.713100,
        ["B"] = 0.799447,
        ["C"] = 0.399723,
        ["D"] = 0.199862,
        ["E"] = 0.119917,
        ["F"] = 0.085655,
        ["G"] = 0.059958,
        ["H"] = 0.042827,
        ["I"] = 0.033310,
        ["J"] = 0.019986,
        ["K"] = 0.009993,
        ["L"] = 0.005996,
    }
end
function length(T)
    local count = 0
    if T ~= nil then
        for _ in pairs(T) do count = count + 1 end
    end
    return count
  end

function gaussian (mean, sigma)
    return  math.sqrt(-2 * sigma * math.log(math.random())) *
            math.cos(2 * math.pi * math.random()) + mean
end

function map(x,in_min,in_max,out_min,out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function setContains(set, key)
  return set[key] ~= nil
end

function stdev()
  local sum, sumsq, k = 0,0,0
  return function(n)
    sum, sumsq, k = sum + n, sumsq + n^2, k+1
    return math.sqrt((sumsq / k) - (sum/k)^2)
  end
end
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
        local epsilon = {}
        epsilon.az = MAG*l_math.sin(ROT)
        epsilon.el = MAG*l_math.cos(ROT)
        return epsilon
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

    function HoundUtils.gaussianWeight(distance,bandwidth)
        local val = (1/(bandwidth*l_math.sqrt(pi_2))) * l_math.exp(-0.5*((distance / bandwidth)^2))
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
do
    HoundElintDatapoint = {}
    HoundElintDatapoint.__index = HoundElintDatapoint

    function HoundElintDatapoint:New(platform0, p0, az0, el0, t0,isPlatformStatic,sensorMargins)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HoundElintDatapoint)
        elintDatapoint.platformPos = p0
        elintDatapoint.az = az0
        elintDatapoint.el = el0
        elintDatapoint.t = tonumber(t0)
        elintDatapoint.platformId = platform0:getID()
        elintDatapoint.platfromName = platform0:getName()
        elintDatapoint.platformStatic = isPlatformStatic or false
        elintDatapoint.platformPrecision = sensorMargins or math.rad(20)
        elintDatapoint.estimatedPos = nil
        return elintDatapoint
    end

    function HoundElintDatapoint:estimatePos()
        if self.el == nil then return end
        local l_math = math
        local maxSlant = self.platformPos.y/l_math.abs(l_math.sin(self.el))

        local unitVector = {
            x = l_math.cos(self.el)*l_math.cos(self.az),
            z = l_math.cos(self.el)*l_math.sin(self.az),
            y = l_math.sin(self.el)
        }

        self.estimatedPos = land.getIP(self.platformPos, unitVector , maxSlant+1000 )
    end
end

do
    HoundContact = {}
    HoundContact.__index = HoundContact

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    function HoundContact:New(DCS_Unit,platformCoalition)
        local elintcontact = {}
        setmetatable(elintcontact, HoundContact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = DCS_Unit:getID()
        elintcontact.DCStypeName = DCS_Unit:getTypeName()
        elintcontact.typeName = DCS_Unit:getTypeName()
        elintcontact.isEWR = false
        elintcontact.typeAssigned = "Unknown" 
        elintcontact.band = "C"
        if setContains(HoundDB.Sam,DCS_Unit:getTypeName())  then
            local unitName = DCS_Unit:getTypeName()
            elintcontact.typeName =  HoundDB.Sam[unitName].Name
            elintcontact.isEWR = (HoundDB.Sam[unitName].Role == "EWR")
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
        elintcontact.uncertenty_radius = nil
        elintcontact.last_seen = timer.getAbsTime()
        elintcontact.first_seen = timer.getAbsTime()
        elintcontact.maxRange = HoundUtils.getSamMaxRange(DCS_Unit)
        elintcontact.dataPoints = {}
        elintcontact.markpointID = nil
        elintcontact.platformCoalition = platformCoalition
        return elintcontact
    end

    function HoundContact:CleanTimedout()
        if HoundUtils:timeDelta(timer.getAbsTime(), self.last_seen) > 900 then
            self.dataPoints = {}
        end
    end

    function HoundContact:isAlive()
        if self.unit:isExist() == false or self.unit:getLife() < 1 then return false end
        return true
    end

    function HoundContact:countDatapoints()
        local count = 0
        for _,platformDataPoints in pairs(self.dataPoints) do
            count = count + length(platformDataPoints)
        end
        return count
    end

    function HoundContact:getName()
        return self.typeName .. " " .. (self.uid%100)
    end

    function HoundContact:getId()
        return self.uid%100
    end

    function HoundContact:AddPoint(datapoint)

        self.last_seen = datapoint.t
        if length(self.dataPoints[datapoint.platformId]) == 0 then
            self.dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            if length(self.dataPoints[datapoint.platformId]) > 0 then
                datapoint.az =  HoundUtils.AzimuthAverage({datapoint.az,self.dataPoints[datapoint.platformId][1].az})
            end
            self.dataPoints[datapoint.platformId] = {datapoint}
            return
        end
        if datapoint.el ~=nil then
            datapoint:estimatePos()
        end

        if length(self.dataPoints[datapoint.platformId]) < 2 then
            table.insert(self.dataPoints[datapoint.platformId], datapoint)
        else
            local LastElementIndex = table.getn(self.dataPoints[datapoint.platformId])
            local DeltaT = HoundUtils:timeDelta(self.dataPoints[datapoint.platformId][LastElementIndex - 1].t, datapoint.t)
            if  DeltaT >= 55 then
                table.insert(self.dataPoints[datapoint.platformId], datapoint)
            else
                self.dataPoints[datapoint.platformId][LastElementIndex] = datapoint
            end
            if table.getn(self.dataPoints[datapoint.platformId]) > 15 then
                table.remove(self.dataPoints[datapoint.platformId], 1)
            end
        end
    end

    function HoundContact:triangulatePoints(earlyPoint, latePoint)
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

    function HoundContact:calculateAzimuthBias(dataPoints)

        local azimuths = {}
        for k,v in ipairs(dataPoints) do
            table.insert(azimuths,v.az)
        end

        return  HoundUtils.AzimuthAverage(azimuths)
    end

    function HoundContact:getDeltaSubsetPercent(Table,referencePos,NthPercentile)
        local t = l_mist.utils.deepCopy(Table)
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(length(t)*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,length(t)),percentile)
        local RelativeToPos = {}
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,l_mist.vec.sub(t[i],referencePos))
        end

        return RelativeToPos
    end

    function HoundContact:calculateEllipse(estimatedPositions,Theta)

        local RelativeToPos = HoundContact:getDeltaSubsetPercent(estimatedPositions,self.pos.p,HOUND.PERCENTILE)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        for k,v in ipairs(RelativeToPos) do
            min.x = l_math.min(min.x,v.x)
            max.x = l_math.max(max.x,v.x)
            min.y = l_math.min(min.y,v.z)
            max.y = l_math.max(max.y,v.z)
        end

        
        local x = l_mist.utils.round(l_math.abs(min.x)+l_math.abs(max.x))
        local y = l_mist.utils.round(l_math.abs(min.y)+l_math.abs(max.y))

        if Theta == nil then

            local AzBiasPool = {}

            for _,pos in ipairs(estimatedPositions) do
                local deltaVec = l_mist.vec.sub(self.pos.p,pos)
                table.insert(AzBiasPool,l_math.atan2(deltaVec.z,deltaVec.x))
            end

            Theta = HoundUtils.AzimuthAverage(AzBiasPool)
        end
        
        local sinTheta = l_math.sin(Theta)
        local cosTheta = l_math.cos(Theta)

        for k,v in ipairs(RelativeToPos) do
            local newPos = {}
            newPos.y = v.y
            newPos.x = v.x*cosTheta - v.z*sinTheta
            newPos.z = v.x*sinTheta + v.z*cosTheta
            RelativeToPos[k] = newPos
        end

        self.uncertenty_radius = {}
        self.uncertenty_radius.major = l_math.max(x,y)
        self.uncertenty_radius.minor = l_math.min(x,y)
        self.uncertenty_radius.az = l_mist.utils.round(l_mist.utils.toDegree(Theta))
        self.uncertenty_radius.r  = (x+y)/4
        
    end

    function HoundContact:calculatePos(estimatedPositions,converge)
        if estimatedPositions == nil then return end
        self.pos.p = l_mist.getAvgPoint(estimatedPositions)
        if converge then
            local subList = estimatedPositions
            local subsetPos = self.pos.p
            while (length(subList) * HOUND.PERCENTILE) > 5 do
                local NewsubList = HoundContact:getDeltaSubsetPercent(subList,subsetPos,HOUND.PERCENTILE)
                subsetPos = l_mist.getAvgPoint(NewsubList)

                self.pos.p.x = self.pos.p.x + (subsetPos.x )
                self.pos.p.z = self.pos.p.z + (subsetPos.z )
                subList = NewsubList

            end
        end
        self.pos.p.y = land.getHeight({x=self.pos.p.x,y=self.pos.p.z})
        local bullsPos = coalition.getMainRefPoint(self.platformCoalition)
        self.pos.LL.lat, self.pos.LL.lon =  coord.LOtoLL(self.pos.p)
        self.pos.elev = self.pos.p.y
        self.pos.grid  = coord.LLtoMGRS(self.pos.LL.lat, self.pos.LL.lon)
        self.pos.be = HoundUtils.getBR(bullsPos,self.pos.p)
    end

    function HoundContact:removeMarker()
        if self.markpointID ~= nil then
            for _ = 1, length(self.markpointID) do
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
    
    function HoundContact:drawMarkerCircle()
        local fillcolor = {0,0,0,0.15}
        local linecolor = {0,0,0,0.3}
        if self.platformCoalition == coalition.side.BLUE then
            fillcolor[1] = 1
            linecolor[1] = 1
        end
        if self.platformCoalition == coalition.side.RED then
            fillcolor[3] = 1
            linecolor[3] = 1
        end  
        trigger.action.circleToAll(self.platformCoalition,self:getMarkerId(),self.pos.p,self.uncertenty_radius.r,linecolor,fillcolor,2,true)
    end

    function HoundContact:drawMarkerPolygon(numPoints)
        if numPoints == nil then numPoints = 4 end
        if numPoints ~= 4 then 
            env.info("DCS limitation, only 4 points are allowed")
            numPoints = 4
         end

        local angleStep = pi_2/numPoints
        local theta = l_math.rad(self.uncertenty_radius.az)

        local polygonPoints = {}
        for pointAngle = angleStep, pi_2, angleStep do
            local point = {}
            point.x = self.uncertenty_radius.major/2 * l_math.cos(pointAngle)
            point.z = self.uncertenty_radius.minor/2 * l_math.sin(pointAngle)
            local x = point.x * l_math.cos(theta) - point.z * l_math.sin(theta)
            local z = point.x * l_math.sin(theta) + point.z * l_math.cos(theta)
            point.x = x + self.pos.p.x
            point.z = z + self.pos.p.z
            point.y = land.getHeight({x=point.x,y=point.z})

            table.insert(polygonPoints, point)
        end

        local fillcolor = {0,0,0,0.15}
        local linecolor = {0,0,0,0.3}
        if self.platformCoalition == coalition.side.BLUE then
            fillcolor[1] = 1
            linecolor[1] = 1
        end
        if self.platformCoalition == coalition.side.RED then
            fillcolor[3] = 1
            linecolor[3] = 1
        end  
        trigger.action.quadToAll(self.platformCoalition,self:getMarkerId(), polygonPoints[1] , polygonPoints[2] , polygonPoints[3] , polygonPoints[4] , linecolor,fillcolor,2,true)
    end

    function HoundContact:updateMarker(coalitionID,MarkerType)
        if self.pos.p == nil or self.uncertenty_radius == nil then return end


        self:removeMarker()

        trigger.action.markToCoalition(self:getMarkerId(), self.typeName .. " " .. (self.uid%100) .. " (" .. self.uncertenty_radius.major .. "/" .. self.uncertenty_radius.minor .. "@" .. self.uncertenty_radius.az .. "|" .. l_math.floor(HoundUtils:timeDelta(self.last_seen)) .. "s)",self.pos.p,self.platformCoalition,true)
        if MarkerType == HOUND.MARKER.CIRCLE then
            self:drawMarkerCircle()
        end
        if MarkerType == HOUND.MARKER.DIAMOND or MarkerType == HOUND.MARKER.POLYGON then
            self:drawMarkerPolygon(4)
        end
    end

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
        phoneticGridPos = phoneticGridPos .. " " .. HoundUtils.TTS.toPhonetic(E) .. " " .. HoundUtils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end

    function HoundContact:generateTtsBrief(NATO)
        if self.pos.p == nil or self.uncertenty_radius == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = string.gsub(self.typeAssigned,"(SA)-",'')
        end
        local str = reportedName .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos -- .. ", bullseye " .. phoneticBulls 
        end
        str = str .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r ) .. "."
        return str
    end

    function HoundContact:generateTtsReport(refPos)
        if self.pos.p == nil then return end
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,3)
        local msg =  self:getName() .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true) 
        if BR ~= nil 
            then
                msg = msg .. " from you " .. HoundUtils.TTS.toPhonetic(BR.brStr) .. " for " .. BR.rng
            else
                msg = msg .." at bullseye " .. phoneticBulls 
        end
        msg = msg .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r )
        msg = msg .. ", position " .. HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon)
        msg = msg .. ", I repeat " .. HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon)
        msg = msg .. ", MGRS " .. phoneticGridPos
        msg = msg .. ", elevation  " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. " feet MSL"
        msg = msg .. ", ellipse " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_radius.major) .. " by " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_radius.minor) .. ", aligned bearing " .. HoundUtils.TTS.toPhonetic(string.format("%03d",self.uncertenty_radius.az))
        msg = msg .. ", first seen " .. HoundUtils.TTS.getTtsTime(self.first_seen) .. ", last seen " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils:getControllerResponse()
        return msg
    end

    function HoundContact:generateTextReport(refPos)
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true,3)
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local msg =  self:getName() .." (" .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true).. ")\n"
        msg = msg .. "Accuracy: " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r ) .. "\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        if BR ~= nil then
            msg = msg .. "BR: " .. BR.brStr .. " for " .. BR.rng
        end
        msg = msg .. "LL: " .. HoundUtils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. "ft\n"
        msg = msg .. "Ellipse: " ..  self.uncertenty_radius.major .. " by " ..  self.uncertenty_radius.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_radius.az) .. "\n"
        msg = msg .. "First detected: " .. HoundUtils.Text.getTime(self.first_seen) .. " Last Contact: " ..  HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils:getControllerResponse()
        return msg
    end

    function HoundContact:generateRadioItemText()
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self.typeName .. (self.uid % 100) .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end 


    function HoundContact:generatePopUpReport(isTTS)
        local msg = "BREAK, BREAK! New threat detected! "
        msg = msg .. self.typeName .. " " .. (self.uid % 100)
        local GridPos,BePos 
        if isTTS then
            GridPos,BePos = self:getTtsData(true)
            msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
        else
            GridPos,BePos = self:getTextData(true)
            msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
        end
        msg = msg .. " is now Alive!"
        return msg
    end

    function HoundContact:generateDeathReport(isTTS)
        local msg = self:getName()
        local GridPos,BePos 
        if isTTS then
            GridPos,BePos = self:getTtsData(true)
            msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
        else
            GridPos,BePos = self:getTextData(true)
            msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
        end
        msg = msg .. " has been destroyed!"
        return msg
    end

    function HoundContact:processData()
        local newContact = (self.pos.p == nil)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}

        for _,platformDatapoints in pairs(self.dataPoints) do 
            if length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do 
                    if datapoint.isReciverStatic then
                        table.insert(staticDataPoints,datapoint) 
                    else
                        table.insert(mobileDataPoints,datapoint) 
                    end
                    if datapoint.estimatedPos ~= nil then
                        table.insert(estimatePositions,datapoint.estimatedPos)
                    end
                    platforms[datapoint.platfromName] = 1
                end
            end
        end
        local numMobilepoints = length(mobileDataPoints)
        local numStaticPoints = length(staticDataPoints)

        if numMobilepoints+numStaticPoints < 2 and length(estimatePositions) == 0 then return end
        if numStaticPoints > 1 then
            for i=1,numStaticPoints-1 do
                for j=i+1,numStaticPoints do
                    local err = (staticDataPoints[i].platformPrecision + staticDataPoints[j].platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoints[i].az,staticDataPoints[j].az) > err then
                        table.insert(estimatePositions,self:triangulatePoints(staticDataPoints[i],staticDataPoints[j]))
                    end
                end
            end
        end

        if numStaticPoints > 0  and numMobilepoints > 0 then
            for i,staticDataPoint in ipairs(staticDataPoints) do
                for j,mobileDataPoint in ipairs(mobileDataPoints) do
                    local err = (staticDataPoint.platformPrecision + mobileDataPoint.platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoint.az,mobileDataPoint.az) > err then
                        table.insert(estimatePositions,self:triangulatePoints(staticDataPoint,mobileDataPoint))
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
                            table.insert(estimatePositions,self:triangulatePoints(mobileDataPoints[i],mobileDataPoints[j]))
                        end
                    end
                end
            end
        end
        
        if length(estimatePositions) > 2 then
            self:calculatePos(estimatePositions,true)

            self:calculateEllipse(estimatePositions)

            local detected_by = {}

            for key, value in pairs(platforms) do
                table.insert(detected_by,key)
            end
            self.detected_by = detected_by
        end

        if newContact and self.pos.p ~= nil and self.isEWR == false then
            return true
        end
        return false

    end
    function HoundContact:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DCSunitName = self.unit:getName()
        if self.pos.p ~= nil and self.uncertenty_radius ~= nil then

        contact.pos = self.pos.p
        contact.accuracy = HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r )
        contact.uncertenty = {
            major = self.uncertenty_radius.major,
            minor = self.uncertenty_radius.minor,
            heading = self.uncertenty_radius.az
        }
        contact.maxRange = self.maxRange
        contact.last_seen = self.last_seen
        end
        contact.detected_by = self.detected_by
        return contact
    end
end
do
    HoundCommsManager = {}
    HoundCommsManager.__index = HoundCommsManager

    function HoundCommsManager:create(settings)
        local CommsManager = {}
        setmetatable(CommsManager, HoundCommsManager)
        CommsManager.enabled = false
        CommsManager.transmitter = nil

        CommsManager._queue = {
            {},{},{}
        }

        CommsManager.loop = {
            MsgCallback = nil,
            body = "",
            header = "",
            footer = "",
            msg = "",
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

        CommsManager.scheduler = nil

        if settings ~= nil and type(settings) == "table" then
            CommsManager:updateSettings(settings)
        end
        return CommsManager
    end

    function HoundCommsManager:updateSettings(settings)
        for k,v in pairs(settings) do self.settings[k] = v end
    end

    function HoundCommsManager:StopLoop()
        self.loop.msg = ""
        self.loop.header = ""
        self.loop.body = ""
        self.loop.footer = ""
        self.loop.MsgCallback = nil
    end

    function HoundCommsManager:SetMsgCallback(callback,args)
        if callback ~=nil and type(callback) == "function" then
            self.loop.MsgCallback = {func=callback,args=args}
        end
    end
    
    function HoundCommsManager:addMessageObj(obj)
        if obj.coalition == nil then return end
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
        if msg == nil or string.len(tostring(msg)) == 0 or coalition == nil then return end
        if prio == nil then prio = 1 end
        local obj = {
            coalition = coalition,
            priority = prio,
            txt = msg
        }
        self:addMessageObj(obj)
    end

    function HoundCommsManager:getNextMsg()
        if self.loop.MsgCallback ~= nil and type(self.loop.MsgCallback.func) == "function"  then 
                self.loop.MsgCallback.func(self.loop.MsgCallback.args) 
        end

        if self.loop.msg.tts ~= nil and (string.len(self.loop.msg.tts) > 0 or string.len(self.loop.msg.txt) > 0) then
            return self.loop.msg
        end

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
        if self.transmitter:getCategory() == Object.Category.STATIC then
            pos.y = pos.y + 120
        end
        if self.transmitter:getDesc()["category"] == Unit.Category.GROUND_UNIT then
            pos.y = pos.y + 50
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
            return timer.getTime() + 10
        end

        if gSelf.enabled and STTS ~= nil and msgObj.tts ~= nil then
            HoundUtils.TTS.Transmit(msgObj.tts,msgObj.coalition,gSelf.settings,transmitterPos)
            readTime = HoundUtils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed)
        end

        if gSelf.settings.enableText and msgObj.txt ~= nil then
            readTime =  HoundUtils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed) or HoundUtils.TTS.getReadTime(msgObj.txt,gSelf.settings.speed)
            trigger.action.outTextForCoalition(msgObj.coalition,msgObj.txt,readTime + 2 )
        end

        return timer.getTime() + readTime + 2 + gSelf.settings.interval
    end

    function HoundCommsManager:enable()
        self.enabled = true 
        if self.scheduler == nil then
            self.scheduler = timer.scheduleFunction(HoundCommsManager.TransmitFromQueue, self, timer.getTime() + self.settings.interval)
        end
    end

    function HoundCommsManager:disable()
        self.enabled = false 
        self:StopLoop()
    end

    function HoundCommsManager:setTransmitter(platformName)
        local canidate = Unit.getByName(platformName)
        if canidate == nil then
            canidate = StaticObject.getByName(platformName)
        end

        self.transmitter = canidate
    end

    function HoundCommsManager:removeTransmitter()
        if self.transmitter ~= nil then
            self.transmitter = nil
        end
    end

    function HoundCommsManager:setInterval(seconds)
        if type(seconds) == "number" then
            self.settings.interval = seconds
        end
    end
end
do

    local l_math = math
    local l_mist = mist

    HoundElint = {}
    HoundElint.__index = HoundElint

    function HoundElint:create(platformName)
        local elint = {}
        setmetatable(elint, HoundElint)
        elint.platform = {}
        elint.emitters = {}
        elint.elintTaskID = nil
        elint.radioMenu = {}
        elint.radioAdminMenu = nil
        elint.coalitionId = nil
        elint.useMarkers = true

        elint.addPositionError = false
        elint.positionErrorRadius = 30

        elint.settings = {
            mainInterval = 15,
            processInterval = 60,
            barkInterval = 120,
            markerType = HOUND.MARKER.DIAMOND
        }
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

        elint.controller = HoundCommsManager:create()
        elint.controller.settings.enableText = false
        elint.controller.settings.alerts = true

        elint.atis = HoundCommsManager:create()
        elint.atis.settings.freq = 250.500
        elint.atis.settings.interval = 4
        elint.atis.settings.speed = 1
        elint.atis.settings.reportEWR = false
        return elint
    end

    --[[
        Admin functions
    --]]

    function HoundElint:setCoalition(side)
        if self.coalitionId ~= nil then
            env.info("[ Hound ] - coalition already set")
            return false
        end
        if side == coalition.side.BLUE or side == coalition.side.RED then
            self.coalitionId = side
            return true
        end
    end

    function HoundElint:addPlatform(platformName)

        local canidate = Unit.getByName(platformName)
        if canidate == nil then
            canidate = StaticObject.getByName(platformName)
        end

        if self.coalitionId == nil and canidate ~= nil then
            self:setCoalition(canidate:getCoalition())
        end

        if canidate ~= nil and canidate:getCoalition() == self.coalitionId then
            local mainCategory = canidate:getCategory()
            local type = canidate:getTypeName()
    
            if setContains(HoundDB.Platform,mainCategory) then
                if setContains(HoundDB.Platform[mainCategory],type) then
                    for k,v in pairs(self.platform) do
                        if v == canidate then
                            return
                        end
                    end
                    table.insert(self.platform, canidate)
                    return true
                end
            end
        end
        env.info("[Hound] - Failed to add platform "..platformName..". Make sure you use unit name.")
        return false
    end

    function HoundElint:removePlatform(platformName)
        local canidate = Unit.getByName(platformName)
        if canidate == nil then
            canidate = StaticObject.getByName(platformName)
        end

        if canidate ~= nil then
            for k,v in ipairs(self.platform) do
                if v == canidate then
                    table.remove(self.platform, k)
                    return true
                end
            end
        end
        return false
    end

    function HoundElint:platformRefresh()
        if length(self.platform) < 1 then return end
        local toRemove = {}
        for i = length(self.platform), 1,-1 do
            if self.platform[i]:isExist() == false or self.platform[i]:getLife() <1 then  
                table.remove(self.platform, i) 
            end
        end
    end

    function HoundElint:removeDeadPlatforms()
        if length(self.platform) < 1 then return end
        for i=table.getn(self.platform),1,-1  do
            if self.platform[i]:isExist() == false or self.platform[i]:getLife() < 1 or (self.platform[i]:getCategory() ~= Object.Category.STATIC and self.platform[i]:isActive() == false) then
                table.remove(self.platform,i)
            end
        end
    end

    function HoundElint:configureController(args)
        self.controller:updateSettings(args)
    end

    function HoundElint:configureAtis(args)
        self.atis:updateSettings(args)
    end

    --[[
        Toggle functions
    --]]

    function HoundElint:toggleController(state,textMode)
        if STTS ~= nil  then
            if state == true and type(state) == "boolean" then
                self.controller:enable()
                return
            end
        end
        self.controller:disable()
     end

     function HoundElint:toggleControllerText(state)
        if type(state) == "boolean" then
            self.controller.settings.enableText = state
        end
     end

    function HoundElint:enableController(textMode)
        self:toggleController(true)
        self.controller:enable()
        if textMode then
            self:toggleControllerText(true)
        end
        self:addRadioMenu()
    end

    function HoundElint:disableController(textMode)
        self.controller:disable()
        if textMode then
            self:toggleControllerText(true)
        end
        self:removeRadioMenu()
    end

    function HoundElint:atisReportEWR(state)
        if type(state) == "boolean" then
            self.atis.reportEWR = state
        end
    end

    function HoundElint:toggleATIS(state) 
        if STTS ~= nil then
            if state == true and type(state) == "boolean" then
                    self.atis:enable()
                    return
            end
        end
        self.atis:disable()
    end

    function HoundElint:enableATIS()
        self.atis:enable()
        self.atis:SetMsgCallback(self.generateATIS,self)
    end

    function HoundElint:disableATIS()
        self.atis:disable()
    end

    function HoundElint:enableMarkers(markerType)
        self.useMarkers = true
        if markerType then
            self.settings.markerType = markerType
        end
    end

    function HoundElint:disableMarkers()
        self.useMarkers = false 
    end
    
    --[[
        ATIS functions
    --]]

    function HoundElint.generateATIS(gSelf)        
        local body = ""
        local numberEWR = 0

        if length(gSelf.emitters) > 0 then
            if (gSelf.atis.loop.last_count ~= nil and gSelf.atis.loop.last_update ~= nil) then
                if ((gSelf.atis.loop.last_count == length(gSelf.emitters)) and
                     ((timer.getAbsTime() - gSelf.atis.loop.last_update) < 120)) then return end
            end
            local sortedContacts = {}

            for uid,emitter in pairs(gSelf.emitters) do
                table.insert(sortedContacts,emitter)
            end
    
            table.sort(sortedContacts, HoundElint.sortContacts)

            for uid, emitter in pairs(sortedContacts) do
                if emitter.pos.p ~= nil then
                    if emitter.isEWR == false or (gSelf.atis.settings.reportEWR and emitter.isEWR) then
                    body = body .. emitter:generateTtsBrief(gSelf.atis.settings.NATO) .. " "
                    end
                    if (gSelf.atis.settings.reportEWR == false and emitter.isEWR) then
                        numberEWR = numberEWR+1
                    end
                end
            end
        end

        if body == "" then body = "No threats had been detected " end
        if numberEWR > 0 then body = body .. ",  " .. numberEWR .. " EWRs are tracked. " end
        if body == gSelf.atis.loop.body then return end
        gSelf.atis.loop.body = body

        local reportId = HoundUtils.getReportId()
        gSelf.atis.loop.header = gSelf.atis.settings.name 
        if gSelf.atis.settings.NATO then
            gSelf.atis.loop.header = gSelf.atis.loop.header .. " Lowdown "
        else
            gSelf.atis.loop.header = gSelf.atis.loop.header .. " SAM information "
        end 

        gSelf.atis.loop.header = gSelf.atis.loop.header .. reportId .. " " .. HoundUtils.TTS.getTtsTime() .. ". "
        gSelf.atis.loop.footer = "you have " .. reportId .. "."
        local msg = gSelf.atis.loop.header .. gSelf.atis.loop.body .. gSelf.atis.loop.footer
        local msgObj = {
            coalition = gSelf.coalitionId,
            priority = "loop",
            tts = msg
        }

        gSelf.atis.loop.msg = msgObj
        gSelf.atis.loop.last_count = length(gSelf.emitters)
        gSelf.atis.loop.last_update = timer.getAbsTime()
    end

    --[[
        Controller functions
    --]]

    function HoundElint.TransmitSamReport(args)
        local gSelf = args["self"]
        local emitter = args["emitter"]
        local requester = args["requester"]
        local controllerCallsign = args["self"].controller.settings.name
        local coalitionId = args["self"].coalitionId
        local msgObj = {
            coalition = args["self"].coalitionId,
            priority = 1
        }
        if emitter.isEWR then msgObj.priority = 2 end

        if gSelf.controller.enabled then
            msgObj.tts = args["emitter"]:generateTtsReport()
            if requester ~= nil then
                msgObj.tts = requester .. ", " .. controllerCallsign .. ", " .. msgObj.tts
            end
        end
        if gSelf.controller.settings.enableText == true then
            msgObj.txt = emitter:generateTextReport()
        end

        gSelf.controller:addMessageObj(msgObj)
    end

    function HoundElint:notifyDeadEmitter(emitter)
        if self.controller.settings.alerts == false then return end
        local msg = {
            coalition = self.coalitionId,
            priority = 3
        }
        if self.controller.settings.enableText then
            msg.txt = emitter:generateDeathReport(false)
        end
        msg.tts = emitter:generateDeathReport(true)
        self.controller:addMessageObj(msg)
    end

    function HoundElint:notifyNewEmitter(emitter)
        if self.controller.settings.alerts == false then return end
        local msg = {
            coalition = self.coalitionId,
            priority = 2
        }
        if self.controller.settings.enableText then
            msg.txt = emitter:generatePopUpReport(false)
        end
        msg.tts = emitter:generatePopUpReport(true)
        
        self.controller:addMessageObj(msg)
    end

    --[[
        Actual work functions
    --]]

    function HoundElint:getSensorPrecision(platform,emitterBand)
        local mainCategory = platform:getCategory()
        local type = platform:getTypeName()

        if setContains(HoundDB.Platform,mainCategory) then
            if setContains(HoundDB.Platform[mainCategory],type) then
                local antenna_size = HoundDB.Platform[mainCategory][type].antenna.size *  HoundDB.Platform[mainCategory][type].antenna.factor
                return  HoundUtils.getDefraction(emitterBand,antenna_size) -- precision
            end
        end
        return l_math.rad(15.0)
    end

    function HoundElint:getAzimuth(src, dst, sensorPrecision)
        local pi_2 = 2*l_math.pi
        local AngularErr = HoundUtils.getNormalAngularError(sensorPrecision)

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

    function HoundElint:getActiveRadars()
        local Radars = {}

        for coalitionId,coalitionName in pairs(coalition.side) do
            if coalitionName ~= self.coalitionId then
                for cid,CategoryId in pairs({Group.Category.GROUND,Group.Category.SHIP}) do
                    for gid, group in pairs(coalition.getGroups(coalitionName, CategoryId)) do
                        for uid, unit in pairs(group:getUnits()) do
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

    function HoundElint:Sniff()
        local Recivers = {}
        self:removeDeadPlatforms()

        if length(self.platform) == 0 then
            env.info("no active platform")
            return
        end

        local Radars = self:getActiveRadars()

        if length(Radars) == 0 then
            env.info("No Transmitting Radars")
            return
        end
        for i,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            local RadarUid = radar:getID()
            local RadarType = radar:getTypeName()
            local RadarName = radar:getName()
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + radar:getDesc()["box"]["max"]["y"] -- use vehicle bounting box for height

            for j,platform in ipairs(self.platform) do
                local platformPos = platform:getPosition().p
                local platformId = platform:getID()
                local platformIsStatic = false
                local isAerialUnit = false

                if platform:getCategory() == Object.Category.STATIC then
                    platformIsStatic = true
                    platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                else
                    local PlatformUnitCategory = platform:getDesc()["category"]
                    if PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE then
                        isAerialUnit = true
                        if self.addPositionError then
                        end                    
                    end

                    if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
                        platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                    end
                end

                if HoundUtils.checkLOS(platformPos, radarPos) then
                    if (self.emitters[RadarUid] == nil) then
                        self.emitters[RadarUid] =
                            HoundContact:New(radar, self.coalitionId)
                    end
                    local sensorMargins = self:getSensorPrecision(platform,self.emitters[RadarUid].band)
                    if sensorMargins < l_math.rad(15.0) then
                        local az,el = self:getAzimuth( platformPos, radarPos, sensorMargins )
                        if not isAerialUnit then
                            el = nil
                        end
                        local datapoint = HoundElintDatapoint:New(platform,platformPos, az, el, timer.getAbsTime(),platformIsStatic,sensorMargins)
                        self.emitters[RadarUid]:AddPoint(datapoint)
                    end
                end
            end
        end 
    end 

    function HoundElint:Process()
        local currentTime = timer.getTime() + 0.2
        for uid, emitter in pairs(self.emitters) do
            if emitter ~= nil then
                local isNew = emitter:processData()
                if isNew then
                    self:notifyNewEmitter(emitter)
                    if self.useMarkers then emitter:updateMarker(self.coalitionId,self.settings.markerType) end
                end
                emitter:CleanTimedout()
                if emitter:isAlive() == false and HoundUtils:timeDelta(emitter.last_seen, timer.getAbsTime()) > 60 then
                    self:notifyDeadEmitter(emitter)
                    self:removeRadarRadioItem(emitter)
                    emitter:removeMarker()
                    self.emitters[uid] = nil
                else
                    if HoundUtils:timeDelta(emitter.last_seen,
                                            timer.getAbsTime()) > 1800 then
                        self:removeRadarRadioItem(emitter)
                        emitter:removeMarker()
                        self.emitters[uid] = nil
                    end
                end
            end
        end
    end

    function HoundElint:UpdateMarkers()
        if self.useMarkers then
            for _, emitter in pairs(self.emitters) do
                emitter:updateMarker(self.coalitionId,self.settings.markerType)
            end
        end
    end

    function HoundElint.runCycle(self)
        local nextRun = timer.getTime() + gaussian(self.settings.mainInterval,3)
        if self.coalitionId == nil then return nextRun end
        if self.platform then self:platformRefresh() end
        if length(self.platform) > 0 then
            self:Sniff()
        end
        if length(self.emitters) > 0 then
            self.timingCounters.short = not self.timingCounters.short
            if self.timingCounters.short then
                self:Process()
                self.timingCounters.long = self.timingCounters.long + 1
            end
            if self.timingCounters.long == 2 then
                self:populateRadioMenu()
                self:UpdateMarkers()
                self.timingCounters.long = 0
            end
        end
        return nextRun
    end

    function HoundElint.updatePlatformState(params)
        local option = params.option
        local self = params.self
        if option == 'systemOn' then
            self:systemOn()
        elseif option == 'systemOff' then
            self:systemOff()
        end
    end

    function HoundElint:systemOn(notify)
        if self.coalitionId == nil then
            env.info("[Hound] - failed to start. no coalition found.")
            return false
        end
        self:systemOff(false)

        self.elintTaskID = timer.scheduleFunction(self.runCycle, self, timer.getTime() + self.settings.mainInterval)
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.coalitionId,
                                           "Hound ELINT system is now Operating", 10)
        end
        env.info("Hound is now on")
        return true
    end

    function HoundElint:systemOff(notify)
        if self.elintTaskID ~= nil then
            mist.removeFunction(self.elintTaskID)
        end
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.coalitionId,
                                           "Hound ELINT system is now Offline", 10)
        end
        env.info("Hound is now off")
        return true
    end

    --[[
        Menu functions - Admin Menu
    --]]
    function HoundElint:addAdminRadioMenu()
        self.radioAdminMenu = missionCommands.addSubMenuForCoalition(
                                  self.coalitionId, 'ELINT managment')
        missionCommands.addCommandForCoalition(self.coalitionId, 'Activate',
                                               self.radioAdminMenu,
                                               HoundElint.updatePlatformState, {
            self = self,
            option = 'systemOn'
        })
        missionCommands.addCommandForCoalition(self.coalitionId, 'DeActivate',
                                               self.radioAdminMenu,
                                               HoundElint.updatePlatformState, {
            self = self,
            option = 'systemOff'
        })
    end

    function HoundElint:removeAdminRadioMenu()
        missionCommands.removeItem(self.radioAdminMenu)
    end

    --[[
        Menu functions - Unit Info Menues
    --]]

    function HoundElint:addRadioMenu()
        self.radioMenu.root = missionCommands.addSubMenuForCoalition(
                                  self.coalitionId, 'ELINT Intel')
        self.radioMenu.data = {}
        self.radioMenu.noData = missionCommands.addCommandForCoalition(self.coalitionId,
                                                   "No radars are currently tracked",
                                                   self.radioMenu.root, timer.getAbsTime)

    end

    function HoundElint.sortContacts(a,b)
        if a.isEWR ~= b.isEWR then
          return b.isEWR and not a.isEWR
        end
        if a.maxRange ~= b.maxRange then
            return a.maxRange > b.maxRange
        end
        if a.typeAssigned ~= b.typeAssigned then
            return a.typeAssigned < b.typeAssigned
        end
        if a.typeName ~= b.typeName then
            return a.typeName < b.typeName
        end
        if a.first_seen ~= b.first_seen then
            return a.first_seen > b.first_seen
        end
        return a.uid < b.uid 
    end

    function HoundElint:populateRadioMenu()
        if self.radioMenu.root == nil or length(self.emitters) == 0 or self.coalitionId == nil or not self.controller.enabled then
            return
        end
        local sortedContacts = {}

        for uid,emitter in pairs(self.emitters) do
            table.insert(sortedContacts,emitter)
        end

        table.sort(sortedContacts, HoundElint.sortContacts)

        if length(sortedContacts) == 0 then return end
        for k,t in pairs(self.radioMenu.data) do
            if k ~= "placeholder" then
                t.counter = 0
            end
        end

        for id, emitter in ipairs(sortedContacts) do
            local DCStypeName = emitter.DCStypeName
            local assigned = emitter.typeAssigned
            local uid = emitter.uid
            if emitter.pos.p ~= nil then
                if length(self.radioMenu.data[assigned]) == 0 then
                    self.radioMenu.data[assigned] = {}
                    self.radioMenu.data[assigned].root =
                        missionCommands.addSubMenuForCoalition(self.coalitionId,
                                                               assigned, self.radioMenu.root)
                    self.radioMenu.data[assigned].data = {}
                    self.radioMenu.data[assigned].menus = {}
                    self.radioMenu.data[assigned].counter = 0
                end

                self:removeRadarRadioItem(emitter)
                self:addRadarRadioItem(emitter)
            end
        end
    end

    function HoundElint:addRadarRadioItem(emitter)
        local DCStypeName = emitter.DCStypeName
        local assigned = emitter.typeAssigned
        local uid = emitter.uid
        local text = emitter:generateRadioItemText()

        self.radioMenu.data[assigned].counter = self.radioMenu.data[assigned].counter + 1

        if self.radioMenu.data[assigned].counter == 1 then
            for k,v in pairs(self.radioMenu.data[assigned].menus) do
                self.radioMenu.data[assigned].menus[k] = missionCommands.removeItemForCoalition(self.coalitionId,v)
            end
        end

        if self.radioMenu.noData ~= nil then
            self.radioMenu.noData = missionCommands.removeItemForCoalition(self.coalitionId, self.radioMenu.noData)
        end
 
        local submenu = 0
        if self.radioMenu.data[assigned].counter > 9 then
            submenu = math.floor((self.radioMenu.data[assigned].counter+1)/10)
        end
        if submenu == 0 then
            self.radioMenu.data[assigned].data[uid] = missionCommands.addCommandForCoalition(self.coalitionId, emitter:generateRadioItemText(), self.radioMenu.data[assigned].root, self.TransmitSamReport,{self=self,emitter=emitter})
        end
        if submenu > 0 then
            if self.radioMenu.data[assigned].menus[submenu] == nil then
                if submenu == 1 then
                    self.radioMenu.data[assigned].menus[submenu] = missionCommands.addSubMenuForCoalition(self.coalitionId, "More (Page " .. submenu+1 .. ")", self.radioMenu.data[assigned].root)
                else
                    self.radioMenu.data[assigned].menus[submenu] = missionCommands.addSubMenuForCoalition(self.coalitionId, "More (Page " .. submenu+1 .. ")", self.radioMenu.data[assigned].menus[submenu-1])
                end
            end
            self.radioMenu.data[assigned].data[uid] = missionCommands.addCommandForCoalition(self.coalitionId, emitter:generateRadioItemText(), self.radioMenu.data[assigned].menus[submenu], self.TransmitSamReport,{self=self,emitter=emitter})
        end
    end

    function HoundElint:removeRadarRadioItem(emitter)

        local DCStypeName = emitter.DCStypeName
        local assigned = emitter.typeAssigned
        local uid = emitter.uid
        if not self.controller.enabled or self.radioMenu.data[assigned] == nil then
            return
        end

        if setContains(self.radioMenu.data[assigned].data,uid) then
            self.radioMenu.data[assigned].data[uid] = missionCommands.removeItemForCoalition(self.coalitionId, self.radioMenu.data[assigned].data[uid])
        end
    end

    function HoundElint:removeRadioMenu()
        missionCommands.removeItemForCoalition(self.coalitionId,
                                               self.radioMenu.root)
        self.radioMenu = {}
    end

    function HoundElint:getContacts()
        local contacts = {
            ewr = { contacts = {}
                },
            sam = {
                    contacts = {}
                }
        }
        for uid,emitter in pairs(self.emitters) do
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
end

do
    trigger.action.outText("Hound ELINT ("..HOUND.VERSION..") is loaded.", 15)
    env.info("[ Hound ] - finished loading (".. HOUND.VERSION..")")
end

env.info("Hound ELINT Loaded Successfully")
