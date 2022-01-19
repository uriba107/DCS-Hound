env.info("Loading Hound Scripts dynamicly")

-- local Loaderlfs=require('lfs')
-- env.info(Loaderlfs.HoundWorkDir())
local HoundWorkDir = "F:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
assert(loadfile(HoundWorkDir..'test\\StopWatch.lua'))()
-- assert(loadfile(HoundWorkDir..'test\\luaunit.lua'))()

-- assert(loadfile(HoundWorkDir..'include\\DCS-SimpleTextToSpeech.lua'))()
-- assert(loadfile(HoundWorkDir..'src\\00 - HoundDBs.lua'))()
-- assert(loadfile(HoundWorkDir..'src\\01 - HoundGlobals.lua'))()
-- assert(loadfile(HoundWorkDir..'src\\02 - HoundUtils.lua'))()
-- assert(loadfile(HoundWorkDir..'src\\03 - HoundContact.lua'))()
-- assert(loadfile(HoundWorkDir..'src\\04 - HoundCommsManager.lua'))()
-- assert(loadfile(HoundWorkDir..'src\\05 - HoundElint.lua'))()
    assert(loadfile(HoundWorkDir..'src\\000 - HoundGlobals.lua'))()
    assert(loadfile(HoundWorkDir..'src\\010 - HoundLogger.lua'))()
    assert(loadfile(HoundWorkDir..'src\\100 - HoundDBs.lua'))()
    assert(loadfile(HoundWorkDir..'src\\110 - HoundConfig.lua'))()
    assert(loadfile(HoundWorkDir..'src\\200 - HoundUtils.lua'))()
    assert(loadfile(HoundWorkDir..'src\\210 - HoundEventHandler.lua'))()
    assert(loadfile(HoundWorkDir..'src\\295 - HoundEstimator.lua'))()
    assert(loadfile(HoundWorkDir..'src\\299 - HoundDatapoint.lua'))()
    assert(loadfile(HoundWorkDir..'src\\300 - HoundContact.lua'))()
    assert(loadfile(HoundWorkDir..'src\\301 - HoundContact_comms.lua'))()
    assert(loadfile(HoundWorkDir..'src\\400 - HoundCommsManager.lua'))()
    assert(loadfile(HoundWorkDir..'src\\410 - HoundInformationSystem.lua'))()
    assert(loadfile(HoundWorkDir..'src\\420 - HoundController.lua'))()
    assert(loadfile(HoundWorkDir..'src\\421 - HoundNotifier.lua'))()
    assert(loadfile(HoundWorkDir..'src\\500 - HoundElintWorker.lua'))()
    assert(loadfile(HoundWorkDir..'src\\510 - HoundContactManager.lua'))()
    assert(loadfile(HoundWorkDir..'src\\550 - HoundSector.lua'))()
    assert(loadfile(HoundWorkDir..'src\\800 - HoundElint.lua'))()
    assert(loadfile(HoundWorkDir..'src\\999 - Hound_footer.lua'))()

    -- assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\hound-unit-tests.lua'))()


    assert(loadfile(HoundWorkDir..'demo_mission\\Caucasus_demo\\HoundElint_demo.lua'))()
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Syria_POC\\Hound_Demo_SyADFGCI.lua'))()


env.info("Loading Done")

