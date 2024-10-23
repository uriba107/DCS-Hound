--[[

DCS-SimpleTextToSpeech
Version 0.4
Compatible with SRS version 1.9.6.0 +

DCS Modification Required:

You will need to edit MissionScripting.lua in DCS World/Scripts/MissionScripting.lua and remove the sanitisation.
To do this remove all the code below the comment - the line starts "local function sanitizeModule(name)"

Do this without DCS running to allow mission scripts to use os functions.

*You WILL HAVE TO REAPPLY AFTER EVERY DCS UPDATE*

USAGE:

Add this script into the mission as a DO SCRIPT or DO SCRIPT FROM FILE to initialise it

Make sure to edit the STTS.SRS_PORT and STTS.DIRECTORY to the correct values before adding to the mission.

Then its as simple as calling the correct function in LUA as a DO SCRIPT or in your own scripts

Example calls:

STTS.TextToSpeech("Hello DCS WORLD","251","AM","1.0","SRS",2)

Arguments in order are:
 - Message to say, make sure not to use a newline (\n) !
 - Frequency in MHz
 - Modulation - AM/FM
 - Volume - 1.0 max, 0.5 half
 - Name of the transmitter - ATC, RockFM etc
 - Coalition - 0 spectator, 1 red 2 blue
 - OPTIONAL - Vec3 Point i.e Unit.getByName("A UNIT"):getPoint() - needs Vec3 for Height! OR null if not needed
 - OPTIONAL - Speed -10 to +10
 - OPTIONAL - Gender male, female or neuter
 - OPTIONAL - Culture - en-US, en-GB etc
 - OPTIONAL - Voice - a specfic voice by name. Run DCS-SR-ExternalAudio.exe with --help to get the ones you can use on the command line
 - OPTIONAL - Google TTS - Switch to Google Text To Speech - Requires STTS.GOOGLE_CREDENTIALS path and Google project setup correctly

 This example will say the words "Hello DCS WORLD" on 251 MHz AM at maximum volume with a client called SRS and to the Blue coalition only

STTS.TextToSpeech("Hello DCS WORLD","251","AM","1.0","SRS",2,null,-5,"male","en-GB")

 This example will say the words "Hello DCS WORLD" on 251 MHz AM at maximum volume with a client called SRS and to the Blue coalition only centered on
 the position of the Unit called "A UNIT"

STTS.TextToSpeech("Hello DCS WORLD","251","AM","1.0","SRS",2,Unit.getByName("A UNIT"):getPoint(),-5,"male","en-GB")

Arguments in order are:
 - FULL path to the MP3 OR OGG to play
 - Frequency in MHz - to use multiple separate with a comma - Number of frequencies MUST match number of Modulations
 - Modulation - AM/FM - to use multiple
 - Volume - 1.0 max, 0.5 half
 - Name of the transmitter - ATC, RockFM etc
 - Coalition - 0 spectator, 1 red 2 blue

This will play that MP3 on 255MHz AM & 31 FM at half volume with a client called "Multiple" and to Spectators only

STTS.PlayMP3("C:\\Users\\Ciaran\\Downloads\\PR-Music.mp3","255,31","AM,FM","0.5","Multiple",0)

]]


STTS = {}
-- FULL Path to the FOLDER containing DCS-SR-ExternalAudio.exe - EDIT TO CORRECT FOLDER
STTS.DIRECTORY = "C:\\Users\\Ciaran\\Dropbox\\Dev\\DCS\\DCS-SRS\\install-build"
STTS.SRS_PORT = 5002 -- LOCAL SRS PORT - DEFAULT IS 5002
STTS.GOOGLE_CREDENTIALS = "C:\\Users\\Ciaran\\Downloads\\googletts.json"

-- DONT CHANGE THIS UNLESS YOU KNOW WHAT YOU'RE DOING
STTS.EXECUTABLE = "DCS-SR-ExternalAudio.exe"

