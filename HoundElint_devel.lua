env.info("Loading Hound Scripts dynamicly")


local HoundWorkDir = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
    assert(loadfile(HoundWorkDir..'test\\StopWatch.lua'))()

    assert(loadfile(HoundWorkDir..'include\\mist_4_5_113.lua'))()
    assert(loadfile(HoundWorkDir..'include\\DCS-SimpleTextToSpeech.lua'))()

    assert(loadfile(HoundWorkDir..'src\\000 - HoundGlobals.lua'))()
    assert(loadfile(HoundWorkDir..'src\\010 - HoundLogger.lua'))()
    assert(loadfile(HoundWorkDir..'src\\100 - HoundDBs.lua'))()
    assert(loadfile(HoundWorkDir..'src\\101 - HoundDBs_UnitDcs.lua'))()
    assert(loadfile(HoundWorkDir..'src\\102 - HoundDBs_UnitMods.lua'))()
    assert(loadfile(HoundWorkDir..'src\\103 - HoundDBs_func.lua'))()
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
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Caucasus_demo\\HoundElint_demo.lua'))()
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Syria_POC\\Hound_Demo_SyADFGCI.lua'))()
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Syria_HARM\\Hound_Demo_syria.lua'))()


env.info("Loading Done")

