-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -type f -name "*.lua"); do echo $file; gsed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; gsed -i 's/<[[:digit:]]*>//g' "${file}"; done
require'lfs'

local basePath = '../../dcs-lua-datamine/_G/db/Units'
_G["db"] = {
    Units = {
        Ships = {
            Ship = {}
        },
        Cars = {
            Car = {}
        }
    }
}
mist = {}
Object = {
    Category = {
        STATIC = {},
        UNIT = {}
    }
}
function loadHound(path)
    print(path)
    loadfile(path..'/src/000 - HoundGlobals.lua')()
    loadfile(path..'/src/100 - HoundDBs.lua')()
    loadfile(path..'/src/101 - HoundDBs_UnitDcs.lua')()
    loadfile(path..'/src/102 - HoundDBs_UnitMods.lua')()

end

function tableprint(data)
    if type(data) ~= "table" 
        then 
            print(data)
        else
            for k, v in pairs(data) do
                if type(v) == "table" then tableprint(v) 
                else
                print(k, v)
                end
            end
    end
end

loadHound('..')
for _,db in ipairs({'Car','Ship'}) do
    local dirPath = basePath..'/'..db..'s/'..db
    for file in lfs.dir(dirPath) do
        file = dirPath..'/'..file
        if lfs.attributes(file,"mode") == "file" then 
            -- print("found file, "..file)
            loadfile(file)()

            local data = _G["db"]["Units"][db..'s'][db]["#Index"]
            if data["Sensors"] and data["Sensors"]["RADAR"] then
                if not HOUND.DB.Radars[data['type']] then
                    print(data['type'],data['DisplayName'])
                end

            end
            -- tableprint(_G["db"])
        -- elseif lfs.attributes(file,"mode")== "directory" then print("found dir, "..file," containing:")
        --     for l in lfs.dir(dirPath..file) do
        --          print("",l)
        --     end
        end
    end

end