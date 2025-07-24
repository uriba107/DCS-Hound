-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -type f -name "*.lua"); do echo $file; gsed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; gsed -i 's/<[[:digit:]]*>//g' "${file}"; done
-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -type f -name "*.lua"); do echo $file; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done
-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -regex ".*\/\(Ships\|Cars\)\/.*lua"); do echo "${file}"; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done
-- find ../../dcs-lua-datamine/_G/db/Units/ -regex ".*\/\(Ships\|Cars\)\/.*lua" | while read file; do echo "${file}"; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done
-- find '/mnt/c/Users/Me/Saved Games/DCS/DCS.Lua.Exporter/_G/db/Units/' -regex ".*\/\(Ships\|Cars\)\/.*lua" | while read file; do echo "${file}"; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done

lfs = require('lfs')
-- local basePath = '/mnt/c/Users/Me/Saved Games/DCS/DCS.Lua.Exporter/_G/db/Units'
local basePath = '../../dcs-lua-datamine/_G/db/Units'
local unitIgnoreList =  {
    "Patriot ECS",
    'LvS-103_StriE103',
    'LvS-103_Elverk103'
}

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
coalition = {
    side = {
        NEUTRAL = 0,
        RED = 1,
        BLUE = 2
    }
}
timer = {
    getTime0 = math.random,
    getTime = function() return 0 end
}


function loadHound(path)
    print(path)
    loadfile(path..'/src/000 - HoundGlobals.lua')()
    loadfile(path..'/src/100 - HoundDBs.lua')()
    loadfile(path..'/src/101 - HoundDBs_UnitDcs.lua')()
    loadfile(path..'/src/102 - HoundDBs_UnitMods.lua')()
end

function printMissing(info)
    print(string.format("HOUND.DB.Radars['%s'] = {\n\t['Name'] = \"%s\",\n\t['Assigned'] = {\"%s\"},\n\t['Role'] = %s,\n\t['Band'] = {\n\t\t[true] = {0,0},\n\t\t[false] = {0,0}\n\t},\n\t['Primary'] = true\n}",info.type,info.name,info.assigned,info.role))

    -- print(tableShow(info))
    
end
function printMissingWithFreq(info)
    -- print(data['type'],data['DisplayName'])
    local track_freq = string.format("{%.6f,%.6f}",info[true][1],info[true][2])
    local search_freq = string.format("{%.6f,%.6f}",info[false][1],info[false][2])
    -- if type(track_freq) ~= "string" or type(search_freq) ~= "string" then
        -- print(file,track_freq,search_freq)
        -- break
    -- end
    print(string.format("HOUND.DB.Radars['%s'] = {\n\t['Name'] = \"%s\",\n\t['Assigned'] = {\"%s\"},\n\t['Role'] = %s,\n\t['Band'] = {\n\t\t[true] = %s,\n\t\t[false] = %s\n\t},\n\t['Primary'] = true\n}",info.type,info.name,info.assigned,info.role,track_freq,search_freq))
end


function printFreqUpdate(info)
    local track_freq = string.format("{%.6f,%.6f}",info[true][1],info[true][2])
                        if BANDS[track_freq] then
                            track_freq = "HOUND.DB.Bands." .. BANDS[track_freq]
                        end
                        local search_freq = string.format("{%.6f,%.6f}",info[false][1],info[false][2])
                        if BANDS[search_freq] then
                            search_freq = "HOUND.DB.Bands." .. BANDS[search_freq]
                        end
                        -- if track_freq ~= "{0.000000,0.000000}" and search_freq ~= "{0.000000,0.000000}" then
                            print(string.format("HOUND.DB.Radars['%s'] = {\n\t['Band'] = {\n\t\t[true] = %s,\n\t\t[false] = %s\n\t},\n}",info.type,track_freq,search_freq))
                        -- end
end

function getRoleFromTags(info,tags)
    if type(tags) ~= "table" then 
        info.role = "{ HOUND.DB.Radar.NONE }" 
        return
    end
    local switch = {
        ["Tracking Radar"] = "{ HOUND.DB.RadarType.TRACK }",
        ["EW Radar"] = "{ HOUND.DB.RadarType.EWR }",
        ["Search Radar"] = "{ HOUND.DB.RadarType.SEARCH }",
        ["Search & Track Radar"] = "{ HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK }",
        ["SP AAA"] = "{ HOUND.DB.RadarType.TRACK }",
        ["SAM SHORAD"] = "{ HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK }",
    }
                -- ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK HOUND.DB.RadarType.EWR},
    for _,tag in ipairs(tags) do
        if switch[tag] then
            info.role = switch[tag]
        end
        if tag == "SP AAA" then
            info.assigned = "AAA"
        end
        if tag == "EW Radar" then
            info.assigned = "Naval"
        end
        if tag == "SAM SHORAD" then
            info.assigned = "SHORAD"
        end
    end
    if type(info.role) == "string" then
        return
    end 
    info.role = "{ HOUND.DB.RadarType.NAVAL }"
    info.assigned = "Naval"

