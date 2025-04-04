env.info("Loading Hound Scripts dynamicly")

    if HoundWorkDir == nil then
        HoundWorkDir = "E:\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
        -- HoundWorkDir = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\DCS-Hound\\"
    end

    assert(loadfile(HoundWorkDir..'test\\StopWatch.lua'))()

    -- assert(loadfile(HoundWorkDir..'include\\mist.lua'))()
    assert(loadfile(HoundWorkDir..'include\\DCS-SimpleTextToSpeech.lua'))()

    assert(loadfile(HoundWorkDir..'src\\000 - HoundGlobals.lua'))()
    assert(loadfile(HoundWorkDir..'src\\010 - HoundLogger.lua'))()
    assert(loadfile(HoundWorkDir..'src\\020 - HoundMist.lua'))()
    assert(loadfile(HoundWorkDir..'src\\021 - HoundMatrix.lua'))()
    assert(loadfile(HoundWorkDir..'src\\100 - HoundDBs.lua'))()
    assert(loadfile(HoundWorkDir..'src\\101 - HoundDBs_UnitDcs.lua'))()
    assert(loadfile(HoundWorkDir..'src\\102 - HoundDBs_UnitMods.lua'))()
    assert(loadfile(HoundWorkDir..'src\\103 - HoundDBs_func.lua'))()
    assert(loadfile(HoundWorkDir..'src\\110 - HoundConfig.lua'))()
    assert(loadfile(HoundWorkDir..'src\\200 - HoundUtils.lua'))()
    assert(loadfile(HoundWorkDir..'src\\201 - HoundUtils_TTS.lua'))()
    assert(loadfile(HoundWorkDir..'src\\202 - HoundUtils_Adv.lua'))()
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
    assert(loadfile(HoundWorkDir..'src\\501 - HoundElintWorker_queries.lua'))()
    assert(loadfile(HoundWorkDir..'src\\510 - HoundContactManager.lua'))()
    assert(loadfile(HoundWorkDir..'src\\550 - HoundSector.lua'))()
    assert(loadfile(HoundWorkDir..'src\\551 - HoundSector_menu.lua'))()
    assert(loadfile(HoundWorkDir..'src\\800 - HoundElint.lua'))()
    assert(loadfile(HoundWorkDir..'src\\801 - HoundElintEvents.lua'))()
    assert(loadfile(HoundWorkDir..'src\\999 - Hound_footer.lua'))()

env.info("Loading Done")

