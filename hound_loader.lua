do
    if HoundWorkDir == nil then
        HoundWorkDir = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
        -- HoundWorkDir = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\DCS-Hound\\"
    end
    assert(loadfile(HoundWorkDir..'HoundElint_devel.lua'))()

    -- Choose which mission you insert into
    -- assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\hound-unit-tests.lua'))()
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Caucasus_demo\\HoundElint_demo.lua'))()
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Syria_POC\\Hound_Demo_SyADFGCI.lua'))()
    -- assert(loadfile(HoundWorkDir..'demo_mission\\Syria_HARM\\Hound_Demo_syria.lua'))()
end