--- HOUND.Mist
-- This class holds a subset function from MIST framework required by Hound.
-- They are included in Hound to eliminate external dependencies
-- Original code, with more extensive functionality can be found at https://github.com/mrSkortch/MissionScriptingTools
-- Code was taken from Mist 4.5.126
-- @module HOUND.Mist
do
    local l_math = math
    HOUND.Mist = {}
    HOUND.Mist.__index = HOUND.Mist

    function HOUND.Mist.getNorthCorrection(gPoint)	--gets the correction needed for true north
		local point = HOUND.Utils.Dcs.copyPoint(gPoint)
		if not point.z then --Vec2; convert to Vec3
			point.z = point.y
			point.y = 0
		end
		local lat, lon = coord.LOtoLL(point)
		local north_posit = coord.LLtoLO(lat + 1, lon)
		return l_math.atan2(north_posit.z - point.z, north_posit.x - point.x)
	end

function HOUND.Mist.getAvgPoint(points)
	local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
	for i = 1, #points do
        --log:warn(points[i])
        local nPoint = HOUND.Mist.utils.makeVec3(points[i])
		if nPoint.z then
			avgX = avgX + nPoint.x
			avgY = avgY + nPoint.y
			avgZ = avgZ + nPoint.z
			totNum = totNum + 1
		end
	end
	if totNum ~= 0 then
		return {x = avgX/totNum, y = avgY/totNum, z = avgZ/totNum}
	end
end

--Gets the average position of a group of units (by name)
function HOUND.Mist.getAvgPos(unitNames)
	local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
	for i = 1, #unitNames do
		local unit
		if Unit.getByName(unitNames[i]) then
			unit = Unit.getByName(unitNames[i])
		elseif StaticObject.getByName(unitNames[i]) then
			unit = StaticObject.getByName(unitNames[i])
		end
		if unit and unit:isExist() == true then
			local pos = unit:getPosition().p
			if pos then -- you never know O.o
				avgX = avgX + pos.x
				avgY = avgY + pos.y
				avgZ = avgZ + pos.z
				totNum = totNum + 1
			end
		end
	end
	if totNum ~= 0 then
		return {x = avgX/totNum, y = avgY/totNum, z = avgZ/totNum}
	end
end

function HOUND.Mist.getAvgGroupPos(groupName)
	if type(groupName) == 'string' and Group.getByName(groupName) and Group.getByName(groupName):isExist() == true then
		groupName = Group.getByName(groupName)
	end
	local units = {}
	for i = 1, groupName:getSize() do
		table.insert(units, groupName:getUnit(i):getName())
	end

	return HOUND.Mist.getAvgPos(units)

end

end

    --- 3D Vector functions
    -- @section HOUND.Mist.vec
do -- HOUND.Mist.vec scope
	HOUND.Mist.vec = {}

	--- Vector addition.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn Vec3 new vector, sum of vec1 and vec2.
	function HOUND.Mist.vec.add(vec1, vec2)
		return {x = vec1.x + vec2.x, y = vec1.y + vec2.y, z = vec1.z + vec2.z}
	end

	--- Vector substraction.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn Vec3 new vector, vec2 substracted from vec1.
	function HOUND.Mist.vec.sub(vec1, vec2)
		return {x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z}
	end

	--- Vector scalar multiplication.
	-- @tparam Vec3 vec vector to multiply
	-- @tparam number mult scalar multiplicator
	-- @treturn Vec3 new vector multiplied with the given scalar
	function HOUND.Mist.vec.scalarMult(vec, mult)
		return {x = vec.x*mult, y = vec.y*mult, z = vec.z*mult}
	end

	HOUND.Mist.vec.scalar_mult = HOUND.Mist.vec.scalarMult

	--- Vector dot product.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn number dot product of given vectors
	function HOUND.Mist.vec.dp (vec1, vec2)
		return vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z
	end

	--- Vector cross product.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn Vec3 new vector, cross product of vec1 and vec2.
	function HOUND.Mist.vec.cp(vec1, vec2)
		return { x = vec1.y*vec2.z - vec1.z*vec2.y, y = vec1.z*vec2.x - vec1.x*vec2.z, z = vec1.x*vec2.y - vec1.y*vec2.x}
	end

	--- Vector magnitude
	-- @tparam Vec3 vec vector
	-- @treturn number magnitude of vector vec
	function HOUND.Mist.vec.mag(vec)
		return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
	end

	--- Unit vector
	-- @tparam Vec3 vec
	-- @treturn Vec3 unit vector of vec
	function HOUND.Mist.vec.getUnitVec(vec)
		local mag = HOUND.Mist.vec.mag(vec)
		return { x = vec.x/mag, y = vec.y/mag, z = vec.z/mag }
	end

	--- Rotate vector.
	-- @tparam Vec2 vec2 to rotoate
	-- @tparam number theta
	-- @return Vec2 rotated vector.
	function HOUND.Mist.vec.rotateVec2(vec2, theta)
		return { x = vec2.x*math.cos(theta) - vec2.y*math.sin(theta), y = vec2.x*math.sin(theta) + vec2.y*math.cos(theta)}
	end

    function HOUND.Mist.vec.normalize(vec3)
        local mag =  HOUND.Mist.vec.mag(vec3)
        if mag ~= 0 then
            return HOUND.Mist.vec.scalar_mult(vec3, 1.0 / mag)
        end
    end
end

