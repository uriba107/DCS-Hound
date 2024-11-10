-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -type f -name "*.lua"); do echo $file; gsed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; gsed -i 's/<[[:digit:]]*>//g' "${file}"; done
-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -type f -name "*.lua"); do echo $file; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done
-- for file in $(find ../../dcs-lua-datamine/_G/db/Units/ -regex ".*\/\(Ships\|Cars\)\/.*lua"); do echo "${file}"; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done

-- 

lfs = require('lfs')

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

                -- table.print(searchBand,"Search ("..table.length(searchBand).."): ")
                -- table.print(trackBand,"Track("..table.length(trackBand).."): ")
                if table.length(trackBand) > 0 then
                    local str="{\n" .. "\t['Band'] = {\n\t\t[true] = "
                    for k,v in pairs(trackBand) do
                        
                        str = str .. string.format("{%.6f,%.6f},\n",k,v)
                    end
                    str = str.."\t\t[false] = "
                    for k,v in pairs(searchBand) do
                        str = str .. string.format("{%.6f,%.6f},\n",k,v)
                    end
                    str = str .. "\t},"
                    local unittype = data['type']
                    -- dataToImport[unittype]=str
-- print(table.length(dataToImport))
                    -- houndData[data['type']] = {
                    --     ['Band'] = {
                    --         [true] = {},
                    --         [false] = {}
                    --     }
                    -- -- }
                    local info = {}

                    for k,v in pairs(trackBand) do
                        info[true] = {k,v}
                    end
                    for k,v in pairs(searchBand) do
                        info[false]={k,v}
                    end
                    -- table.print(info)
                    dataToImport[unittype]=info

                end
                if not HOUND.DB.Radars[data['type']] then
                    print(data['type'],data['DisplayName'])
                end
            end
            -- print(tableShow(dataToImport))
            -- for k,v in pairs(dataToImport) do
            --     print("dataToImport ("..k.."): "..tostring(v))
            -- end
            for k,v in pairs(HOUND.DB.Radars) do
                if dataToImport[k] then
                    local update=false
                    for state,wavelength in pairs(v['Band']) do
                        for i,wave in ipairs(wavelength) do
                            update = (wave ~= tonumber(string.format('%.6f',dataToImport[k][state][i])))
                            -- print(k,tostring(update),wave,tonumber(string.format('%.6f',dataToImport[k][state][i])))
                            if update then
                                break
                            end
                        end
                        if update then
                            break
                        end
                    end
                    if update then
                        print(string.format("['%s'] = {\n\t['Band'] = {\n\t\t[true] = {%.6f,%.6f},\n\t\t[false] = {%.6f,%.6f}\n\t},\n}",k,dataToImport[k][true][1],dataToImport[k][true][2],dataToImport[k][false][1],dataToImport[k][false][2]))
                    end
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