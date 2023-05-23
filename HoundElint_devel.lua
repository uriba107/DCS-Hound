env.info("Loading Hound Scripts dynamicly")


    if HoundWorkDir == nil then
        HoundWorkDir = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
    end
    
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
    assert(loadfile(HoundWorkDir..'src\\300 - HoundContactBase.lua'))()
    assert(loadfile(HoundWorkDir..'src\\301 - HoundContactEstimator.lua'))()
    assert(loadfile(HoundWorkDir..'src\\302 - HoundContactDatapoint.lua'))()
    assert(loadfile(HoundWorkDir..'src\\310 - HoundContactEmitter.lua'))()
    assert(loadfile(HoundWorkDir..'src\\311 - HoundContactEmitter_comms.lua'))()
    assert(loadfile(HoundWorkDir..'src\\320 - HoundContactSite.lua'))()
    assert(loadfile(HoundWorkDir..'src\\321 - HoundContactSite_comms.lua'))()
    assert(loadfile(HoundWorkDir..'src\\400 - HoundCommsManager.lua'))()
    assert(loadfile(HoundWorkDir..'src\\410 - HoundCommsInformationSystem.lua'))()
    assert(loadfile(HoundWorkDir..'src\\420 - HoundCommsController.lua'))()
    assert(loadfile(HoundWorkDir..'src\\421 - HoundCommsNotifier.lua'))()
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