--- Utility functions.
-- E.g. conversions between units etc.
-- @section HOUND.Mist.utils
do -- HOUND.Mist.util scope
 	HOUND.Mist.utils = {}

	--- Converts angle in radians to degrees.
	-- @param angle angle in radians
	-- @return angle in degrees
	function HOUND.Mist.utils.toDegree(angle)
		return angle*180/math.pi
	end

	--- Converts angle in degrees to radians.
	-- @param angle angle in degrees
	-- @return angle in degrees
	function HOUND.Mist.utils.toRadian(angle)
		return angle*math.pi/180
	end

	--- Converts meters to nautical miles.
	-- @param meters distance in meters
	-- @return distance in nautical miles
	function HOUND.Mist.utils.metersToNM(meters)
		return meters/1852
	end

	--- Converts meters to feet.
	-- @param meters distance in meters
	-- @return distance in feet
	function HOUND.Mist.utils.metersToFeet(meters)
		return meters/0.3048
	end

	--- Converts nautical miles to meters.
	-- @param nm distance in nautical miles
	-- @return distance in meters
	function HOUND.Mist.utils.NMToMeters(nm)
		return nm*1852
	end

	--- Converts feet to meters.
	-- @param feet distance in feet
	-- @return distance in meters
	function HOUND.Mist.utils.feetToMeters(feet)
		return feet*0.3048
	end

	function HOUND.Mist.utils.hexToRGB(hex, l) -- because for some reason the draw tools use hex when everything is rgba 0 - 1
        local int = 255
        if l then
         int = 1
        end
        if hex and type(hex) == 'string' then
            local val = {}
            hex = string.gsub(hex, '0x', '')
            if string.len(hex) == 8 then
                val[1] = tonumber("0x"..hex:sub(1,2)) / int
                val[2] = tonumber("0x"..hex:sub(3,4)) / int
                val[3] = tonumber("0x"..hex:sub(5,6)) / int
                val[4] = tonumber("0x"..hex:sub(7,8)) / int

                return val
            end
        end
   end

	--- Converts a Vec3 to a Vec2.
	-- @tparam Vec3 vec the 3D vector
	-- @return vector converted to Vec2
	function HOUND.Mist.utils.makeVec2(vec)
		if vec.z then
			return {x = vec.x, y = vec.z}
		else
			return {x = vec.x, y = vec.y}	-- it was actually already vec2.
		end
	end

	--- Converts a Vec2 to a Vec3.
	-- @tparam Vec2 vec the 2D vector
	-- @param y optional new y axis (altitude) value. If omitted it's 0.
	function HOUND.Mist.utils.makeVec3(vec, y)
		if not vec.z then
			if vec.alt and not y then
				y = vec.alt
			elseif not y then
				y = 0
			end
			return {x = vec.x, y = y, z = vec.y}
		else
			return {x = vec.x, y = vec.y, z = vec.z}	-- it was already Vec3, actually.
		end
	end

	--- Converts a Vec2 to a Vec3 using ground level as altitude.
	-- The ground level at the specific point is used as altitude (y-axis)
	-- for the new vector. Optionally a offset can be specified.
	-- @tparam Vec2 vec the 2D vector
	-- @param[opt] offset offset to be applied to the ground level
	-- @return new 3D vector
	function HOUND.Mist.utils.makeVec3GL(vec, offset)
		local adj = offset or 0

		if not vec.z then
			return {x = vec.x, y = (land.getHeight(vec) + adj), z = vec.y}
		else
			return {x = vec.x, y = (land.getHeight({x = vec.x, y = vec.z}) + adj), z = vec.z}
		end
	end

    function HOUND.Mist.utils.getHeadingPoints(point1, point2, north) -- sick of writing this out.
        if north then
			local p1 = HOUND.Mist.utils.get3DDist(point1)
            return HOUND.Mist.utils.getDir(HOUND.Mist.vec.sub(HOUND.Mist.utils.makeVec3(point2), p1), p1)
        else
            return HOUND.Mist.utils.getDir(HOUND.Mist.vec.sub(HOUND.Mist.utils.makeVec3(point2), HOUND.Mist.utils.makeVec3(point1)))
        end
    end

	--- Returns heading-error corrected direction.
	-- True-north corrected direction from point along vector vec.
	-- @tparam Vec3 vec
	-- @tparam Vec2 point
	-- @return heading-error corrected direction from point.
	function HOUND.Mist.utils.getDir(vec, point)
		local dir = math.atan2(vec.z, vec.x)
		if point then
			dir = dir + HOUND.Mist.getNorthCorrection(point)
		end
		if dir < 0 then
			dir = dir + 2 * math.pi	-- put dir in range of 0 to 2*pi
		end
		return dir
	end

	--- Returns distance in meters between two points.
	-- @tparam Vec2|Vec3 point1 first point
	-- @tparam Vec2|Vec3 point2 second point
	-- @treturn number distance between given points.
	function HOUND.Mist.utils.get2DDist(point1, point2)
        if not point1 then
            log:warn("HOUND.Mist.utils.get2DDist  1st input value is nil")
        end
        if not point2 then
            log:warn("HOUND.Mist.utils.get2DDist  2nd input value is nil")
        end
		point1 = HOUND.Mist.utils.makeVec3(point1)
		point2 = HOUND.Mist.utils.makeVec3(point2)
		return HOUND.Mist.vec.mag({x = point1.x - point2.x, y = 0, z = point1.z - point2.z})
	end

	--- Returns distance in meters between two points in 3D space.
	-- @tparam Vec3 point1 first point
	-- @tparam Vec3 point2 second point
	-- @treturn number distancen between given points in 3D space.
	function HOUND.Mist.utils.get3DDist(point1, point2)
        if not point1 then
            log:warn("HOUND.Mist.utils.get2DDist  1st input value is nil")
        end
        if not point2 then
            log:warn("HOUND.Mist.utils.get2DDist  2nd input value is nil")
        end
		return HOUND.Mist.vec.mag({x = point1.x - point2.x, y = point1.y - point2.y, z = point1.z - point2.z})
	end

	--- Creates a deep copy of a object.
	-- Usually this object is a table.
	-- See also: from http://lua-users.org/wiki/CopyTable
	-- @param object object to copy
	-- @return copy of object
	function HOUND.Mist.utils.deepCopy(object)
		local lookup_table = {}
		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup_table[object] then
				return lookup_table[object]
			end
			local new_table = {}
			lookup_table[object] = new_table
			for index, value in pairs(object) do
				new_table[_copy(index)] = _copy(value)
			end
			return setmetatable(new_table, getmetatable(object))
		end
		return _copy(object)
	end

	--- Simple rounding function.
	-- From http://lua-users.org/wiki/SimpleRound
	-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
	-- @tparam number num number to round
	-- @param idp
	function HOUND.Mist.utils.round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	--- Serializes the give variable to a string.
	-- borrowed from slmod
	-- @param var variable to serialize
	-- @treturn string variable serialized to string
