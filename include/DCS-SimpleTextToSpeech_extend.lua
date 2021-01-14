-- Override functions - rquire DCS-SimpleTextToSpeech
STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"


function STTS.TextToSpeech(message,freqs,modulations, volume,name, coalition )

    message = message:gsub("\"","\\\"")
    local cmd = string.format("start /min \"%s\" \"%s\\%s\" \"%s\" %s %s %s %s \"%s\" %s", "STTS", STTS.DIRECTORY, STTS.EXECUTABLE, message, freqs, modulations, coalition,STTS.SRS_PORT, name, volume )
    if string.len(cmd) > 250 then
        local filename = STTS.DIRECTORY .. "\\" .."tmp_" .. os.time()%string.len(cmd) .. timer.getAbsTime() % math.random(string.len(cmd)) .. coalition .. ".bat"
        local script = io.open(filename,"w+")
        script:write(cmd .. " && exit")
        script:close()
        os.execute(string.format("start \"STTS_wrapper\" /min /WAIT \"%s\"",filename))
        os.remove(filename)
    end
    os.execute(cmd)
end






