--- HOUND.Matrix
-- This class holds matrix math function
-- code is Directly taken from https://github.com/davidm/lua-matrix
-- @module HOUND.Matrix

do
    HOUND.Matrix = {}
    HOUND.Matrix.__index = HOUND.Matrix

    --/////////////////////////////
    --// Get 'new' matrix object //
    --/////////////////////////////

    --- Get new matrix object
    -- @param rows number or rows or table to convert to matrix object
    -- if rows is a table then sets rows as matrix
    -- if rows is a table of structure {1,2,3} then it sets it as a vector matrix
    -- @param columns number of columns or "I" to create identity matrix
    -- if rows and columns are given and are numbers, returns a matrix with size rowsxcolumns
    -- if rows is given as number and columns is "I", will return an identity matrix of size rowsxrows
    -- @param value value to give cells of matrix
    -- if value is given then returns a matrix with given size and all values set to value
    -- @return matrix object
    function HOUND.Matrix:new( rows, columns, value )
        -- check for given matrix
        if type( rows ) == "table" then
            -- check for vector
            if type(rows[1]) ~= "table" then -- expect a vector
                return setmetatable( {{rows[1]},{rows[2]},{rows[3]}},HOUND.Matrix )
            end
            return setmetatable( rows,HOUND.Matrix )
        end
        -- get matrix table
        local mtx = {}
        local value = value or 0
        -- build identity matrix of given rows
        if columns == "I" then
            for i = 1,rows do
                mtx[i] = {}
                for j = 1,rows do
                    if i == j then
                        mtx[i][j] = 1
                    else
                        mtx[i][j] = 0
                    end
                end
            end
        -- build new matrix
        else
            for i = 1,rows do
                mtx[i] = {}
                for j = 1,columns do
                    mtx[i][j] = value
                end
            end
        end
        -- return matrix with shared metatable
        return setmetatable( mtx,HOUND.Matrix )
    end

    --// matrix ( rows [, comlumns [, value]] )
    -- set __call behaviour of matrix
    -- for matrix( ... ) as HOUND.Matrix.new( ... )
    setmetatable( HOUND.Matrix, { __call = function( ... ) return HOUND.Matrix.new( ... ) end } )

    -- functions are designed to be light on checks
    -- so we get Lua errors instead on wrong input
    -- HOUND.Matrix.<functions> should handle any table of structure t[i][j] = value
    -- we always return a matrix with scripts metatable
    -- cause its faster than setmetatable( mtx, getmetatable( input matrix ) )

    --///////////////////////////////
    --// matrix 'matrix' functions //
    --///////////////////////////////

    --// for real, complex and symbolic matrices //--

    -- note: real and complex matrices may be added, subtracted, etc.
    --		real and symbolic matrices may also be added, subtracted, etc.
    --		but one should avoid using symbolic matrices with complex ones
    --		since it is not clear which metatable then is used

    --- add matrices
    -- @param m1 Matrix
    -- @param m2 Matrix
    -- @return Matrix, sum of m1 and m2
    -- @local
    function HOUND.Matrix.add( m1, m2 )
        local mtx = {}
        for i = 1,#m1 do
            local m3i = {}
            mtx[i] = m3i
            for j = 1,#m1[1] do
                m3i[j] = m1[i][j] + m2[i][j]
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --- Subtract two matrices
    -- @param m1 Matrix
    -- @param m2 Matrix
    -- @return Matrix
    -- @local
    function HOUND.Matrix.sub( m1, m2 )
        local mtx = {}
        for i = 1,#m1 do
            local m3i = {}
            mtx[i] = m3i
            for j = 1,#m1[1] do
                m3i[j] = m1[i][j] - m2[i][j]
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --- Multiply two matrices
    -- m1 columns must be equal to m2 rows
    -- @param m1 Matrix
    -- @param m2 Matrix
    -- @return Matrix
    -- @local
    function HOUND.Matrix.mul( m1, m2 )
        -- multiply rows with columns
        local mtx = {}
        for i = 1,#m1 do
            mtx[i] = {}
            for j = 1,#m2[1] do
                local num = m1[i][1] * m2[1][j]
                for n = 2,#m1[1] do
                    num = num + m1[i][n] * m2[n][j]
                end
                mtx[i][j] = num
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --- Divide two matrices
    -- m1 columns must be equal to m2 rows
    -- m2 must be square, to be inverted,
    -- if that fails returns the rank of m2 as second argument
    -- @param m1 Matrix
    -- @param m2 Matrix
    -- @return Matrix
    -- @local
    function HOUND.Matrix.div( m1, m2 )
        local rank; m2,rank = HOUND.Matrix.invert( m2 )
        if not m2 then return m2, rank end -- singular
        return HOUND.Matrix.mul( m1, m2 )
    end

    --// HOUND.Matrix.mulnum ( m1, num )
    --- Multiply matrix with a number
    -- num may be of type 'number' or 'complex number'
    -- strings get converted to complex number, if that fails then to symbol
    -- @param m1 Matrix
    -- @param[type=number] num
    -- @return Matrix
    -- @local
    function HOUND.Matrix.mulnum( m1, num )
        local mtx = {}
        -- multiply elements with number
        for i = 1,#m1 do
            mtx[i] = {}
            for j = 1,#m1[1] do
                mtx[i][j] = m1[i][j] * num
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --- Divide matrix by a number
    -- num may be of type 'number' or 'complex number'
    -- strings get converted to complex number, if that fails then to symbol
    -- @param m1 Matrix
    -- @param[type=number] num
    -- @return Matrix
    -- @local
    function HOUND.Matrix.divnum( m1, num )
        local mtx = {}
        -- divide elements by number
        for i = 1,#m1 do
            local mtxi = {}
            mtx[i] = mtxi
            for j = 1,#m1[1] do
                mtxi[j] = m1[i][j] / num
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// for real and complex matrices only //--

    --- Power of matrix; mtx^(num)
    -- num is an integer and may be negative
    -- m1 has to be square
    -- if num is negative and inverting m1 fails
    -- returns the rank of matrix m1 as second argument
    -- @param m1 Matrix
    -- @param[type=number] num
    -- @return Matrix
    -- @local
    function HOUND.Matrix.pow( m1, num )
        assert(num == math.floor(num), "exponent not an integer")
        if num == 0 then
            return HOUND.Matrix:new( #m1,"I" )
        end
        if num < 0 then
            local rank; m1,rank = HOUND.Matrix.invert( m1 )
          if not m1 then return m1, rank end -- singular
            num = -num
        end
        local mtx = HOUND.Matrix.copy( m1 )
        for i = 2,num	do
            mtx = HOUND.Matrix.mul( mtx,m1 )
        end
        return mtx
    end

    local function number_norm2(x)
      return x * x
    end

    --- Calculate the determinant of a matrix
    -- m1 needs to be square
    -- Can calc the det for symbolic matrices up to 3x3 too
    -- The function to calculate matrices bigger 3x3
    -- is quite fast and for matrices of medium size ~(100x100)
    -- and average values quite accurate
    -- here we try to get the nearest element to |1|, (smallest pivot element)
    -- os that usually we have |mtx[i][j]/subdet| > 1 or mtx[i][j];
    -- with complex matrices we use the complex.abs function to check if it is bigger or smaller
    -- @param m1 Matrix
    -- @return Matrix
    -- @local
    function HOUND.Matrix.det( m1 )
        -- check if matrix is quadratic
        assert(#m1 == #m1[1], "matrix not square")

        local size = #m1

        if size == 1 then
            return m1[1][1]
        end

        if size == 2 then
            return m1[1][1]*m1[2][2] - m1[2][1]*m1[1][2]
        end

        if size == 3 then
            return ( m1[1][1]*m1[2][2]*m1[3][3] + m1[1][2]*m1[2][3]*m1[3][1] + m1[1][3]*m1[2][1]*m1[3][2]
                - m1[1][3]*m1[2][2]*m1[3][1] - m1[1][1]*m1[2][3]*m1[3][2] - m1[1][2]*m1[2][1]*m1[3][3] )
        end

        --// no symbolic matrix supported below here
        local e = m1[1][1]
        local zero  = type(e) == "table" and e.zero or 0
        local norm2 = type(e) == "table" and e.norm2 or number_norm2

        --// matrix is bigger than 3x3
        -- get determinant
        -- using Gauss elimination and Laplace
        -- start eliminating from below better for removals
        -- get copy of matrix, set initial determinant
        local mtx = HOUND.Matrix.copy( m1 )
        local det = 1
        -- get det up to the last element
        for j = 1,#mtx[1] do
            -- get smallest element so that |factor| > 1
            -- and set it as last element
            local rows = #mtx
            local subdet,xrow
            for i = 1,rows do
                -- get element
                local e = mtx[i][j]
                -- if no subdet has been found
                if not subdet then
                    -- check if element it is not zero
                    if e ~= zero then
                        -- use element as new subdet
                        subdet,xrow = e,i
                    end
                -- check for elements nearest to 1 or -1
                elseif e ~= zero and math.abs(norm2(e)-1) < math.abs(norm2(subdet)-1) then
                    subdet,xrow = e,i
                end
            end
            -- only cary on if subdet is found
            if subdet then
                -- check if xrow is the last row,
                -- else switch lines and multiply det by -1
                if xrow ~= rows then
                    mtx[rows],mtx[xrow] = mtx[xrow],mtx[rows]
                    det = -det
                end
                -- traverse all fields setting element to zero
                -- we don't set to zero cause we don't use that column anymore then anyways
                for i = 1,rows-1 do
                    -- factor is the dividor of the first element
                    -- if element is not already zero
                    if mtx[i][j] ~= zero then
                        local factor = mtx[i][j]/subdet
                        -- update all remaining fields of the matrix, with value from xrow
                        for n = j+1,#mtx[1] do
                            mtx[i][n] = mtx[i][n] - factor * mtx[rows][n]
                        end
                    end
                end
                -- update determinant and remove row
                if math.fmod( rows,2 ) == 0 then
                    det = -det
                end
                det = det * subdet
                table.remove( mtx )
            else
                -- break here table det is 0
                return det * 0
            end
        end
        -- det ready to return
        return det
    end

    --// HOUND.Matrix.dogauss ( mtx )
    --- Gauss elimination, Gauss-Jordan Method
    -- this function changes the matrix itself
    -- returns on success: true,
    -- returns on failure: false,'rank of matrix'

    -- locals
    -- checking here for the element nearest but not equal to zero (smallest pivot element).
    -- This way the `factor` in `dogauss` will be >= 1, which
    -- can give better results.
    -- @param mtx Matrix
    -- @param[type=number] i
    -- @param[type=number] j
    -- @param[type=number] norm2
    -- @return Boolean
    -- @local
    local pivotOk = function( mtx,i,j,norm2 )
        -- find min value
        local iMin
        local normMin = math.huge
        for _i = i,#mtx do
            local e = mtx[_i][j]
            local norm = math.abs(norm2(e))
            if norm > 0 and norm < normMin then
                iMin = _i
                normMin = norm
                end
            end
        if iMin then
            -- switch lines if not in position.
            if iMin ~= i then
                mtx[i],mtx[iMin] = mtx[iMin],mtx[i]
            end
            return true
            end
        return false
    end

    local function copy(x)
        return type(x) == "table" and x.copy(x) or x
    end

    -- note: in --// ... //-- we have a way that does no divison,
    -- however with big number and matrices we get problems since we do no reducing
    function HOUND.Matrix.dogauss( mtx )
        local e = mtx[1][1]
        local zero = type(e) == "table" and e.zero or 0
        local one  = type(e) == "table" and e.one  or 1
        local norm2 = type(e) == "table" and e.norm2 or number_norm2

        local rows,columns = #mtx,#mtx[1]
        -- stairs left -> right
        for j = 1,rows do
            -- check if element can be setted to one
            if pivotOk( mtx,j,j,norm2 ) then
                -- start parsing rows
                for i = j+1,rows do
                    -- check if element is not already zero
                    if mtx[i][j] ~= zero then
                        -- we may add x*otherline row, to set element to zero
                        -- tozero - x*mtx[j][j] = 0; x = tozero/mtx[j][j]
                        local factor = mtx[i][j]/mtx[j][j]
                        --// this should not be used although it does no division,
                        -- yet with big matrices (since we do no reducing and other things)
                        -- we get too big numbers
                        --local factor1,factor2 = mtx[i][j],mtx[j][j] //--
                        mtx[i][j] = copy(zero)
                        for _j = j+1,columns do
                            --// mtx[i][_j] = mtx[i][_j] * factor2 - factor1 * mtx[j][_j] //--
                            mtx[i][_j] = mtx[i][_j] - factor * mtx[j][_j]
                        end
                    end
                end
            else
                -- return false and the rank of the matrix
                return false,j-1
            end
        end
        -- stairs right <- left
        for j = rows,1,-1 do
            -- set element to one
            -- do division here
            local div = mtx[j][j]
            for _j = j+1,columns do
                mtx[j][_j] = mtx[j][_j] / div
            end
            -- start parsing rows
            for i = j-1,1,-1 do
                -- check if element is not already zero
                if mtx[i][j] ~= zero then
                    local factor = mtx[i][j]
                    for _j = j+1,columns do
                        mtx[i][_j] = mtx[i][_j] - factor * mtx[j][_j]
                    end
                    mtx[i][j] = copy(zero)
                end
            end
            mtx[j][j] = copy(one)
        end
        return true
    end

    --// HOUND.Matrix.invert ( m1 )
    --- Get the inverted matrix or m1
    -- matrix must be square and not singular
    -- on success: returns inverted matrix
    -- on failure: returns nil,'rank of matrix'
    -- @param m1 Matrix
    -- @return Matrix

    function HOUND.Matrix.invert( m1 )
        assert(#m1 == #m1[1], "matrix not square")
        local mtx = HOUND.Matrix.copy( m1 )
        local ident = setmetatable( {},HOUND.Matrix )
        local e = m1[1][1]
        local zero = type(e) == "table" and e.zero or 0
        local one  = type(e) == "table" and e.one  or 1
        for i = 1,#m1 do
            local identi = {}
            ident[i] = identi
            for j = 1,#m1 do
                identi[j] = copy((i == j) and one or zero)
            end
        end
        mtx = HOUND.Matrix.concath( mtx,ident )
        local done,rank = HOUND.Matrix.dogauss( mtx )
        if done then
            return HOUND.Matrix.subm( mtx, 1,(#mtx[1]/2)+1,#mtx,#mtx[1] )
        else
            return nil,rank
        end
    end

    --// HOUND.Matrix.sqrt ( m1 [,iters] )
    -- calculate the square root of a matrix using "Denman Beavers square root iteration"
    -- condition: matrix rows == matrix columns; must have a invers matrix and a square root
    -- if called without additional arguments, the function finds the first nearest square root to
    -- input matrix, there are others but the error between them is very small
    -- if called with agument iters, the function will return the matrix by number of iterations
    -- the script returns:
    --		as first argument, matrix^.5
    --		as second argument, matrix^-.5
    --		as third argument, the average error between (matrix^.5)^2-inputmatrix
    -- you have to determin for yourself if the result is sufficent enough for you
    -- local average error
    local function get_abs_avg( m1, m2 )
        local dist = 0
        local e = m1[1][1]
        local abs = type(e) == "table" and e.abs or math.abs
        for i=1,#m1 do
            for j=1,#m1[1] do
                dist = dist + abs(m1[i][j]-m2[i][j])
            end
        end
        -- norm by numbers of entries
        return dist/(#m1*2)
    end
    -- square root function
    function HOUND.Matrix.sqrt( m1, iters )
        assert(#m1 == #m1[1], "matrix not square")
        local iters = iters or math.huge
        local y = HOUND.Matrix.copy( m1 )
        local z = HOUND.Matrix(#y, 'I')
        local dist = math.huge
        -- iterate, and get the average error
        for n=1,iters do
            local lasty,lastz = y,z
            -- calc square root
            -- y, z = (1/2)*(y + z^-1), (1/2)*(z + y^-1)
            y, z = HOUND.Matrix.divnum((HOUND.Matrix.add(y,HOUND.Matrix.invert(z))),2),
                    HOUND.Matrix.divnum((HOUND.Matrix.add(z,HOUND.Matrix.invert(y))),2)
            local dist1 = get_abs_avg(y,lasty)
            if iters == math.huge then
                if dist1 >= dist then
                    return lasty,lastz,get_abs_avg(HOUND.Matrix.mul(lasty,lasty),m1)
                end
            end
            dist = dist1
        end
        return y,z,get_abs_avg(HOUND.Matrix.mul(y,y),m1)
    end

    --// HOUND.Matrix.root ( m1, root [,iters] )
    -- calculate any root of a matrix
    -- source: http://www.dm.unipi.it/~cortona04/slides/bruno.pdf
    -- m1 and root have to be given;(m1 = matrix, root = number)
    -- conditions same as HOUND.Matrix.sqrt
    -- returns same values as HOUND.Matrix.sqrt
    function HOUND.Matrix.root( m1, root, iters )
        assert(#m1 == #m1[1], "matrix not square")
        local iters = iters or math.huge
        local mx = HOUND.Matrix.copy( m1 )
        local my = HOUND.Matrix.mul(mx:invert(),mx:pow(root-1))
        local dist = math.huge
        -- iterate, and get the average error
        for n=1,iters do
            local lastx,lasty = mx,my
            -- calc root of matrix
            --mx,my = ((p-1)*mx + my^-1)/p,
            --	((((p-1)*my + mx^-1)/p)*my^-1)^(p-2) *
            --	((p-1)*my + mx^-1)/p
            mx,my = mx:mulnum(root-1):add(my:invert()):divnum(root),
                my:mulnum(root-1):add(mx:invert()):divnum(root)
                    :mul(my:invert():pow(root-2)):mul(my:mulnum(root-1)
                    :add(mx:invert())):divnum(root)
            local dist1 = get_abs_avg(mx,lastx)
            if iters == math.huge then
                if dist1 >= dist then
                    return lastx,lasty,get_abs_avg(HOUND.Matrix.pow(lastx,root),m1)
                end
            end
            dist = dist1
        end
        return mx,my,get_abs_avg(HOUND.Matrix.pow(mx,root),m1)
    end

    --// Norm functions //--

    --// HOUND.Matrix.normf ( mtx )
    -- calculates the Frobenius norm of the matrix.
    --   ||mtx||_F = sqrt(SUM_{i,j} |a_{i,j}|^2)
    -- http://en.wikipedia.org/wiki/Frobenius_norm#Frobenius_norm
    function HOUND.Matrix.normf(mtx)
        local mtype = HOUND.Matrix.type(mtx)
        local result = 0
        for i = 1,#mtx do
        for j = 1,#mtx[1] do
            local e = mtx[i][j]
            if mtype ~= "number" then e = e:abs() end
            result = result + e^2
        end
        end
        local sqrt = (type(result) == "number") and math.sqrt or result.sqrt
        return sqrt(result)
    end

    --// HOUND.Matrix.normmax ( mtx )
    -- calculates the max norm of the matrix.
    --   ||mtx||_{max} = max{|a_{i,j}|}
    -- Does not work with symbolic matrices
    -- http://en.wikipedia.org/wiki/Frobenius_norm#Max_norm
    function HOUND.Matrix.normmax(mtx)
        local abs = (HOUND.Matrix.type(mtx) == "number") and math.abs or mtx[1][1].abs
        local result = 0
        for i = 1,#mtx do
        for j = 1,#mtx[1] do
            local e = abs(mtx[i][j])
            if e > result then result = e end
        end
        end
        return result
    end

    --// only for number and complex type //--
    -- Functions changing the matrix itself

    --// HOUND.Matrix.round ( mtx [, idp] )
    -- perform round on elements
    local numround = function( num,mult )
        return math.floor( num * mult + 0.5 ) / mult
    end
    local tround = function( t,mult )
        for i,v in ipairs(t) do
            t[i] = math.floor( v * mult + 0.5 ) / mult
        end
        return t
    end
    function HOUND.Matrix.round( mtx, idp )
        local mult = 10^( idp or 0 )
        local fround = HOUND.Matrix.type( mtx ) == "number" and numround or tround
        for i = 1,#mtx do
            for j = 1,#mtx[1] do
                mtx[i][j] = fround(mtx[i][j],mult)
            end
        end
        return mtx
    end

    --// HOUND.Matrix.random( mtx [,start] [, stop] [, idip] )
    -- fillmatrix with random values
    local numfill = function( _,start,stop,idp )
        return l_math.random( start,stop ) / idp
    end
    local tfill = function( t,start,stop,idp )
        for i in ipairs(t) do
            t[i] = l_math.random( start,stop ) / idp
        end
        return t
    end
    function HOUND.Matrix.random( mtx,start,stop,idp )
        local start,stop,idp = start or -10,stop or 10,idp or 1
        local ffill = HOUND.Matrix.type( mtx ) == "number" and numfill or tfill
        for i = 1,#mtx do
            for j = 1,#mtx[1] do
                mtx[i][j] = ffill( mtx[i][j], start, stop, idp )
            end
        end
        return mtx
    end

    --//////////////////////////////
    --// Object Utility Functions //
    --//////////////////////////////

    --// for all types and matrices //--

    --// HOUND.Matrix.type ( mtx )
    -- get type of matrix, normal/complex/symbol or tensor
    function HOUND.Matrix.type( mtx )
        local e = mtx[1][1]
        if type(e) == "table" then
            if e.type then
                return e:type()
            end
            return "tensor"
        end
        return "number"
    end

    -- local functions to copy matrix values
    local num_copy = function( num )
        return num
    end
    local t_copy = function( t )
        local newt = setmetatable( {}, getmetatable( t ) )
        for i,v in ipairs( t ) do
            newt[i] = v
        end
        return newt
    end

    --// HOUND.Matrix.copy ( m1 )
    -- Copy a matrix
    -- simple copy, one can write other functions oneself
    function HOUND.Matrix.copy( m1 )
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        local mtx = {}
        for i = 1,#m1[1] do
            mtx[i] = {}
            for j = 1,#m1 do
                mtx[i][j] = docopy( m1[i][j] )
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// HOUND.Matrix.transpose ( m1 )
    -- Transpose a matrix
    -- switch rows and columns
    function HOUND.Matrix.transpose( m1 )
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        local mtx = {}
        for i = 1,#m1[1] do
            mtx[i] = {}
            for j = 1,#m1 do
                mtx[i][j] = docopy( m1[j][i] )
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// HOUND.Matrix.subm ( m1, i1, j1, i2, j2 )
    -- Submatrix out of a matrix
    -- input: i1,j1,i2,j2
    -- i1,j1 are the start element
    -- i2,j2 are the end element
    -- condition: i1,j1,i2,j2 are elements of the matrix
    function HOUND.Matrix.subm( m1,i1,j1,i2,j2 )
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        local mtx = {}
        for i = i1,i2 do
            local _i = i-i1+1
            mtx[_i] = {}
            for j = j1,j2 do
                local _j = j-j1+1
                mtx[_i][_j] = docopy( m1[i][j] )
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// HOUND.Matrix.concath( m1, m2 )
    -- Concatenate two matrices, horizontal
    -- will return m1m2; rows have to be the same
    -- e.g.: #m1 == #m2
    function HOUND.Matrix.concath( m1,m2 )
        assert(#m1 == #m2, "matrix size mismatch")
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        local mtx = {}
        local offset = #m1[1]
        for i = 1,#m1 do
            mtx[i] = {}
            for j = 1,offset do
                mtx[i][j] = docopy( m1[i][j] )
            end
            for j = 1,#m2[1] do
                mtx[i][j+offset] = docopy( m2[i][j] )
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// HOUND.Matrix.concatv ( m1, m2 )
    -- Concatenate two matrices, vertical
    -- will return	m1
    --					m2
    -- columns have to be the same; e.g.: #m1[1] == #m2[1]
    function HOUND.Matrix.concatv( m1,m2 )
        assert(#m1[1] == #m2[1], "matrix size mismatch")
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        local mtx = {}
        for i = 1,#m1 do
            mtx[i] = {}
            for j = 1,#m1[1] do
                mtx[i][j] = docopy( m1[i][j] )
            end
        end
        local offset = #mtx
        for i = 1,#m2 do
            local _i = i + offset
            mtx[_i] = {}
            for j = 1,#m2[1] do
                mtx[_i][j] = docopy( m2[i][j] )
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// matrix.rotl ( m1 )
    -- Rotate Left, 90 degrees
    function HOUND.Matrix.rotl( m1 )
        local mtx = HOUND.Matrix:new( #m1[1],#m1 )
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        for i = 1,#m1 do
            for j = 1,#m1[1] do
                mtx[#m1[1]-j+1][i] = docopy( m1[i][j] )
            end
        end
        return mtx
    end

    --// matrix.rotr ( m1 )
    -- Rotate Right, 90 degrees
    function HOUND.Matrix.rotr( m1 )
        local mtx = HOUND.Matrix:new( #m1[1],#m1 )
        local docopy = HOUND.Matrix.type( m1 ) == "number" and num_copy or t_copy
        for i = 1,#m1 do
            for j = 1,#m1[1] do
                mtx[j][#m1-i+1] = docopy( m1[i][j] )
            end
        end
        return mtx
    end

    local function tensor_tostring( t,fstr )
        if not fstr then return "["..table.concat(t,",").."]" end
        local tval = {}
        for i,v in ipairs( t ) do
            tval[i] = string.format( fstr,v )
        end
        return "["..table.concat(tval,",").."]"
    end
    local function number_tostring( e,fstr )
        return fstr and string.format( fstr,e ) or e
    end

    --// matrix.tostring ( mtx, formatstr )
    -- tostring function
    function HOUND.Matrix.tostring( mtx, formatstr )
        local ts = {}
        local mtype = HOUND.Matrix.type( mtx )
        local e = mtx[1][1]
        local tostring = mtype == "tensor" and tensor_tostring or
              type(e) == "table" and e.tostring or number_tostring
        for i = 1,#mtx do
            local tstr = {}
            for j = 1,#mtx[1] do
                tstr[j] = tostring(mtx[i][j],formatstr)
            end
            ts[i] = table.concat(tstr, "\t")
        end
        return table.concat(ts, "\n")
    end

    --// matrix.print ( mtx [, formatstr] )
    -- print out the matrix, just calls tostring
    -- function HOUND.Matrix.print( ... )
    --     print( HOUND.Matrix.tostring( ... ) )
    -- end

    --// matrix.latex ( mtx [, align] )
    -- LaTeX output
    function HOUND.Matrix.latex( mtx, align )
        -- align : option to align the elements
        --		c = center; l = left; r = right
        --		\usepackage{dcolumn}; D{.}{,}{-1}; aligns number by . replaces it with ,
        local align = align or "c"
        local str = "$\\left( \\begin{array}{"..string.rep( align, #mtx[1] ).."}\n"
        local getstr = HOUND.Matrix.type( mtx ) == "tensor" and tensor_tostring or number_tostring
        for i = 1,#mtx do
            str = str.."\t"..getstr(mtx[i][1])
            for j = 2,#mtx[1] do
                str = str.." & "..getstr(mtx[i][j])
            end
            -- close line
            if i == #mtx then
                str = str.."\n"
            else
                str = str.." \\\\\n"
            end
        end
        return str.."\\end{array} \\right)$"
    end

    --// Functions not changing the matrix

    --// matrix.rows ( mtx )
    -- return number of rows
    function HOUND.Matrix.rows( mtx )
        return #mtx
    end

    --// matrix.columns ( mtx )
    -- return number of columns
    function HOUND.Matrix.columns( mtx )
        return #mtx[1]
    end

    --//  matrix.size ( mtx )
    -- get matrix size as string rows,columns
    function HOUND.Matrix.size( mtx )
        if HOUND.Matrix.type( mtx ) == "tensor" then
            return #mtx,#mtx[1],#mtx[1][1]
        end
        return #mtx,#mtx[1]
    end

    --// HOUND.Matrix.getelement ( mtx, i, j )
    -- return specific element ( row,column )
    -- returns element on success and nil on failure
    function HOUND.Matrix.getelement( mtx,i,j )
        if mtx[i] and mtx[i][j] then
            return mtx[i][j]
        end
    end

    --// HOUND.Matrix.setelement( mtx, i, j, value )
    -- set an element ( i, j, value )
    -- returns 1 on success and nil on failure
    function HOUND.Matrix.setelement( mtx,i,j,value )
        if HOUND.Matrix.getelement( mtx,i,j ) then
            -- check if value type is number
            mtx[i][j] = value
            return 1
        end
    end

    --// HOUND.Matrix.ipairs ( mtx )
    -- iteration, same for complex
    function HOUND.Matrix.ipairs( mtx )
        local i,j,rows,columns = 1,0,#mtx,#mtx[1]
        local function iter()
            j = j + 1
            if j > columns then -- return first element from next row
                i,j = i + 1,1
            end
            if i <= rows then
                return i,j
            end
        end
        return iter
    end

    --///////////////////////////////
    --// matrix 'vector' functions //
    --///////////////////////////////

    -- a vector is defined as a 3x1 matrix
    -- get a vector; vec = matrix{{ 1,2,3 }}^'T'

    --// HOUND.Matrix.scalar ( m1, m2 )
    -- returns the Scalar Product of two 3x1 matrices (vectors)
    function HOUND.Matrix.scalar( m1, m2 )
        return m1[1][1]*m2[1][1] + m1[2][1]*m2[2][1] +  m1[3][1]*m2[3][1]
    end

    --// HOUND.Matrix.cross ( m1, m2 )
    -- returns the Cross Product of two 3x1 matrices (vectors)
    function HOUND.Matrix.cross( m1, m2 )
        local mtx = {}
        mtx[1] = { m1[2][1]*m2[3][1] - m1[3][1]*m2[2][1] }
        mtx[2] = { m1[3][1]*m2[1][1] - m1[1][1]*m2[3][1] }
        mtx[3] = { m1[1][1]*m2[2][1] - m1[2][1]*m2[1][1] }
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// HOUND.Matrix.len ( m1 )
    -- returns the Length of a 3x1 matrix (vector)
    function HOUND.Matrix.len( m1 )
        return math.sqrt( m1[1][1]^2 + m1[2][1]^2 + m1[3][1]^2 )
    end

    --// HOUND.Matrix.replace (mtx, func, ...)
    -- for each element e in the matrix mtx, replace it with func(mtx, ...).
    function HOUND.Matrix.replace( m1, func, ... )
        local mtx = {}
        for i = 1,#m1 do
            local m1i = m1[i]
            local mtxi = {}
            for j = 1,#m1i do
                mtxi[j] = func( m1i[j], ... )
            end
            mtx[i] = mtxi
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --// HOUND.Matrix.remcomplex ( mtx )
    -- set the matrix elements to strings
    -- IMPROVE: tostring v.s. tostringelements confusing
    function HOUND.Matrix.elementstostrings( mtx )
        local e = mtx[1][1]
        local tostring = type(e) == "table" and e.tostring or tostring
        return HOUND.Matrix.replace(mtx, tostring)
    end

    --// HOUND.Matrix.solve ( m1 )
    -- solve; tries to solve a symbolic matrix to a number
    function HOUND.Matrix.solve( m1 )
        assert( HOUND.Matrix.type( m1 ) == "symbol", "matrix not of type 'symbol'" )
        local mtx = {}
        for i = 1,#m1 do
            mtx[i] = {}
            for j = 1,#m1[1] do
                mtx[i][j] = tonumber( loadstring( "return "..m1[i][j][1] )() )
            end
        end
        return setmetatable( mtx, HOUND.Matrix )
    end

    --////////////////////////--
    --// METATABLE HANDLING //--
    --////////////////////////--

    --// MetaTable
    -- as we declaired on top of the page
    -- local/shared metatable
    -- HOUND.Matrix

    -- note '...' is always faster than 'arg1,arg2,...' if it can be used

    -- Set add "+" behaviour
    HOUND.Matrix.__add = function( ... )
        return HOUND.Matrix.add( ... )
    end

    -- Set subtract "-" behaviour
    HOUND.Matrix.__sub = function( ... )
        return HOUND.Matrix.sub( ... )
    end

    -- Set multiply "*" behaviour
    HOUND.Matrix.__mul = function( m1,m2 )
        if getmetatable( m1 ) ~= HOUND.Matrix then
            return HOUND.Matrix.mulnum( m2,m1 )
        elseif getmetatable( m2 ) ~= HOUND.Matrix then
            return HOUND.Matrix.mulnum( m1,m2 )
        end
        return HOUND.Matrix.mul( m1,m2 )
    end

    -- Set division "/" behaviour
    HOUND.Matrix.__div = function( m1,m2 )
        if getmetatable( m1 ) ~= HOUND.Matrix then
            return HOUND.Matrix.mulnum( HOUND.Matrix.invert(m2),m1 )
        elseif getmetatable( m2 ) ~= HOUND.Matrix then
            return HOUND.Matrix.divnum( m1,m2 )
        end
        return HOUND.Matrix.div( m1,m2 )
    end

    -- Set unary minus "-" behavior
    HOUND.Matrix.__unm = function( mtx )
        return HOUND.Matrix.mulnum( mtx,-1 )
    end

    -- Set power "^" behaviour
    -- if opt is any integer number will do mtx^opt
    --   (returning nil if answer doesn't exist)
    -- if opt is 'T' then it will return the transpose matrix
    -- only for complex:
    --    if opt is '*' then it returns the complex conjugate matrix
        local option = {
            -- only for complex
            ["*"] = function( m1 ) return HOUND.Matrix.conjugate( m1 ) end,
            -- for both
            ["T"] = function( m1 ) return HOUND.Matrix.transpose( m1 ) end,
        }
    HOUND.Matrix.__pow = function( m1, opt )
        return option[opt] and option[opt]( m1 ) or HOUND.Matrix.pow( m1,opt )
    end

    -- Set equal "==" behaviour
    HOUND.Matrix.__eq = function( m1, m2 )
        -- check same type
        if HOUND.Matrix.type( m1 ) ~= HOUND.Matrix.type( m2 ) then
            return false
        end
        -- check same size
        if #m1 ~= #m2 or #m1[1] ~= #m2[1] then
            return false
        end
        -- check elements equal
        for i = 1,#m1 do
            for j = 1,#m1[1] do
                if m1[i][j] ~= m2[i][j] then
                    return false
                end
            end
        end
        return true
    end

    -- -- Set tostring "tostring( mtx )" behaviour
    -- matrix_meta.__tostring = function( ... )
    --     return HOUND.Matrix.tostring( ... )
    -- end

    -- -- set __call "mtx( [formatstr] )" behaviour, mtx [, formatstr]
    -- matrix_meta.__call = function( ... )
    --     HOUND.Matrix.print( ... )
    -- end

    --// __index handling
    -- HOUND.Matrix.__index = HOUND.Matrix
    -- for k,v in pairs( HOUND.Matrix ) do
    --     HOUND.Matrix.__index[k] = v
    -- end
end