function HOUND.Mist.utils.basicSerialize(var)
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

function HOUND.Mist.utils.tableShowSorted(tbls, v)
	local vars = v or {}
	local loc = vars.loc or ""
	local indent = vars.indent or ""
	local tableshow_tbls = vars.tableshow_tbls or {}
	local tbl = tbls or {}

	if type(tbl) == 'table' then --function only works for tables!
		tableshow_tbls[tbl] = loc

		local tbl_str = {}

		tbl_str[#tbl_str + 1] = indent .. '{\n'

		local sorted = {}
		local function byteCompare(str1, str2)
			local shorter = string.len(str1)
			if shorter > string.len(str2) then
				 shorter = string.len(str2)
			end
			for i = 1, shorter do
				local b1 = string.byte(str1, i)
				local b2 = string.byte(str2, i)

				if b1 < b2 then
					return true
				elseif b1 > b2 then
					return false
				end

			end
			return false
		end
		for ind, val in pairs(tbl) do -- serialize its fields
			local indS = tostring(ind)
			local ins = {ind = indS, val = val}
			local index
			if #sorted > 0 then
				local found = false
				for i = 1, #sorted do
					if byteCompare(indS, tostring(sorted[i].ind)) == true then
						index = i
						break
					end
				end
			end
			if index then
				table.insert(sorted, index, ins)
			else
				table.insert(sorted, ins)
			end
		end
		--log:warn(sorted)
		for i = 1, #sorted do
			local ind = sorted[i].ind
			local val = sorted[i].val

			if type(ind) == "number" then
				tbl_str[#tbl_str + 1] = indent
				tbl_str[#tbl_str + 1] = loc .. '['
				tbl_str[#tbl_str + 1] = tostring(ind)
				tbl_str[#tbl_str + 1] = '] = '
			else
				tbl_str[#tbl_str + 1] = indent
				tbl_str[#tbl_str + 1] = loc .. '['
				tbl_str[#tbl_str + 1] = HOUND.Mist.utils.basicSerialize(ind)
				tbl_str[#tbl_str + 1] = '] = '
			end

			if ((type(val) == 'number') or (type(val) == 'boolean')) then
				tbl_str[#tbl_str + 1] = tostring(val)
				tbl_str[#tbl_str + 1] = ',\n'
			elseif type(val) == 'string' then
				tbl_str[#tbl_str + 1] = HOUND.Mist.utils.basicSerialize(val)
				tbl_str[#tbl_str + 1] = ',\n'
			elseif type(val) == 'nil' then -- won't ever happen, right?
				tbl_str[#tbl_str + 1] = 'nil,\n'
			elseif type(val) == 'table' then
				if tableshow_tbls[val] then
					tbl_str[#tbl_str + 1] = ' already defined: ' .. tableshow_tbls[val] .. ',\n'
				else
					tableshow_tbls[val] = loc .. '["' .. ind .. '"]'
					--tbl_str[#tbl_str + 1] = tostring(val) .. ' '
					tbl_str[#tbl_str + 1] = HOUND.Mist.utils.tableShowSorted(val, {loc =  loc .. '["' .. ind .. '"]', indent = indent .. '    ', tableshow_tbls = tableshow_tbls})
					tbl_str[#tbl_str + 1] = ',\n'
				end
			elseif type(val) == 'function' then
				if debug and debug.getinfo then
					local fcnname = tostring(val)
					local info = debug.getinfo(val, "S")
					if info.what == "C" then
						tbl_str[#tbl_str + 1] =  ', C function\n'
					else
						if (string.sub(info.source, 1, 2) == [[./]]) then
							tbl_str[#tbl_str + 1] = string.format('%q',  'function, defined in (' ..  '-' .. info.lastlinedefined .. ')' .. info.source) ..',\n'
						else
							tbl_str[#tbl_str + 1] = string.format('%q', 'function, defined in (' ..  '-' .. info.lastlinedefined .. ')') ..',\n'
						end
					end

				else
					tbl_str[#tbl_str + 1] = 'a function,\n'
				end
			else
				tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. HOUND.Mist.utils.basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
			end
		end

		tbl_str[#tbl_str + 1] = indent .. '}'
		return table.concat(tbl_str)
	end

end

--- Returns table in a easy readable string representation.
-- this function is not meant for serialization because it uses
-- newlines for better readability.
-- @param tbl table to show
-- @param loc
-- @param indent
-- @param tableshow_tbls
-- @return human readable string representation of given table
function HOUND.Mist.utils.tableShow(tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
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
				tbl_str[#tbl_str + 1] = HOUND.Mist.utils.basicSerialize(ind)
				tbl_str[#tbl_str + 1] = '] = '
			end

			if ((type(val) == 'number') or (type(val) == 'boolean')) then
				tbl_str[#tbl_str + 1] = tostring(val)
				tbl_str[#tbl_str + 1] = ',\n'
			elseif type(val) == 'string' then
				tbl_str[#tbl_str + 1] = HOUND.Mist.utils.basicSerialize(val)
				tbl_str[#tbl_str + 1] = ',\n'
			elseif type(val) == 'nil' then -- won't ever happen, right?
				tbl_str[#tbl_str + 1] = 'nil,\n'
			elseif type(val) == 'table' then
				if tableshow_tbls[val] then
					tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
				else
					tableshow_tbls[val] = loc ..	'[' .. HOUND.Mist.utils.basicSerialize(ind) .. ']'
					tbl_str[#tbl_str + 1] = tostring(val) .. ' '
					tbl_str[#tbl_str + 1] = HOUND.Mist.utils.tableShow(val,	loc .. '[' .. HOUND.Mist.utils.basicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
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
				tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. HOUND.Mist.utils.basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
			end
		end

		tbl_str[#tbl_str + 1] = indent .. '}'
		return table.concat(tbl_str)
	end
end

do
    HOUND.Mist.shape = {}
    function HOUND.Mist.shape.insideShape(shape1, shape2, full)
        if shape1.radius then -- probably a circle
            if shape2.radius then
                 return HOUND.Mist.shape.circleInCircle(shape1, shape2, full)
            elseif shape2[1] then
                 return HOUND.Mist.shape.circleInPoly(shape1, shape2, full)
            end

        elseif shape1[1] then -- shape1 is probably a polygon
            if shape2.radius then
                return  HOUND.Mist.shape.polyInCircle(shape1, shape2, full)
            elseif shape2[1] then
                return  HOUND.Mist.shape.polyInPoly(shape1, shape2, full)
            end
        end
        return false
    end

    function HOUND.Mist.shape.circleInCircle(c1, c2, full)
        if not full then -- quick partial check
            if HOUND.Mist.utils.get2DDist(c1.point, c2.point) <= c2.radius then
                return true
            end
        end
        local theta = HOUND.Mist.utils.getHeadingPoints(c2.point, c1.point) -- heading from
        if full then
            return  HOUND.Mist.utils.get2DDist(HOUND.Mist.projectPoint(c1.point, c1.radius, theta), c2.point) <= c2.radius
        else
            return HOUND.Mist.utils.get2DDist(HOUND.Mist.projectPoint(c1.point, c1.radius, theta + math.pi), c2.point) <= c2.radius
        end
    end
    function HOUND.Mist.shape.circleInPoly(circle, poly, full)

        if poly and type(poly) == 'table' and circle and type(circle) == 'table' and circle.radius and circle.point then
            if not full then
                for i = 1, #poly do
                    if HOUND.Mist.utils.get2DDist(circle.point, poly[i]) <= circle.radius then
                        return true
                    end
                end
            end
            -- no point is inside of the zone, now check if any part is
            local count = 0
            for i = 1, #poly do
                local theta -- heading of each set of points
                if i == #poly then
                    theta = HOUND.Mist.utils.getHeadingPoints(poly[i],poly[1])
                else
                    theta = HOUND.Mist.utils.getHeadingPoints(poly[i],poly[i+1])
                end
                -- offset
                local pPoint = HOUND.Mist.projectPoint(circle.point, circle.radius, theta - (math.pi/180))
                local oPoint = HOUND.Mist.projectPoint(circle.point, circle.radius, theta + (math.pi/180))
                if HOUND.Mist.pointInPolygon(pPoint, poly) == true then
                     if (full and HOUND.Mist.pointInPolygon(oPoint, poly) == true) or not full then
                        return true

                    end

                end
            end
        end
        return false
    end
    function HOUND.Mist.shape.polyInPoly(p1, p2, full)
        local count = 0
        for i = 1, #p1 do

            if HOUND.Mist.pointInPolygon(p1[i], p2) then
                count = count + 1
            end
            if (not full) and count > 0 then
                return true
            end
        end
        if count == #p1 then
            return true
        end

        return false
    end

    function HOUND.Mist.shape.polyInCircle(poly, circle, full)
            local count = 0
            for i = 1, #poly do
                if HOUND.Mist.utils.get2DDist(circle.point, poly[i]) <= circle.radius then
                    if full then
                        count = count + 1
                    else
                       return true
                    end
                end
            end
            if count == #poly then
                return true
            end

        return false
    end

    function HOUND.Mist.shape.getPointOnSegment(point, seg, isSeg)
        local p = HOUND.Mist.utils.makeVec2(point)
        local s1 = HOUND.Mist.utils.makeVec2(seg[1])
        local s2 = HOUND.Mist.utils.makeVec2(seg[2])
        local cx, cy = p.x - s1.x, p.y - s1.y
        local dx, dy = s2.x - s1.x, s2.y - s1.y
        local d = (dx*dx + dy*dy)

        if d == 0 then
           return {x = s1.x, y = s1.y}
        end
        local u = (cx*dx + cy*dy)/d
        if isSeg then
           if u < 0 then
                u = 0
            elseif u > 1 then
                u = 1
            end
        end
        return {x = s1.x + u*dx, y = s1.y + u*dy}
    end

    function HOUND.Mist.shape.segmentIntersect(seg1, seg2)
        local segA = {HOUND.Mist.utils.makeVec2(seg1[1]), HOUND.Mist.utils.makeVec2(seg1[2])}
        local segB = {HOUND.Mist.utils.makeVec2(seg2[1]), HOUND.Mist.utils.makeVec2(seg2[2])}

        local dx1, dy1 = segA[2].x - segA[1].x, segA[2].y - segA[1].y
        local dx2, dy2 = segB[2].x - segB[1].x, segB[2].y - segB[1].y
        local dx3, dy3 = segA[1].x - segB[1].x, segA[1].y - segB[1].y

        local d = dx1*dy2 - dy1*dx2

        if d == 0 then
           return false
        end
        local t1 = (dx2*dy3 - dy2*dx3)/d
        if t1 < 0 or t1 > 1 then
          return false
        end
        local t2 = (dx1*dy3 - dy1*dx3)/d
        if t2 < 0 or t2 > 1 then
          return false
        end
          -- point of intersection
          return true, {x = segA[1].x + t1*dx1, y = segA[1].y + t1*dy1}
    end
    function HOUND.Mist.pointInPolygon(point, poly, maxalt) --raycasting point in polygon. Code from http://softsurfer.com/Archive/algorithm_0103/algorithm_0103.htm

        point = HOUND.Mist.utils.makeVec3(point)
        local px = point.x
        local pz = point.z
        local cn = 0
        local newpoly = HOUND.Mist.utils.deepCopy(poly)

        if not maxalt or (point.y <= maxalt) then
            local polysize = #newpoly
            newpoly[#newpoly + 1] = newpoly[1]

            newpoly[1] = HOUND.Mist.utils.makeVec3(newpoly[1])

            for k = 1, polysize do
                newpoly[k+1] = HOUND.Mist.utils.makeVec3(newpoly[k+1])
                if ((newpoly[k].z <= pz) and (newpoly[k+1].z > pz)) or ((newpoly[k].z > pz) and (newpoly[k+1].z <= pz)) then
                    local vt = (pz - newpoly[k].z) / (newpoly[k+1].z - newpoly[k].z)
                    if (px < newpoly[k].x + vt*(newpoly[k+1].x - newpoly[k].x)) then
                        cn = cn + 1
                    end
                end
            end

            return cn%2 == 1
        else
            return false
        end
    end

	function HOUND.Mist.projectPoint(point, dist, theta)
		local newPoint = {}
		if point.z then
		   newPoint.z = HOUND.Mist.utils.round(math.sin(theta) * dist + point.z, 3)
		   newPoint.y = HOUND.Mist.utils.deepCopy(point.y)
		else
		   newPoint.y = HOUND.Mist.utils.round(math.sin(theta) * dist + point.y, 3)
		end
		newPoint.x = HOUND.Mist.utils.round(math.cos(theta) * dist + point.x, 3)

		return newPoint
	end
end

do
	HOUND.Mist.time = {}
	function HOUND.Mist.time.getDHMS(timeInSec)
		if timeInSec and type(timeInSec) == 'number' then
			local tbl = {d = 0, h = 0, m = 0, s = 0}
			if timeInSec > 86400 then
				while timeInSec > 86400 do
					tbl.d = tbl.d + 1
					timeInSec = timeInSec - 86400
				end
			end
			if timeInSec > 3600 then
				while timeInSec > 3600 do
					tbl.h = tbl.h + 1
					timeInSec = timeInSec - 3600
				end
			end
			if timeInSec > 60 then
				while timeInSec > 60 do
					tbl.m = tbl.m + 1
					timeInSec = timeInSec - 60
				end
			end
			tbl.s = timeInSec
			return tbl
		else
			log:error("Didn't recieve number")
			return
		end
	end
end

do
	-- https://www.redblobgames.com/grids/hexagons/
	-- Due to how DCS handles coordinates I swapped the two main coordinates used with hexagons q and r. All examples from that page are in qrs. I'm using rqs
	-- uses "pointy top" hexagon orientation
	-- r cooresponds to x axis (north-south)
	-- q corresponds to "y axis" but it isn't strictly east-west because it exists on a slight diagonal
	-- Primarily added as util functions used by Grayflag to abstract spacial calculations related to coalition land ownership, threats, and AI navigation

	--- Hex grid (pointy-top cube rqs, MIST 4.6 ec4e9ca, redblobgames).
	-- @section HOUND.Mist.hex

	HOUND.Mist.hex = {}

	local hexRadius = 10000
	local hexIter = math.rad(360/6)

	--- Return the current hex grid radius in meters.
	-- @treturn number current hex radius
	function HOUND.Mist.hex.getRadius()
		return HOUND.Mist.utils.deepCopy(hexRadius)
	end

	--- Set the hex grid radius in meters.
	-- @tparam number r new hex radius
	function HOUND.Mist.hex.setRadius(r)
		hexRadius = r
	end



	--- Construct a cube hex from r/q/s coordinates (r+q+s must be 0).
	-- @tparam number r r coordinate (DCS x axis, north-south)
	-- @tparam number q q coordinate (diagonal east-west axis)
	-- @tparam number s s coordinate
	-- @treturn table cube hex {q, r, s}
	function HOUND.Mist.hex.to(r, q, s)
		assert(math.floor (0.5 + q + r + s) == 0, "r + q + s must be 0")
		return {q = q, r = r, s = s}
	end
	local dirInit = { HOUND.Mist.hex.to(0, 1, -1), HOUND.Mist.hex.to(-1, 1, 0), HOUND.Mist.hex.to(-1, 0, 1), HOUND.Mist.hex.to(0, -1, 1), HOUND.Mist.hex.to(1, -1, 0), HOUND.Mist.hex.to(1, 0, -1),  HOUND.Mist.hex.to(0, -1, 1)}
	HOUND.Mist.hex.directions = HOUND.Mist.utils.deepCopy(dirInit)
	for i = 6, 1, -1 do
		--table.insert(HOUND.Mist.hex.directions, dirInit[i])--HOUND.Mist.hex.directions[1-i] = HOUND.Mist.utils.deepCopy(dirInit[i])
	end

	--- Add two cube hexes.
	-- @tparam table a first hex
	-- @tparam table b second hex
	-- @treturn table sum hex
	function HOUND.Mist.hex.add (a, b)
		return HOUND.Mist.hex.to( a.r + b.r, a.q + b.q, a.s + b.s)
	end

	--- Subtract hex b from hex a.
	-- @tparam table a first hex
	-- @tparam table b second hex
	-- @treturn table difference hex
	function HOUND.Mist.hex.subtract (a, b)
		return HOUND.Mist.hex.to(a.r - b.r, a.q - b.q, a.s - b.s)
	end

	--- Scale a hex by a scalar factor.
	-- @tparam table a hex
	-- @tparam number k scale factor
	-- @treturn table scaled hex
	function HOUND.Mist.hex.scale (a, k)
		return HOUND.Mist.hex.to( a.r * k, a.q * k, a.s * k)
	end

	--- Rotate a hex 60 degrees counter-clockwise.
	-- @tparam table a hex
	-- @treturn table rotated hex
	function HOUND.Mist.hex.rotate_left (a)				-- might need to swap
		return HOUND.Mist.hex.to(-a.s, -a.q, -a.r)
	end

	--- Rotate a hex 60 degrees clockwise.
	-- @tparam table a hex
	-- @treturn table rotated hex
	function HOUND.Mist.hex.rotate_right (a)			-- might need to swap
		return HOUND.Mist.hex.to(-a.r, -a.s, -a.q)
	end


	--- Return the unit hex for a direction index (1-6).
	-- @tparam number direction direction index
	-- @treturn table unit hex, or nil when out of range
	function HOUND.Mist.hex.direction(direction)
		if HOUND.Mist.hex.directions[direction] then
			return HOUND.Mist.hex.directions[direction]
		end
	end

	--- Return the neighboring hex in a direction (1-6).
	-- @tparam table hex origin hex
	-- @tparam number direction direction index
	-- @treturn table neighbor hex, or nil when out of range
	function HOUND.Mist.hex.neighbor (hex, direction)
		local dirHex = HOUND.Mist.hex.direction(direction)
		if dirHex then
			return HOUND.Mist.hex.add(hex, dirHex)

		end
	end

	--- Count neighbors of a hex not present in a visited set.
	-- @tparam table hex origin hex
	-- @tparam table visited set of hashes to skip
	-- @treturn number count of unvisited neighbors
	function HOUND.Mist.hex.getNeighborCount(hex, visited)
		local count = 0
		for i = 1, 6 do
			local nHex = HOUND.Mist.hex.neighbor(hex, i)
			if nHex and not visited[HOUND.Mist.hex.hash(nHex)] then
				count = count + 1
			end
		end

		return count
	end

	--- Unit diagonal offsets (indexed 1-6 via direction+1).
	-- @field HOUND.Mist.hex.diagonals
	HOUND.Mist.hex.diagonals = { HOUND.Mist.hex.to(1, -2, 1), HOUND.Mist.hex.to(2, -1, -1), HOUND.Mist.hex.to(1, 1, -2), HOUND.Mist.hex.to(-1, 2, -1), HOUND.Mist.hex.to(-2, 1, 1), HOUND.Mist.hex.to(-1, -1, 2)}
	--- Return the diagonal neighbor of a hex (direction 0-5, offset by +1).
	-- @tparam table hex origin hex
	-- @tparam number direction diagonal index
	-- @treturn table diagonal neighbor hex
	function HOUND.Mist.hex.diagonalNeighbor (hex, direction)
		return HOUND.Mist.hex.add(hex, HOUND.Mist.hex.diagonals[1+direction])
	end


	--- Return the distance of a hex from the origin (cube length).
	-- @tparam table hex hex
	-- @treturn number length
	function HOUND.Mist.hex.length (hex)
		return math.floor((math.abs(hex.q) + math.abs(hex.r) + math.abs(hex.s)) / 2)
	end

	--- Return the hex distance between two hexes.
	-- @tparam table a first hex
	-- @tparam table b second hex
	-- @treturn number distance in hex steps
	function HOUND.Mist.hex.distance (a, b)
		return HOUND.Mist.hex.length(HOUND.Mist.hex.subtract(a, b))
	end

	--- Round fractional cube coordinates to the nearest valid hex.
	-- @tparam table h fractional hex
	-- @treturn table rounded hex
	function HOUND.Mist.hex.round (h)
		local qi = math.floor(math.floor (0.5 + h.q))
		local ri = math.floor(math.floor (0.5 + h.r))
		local si = math.floor(math.floor (0.5 + h.s))
		local q_diff = math.abs(qi - h.q)
		local r_diff = math.abs(ri - h.r)
		local s_diff = math.abs(si - h.s)
		if qi == 0 and ri == 0 and si == 0 then
			return {r = 0, q = 0, s = 0}
		elseif q_diff > r_diff and q_diff > s_diff then
			qi = (ri*-1) - si
		else
			if r_diff > s_diff then
				ri = -qi - si
			else
				si = -qi - ri
			end
		end
		return HOUND.Mist.hex.to(ri, qi, si)
	end

	--- Linearly interpolate between two hexes.
	-- @tparam table a first hex
	-- @tparam table b second hex
	-- @tparam number t blend factor (0-1)
	-- @treturn table interpolated fractional hex
	function HOUND.Mist.hex.lerp (a, b, t)
		return HOUND.Mist.hex.to(a.r * (1.0 - t) + b.r * t, a.q * (1.0 - t) + b.q * t, a.s * (1.0 - t) + b.s * t)
	end


	--- Scale a hex outward from the origin by a factor.
	-- @tparam table hex hex
	-- @tparam number factor scale factor
	-- @treturn table scaled hex
	function HOUND.Mist.hex.cubeScale(hex, factor)
		return  HOUND.Mist.hex.axialToCube({q = hex.q * factor, r = hex.r * factor, s = hex.s * factor})
	end
	--- Return the ring of hexes at exactly radius steps from center.
	-- Note: returns a {[hash]=hex} map, not an array.
	-- @tparam table center center hex
	-- @tparam number radius ring radius
	-- @treturn table ring hexes keyed by hash
	function HOUND.Mist.hex.cubeRing(center, radius)			-- TODO breakout on match
		local results = {}
		local curHex = HOUND.Mist.hex.add(center, HOUND.Mist.hex.cubeScale(HOUND.Mist.hex.direction(5), radius))	--- note dont change 5. This apparently is the axis the coord system uses.
		--log:warn(curHex)
		--drawHex(HOUND.Mist.hex.makeVec3(curHex), {0, 0, 1, 0.5})
		results[HOUND.Mist.hex.hash(curHex)] = curHex
		for i = 1, 6 do

			for j = 1, radius do
				curHex = HOUND.Mist.hex.neighbor(curHex, i)
				--HOUND.Mist.marker.add({mType = "text", point = HOUND.Mist.hex.makeVec3(curHex), text = HOUND.Mist.hex.hash(curHex)})
				--log:warn(curHex)
				if HOUND.Mist.hex.distance(center, curHex) <= radius  then
					--drawHex(HOUND.Mist.hex.makeVec3(curHex), {0, 1/j, 0, 0.5})
					results[HOUND.Mist.hex.hash(curHex)] = curHex
				end



			end

		end
		return results
	end

	--- Return all hexes within radius steps of center (center + rings).
	-- @tparam table center center hex
	-- @tparam number radius spiral radius
	-- @treturn table filled hexes keyed by hash
	function HOUND.Mist.hex.cubeSpiral(center, radius)		-- TODO breakout on match
		local results = {[HOUND.Mist.hex.hash(center)] = center}
		for i = 1, radius do
			local ring = HOUND.Mist.hex.cubeRing(center, i)

			for hexName, hexval in pairs(ring) do
				results[hexName] = hexval
			end

		end
		return results

	end

	--- Return the hexes on the line between two hexes (inclusive).
	-- @tparam table a first hex
	-- @tparam table b second hex
	-- @treturn table array of hexes from a to b
	function HOUND.Mist.hex.lineDraw (a, b)
		local N = HOUND.Mist.hex.distance(a, b)
		local a_nudge = HOUND.Mist.hex.to( a.r + 1e-06, a.q + 1e-06, a.s - 2e-06)
		local b_nudge = HOUND.Mist.hex.to(b.r + 1e-06, b.q + 1e-06,  b.s - 2e-06)
		local results = {}
		local step = 1.0 / math.max(N, 1)
		for i = 0, N do
			table.insert(results, HOUND.Mist.hex.round(HOUND.Mist.hex.lerp(a_nudge, b_nudge, step * i)))
		end
		return results
	end


	--- Convert a cube hex to axial coordinates.
	-- @tparam table cube cube hex
	-- @treturn table axial hex {q, r}
	function HOUND.Mist.hex.cubeToAxial(cube)
		local q = cube.q
		local r = cube.r
		return {q = q, r = r}
	end

	--- Convert an axial hex to cube coordinates.
	-- @tparam table hex axial hex
	-- @treturn table cube hex
	function HOUND.Mist.hex.axialToCube(hex)
		local q = hex.q
		local r = hex.r
		local s = -q-r
		return {q = q, r = r, s = s}
	end

	--- Convert a DCS point to the containing hex.
	-- Reads point.z or point.y as the second axis; point.x maps to r.
	-- @tparam table point DCS point (Vec2/Vec3)
	-- @tparam number radius optional hex radius override
	-- @treturn table hex containing the point
	function HOUND.Mist.hex.pointToHex(point, radius)
		local radiusUse = radius or hexRadius
		local x = point.z or point.y
		local y = point.x
		local q = (math.sqrt(3)/3 * x  -  1/3 * y) / radiusUse
		local r = (2/3 * y) / radiusUse

		return HOUND.Mist.hex.round({q = q, r = r, s = -q-r})

	end




	--- Return the Vec2 center of a hex.
	-- @tparam table hex hex
	-- @tparam number radius optional hex radius override
	-- @treturn table Vec2 {x, y}
	function HOUND.Mist.hex.makeVec2(hex, radius)
		local radiusUse = radius or hexRadius
		hex =  HOUND.Mist.hex.round(hex)
		local y = radiusUse * ((math.sqrt(3) * hex.q)  +  (math.sqrt(3)/2 * hex.r))
		local x = radiusUse * (3/2 * hex.r)
		return HOUND.Mist.utils.deepCopy({x = x, y = y})
	end
	--- Return the Vec3 center of a hex (ground level, y=0).
	-- @tparam table hex hex
	-- @tparam number radius optional hex radius override
	-- @treturn table Vec3 {x, y=0, z}
	function HOUND.Mist.hex.makeVec3(hex, radius)
		local radiusUse = radius or hexRadius
		local y = radiusUse * ((math.sqrt(3) * hex.q)  +  (math.sqrt(3)/2 * hex.r))
		local x = radiusUse * (3/2 * hex.r)
		return HOUND.Mist.utils.deepCopy({x = x, z = y, y = 0})
	end
	--- Return the Vec3 center of a hex draped on terrain height.
	-- DCS-only: requires land.getHeight.
	-- @tparam table hex hex
	-- @tparam number o optional altitude offset
	-- @tparam number radius optional hex radius override
	-- @treturn table Vec3 {x, y, z}
	function HOUND.Mist.hex.makeVec3GL(hex, o, radius )
		local radiusUse = radius or hexRadius
		local offset = o or 0
		local z = radiusUse * ((math.sqrt(3) * hex.q)  +  (math.sqrt(3)/2 * hex.r))
		local x = radiusUse * (3/2 * hex.r)
		local y = land.getHeight({x = x, y = z}) + offset
		return {x = x, y = y, z = z}
	end

	--- Hash a hex to a "r q s" string key (s omitted when nil).
	-- @tparam table tbl hex
	-- @treturn string hash key
	function HOUND.Mist.hex.hash(tbl)
		local s = tostring(tbl.r) .. " " .. tostring(tbl.q)
		if tbl.s then
			s = s .. " " .. tostring(tbl.s)
		end
		return s
	end

	--- Parse a hash string back into a hex.
	-- @tparam string s hash string
	-- @treturn table hex {r, q, s}
	function HOUND.Mist.hex.hashToHex(s)	-- convrt hash string to a hex.

		local commands = {}
		for w in string.gmatch(s, "%-?%d+") do
			table.insert(commands, tonumber(w))
		end

		local hexVal = {}
		hexVal.r = commands[1]
		hexVal.q = commands[2]
		hexVal.s = commands[3]

		return hexVal
	end

	--- Draw a hex polygon via MIST markers (debug-only, inert without MIST).
	-- @tparam table|string p hex, DCS point, or hash string
	-- @tparam table v optional marker overrides (radius supported)
	-- @treturn table MIST marker id, or nil when MIST is absent
	function HOUND.Mist.hex.draw(p, v)
		if type(mist) ~= "table" or type(mist.marker) ~= "table" then return end
		--log:echo(p)
		--HOUND.Mist.debug.mark("hex", p)
		local vars = v or {}
		local point
		if type(p) == "string" then
			point = HOUND.Mist.hex.makeVec2(HOUND.Mist.hex.hashToHex(p))
		elseif type(p) == "table" then
			if p.x then
				point = HOUND.Mist.utils.makeVec2(p)
			elseif p.q then
				point = HOUND.Mist.hex.makeVec2(p)
			end
		end
		local radiusUse = vars.radius or hexRadius
		local coords = {}
		for j = 1, 6 do
			local theta = hexIter*j
			--log:info(theta)

			local corner = HOUND.Mist.projectPoint(point, radiusUse, theta)
			table.insert(coords, corner)
			--HOUND.Mist.marker.add({mType = "text", text = j, point = corner})
		end

		local hexDraw = {mType = 7, points = coords}
		for key, val in pairs(vars) do
			hexDraw[key] = val
		end

		return mist.marker.add(hexDraw)
	end

	--- Return the hexes covered by a route polygon (edge, or filled when fill=true).
	-- @tparam table p array of DCS points forming the polygon
	-- @tparam boolean fill when true, fill interior hexes via point-in-polygon
	-- @treturn table covered hexes keyed by hash
	function HOUND.Mist.hex.getFromRoute(p, fill)
		local points = HOUND.Mist.utils.deepCopy(p)
		local avg = HOUND.Mist.getAvgPoint(points)
		table.insert(points, points[1])
		local drawn = {}
		local indexed = {}
		local meta = {count = 0, maxR = 0, minR = 100000000}

		--drawHex(HOUND.Mist.hex.makeVec2(HOUND.Mist.hex.pointToHex(avg)), {1, 1, 1, 0.3})

		for i = 1, #points-1 do
			--HOUND.Mist.marker.add({mType = "line", points = {points[i], points[i+1]}})
			local res = HOUND.Mist.hex.lineDraw(HOUND.Mist.hex.pointToHex(points[i]), HOUND.Mist.hex.pointToHex(points[i+1]))
			for j = 1, #res do
				local hash = HOUND.Mist.hex.hash(res[j])

				if not drawn[hash] then
					drawn[hash] = res[j]
					table.insert(indexed, res[j])
					local point = HOUND.Mist.hex.makeVec2(res[j])
					--drawHex(point)
					--HOUND.Mist.marker.add({mType = "text", text = hash, point = point })
					meta.count = meta.count + 1
				end


			end

			--log:echo(res)
		end
		local row = {}
		if fill then
			local poly = HOUND.Mist.utils.deepCopy(drawn)

			for hexName, hex in pairs(poly) do
				if not row[hex.r] then
					row[hex.r] = {maxQ = 0, minQ = math.huge}
				end
				if hex.q > row[hex.r].maxQ then
					row[hex.r].maxQ = HOUND.Mist.utils.deepCopy(hex.q)
				end
				if hex.q < row[hex.r].minQ then
					row[hex.r].minQ = HOUND.Mist.utils.deepCopy(hex.q)
				end
				row[hex.r][hex.q] = hex

				if hex.r > meta.maxR then
					meta.maxR = HOUND.Mist.utils.deepCopy(hex.r)
				end
				if  hex.r < meta.minR then
					meta.minR = HOUND.Mist.utils.deepCopy(hex.r)
				end

			end

			for rIndex, rData in pairs(row) do
				local skip = {}
				local draws = {}
				local crosses = 0
				local lastClear
				for i = rData.minQ+1, rData.maxQ-1 do
					local newHex = {q = i, r = rIndex, s = -rIndex-i}
					local hash = HOUND.Mist.hex.hash(newHex)
					local hexPoint = HOUND.Mist.hex.makeVec2(newHex)
					if (not drawn[hash]) and HOUND.Mist.pointInPolygon(hexPoint, p) then			--- still think there is a faster way than checking old point in polygon, but whatever.
						row[rIndex][newHex.q] = newHex
						drawn[hash] = newHex
						--drawHex(hexPoint, {0, 1, 0, 0.5})
						--HOUND.Mist.marker.add({mType = "text", text = hash, point = hexPoint })
						meta.count = meta.count + 1
					end
				end

			end
			meta.row = row
			--return {hexes = drawn, meta = meta}
		end
		if drawn["0 0 -0"] then
			drawn["0 0 0"] = {r = 0, q = 0, s = 0}
			drawn["0 0 -0"] = nil
		end

		return drawn

	end

end

end
