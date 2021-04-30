-- Override functions - rquire DCS-SimpleTextToSpeech 1.9.6.0+
STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"

function STTS.isLoaded()
    if STTS.PlayMP3 ~= nil then return true end
    return false
end




function STTS.TextToSpeech(message,freqs,modulations, volume,name, coalition,point, speed,gender,culture,voice, googleTTS )
    if os == nil then return end
	speed = speed or 1
	gender = gender or "female"
	culture = culture or ""
	voice = voice or ""

    message = message:gsub("\"","\\\"")
    
    local cmd = string.format("start \"\" /min /d \"%s\" /b \"%s\" -f %s -m %s -c %s -p %s -n \"%s\" -h", STTS.DIRECTORY, STTS.EXECUTABLE, freqs, modulations, coalition,STTS.SRS_PORT, name )

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

    local inlineText = string.format(" -t \"%s\"",message)

    if string.len(cmd) + string.len(inlineText) >= 260 then
        local filename = "tmp_" .. STTS.uuid() .. ".txt"
        local script = io.open(STTS.DIRECTORY .. "\\" .. filename,"w+")
        script:write(message)
        script:close()
        cmd = cmd .. string.format(" -I \"%s\"",filename)
        timer.scheduleFunction(os.remove, STTS.DIRECTORY .. "\\" .. filename, timer.getTime() + 5) 
    else
        cmd = cmd .. inlineText
    end

    if string.len(cmd) > 255 then env.error("[DCS-STTS] - cmd string too long") end
    env.info("[DCS-STTS] TextToSpeech Command :\n" .. cmd.."\n")
    os.execute(cmd)

end





