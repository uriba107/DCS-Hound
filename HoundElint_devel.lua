env.info("Loading Hound Scripts dynamicly")

-- local Loaderlfs=require('lfs')
-- env.info(Loaderlfs.currentdir())
local currentDir = "F:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
assert(loadfile(currentDir..'test\\StopWatch.lua'))()
-- assert(loadfile(currentDir..'test\\luaunit.lua'))()

-- assert(loadfile(currentDir..'include\\DCS-SimpleTextToSpeech.lua'))()
-- assert(loadfile(currentDir..'src\\00 - HoundDBs.lua'))()
-- assert(loadfile(currentDir..'src\\01 - HoundGlobals.lua'))()
-- assert(loadfile(currentDir..'src\\02 - HoundUtils.lua'))()
-- assert(loadfile(currentDir..'src\\03 - HoundContact.lua'))()
-- assert(loadfile(currentDir..'src\\04 - HoundCommsManager.lua'))()
-- assert(loadfile(currentDir..'src\\05 - HoundElint.lua'))()
    assert(loadfile(currentDir..'src\\000 - HoundGlobals.lua'))()
    assert(loadfile(currentDir..'src\\010 - HoundLogger.lua'))()
    assert(loadfile(currentDir..'src\\100 - HoundDBs.lua'))()
    assert(loadfile(currentDir..'src\\110 - HoundConfig.lua'))()
    assert(loadfile(currentDir..'src\\200 - HoundUtils.lua'))()
    assert(loadfile(currentDir..'src\\210 - HoundEventHandler.lua'))()
    assert(loadfile(currentDir..'src\\299 - HoundDatapoint.lua'))()
    assert(loadfile(currentDir..'src\\300 - HoundContact.lua'))()
    assert(loadfile(currentDir..'src\\301 - HoundContact_comms.lua'))()
    assert(loadfile(currentDir..'src\\400 - HoundCommsManager.lua'))()
    assert(loadfile(currentDir..'src\\410 - HoundInformationSystem.lua'))()
    assert(loadfile(currentDir..'src\\420 - HoundController.lua'))()
    assert(loadfile(currentDir..'src\\421 - HoundNotifier.lua'))()
    assert(loadfile(currentDir..'src\\500 - HoundElintWorker.lua'))()
    assert(loadfile(currentDir..'src\\510 - HoundContactManager.lua'))()
    assert(loadfile(currentDir..'src\\550 - HoundSector.lua'))()
    assert(loadfile(currentDir..'src\\800 - HoundElint.lua'))()
    assert(loadfile(currentDir..'src\\999 - Hound_footer.lua'))()

    -- assert(loadfile(currentDir..'demo_mission\\hound_unit_test\\hound-unit-tests.lua'))()


-- assert(loadfile(currentDir..'demo_mission\\Caucasus_demo\\HoundElint_demo.lua'))()
-- assert(loadfile(currentDir..'demo_mission\\Syria_POC\\Hound_Demo_SyADFGCI.lua'))()


env.info("Loading Done")

