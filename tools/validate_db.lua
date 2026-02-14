lfs = require('lfs')
lu = require('luaunit')
HoundPath = arg[1] or '..'

-- DCS Globals

coalition = {
    side = {
        NEUTRAL = 0,
        RED = 1,
        BLUE = 2
    }
}
Object = {
    Category = {
        UNIT    = 1,
        WEAPON  = 2,
        STATIC  = 3,
        BASE    = 4,
        SCENERY = 5,
        Cargo   = 6,
    }
}

HOUND={
    DB = {
        Platform = {},
        Radars = {}
    }
}
function loadHound(path)
    print(path)
    -- loadfile(path..'/src/000 - HoundGlobals.lua')()
    loadfile(path..'/src/100 - HoundDBs.lua')()
    -- loadfile(path..'/src/101 - HoundDBs_UnitDcs.lua')()
    -- loadfile(path..'/src/102 - HoundDBs_UnitMods.lua')()
end

function getKeys(t)
    local keys = {}
    if type(t) == 'table' then
        for k,_ in pairs(t) do
            table.insert(keys,k)
        end
    end
    return keys
end

TestHoundDB = {}

function TestHoundDB:setUp()
    HOUND.DB.Radars = {}
    -- HOUND.DB.Platform = {}
end

function TestHoundDB:TestDCSUnits()
    loadfile(HoundPath..'/src/101 - HoundDBs_UnitDcs.lua')()
    for type,unitData in pairs(HOUND.DB.Radars) do
        lu.assertItemsEquals({'Name','Assigned','Role','Band','Primary','numDistinctFreqs'} ,getKeys(unitData),type)
        lu.assertItemsEquals({true,false},getKeys(unitData['Band']),type.."['Band']")
    end
end

function TestHoundDB:TestModUnits()
    loadfile(HoundPath..'/src/102 - HoundDBs_UnitMods.lua')()
    for type,unitData in pairs(HOUND.DB.Radars) do
        lu.assertItemsEquals({'Name','Assigned','Role','Band','Primary','numDistinctFreqs'},getKeys(unitData),type)
        lu.assertItemsEquals({true,false},getKeys(unitData['Band']),type.."['Band']")
    end
end

function TestHoundDB:testDCSPlatforms()
    loadfile(HoundPath..'/src/101 - HoundDBs_UnitDcs.lua')()
    for _,platforms in pairs(HOUND.DB.Platform) do
        for type,data in pairs(platforms) do
            lu.assertIsNumber(data['ins_error'],"ins_error is invalid for "..type)
            lu.assertIsTable(data['antenna'],"antenna data is invalid for "..type)
            lu.assertIsNumber(data['antenna']['size'])
            lu.assertIsNumber(data['antenna']['factor'])
            if data.require then
                lu.assertIsTable(data.require,"require is invalid for "..type)
            end
        end
    end
end

function TestHoundDB:TestModPlatforms()
    loadfile(HoundPath..'/src/102 - HoundDBs_UnitMods.lua')()
    for _,platforms in pairs(HOUND.DB.Platform) do
        for type,data in pairs(platforms) do
            lu.assertIsNumber(data['ins_error'],"ins_error is invalid for "..type)
            lu.assertIsTable(data['antenna'],"antenna data is invalid for "..type)
            lu.assertIsNumber(data['antenna']['size'])
            lu.assertIsNumber(data['antenna']['factor'])
            if data.require then
                lu.assertIsTable(data.require,"require is invalid for "..type)
            end
        end
    end
end
    -- ['Name'] = "Box Spring",
    --         ['Assigned'] = {"EWR"},
    --         ['Role'] = {HOUND.DB.RadarType.EWR},
    --         ['Band'] = {
    --             [true] = {1.362693,0.302821},
    --             [false] = {1.362693,0.302821},
    --         },
    --         ['Primary']
    


loadHound(HoundPath)
os.exit(lu.LuaUnit.run())