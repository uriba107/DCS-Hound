-- Override functions - rquire DCS-SimpleTextToSpeech 1.9.6.0+
STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"

function STTS.getSpeechTime(length,speed,isGoogle)
    -- Function returns estimated speech time in seconds

    -- Assumptions for time calc: 100 Words per min, avarage of 5 letters for english word
    -- so 5 chars * 100wpm = 500 characters per min = 8.3 chars per second
    -- so lengh of msg / 8.3 = number of seconds needed to read it. rounded down to 8 chars per sec
    -- map function:  (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

    local maxRateRatio = 3 

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
    
    local cmd = string.format("start /min \"\" /d \"%s\" /b \"%s\" -f %s -m %s -c %s -p %s -n \"%s\" -h", STTS.DIRECTORY, STTS.EXECUTABLE, freqs, modulations, coalition,STTS.SRS_PORT, name )
    
    if voice ~= "" then
    	cmd = cmd .. string.format(" -V \"%s\"",voice)
    else

    	if culture ~= "" then
    		cmd = cmd .. string.format(" -l %s",culture)
    	end

    	if gender ~= "" then
    		cmd = cmd .. string.format(" -g %s",gender)
    	end
    end

    if googleTTS == true then
        cmd = cmd .. string.format(" -G \"%s\"",STTS.GOOGLE_CREDENTIALS)
    end

    if speed ~= 1 then
        cmd = cmd .. string.format(" -s %s",speed)
    end

    if volume ~= 1.0 then
        cmd = cmd .. string.format(" -v %s",volume)
    end

    if point and type(point) == "table" and point.x then
        local lat, lon, alt = coord.LOtoLL(point)

        lat = STTS.round(lat,4)
        lon = STTS.round(lon,4)
        alt = math.floor(alt)

        cmd = cmd .. string.format(" -L %s -O %s -A %s",lat,lon,alt)        
    end

    cmd = cmd ..string.format(" -t \"%s\"",message)

    if string.len(cmd) > 255 then
        local filename = os.getenv('TMP') .. "\\DCS_STTS-" .. STTS.uuid() .. ".bat"
        local script = io.open(filename,"w+")
        script:write(cmd .. " && exit" )
        script:close()
        cmd = string.format("\"%s\"",filename)
        timer.scheduleFunction(os.remove, filename, timer.getTime() + 1) 
    end

    if string.len(cmd) > 255 then
         env.info("[DCS-STTS] - cmd string too long")
         env.info("[DCS-STTS] TextToSpeech Command :\n" .. cmd.."\n")
    end
    os.execute(cmd)

    return STTS.getSpeechTime(message,speed,googleTTS)

end