end
function table.length(t)
    local count = 0
    if type(t) ~= "table" then
        return count
    end
    for _,_ in pairs(t) do
        count = count + 1
    end
    return count
end

function table.print(t,comment)
    if type(comment) ~= "nil" then
        print(comment)
    end
    if type(t) ~= "table" 
        then 
            print(t)
        else
            for k, v in pairs(t) do
                if type(v) == "table" then table.print(v) 
                else
                print(k, v)
                end
            end
    end
end

function basicSerialize(var)
    if var == nil then
        return "\"\""
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata') ) then
                    return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end
function setContainsValue(set,value)
    if not set or not value then return false end
    for _,v in pairs(set) do
        if v == value then
            return true
        end
    end
    return false
end
function tableShow(tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
	tableshow_tbls = tableshow_tbls or {} --create table of tables
	loc = loc or ""
	indent = indent or ""
	if type(tbl) == 'table' then --function only works for tables!
		tableshow_tbls[tbl] = loc

		local tbl_str = {}

		tbl_str[#tbl_str + 1] = indent .. '{\n'

		for ind, val in pairs(tbl) do
			if type(ind) == "number" then
				tbl_str[#tbl_str + 1] = indent
				tbl_str[#tbl_str + 1] = loc .. '['
				tbl_str[#tbl_str + 1] = tostring(ind)
				tbl_str[#tbl_str + 1] = '] = '
			else
				tbl_str[#tbl_str + 1] = indent
				tbl_str[#tbl_str + 1] = loc .. '['
				tbl_str[#tbl_str + 1] = basicSerialize(ind)
				tbl_str[#tbl_str + 1] = '] = '
			end

			if ((type(val) == 'number') or (type(val) == 'boolean')) then
				tbl_str[#tbl_str + 1] = tostring(val)
				tbl_str[#tbl_str + 1] = ',\n'
			elseif type(val) == 'string' then
				tbl_str[#tbl_str + 1] = basicSerialize(val)
				tbl_str[#tbl_str + 1] = ',\n'
			elseif type(val) == 'nil' then -- won't ever happen, right?
				tbl_str[#tbl_str + 1] = 'nil,\n'
			elseif type(val) == 'table' then
				if tableshow_tbls[val] then
					tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
				else
					tableshow_tbls[val] = loc ..	'[' .. basicSerialize(ind) .. ']'
					tbl_str[#tbl_str + 1] = tostring(val) .. ' '
					tbl_str[#tbl_str + 1] = tableShow(val,	loc .. '[' .. basicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
					tbl_str[#tbl_str + 1] = ',\n'
				end
			elseif type(val) == 'function' then
				if debug and debug.getinfo then
					local fcnname = tostring(val)
					local info = debug.getinfo(val, "S")
					if info.what == "C" then
						tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
					else
						if (string.sub(info.source, 1, 2) == [[./]]) then
							tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) ..',\n'
						else
							tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..',\n'
						end
					end

				else
					tbl_str[#tbl_str + 1] = 'a function,\n'
				end
			else
				tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
			end
		end

		tbl_str[#tbl_str + 1] = indent .. '}'
		return table.concat(tbl_str)
	end
end

function freqToWavelength(freq)
    if type(freq) == "number" then
        return 299792458.0/freq        
    end
end


loadHound('..')
BANDS = {}
for band,freq in pairs(HOUND.DB.Bands) do
    local k = string.format("{%.6f,%.6f}",freq[1],freq[2])
    BANDS[k] = band
end
for _,db in ipairs({'Car','Ship'}) do
    local dirPath = basePath..'/'..db..'s/'..db
    for file in lfs.dir(dirPath) do
        file = dirPath..'/'..file
        if lfs.attributes(file,"mode") == "file" then
            -- print("found file, "..file)
            loadfile(file)()

            local data = _G["db"]["Units"][db..'s'][db]["#Index"]
            local dataToImport = {}

            if data["Sensors"] and data["Sensors"]["RADAR"] then
                local unittype = data['type']
                local assigned = data['DisplayNameShort'] or "NA"
                if data['EWR'] then
                    assigned = 'EWR'
                end

                local info = {
                    name = data['Name'],
                    type = unittype,
                    assigned = assigned,
                    state = 0
                }
                info[true] = {0,0}
                info[false] = {0,0}
                if setContainsValue(unitIgnoreList,unittype) then break end
                dataToImport[unittype]=info
                getRoleFromTags(info,data.tags)

                local searchBand = {}
                local freq = data["WS"]["searchRadarFrequencies"]
                if freq and  type(freq[#freq]) == "table" then
                    local low,high = freqToWavelength(freq[#freq][1]),freqToWavelength(freq[#freq][2])
                    if type(high) == "nil" then
                        high = low
                    end
                    searchBand[high] = low-high
                end
                local trackBand = {}
                for _,v in ipairs(data["WS"]) do
                    if type(v["LN"]) == "table" then
                        if type(v["LN"][1]["frequencyRange"]) == "table" and next(v["LN"][1]["frequencyRange"]) ~= nil then
                            local freq = v["LN"][1]["frequencyRange"]
                            local low,high = freqToWavelength(freq[1]),freqToWavelength(freq[2])
                            if type(high) == "nil" then
                                high = low
                            end
                            trackBand[high] = low-high
                        end
                    end
                end

                -- local uniqTrack = {}
                -- for _,freq in ipairs(trackBand) do
                --     local low,high = freq[1], freq[2]
                --     if not uniqTrack[low] and uniqTrack[low] ~= high-low then
                --         uniqTrack[low] = high-low
                --     end
                -- end
                -- trackBand=uniqTrack

                -- print("DEBUG: ",data['type'],data['DisplayName'])
                -- print("Search ("..table.length(searchBand)..")","Track("..table.length(trackBand)..")")
                if table.length(searchBand) > 0 and table.length(trackBand) == 0 then
                    trackBand = searchBand
                elseif  table.length(searchBand) == 0 and table.length(trackBand) > 0 then
                    searchBand = trackBand
                end


                if BANDS[searchBand] then
                    searchBand = BANDS[searchBand]
                end

                -- table.print(searchBand,"Search ("..table.length(searchBand).."): ")
                -- table.print(trackBand,"Track("..table.length(trackBand).."): ")
                if not HOUND.DB.Radars[info.type] then
                    info.state = 1
                end
                if table.length(trackBand) > 0 then
                    local str="{\n" .. "\t['Band'] = {\n\t\t[true] = "
                    local freq_str = ""
                    for k,v in pairs(trackBand) do
                        freq_str = string.format("{%.6f,%.6f},\n",k,v)
                    end
                    -- if BANDS[freq_str] then
                    --     freq_str = "HOUND.DB.Bands." .. BANDS[trackBand]
                    -- end
                    str = str .. freq_str .."\t\t[false] = "

                    for k,v in pairs(searchBand) do
                        freq_str = string.format("{%.6f,%.6f},\n",k,v)
                    end
                    -- if BANDS[freq_str] then
                    --     freq_str = "HOUND.DB.Bands." .. BANDS[trackBand]
                    -- end
                    str = str .. freq_str .. "\t},"


                    for k,v in pairs(trackBand) do
                        info[true] = {k,v}
                    end
                    for k,v in pairs(searchBand) do
                        info[false]={k,v}
                    end
                    -- table.print(info)
                    -- dataToImport[unittype]=info
                    if info.state == 1 then
                        info.state = 2
                    end
                end
            end
            -- print(tableShow(dataToImport))
            -- for k,v in pairs(dataToImport) do
            --     print("dataToImport ("..k.."): "..tostring(v))
            -- end
            for k,v in pairs(HOUND.DB.Radars) do
                if dataToImport[k] then
                    local info = dataToImport[k]
                    if info[true][1] == 0 and info[false][1] == 0 then
                        break
                    end
                    local update=false
                    for state,wavelength in pairs(v['Band']) do
                            for i,wave in ipairs(wavelength) do
                                update = (wave ~= tonumber(string.format('%.6f',info[state][i])))
                                -- print(k,tostring(update),wave,tonumber(string.format('%.6f',dataToImport[k][state][i])))
                            end
                            if update then
                                info.state = 3
                                break
                            end
                    end
                end
            end
            local radars = {
                {},{},{}
            }

            for _,info in pairs(dataToImport) do
                -- if info.state > 0 then
                --     print(info.type,info.state)
                -- end
                if info.state == 1 then
                    printMissing(info)
                end
                if info.state == 2 then
                    printMissingWithFreq(info)
                end
                if info.state == 3 then
                    printFreqUpdate(info)
                end
            end

            -- table.print(_G["db"])
        -- elseif lfs.attributes(file,"mode")== "directory" then print("found dir, "..file," containing:")
        --     for l in lfs.dir(dirPath..file) do
        --          print("",l)
        --     end
        end
    end

end