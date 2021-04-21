-- Override functions - rquire DCS-SimpleTextToSpeech
STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"

function STTS.isLoaded()
    if STTS.PlayMP3 ~= nil then return true end
    return false
end

function STTS.TextToSpeech(message,freqs,modulations, volume,name, coalition,gender,locale)
    if os == nil then return end
    message = message:gsub("\"","\\\"")
    local cmd = string.format("start /min \"%s\" \"%s\\%s\" \"%s\" %s %s %s %s \"%s\" %s", "STTS", STTS.DIRECTORY, STTS.EXECUTABLE, message, freqs, modulations, coalition,STTS.SRS_PORT, name, volume )
    if gender ~= nil then cmd = cmd .. " " .. gender end
    if locale ~= nil then cmd = cmd .. " " .. locale end
    if string.len(cmd) > 250 then 
        local filename = STTS.DIRECTORY .. "\\" .."tmp_" .. os.time()%string.len(cmd) .. timer.getAbsTime() % math.random(string.len(cmd)) .. coalition .. ".bat"
        local script = io.open(filename,"w+")
        script:write(cmd .. " && exit")
        script:close()
        os.execute(string.format("\"%s\"",filename))
        timer.scheduleFunction(os.remove, filename, timer.getTime() + 1)
    end
    os.execute(cmd)
end