local random = math.random
function STTS.uuid()
    local template ='yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function STTS.round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function STTS.getSpeechTime(length,speed,googleTTS)
    -- Function returns estimated speech time in seconds

    -- Assumptions for time calc: 100 Words per min, avarage of 5 letters for english word
    -- so 5 chars * 100wpm = 500 characters per min = 8.3 chars per second
    -- so lengh of msg / 8.3 = number of seconds needed to read it. rounded down to 8 chars per sec
    -- map function:  (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

    local maxRateRatio = 3 

    speed = speed or 1.0
    googleTTS = googleTTS or false

    local speedFactor = 1.0
    if googleTTS then
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

function STTS.TextToSpeech(message,freqs,modulations, volume,name, coalition,point, speed,gender,culture,voice, googleTTS )
    if os == nil or io == nil then 
        env.info("[DCS-STTS] LUA modules os or io are sanitized. skipping. ")
        return 
    end

	speed = speed or 1
	gender = gender or "female"
	culture = culture or ""
	voice = voice or ""

    message = message:gsub("\"","\\\"")
    
    local pwsh = string.format("Start-Process -WindowStyle Hidden -WorkingDirectory \"%s\" -FilePath \"%s\"", STTS.DIRECTORY, STTS.EXECUTABLE )

    local cmdArgs = {
        ["-f"] = freqs,
        ["-m"] = modulations,
        ["-c"] = coalition,
        ["-p"] = STTS.SRS_PORT,
        ["-n"] = name
    }

    if voice ~= "" then
        cmdArgs["-V"] = voice
    else
    	if culture ~= "" then
            cmdArgs["-l"] = culture
    	end

    	if gender ~= "" then
            cmdArgs["-g"] = gender
    	end
    end

    if googleTTS == true then
        cmdArgs["-G"] = STTS.GOOGLE_CREDENTIALS
    end

    if speed ~= 1 then
        cmdArgs["-s"] = speed
    end

    if volume ~= 1.0 then
        cmdArgs["-v"] = volume
    end

    if point and type(point) == "table" and point.x then
        local lat, lon, alt = coord.LOtoLL(point)

        lat = STTS.round(lat,4)
        lon = STTS.round(lon,4)
        alt = math.floor(alt)

        cmdArgs["-L"] = lat
        cmdArgs["-O"] = lon
        cmdArgs["-A"] = alt
    end

    cmdArgs["-t"] = message

    local cmdArgsList = {}
    for k,v in pairs(cmdArgs) do
        if type(v) == "string" then
            v = '"'..v..'"'
        end
        table.insert(cmdArgsList,"'"..k.." "..v.."'")
    end
    pwsh = pwsh .. " -ArgumentList " .. table.concat(cmdArgsList,',')
    if string.len(pwsh) > 1 then
        local filename = lfs.tempdir() .. "\\DCS_STTS-" .. STTS.uuid() .. ".ps1"
        local script = io.open(filename,"w+")
        script:write(pwsh)
        script:close()
        pwsh = string.format('powershell.exe  -ExecutionPolicy Unrestricted -WindowStyle Hidden -Command "%s"',filename)
        timer.scheduleFunction(os.remove, filename, timer.getTime() + 1) 
    end
    if string.len(pwsh) > 255 then
        env.info("[DCS-STTS] - pwsh string too long")
        env.info("[DCS-STTS] TextToSpeech Command :\n" .. pwsh.."\n")
   end
    os.execute(pwsh)

    return STTS.getSpeechTime(message,speed,googleTTS)

end

    function STTS.PlayMP3(pathToMP3,freqs,modulations, volume,name, coalition,point )

    local cmd = string.format("start \"\" /d \"%s\" /b /min \"%s\" -i \"%s\" -f %s -m %s -c %s -p %s -n \"%s\" -v %s -h", STTS.DIRECTORY, STTS.EXECUTABLE, pathToMP3, freqs, modulations, coalition,STTS.SRS_PORT, name, volume )
    
    if point and type(point) == "table" and point.x then
        local lat, lon, alt = coord.LOtoLL(point)

        lat = STTS.round(lat,4)
        lon = STTS.round(lon,4)
        alt = math.floor(alt)

        cmd = cmd .. string.format(" -L %s -O %s -A %s",lat,lon,alt)
    end

    env.info("[DCS-STTS] MP3/OGG Command :\n" .. cmd.."\n")
    os.execute(cmd)

end
