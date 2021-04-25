-- Override functions - rquire DCS-SimpleTextToSpeech 1.9.6.0+
STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"

function STTS.isLoaded()
    if STTS.PlayMP3 ~= nil then return true end
    return false
end

-- function STTS.TextToSpeech(message,freqs,modulations, volume,name, coalition,gender,locale)
--     if os == nil then return end
--     message = message:gsub("\"","\\\"")
--     local cmd = string.format("start /min \"%s\" \"%s\\%s\" \"%s\" %s %s %s %s \"%s\" %s", "STTS", STTS.DIRECTORY, STTS.EXECUTABLE, message, freqs, modulations, coalition,STTS.SRS_PORT, name, volume )
--     if gender ~= nil then cmd = cmd .. " " .. gender end
--     if locale ~= nil then cmd = cmd .. " " .. locale end
--     if string.len(cmd) > 250 then 
--         local filename = STTS.DIRECTORY .. "\\" .."tmp_" .. os.time()%string.len(cmd) .. timer.getAbsTime() % math.random(string.len(cmd)) .. coalition .. ".bat"
--         local script = io.open(filename,"w+")
--         script:write(cmd .. " && exit")
--         script:close()
--         os.execute(string.format("\"%s\"",filename))
--         timer.scheduleFunction(os.remove, filename, timer.getTime() + 1)
--     end
--     os.execute(cmd)
-- end


function STTS.TextToSpeech(message,freqs,modulations, volume,name, coalition,point, speed,gender,culture,voice, googleTTS )

	speed = speed or 1
	gender = gender or "female"
	culture = culture or ""
	voice = voice or ""

    -- --creating a temp file to work around the 260 character limit on os.execute
    -- local tmpName = STTS.uuid()..".tmp"

    -- local tmpFile = io.open( tmpName, "w" )
    -- tmpFile:write(message)
    -- tmpFile:close()

    message = message:gsub("\"","\\\"")
    
    local cmd = string.format("start \"\" /d \"%s\" /b /min \"%s\" -t \"%s\" -f %s -m %s -c %s -p %s -n \"%s\" -h", STTS.DIRECTORY, STTS.EXECUTABLE, message, freqs, modulations, coalition,STTS.SRS_PORT, name )
    
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

    if string.len(cmd) >= 260 then
        local filename = STTS.DIRECTORY .. "\\" .."tmp_" .. STTS.uuid() .. ".bat"
        local script = io.open(filename,"w+")
        script:write(cmd .. " && exit")
        script:close()
        os.execute(string.format("\"%s\"",filename))
        timer.scheduleFunction(os.remove, filename, timer.getTime() + 1)   
    end

    env.info("[DCS-STTS] TextToSpeech Command :\n" .. cmd.."\n")
    os.execute(cmd)

end





