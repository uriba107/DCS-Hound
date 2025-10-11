# HOUND ELINT System - Full API Documentation

This document provides comprehensive API documentation for the HOUND ELINT system, automatically generated from LDOC comments in the source code.

*Generated on: 2025-10-11 20:05:16*

## Overview

The HOUND ELINT (Electronic Intelligence) system is a comprehensive radar detection and tracking system for DCS World. It provides real-time detection, classification, and tracking of enemy radar emitters with advanced triangulation algorithms.

## Key Features

- **Real-time radar detection**: Detects active radar emitters in the battlefield
- **Advanced triangulation**: Uses multiple platform bearings for accurate position estimation
- **Automatic classification**: Identifies radar types and associated weapon systems
- **Multi-platform support**: Works with various ELINT-capable aircraft
- **Sector management**: Organizes contacts by geographical sectors
- **Communication integration**: Provides automated reports via radio and text-to-speech
- **Marker system**: Places visual markers on the F10 map

## Table of Contents

- [HOUND](#hound)
- [HOUND.Logger](#hound-logger)
- [HOUND.Mist](#hound-mist)
- [HOUND.Matrix](#hound-matrix)
- [HOUND.DB](#hound-db)
- [HOUND.DB](#hound-db)
- [HOUND.DB](#hound-db)
- [HOUND.DB](#hound-db)
- [HOUND.Config](#hound-config)
- [HOUND.Utils](#hound-utils)
- [HOUND.Utils](#hound-utils)
- [HOUND.Utils](#hound-utils)
- [HOUND.EventHandler](#hound-eventhandler)
- [HOUND.Contact.Base](#hound-contact-base)
- [HOUND.Contact.Estimator](#hound-contact-estimator)
- [HOUND.Contact.Datapoint](#hound-contact-datapoint)
- [HOUND.Contact.Emitter](#hound-contact-emitter)
- [HOUND.Contact.Emitter](#hound-contact-emitter)
- [HOUND.Contact.Site](#hound-contact-site)
- [HOUND.Contact.Site](#hound-contact-site)
- [HOUND.Comms.Manager](#hound-comms-manager)
- [HOUND.Comms.InformationSystem](#hound-comms-informationsystem)
- [HOUND.Comms.Controller](#hound-comms-controller)
- [HOUND.Comms.Notifier](#hound-comms-notifier)
- [HOUND.ElintWorker](#hound-elintworker)
- [HOUND.ElintWorker](#hound-elintworker)
- [HOUND.ContactManager](#hound-contactmanager)
- [HOUND.Sector](#hound-sector)
- [HOUND.Sector](#hound-sector)
- [HoundElint](#houndelint)
- [HoundElint](#houndelint)
- [HOUND](#hound)

## HOUND

Hound Elint system for DCS

**Author:** uri_ba
**Copyright:** uri_ba 2020-2024

**File:** `000 - HoundGlobals.lua`

### Instances

Hound Instances

### globals

Global functions

### Tables

### `HOUND`

Global settings and paramters

**Fields:**
- `VERSION`: Hound Version
- `DEBUG`: Hound will do extended debug output to log (for development)
- `ELLIPSE_PERCENTILE`: Defines the percentile of datapoints used to calculate uncertenty ellipse
- `DATAPOINTS_NUM`: Number of datapoints per platform a contact keeps (FIFO)
- `DATAPOINTS_INTERVAL`: Time between stored data points
- `CONTACT_TIMEOUT`: Timout for emitter to be silent before being dropped from contacts
- `MAX_ANGULAR_RES_DEG`: The maximum (worst) platform angular resolution acceptable
- `ANTENNA_FACTOR`: Global factor of antenna size (bigger antenna == better accuracy). Allows mission builder to quickly nerf or boost hound performace (default 1.0).
- `MGRS_PRECISION`: Number of digits in MGRS conversion
- `EXTENDED_INFO`: Hound will add more in depth uncertenty info to controller messages (default is true)
- `FORCE_MANAGE_MARKERS`: Force Hound to use internal counter for markIds (default is true).
- `USE_LEGACY_MARKERS`: Force Hound to use normal markers for radar positions (default is true)
- `MARKER_MIN_ALPHA`: Minimum opacity for area markers
- `MARKER_MAX_ALPHA`: Maximum opacity for area markers
- `MARKER_LINE_OPACITY`: Opacity of the line around the area markers
- `MARKER_TEXT_POINTER`: Char/string used as pointer on text markers
- `TTS_ENGINE`: Hound will use the table to determin TTS engine priority
- `MENU_PAGE_LENGTH`: Number of Items Hound will put in a menu before starting a new menu page
- `ENABLE_BETTER_SCORE`: If true, will use better scoring algorithm for contacts (default is true)
- `REF_DIST`: Reference distance for contact scoring. Used to calculate the weight of datap
- `ENABLE_WLS`: If true, will use WLS algorithm for contact scoring (currently not implemented, default is false)
- `ENABLE_KALMAN`: If true, will use Kalman filter for contact scoring (currently not implemented, default is false)
- `AUTO_ADD_PLATFORM_BY_PAYLOAD`: If true, will automatically add platforms that have ELINT payloads (currently, due to DCS limits, only works for units spawning with the required pods)

### `HOUND.MARKER`

Map Markers ENUM

**Fields:**
- `NONE`: no markers are drawn
- `SITE_ONLY`: only site markers are drawn
- `POINT`: only draw point marker for emitters
- `CIRCLE`: a circle of uncertenty will be drawn
- `DIAMOND`: a diamond will be drawn with 4 points representing uncertenty ellipse
- `OCTAGON`: ellipse will be drawn with 8 points (diamon with midpoints)
- `POLYGON`: ellipse will be drawn as a 16 sides polygon

### `HOUND.EVENTS`

Hound Events

**Fields:**
- `NO_CHANGE`: nothing changed in the object
- `HOUND_ENABLED`: Hound Event
- `HOUND_DISABLED`: Hound Event
- `PLATFORM_ADDED`: Hound Event
- `PLATFORM_REMOVED`: Hound Event
- `PLATFORM_DESTROYED`: Hound Event
- `RADAR_NEW`: Hound Event
- `RADAR_DETECTED`: Hound Event
- `RADAR_UPDATED`: Hound Event
- `RADAR_DESTROYED`: Hound Event
- `RADAR_ALIVE`: Hound Event
- `RADAR_ASLEEP`: Hound Event
- `SITE_NEW`: Hound Event
- `SITE_CREATED`: Hound Event
- `SITE_UPDATED`: Hound Event
- `SITE_CLASSIFIED`: Hound Event
- `SITE_REMOVED`: Hound Event
- `SITE_ALIVE`: Hound Event
- `SITE_ASLEEP`: Hound Event
- `SITE_LAUNCH`: Hound Event

### `EVENTS.EVENT`

Event structure

**Fields:**
- `id`: event enum from HOUND.EVENTS
- `houndId`: Hound Instace ID that emitted the event
- `coalition`: coalition ID of the Hound Instance that emitted the event
- `initiator`: DCS Unit or HoundContact Subclass that triggered the event
- `time`: of event

### `HOUND.INSTANCES`

Hound Instances every instance created will be added to this list with it's HoundId as key.

### `HOUND.Contact`

setup for inheritance classes

### Functions

### `HOUND.getInstance(InstanceId)`

Get instance get hound instance by ID

**Parameters:**
- `InstanceId` (type=number): instance ID to get

**Returns:**
- (Hound): Instance object or nil

### `HOUND.setMgrsPresicion(value)`

set default MGRS presicion for grid calls

**Parameters:**
- `(Int)` (value): Requested value. allowed values 1-5, default is 3

### `HOUND.showExtendedInfo(value)`

set detailed messages to include or exclude extended tracking data if true, will read and display extended ellipse info and tracking times. (default) if false, will skip that information. only the shortened info will be used

**Parameters:**
- `(Bool)` (value): Requested state

### `HOUND.addEventHandler(handler)`

register new event handler (global)

**Parameters:**
- `handler` (handler): to register

**See also:** HOUND.EVENTS

### `HOUND.removeEventHandler(handler)`

deregister event handler (global)

**Parameters:**
- `handler` (handler): to remove

**See also:** HOUND.EVENTS

### `HOUND.inheritsFrom(baseClass)`

helper code for class inheritance

**Parameters:**
- `Base` (baseClass): class to inherit from

*Note: This is a local function*

### `new_class:class()`

Return the class object of the instance

### `new_class:superClass()`

Return the super class object of the instance

### `new_class:isa(theClass)`

Return true if the caller is an instance of theClass

### `HOUND.Length(T)`

get Length of a table

**Parameters:**
- `T` (any): table

**Returns:**
- (length): of T

*Note: This is a local function*

### `HOUND.setContains(set, key)`

check if set contains a provided key (case sensitive)

**Parameters:**
- `Hash` (set): table to check
- `to` (key): check

**Returns:**
- (type=bool): True if key exists in set

*Note: This is a local function*

### `HOUND.setContainsValue(set, value)`

check if table contains a provided

**Parameters:**
- `Table` (set): to check
- `Value` (value): to check

**Returns:**
- (type=bool): True if value exists in set

*Note: This is a local function*

### `HOUND.setIntersection(a, b)`

return set intersection product

**Parameters:**
- `a` (any): Table
- `b` (any): Table

**Returns:**
- (Tabl): e

*Note: This is a local function*

### `HOUND.Gaussian(mean, sigma)`

return Gaussian random number

**Parameters:**
- `Mean` (mean): value (i.e center of the gausssian curve)
- `amount` (sigma): of variance in the random value

**Returns:**
- (random): number in gaussian space

*Note: This is a local function*

### `HOUND.reverseLookup(tbl, value)`

reverse table lookup

**Parameters:**
- `l` (#tb): table
- `to` (value): search

**Returns:**
- (the): key wher value was found

*Note: This is a local function*

### `string.split(str, delim)`

Split String on delimited

**Parameters:**
- `Input` (str): string
- `delim` (opt): Delimited (default is space)

**Returns:**
- (table): of substrings

*Note: This is a local function*

---

## HOUND.Logger

HOUND.Logger Hound logging function - Based on VEAF work

**File:** `010 - HoundLogger.lua`

### Tables

### `HOUND.Logger`

Hound Logger decleration

### Functions

### `HOUND.Logger.setBaseLevel(level)`

function HOUND.Logger.StopWatch:Stop() if not HOUND.DEBUG then return nil end if os == nil then return nil end local stoptime = os.clock() local str = "[ StopWatch ] " if self.name ~= nil then str = str .. self.name .. " - " end str = str .. stoptime - self.starttime .." ms" HOUND.Logger.debug(str) end

---

## HOUND.Mist

HOUND.Mist This class holds a subset function from MIST framework required by Hound. They are included in Hound to eliminate external dependencies Original code, with more extensive functionality can be found at https://github.com/mrSkortch/MissionScriptingTools Code was taken from Mist 4.5.126

**File:** `020 - HoundMist.lua`

### HOUND.Mist.vec

3D Vector functions

### HOUND.Mist.utils

Utility functions. E.g. conversions between units etc.

### Functions

### `HOUND.Mist.getAvgPos(unitNames)`

Gets the average position of a group of units (by name)

### `HOUND.Mist.vec.add(vec1, vec2)`

Vector addition.

### `HOUND.Mist.vec.sub(vec1, vec2)`

Vector substraction.

### `HOUND.Mist.vec.scalarMult(vec, mult)`

Vector scalar multiplication.

### `HOUND.Mist.vec.dp(vec1, vec2)`

Vector dot product.

### `HOUND.Mist.vec.cp(vec1, vec2)`

Vector cross product.

### `HOUND.Mist.vec.mag(vec)`

Vector magnitude

### `HOUND.Mist.vec.getUnitVec(vec)`

Unit vector

### `HOUND.Mist.vec.rotateVec2(vec2, theta)`

Rotate vector.

**Returns:**
- (Vec2): rotated vector.

### `HOUND.Mist.utils.toDegree(angle)`

Converts angle in radians to degrees.

**Parameters:**
- `angle` (angle): in radians

**Returns:**
- (angle): in degrees

### `HOUND.Mist.utils.toRadian(angle)`

Converts angle in degrees to radians.

**Parameters:**
- `angle` (angle): in degrees

**Returns:**
- (angle): in degrees

### `HOUND.Mist.utils.metersToNM(meters)`

Converts meters to nautical miles.

**Parameters:**
- `distance` (meters): in meters

**Returns:**
- (distance): in nautical miles

### `HOUND.Mist.utils.metersToFeet(meters)`

Converts meters to feet.

**Parameters:**
- `distance` (meters): in meters

**Returns:**
- (distance): in feet

### `HOUND.Mist.utils.NMToMeters(nm)`

Converts nautical miles to meters.

**Parameters:**
- `distance` (nm): in nautical miles

**Returns:**
- (distance): in meters

### `HOUND.Mist.utils.feetToMeters(feet)`

Converts feet to meters.

**Parameters:**
- `distance` (feet): in feet

**Returns:**
- (distance): in meters

### `HOUND.Mist.utils.makeVec2(vec)`

Converts a Vec3 to a Vec2.

**Returns:**
- (vector): converted to Vec2

### `HOUND.Mist.utils.makeVec3(vec, y)`

Converts a Vec2 to a Vec3.

**Parameters:**
- `optional` (y): new y axis (altitude) value. If omitted it's 0.

### `HOUND.Mist.utils.makeVec3GL(vec, offset)`

Converts a Vec2 to a Vec3 using ground level as altitude. The ground level at the specific point is used as altitude (y-axis) for the new vector. Optionally a offset can be specified.

**Parameters:**
- `offset` (opt): offset to be applied to the ground level

**Returns:**
- (new): 3D vector

### `HOUND.Mist.utils.getDir(vec, point)`

Returns heading-error corrected direction. True-north corrected direction from point along vector vec.

**Returns:**
- (heading-error): corrected direction from point.

### `HOUND.Mist.utils.get2DDist(point1, point2)`

Returns distance in meters between two points.

### `HOUND.Mist.utils.get3DDist(point1, point2)`

Returns distance in meters between two points in 3D space.

### `HOUND.Mist.utils.deepCopy(object)`

Creates a deep copy of a object. Usually this object is a table. See also: from http://lua-users.org/wiki/CopyTable

**Parameters:**
- `object` (object): to copy

**Returns:**
- (copy): of object

### `HOUND.Mist.utils.round(num, idp)`

Simple rounding function. From http://lua-users.org/wiki/SimpleRound use negative idp for rounding ahead of decimal place, positive for rounding after decimal place

### `HOUND.Mist.utils.basicSerialize(var)`

Serializes the give variable to a string. borrowed from slmod

**Parameters:**
- `variable` (var): to serialize

### `HOUND.Mist.utils.tableShow(tbl, loc, indent, tableshow_tbls)`

Returns table in a easy readable string representation. this function is not meant for serialization because it uses newlines for better readability.

**Parameters:**
- `table` (tbl): to show

**Returns:**
- (human): readable string representation of given table

---

## HOUND.Matrix

HOUND.Matrix This class holds matrix math function code is Directly taken from https://github.com/davidm/lua-matrix

**File:** `021 - HoundMatrix.lua`

### Functions

### `HOUND.Matrix:new(rows, columns, value)`

Get new matrix object if rows is a table then sets rows as matrix if rows is a table of structure {1,2,3} then it sets it as a vector matrix if rows and columns are given and are numbers, returns a matrix with size rowsxcolumns if rows is given as number and columns is "I", will return an identity matrix of size rowsxrows if value is given then returns a matrix with given size and all values set to value

**Parameters:**
- `number` (rows): or rows or table to convert to matrix object
- `number` (columns): of columns or "I" to create identity matrix
- `value` (value): to give cells of matrix

**Returns:**
- (matrix): object

### `HOUND.Matrix.add(m1, m2)`

add matrices

**Parameters:**
- `1` (m): Matrix
- `2` (m): Matrix

**Returns:**
- (Matrix,): sum of m1 and m2

*Note: This is a local function*

### `HOUND.Matrix.sub(m1, m2)`

Subtract two matrices

**Parameters:**
- `1` (m): Matrix
- `2` (m): Matrix

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.mul(m1, m2)`

Multiply two matrices m1 columns must be equal to m2 rows

**Parameters:**
- `1` (m): Matrix
- `2` (m): Matrix

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.div(m1, m2)`

Divide two matrices m1 columns must be equal to m2 rows m2 must be square, to be inverted, if that fails returns the rank of m2 as second argument

**Parameters:**
- `1` (m): Matrix
- `2` (m): Matrix

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.mulnum(m1, num)`

// HOUND.Matrix.mulnum ( m1, num ) Multiply matrix with a number num may be of type 'number' or 'complex number' strings get converted to complex number, if that fails then to symbol

**Parameters:**
- `1` (m): Matrix
- `]` (type=number): num

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.divnum(m1, num)`

Divide matrix by a number num may be of type 'number' or 'complex number' strings get converted to complex number, if that fails then to symbol

**Parameters:**
- `1` (m): Matrix
- `]` (type=number): num

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.pow(m1, num)`

Power of matrix; mtx^(num) num is an integer and may be negative m1 has to be square if num is negative and inverting m1 fails returns the rank of matrix m1 as second argument

**Parameters:**
- `1` (m): Matrix
- `]` (type=number): num

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.det(m1)`

Calculate the determinant of a matrix m1 needs to be square Can calc the det for symbolic matrices up to 3x3 too The function to calculate matrices bigger 3x3 is quite fast and for matrices of medium size ~(100x100) and average values quite accurate here we try to get the nearest element to |1|, (smallest pivot element) os that usually we have |mtx[i][j]/subdet| > 1 or mtx[i][j]; with complex matrices we use the complex.abs function to check if it is bigger or smaller

**Parameters:**
- `1` (m): Matrix

**Returns:**
- (Matri): x

*Note: This is a local function*

### `HOUND.Matrix.dogauss(mtx)`

note: in --// ... //-- we have a way that does no divison, however with big number and matrices we get problems since we do no reducing

### `HOUND.Matrix.invert(m1)`

// HOUND.Matrix.invert ( m1 ) Get the inverted matrix or m1 matrix must be square and not singular on success: returns inverted matrix on failure: returns nil,'rank of matrix'

**Parameters:**
- `1` (m): Matrix

**Returns:**
- (Matri): x

### `get_abs_avg(m1, m2)`

// HOUND.Matrix.sqrt ( m1 [,iters] ) calculate the square root of a matrix using "Denman Beavers square root iteration" condition: matrix rows == matrix columns; must have a invers matrix and a square root if called without additional arguments, the function finds the first nearest square root to input matrix, there are others but the error between them is very small if called with agument iters, the function will return the matrix by number of iterations the script returns: as first argument, matrix^.5 as second argument, matrix^-.5 as third argument, the average error between (matrix^.5)^2-inputmatrix you have to determin for yourself if the result is sufficent enough for you local average error

### `HOUND.Matrix.sqrt(m1, iters)`

square root function

### `HOUND.Matrix.root(m1, root, iters)`

// HOUND.Matrix.root ( m1, root [,iters] ) calculate any root of a matrix source: http://www.dm.unipi.it/~cortona04/slides/bruno.pdf m1 and root have to be given;(m1 = matrix, root = number) conditions same as HOUND.Matrix.sqrt returns same values as HOUND.Matrix.sqrt

### `HOUND.Matrix.normf(mtx)`

// HOUND.Matrix.normf ( mtx ) calculates the Frobenius norm of the matrix. ||mtx||_F = sqrt(SUM_{i,j} |a_{i,j}|^2) http://en.wikipedia.org/wiki/Frobenius_norm#Frobenius_norm

### `HOUND.Matrix.normmax(mtx)`

// HOUND.Matrix.normmax ( mtx ) calculates the max norm of the matrix. ||mtx||_{max} = max{|a_{i,j}|} Does not work with symbolic matrices http://en.wikipedia.org/wiki/Frobenius_norm#Max_norm

### `HOUND.Matrix.type(mtx)`

// HOUND.Matrix.type ( mtx ) get type of matrix, normal/complex/symbol or tensor

### `HOUND.Matrix.copy(m1)`

// HOUND.Matrix.copy ( m1 ) Copy a matrix simple copy, one can write other functions oneself

### `HOUND.Matrix.transpose(m1)`

// HOUND.Matrix.transpose ( m1 ) Transpose a matrix switch rows and columns

### `HOUND.Matrix.subm(m1, i1, j1, i2, j2)`

// HOUND.Matrix.subm ( m1, i1, j1, i2, j2 ) Submatrix out of a matrix input: i1,j1,i2,j2 i1,j1 are the start element i2,j2 are the end element condition: i1,j1,i2,j2 are elements of the matrix

### `HOUND.Matrix.concath(m1, m2)`

// HOUND.Matrix.concath( m1, m2 ) Concatenate two matrices, horizontal will return m1m2; rows have to be the same e.g.: #m1 == #m2

### `HOUND.Matrix.concatv(m1, m2)`

// HOUND.Matrix.concatv ( m1, m2 ) Concatenate two matrices, vertical will return	m1 m2 columns have to be the same; e.g.: #m1[1] == #m2[1]

### `HOUND.Matrix.rotl(m1)`

// matrix.rotl ( m1 ) Rotate Left, 90 degrees

### `HOUND.Matrix.rotr(m1)`

// matrix.rotr ( m1 ) Rotate Right, 90 degrees

### `HOUND.Matrix.tostring(mtx, formatstr)`

// matrix.tostring ( mtx, formatstr ) tostring function

### `HOUND.Matrix.latex(mtx, align)`

// matrix.latex ( mtx [, align] ) LaTeX output

### `HOUND.Matrix.rows(mtx)`

// matrix.rows ( mtx ) return number of rows

### `HOUND.Matrix.columns(mtx)`

// matrix.columns ( mtx ) return number of columns

### `HOUND.Matrix.size(mtx)`

//  matrix.size ( mtx ) get matrix size as string rows,columns

### `HOUND.Matrix.getelement(mtx, i, j)`

// HOUND.Matrix.getelement ( mtx, i, j ) return specific element ( row,column ) returns element on success and nil on failure

### `HOUND.Matrix.setelement(mtx, i, j, value)`

// HOUND.Matrix.setelement( mtx, i, j, value ) set an element ( i, j, value ) returns 1 on success and nil on failure

### `HOUND.Matrix.ipairs(mtx)`

// HOUND.Matrix.ipairs ( mtx ) iteration, same for complex

### `HOUND.Matrix.scalar(m1, m2)`

// HOUND.Matrix.scalar ( m1, m2 ) returns the Scalar Product of two 3x1 matrices (vectors)

### `HOUND.Matrix.cross(m1, m2)`

// HOUND.Matrix.cross ( m1, m2 ) returns the Cross Product of two 3x1 matrices (vectors)

### `HOUND.Matrix.len(m1)`

// HOUND.Matrix.len ( m1 ) returns the Length of a 3x1 matrix (vector)

### `HOUND.Matrix.replace(m1, func, ...)`

// HOUND.Matrix.replace (mtx, func, ...) for each element e in the matrix mtx, replace it with func(mtx, ...).

### `HOUND.Matrix.elementstostrings(mtx)`

// HOUND.Matrix.remcomplex ( mtx ) set the matrix elements to strings IMPROVE: tostring v.s. tostringelements confusing

### `HOUND.Matrix.solve(m1)`

// HOUND.Matrix.solve ( m1 ) solve; tries to solve a symbolic matrix to a number

---

## HOUND.DB

Hound databases

**File:** `100 - HoundDBs.lua`

### Tables

### `HOUND.DB.PHONETICS`

Enums for Phonetic AlphaBet

**Fields:**
- `Characters`: Phonetic representation

### `HOUND.DB.useDMM`

Units that use DMM format

**Fields:**
- `UnitType`: Bool Value

### `HOUND.DB.useMGRS`

Units that prefer MGRS format (not in use)

**Fields:**
- `UnitType`: Bool value

### `HOUND.DB.Bands`

Band vs wavelength

**Fields:**
- `Band`: wavelength in meters of the highest frequency in the range and the diff from the lowest frequency

### `HOUND.DB.RadarType`

Radar types ENUM

**Fields:**
- `Radar`: type in hex

### `HOUND.DB.CALLSIGNS`

Hound callsigns

**Fields:**
- `NATO`: list of RC-135 callsigns (source: https://henney.com/chm/callsign.htm)
- `GENERIC`: list of generic callsigns for hound, mostly vacuum cleaners and fictional detectives

### `HOUND.DB.HumanUnits`

Hound Human Units automatically generate list containing mist style Unit entries for human flights

---

## HOUND.DB

Hound databases (Units DCS)

**File:** `101 - HoundDBs_UnitDcs.lua`

### Tables

### `HOUND.DB.Radars`

Radar database ['p-19 s-125 sr'] = { ['Name'] = "Flat Face", ['Assigned'] = {"SA-2","SA-3"}, ['Role'] = {HOUND.DB.RadarType.SEARCH}, ['Band'] = { [true] = HOUND.DB.Bands.C, [false] = HOUND.DB.Bands.C }, ['Primary'] = false }

**Fields:**
- `@string`: Name NATO Name
- `#table`: Assigned Which Battery this radar can belong to
- `#table`: Role Role of radar in battery
- `#table`: Band Radio Band the radar operates in true is when tracking target
- `#bool`: Primary set to True if this is a primary radar for site (usually FCR)

### `HOUND.DB.Platform`

Valid platform parameters

**Fields:**
- `UnitTypeName`: contains table of properties

---

## HOUND.DB

Hound databases (Units modded)

**File:** `102 - HoundDBs_UnitMods.lua`

---

## HOUND.DB

Hound databases (functions)

**File:** `103 - HoundDBs_func.lua`

### Functions

DB functions

### Functions

### `HOUND.DB.getRadarData(typeName)`

Get radar object Data

**Parameters:**
- `DCS` (typeName): Tye name

**Returns:**
- (Radar): information table

### `HOUND.DB.isValidPlatform(candidate, PayloadAdded)`

check if canidate Object is a valid platform

**Parameters:**
- `DCS` (candidate): Object (Unit or Static Object)
- `name` (PayloadAdded[?type=string): of payload added to unit (optional)

**Returns:**
- (type=bool): True if object is valid platform

### `HOUND.DB.getPlatformData(DcsObject)`

Get Platform data

**Parameters:**
- `platform` (DcsObject): unit

**Returns:**
- (platform): data

*Note: This is a local function*

### `HOUND.DB.getDefraction(wavelength, antenna_size)`

Get defraction for band and effective antenna size return angular resolution

**Parameters:**
- `Radar` (wavelength): transmission band (A-L) as defined in HOUND.DB
- `Effective` (antenna_size): antenna size for platform as defined in HOUND.DB

**Returns:**
- (angular): resolution in Radians for wavelength and Antenna combo

*Note: This is a local function*

### `HOUND.DB.getApertureSize(DcsObject)`

get Effective Aperture size for platform

**Parameters:**
- `Unit` (DcsObject): requested (used as platform)

**Returns:**
- (Effective): aperture size in meters

*Note: This is a local function*

### `HOUND.DB.getEmitterBand(DcsUnit)`

Get emitter Band

**Parameters:**
- `Radar` (DcsUnit): unit

**Returns:**
- (Char): radar band

*Note: This is a local function*

### `HOUND.DB.getEmitterFrequencies(bands, factor)`

Generate uniqe radar frequencies for contact

**Parameters:**
- `]` (type=tab): bands
- `factor` (type=?number): between 0 and 1 where between high and low freqs (for testing)

**Returns:**
- (table): containig wavelengths in meters for the radar

*Note: This is a local function*

### `HOUND.DB.getSensorPrecision(platform, emitterFreq)`

Elint Function - Get sensor precision

**Parameters:**
- `Instance` (platform): of DCS Unit which is the detecting platform
- `Radar` (emitterFreq): wavelength (frequency) of radar (in meters) or DCS Unit

**Returns:**
- (angular): resolution in Radians of platform against specific Radar frequency

### `HOUND.DB.updateHumanDb(coalitionId)`

populate the HOUND.DB.HumanUnits db

**Parameters:**
- `coalitionId` (type=?number): if provided, DB will be updated to specificd coalition only

### `HOUND.DB.cleanHumanDb(coalitionId)`

cleanup the HOUND.DB.HumanUnits db from disconnected units.

**Parameters:**
- `coalitionId` (type=?number): if provided, DB will be updated to specificd coalition only

### `HOUND.DB.generateMistDbEntry(DcsUnit)`

create a partial "humanByName" mist record from unit use subset of mist format https://github.com/mrSkortch/MissionScriptingTools/blob/master/Example%20DBs/mist_DBs_humansByName.lua @param DcsUnit @return table

---

## HOUND.Config

HOUND.Config Hound config singleton

**File:** `110 - HoundConfig.lua`

### Tables

### `HOUND.Config`

### Functions

### `HOUND.Config.get(HoundInstanceId)`

return config for specific Hound instance

**Parameters:**
- `Hound` (HoundInstanceId): instance ID

**Returns:**
- (config): map for specific hound instace

*Part of: HOUND.Config*

---

## HOUND.Utils

HOUND.Utils This class holds generic function used by all of Hound Components

**File:** `200 - HoundUtils.lua`

### general

General functions

### Tables

### `HOUND.Utils`

HOUND.Utils decleration

**Fields:**
- `Mapping`: Extrapulation functions
- `Geo`: Geographic functions
- `Text`: Text functions
- `Elint`: Elint functions
- `Sort`: Sort funtions
- `Filter`: Filter functions
- `ReportId`: intrnal ATIS numerator
- `_MarkId`: internal markId Counter
- `_HoundId`: internal HoundId counter

### Functions

### `HOUND.Utils.getHoundId()`

get next Hound Instance Id

**Returns:**
- (#number): Next HoundId

### `HOUND.Utils.getMarkId()`

Get next Markpoint Id (Depricated) return the next available MarkId

**Returns:**
- (Next): MarkId

**See also:** HOUND.Utils.Marker.getId

*Note: This is a local function*

### `HOUND.Utils.setInitialMarkId(startId)`

Set New initial marker Id (DEPRICATED)

**Parameters:**
- `Number` (startId): to start counting from

**Returns:**
- (type=Bool): True if initial ID was updated

**See also:** HOUND.Utils.Marker.setInitialId

*Note: This is a local function*

---

## HOUND.Utils

HOUND.Utils This class holds generic function used by all of Hound Components

**File:** `201 - HoundUtils_TTS.lua`

### TTS

TTS Functions

### Functions

### `HOUND.Utils.TTS.isAvailable()`

Check if TTS agent is available (private)

**Returns:**
- (type=Bool): True if TTS is available

### `HOUND.Utils.TTS.getdefaultModulation(freq)`

Return default Modulation based on frequency

**Parameters:**
- `The` (freq): frequency in Mhz, Hz or table of frequencies

**Returns:**
- (Modulation): string "AM" or "FM"

### `HOUND.Utils.TTS.Transmit(msg, coalitionID, args, transmitterPos)`

Transmit message using STTS (private)

**Parameters:**
- `The` (msg): message to transmit
- `Coalition` (coalitionID): to recive transmission
- `STTS` (args): settings in hash table (minimum required is {freq=})
- `transmitterPos` (opt): DCS Position point for transmitter

**Returns:**
- (STTS.TextToSpeech): return value recived from STTS, currently estimated speechTime

### `HOUND.Utils.TTS.TransmitSTTS(msg, coalitionID, args, transmitterPos)`

Transmit message using STTS

**Parameters:**
- `The` (msg): message to transmit
- `Coalition` (coalitionID): to recive transmission
- `STTS` (args): settings in hash table (minimum required is {freq=})
- `transmitterPos` (opt): DCS Position point for transmitter

**Returns:**
- (currently): estimated speechTime

*Note: This is a local function*

### `HOUND.Utils.TTS.TransmitGRPC(msg, coalitionID, args, transmitterPos)`

Transmit message using gRPC.tts

**Parameters:**
- `The` (msg): message to transmit
- `Coalition` (coalitionID): to recive transmission
- `STTS` (args): settings in hash table (minimum required is {freq=})
- `transmitterPos` (opt): DCS Position point for transmitter

**Returns:**
- (currently): estimated speechTime

*Note: This is a local function*

### `HOUND.Utils.TTS.getTtsTime(timestamp)`

returns current DCS time in military time string for TTS

**Parameters:**
- `timestamp` (opt): DCS time in seconds (timer.getAbsTime()) - if not arg provided will return for current game time

**Returns:**
- (timeString): e.g. "14 30 local", "08 hundred local"

### `HOUND.Utils.TTS.getVerbalConfidenceLevel(confidenceRadius)`

return verbal accuracy description in 500 meters interval

**Parameters:**
- `s` (confidenceRadiu): meters

**Returns:**
- ((string)): Description of accuracy e.g "Very High","High","Low"...

### `HOUND.Utils.TTS.getVerbalContactAge(timestamp, isSimple, NATO)`

Get Verbal description of contact age has multiple "modes of operation"

**Parameters:**
- `dcs` (timestamp): time in seconds of last time a target was seen
- `isSimple` (opt): (bool) switch between output modes. true: "Active", "recent"... False: "3 seconds","5 minutes"
- `NATO` (opt): (bool) requires isSimple=true, will return only "Active" or "Awake" as per NATO Lowdown

**Returns:**
- (string): of time passed based on selected flags.

### `HOUND.Utils.TTS.DecToDMS(cood, minDec, padDeg)`

TTS Function - convert Decimal degrees to DMS/DM.M speech string

**Parameters:**
- `(float)` (cood): input coordinate arg in decimal deg (e.g "32.443232", "-144.3432")
- `minDec` (opt): (bool) if true output will return in DM.M else in DMS
- `padDeg` (opt): (Bool) if true degrees will be zero padded. (32 -> 032 )

**Returns:**
- (TTS): ready stings. e.g "32 degrees, 15 mintes, 6 seconds", "32 degrees, 15.100 seconds"

### `HOUND.Utils.TTS.getVerbalLL(lat, lon, minDec)`

convert LL to TTS string eg. "North, 33 degrees, 15 minutes, 12 seconds, East, 42 degrees, 10 minutes, 45 seconds "

**Parameters:**
- `Latitude` (lat): in decimal degrees ("32.343","-14.44333")
- `Longitude` (lon): in decimal degrees ("42.343","-144.432")
- `minDec` (opt): (bool) if true, function will return LL in DM.M format

**Returns:**
- (LL): string.

### `HOUND.Utils.TTS.toPhonetic(str)`

Convert string to phonetic text

**Parameters:**
- `String` (str): to convert

**Returns:**
- (string): broken up to phonetics

**Usage:**
```lua
HOUND.Utils.TTS.toPhonetic("B29") will return "Bravo Two Niner"
```

### `HOUND.Utils.TTS.getReadTime(length, speed, googleTTS)`

get estimated message read time returns estimated time in seconds STTS will need to read a message

**Parameters:**
- `length` (length): of string to estimate (also except the string itself)
- `speed` (opt): speed setting for reading them message
- `googleTTS` (opt): Bool, if true calculation will be done for GoogleTTS engine

**Returns:**
- (estimated): message read time in seconds

### `HOUND.Utils.TTS.simplfyDistance(distanceM)`

simplify distance below 1km function will return number in meters eg. 140m => 150m, 520m => 500m, 4539m => 4.5km

**Parameters:**
- `Distance` (distanceM): in meters to simplify

**Returns:**
- (Simplified): distance

---

## HOUND.Utils

HOUND.Utils This class holds generic function used by all of Hound Components

**File:** `202 - HoundUtils_Adv.lua`

### Polygon

Polygon functions

### Clusters

Clustering algorithems (for future use)

### Functions

### `HOUND.Utils.Polygon.threatOnSector(polygon, point, radius)`

Check if polygon is under threat of SAM

**Parameters:**
- `Table` (polygon): of point reprasenting a polygon
- `DCS` (point): position (x,z)
- `Radius` (radius): in Meters around point to test

**Returns:**
- (type=Bool): True if point is in polygon
- (type=Bool): True if radius around point intersects polygon

### `HOUND.Utils.Polygon.filterPointsByPolygon(points, polygon)`

Filter out points not in polygon

**Parameters:**
- `Points` (points): to filter
- `-` (polygon): enclosing polygon to filter by

**Returns:**
- (points): from original set which are inside polygon.

### `HOUND.Utils.Polygon.clipPolygons(subjectPolygon, clipPolygon)`

calculate cliping of polygons <a href="https://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping#Lua">Sutherland-Hodgman polygon clipping</a>

**Parameters:**
- `List` (subjectPolygon): of points of first polygon
- `list` (clipPolygon): of points of second polygon

**Returns:**
- (List): of points of the clipped polygon or nil if not clipping found

### `HOUND.Utils.Polygon.giftWrap(points)`

Gift wrapping algorithem Returns the convex hull (using <a href="http://en.wikipedia.org/wiki/Gift_wrapping_algorithm">Jarvis' Gift wrapping algorithm</a>).

**Parameters:**
- `array` (points): of DCS points ({x=&ltvalue&gt,z=&ltvalue&gt})

**Returns:**
- (the): convex hull as an array of points

### `signedArea(p, q, r)`

Calculates the signed area

### `isCCW(p, q, r)`

Checks if points p, q, r are oriented counter-clockwise

### `HOUND.Utils.Polygon.circumcirclePoints(points)`

calculate Smallest circle around point cloud Welzel algorithm for <a href="https://en.wikipedia.org/wiki/Smallest-circle_problem">Smallest-circle problem</a> Implementation taken from <a href="https://github.com/rowanwins/smallest-enclosing-circle/blob/master/src/main.js">github/rowins</a>

**Parameters:**
- `Table` (points): containing cloud points

**Returns:**
- (Circle): {x=&ltCenter X&gt,z=&ltCenter Z&gt, y=&ltLand height at XZ&gt,r=&ltradius in meters&gt}

### `HOUND.Utils.Polygon.getArea(polygon)`

return the area of a convex polygon

**Parameters:**
- `list` (polygon): of DCS points

**Returns:**
- (area): of polygon

### `HOUND.Utils.Polygon.clipOrHull(polyA, polyB)`

clip or hull two polygons

**Parameters:**
- `A` (poly): polygon
- `B` (poly): polygon

**Returns:**
- (Polygon): which is clip or convexHull of the two input polygons

### `HOUND.Utils.Polygon.azMinMax(poly, refPos)`

find min/max azimuth

**Parameters:**
- `y` (pol): Polygon
- `DCS` (refPos): point to calculate from

**Returns:**
- (deltaMinMax): delta angle between the two extream points
- (minAz): (rad)
- (maxAz): (rad)

### `HOUND.Utils.Cluster.gaussianKernel(value, bandwidth)`

Get gaussian weight

**Parameters:**
- `input` (value): to evaluate
- `Standard` (bandwidth): diviation for weight calculation

### `HOUND.Utils.Cluster.stdDev()`

Calculate running std dev https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_online_algorithm

**Returns:**
- (std): calc instance

### `HOUND.Utils.Cluster.weightedMean(origPoints, initPos, threashold, maxIttr)`

find the weighted mean of a points cluster (meanShift)

**Parameters:**
- `DCS` (origPoints): points cluster
- `initPos` (opt): externally provided initial mean (DCS Point)
- `threashold` (opt): distance in meters below with solution is considered converged (default 1m)
- `maxIttr` (opt): Max itterations from converging solution (default 100)

**Returns:**
- (DCS): point of the cluster weighted mean

### `HOUND.Utils.Cluster.getDeltaSubsetPercent(Table, referencePos, NthPercentile, returnRelative)`

Get a list of Nth elements centerd around a position from table of positions.

**Parameters:**
- `A` (Table): List of positions
- `Point` (referencePos): in relations to all points are evaluated
- `Percintile` (NthPercentile): of which Datapoints are taken (0.6=60%)
- `If` (returnRelative): true returning array will contain relative positions to referencePos

**Returns:**
- (Lis): t

### `HOUND.Utils.Cluster.WeightedCentroid(PosList)`

Calculate weighted least squares estimate from a list of positions with scores

**Parameters:**
- `List` (PosList): of positions with scores

**Returns:**
- (Weighted): average position estimate {x,y,z}

### `HOUND.Utils.Cluster.WLS_GDOP(measurements, initial_guess, max_iter, tol)`

Weighted Least Squares with GDOP-based uncertainty ellipse Calculates position estimate using weighted least squares with geometric dilution of precision

**Parameters:**
- `Table` (measurements): of measurements containing azimuth angles and platform positions
- `Initial` (initial_guess): position estimate {x,z}
- `max_iter` (opt=10): Maximum number of iterations for convergence
- `tol` (opt=0.001): Convergence tolerance in meters

**Returns:**
- (solution): Position estimate {x,y,z}, uncertenty_data Uncertainty ellipse parameters

---

## HOUND.EventHandler

HOUND.EventHandler class to managing Hound Specific event handlers

**File:** `210 - HoundEventHandler.lua`

### Tables

### `HOUND.EventHandler`

HOUND.EventHandler Decleration

**Type:** HOUND.EventHandler

### Functions

### `HOUND.EventHandler.addEventHandler(handler)`

register new event handler

**Parameters:**
- `handler` (handler): to register

### `HOUND.EventHandler.removeEventHandler(handler)`

deregister event handler

**Parameters:**
- `handler` (handler): to remove

### `HOUND.EventHandler.addInternalEventHandler(handler)`

register new internal event handler

**Parameters:**
- `handler` (handler): to register

*Note: This is a local function*

### `HOUND.EventHandler.removeInternalEventHandler(handler)`

deregister internal event handler

**Parameters:**
- `handler` (handler): to register

*Note: This is a local function*

### `HOUND.EventHandler.on(eventType, handler)`

register using on pattern

**Parameters:**
- `event` (eventType): to register
- `handler` (handler): to register

### `HOUND.EventHandler.onHoundEvent(event)`

Execute event on all registeres subscribers

### `HOUND.EventHandler.publishEvent(event)`

publish event to subscribers

*Note: This is a local function*

### `HOUND.EventHandler.getIdx()`

get next event idx

*Note: This is a local function*

---

## HOUND.Contact.Base

HOUND.Contact.Base Contact class. containing related functions

**File:** `300 - HoundContactBase.lua`

### sectors

Sector Mangment

### markers

Marker managment

### Tables

### `HOUND.Contact.Base`

HOUND.Contact decleration Contact class. containing related functions

**Type:** HOUND.Contact.Base

### Functions

### `HOUND.Contact.Base:New(DcsObject, HoundCoalition)`

create new HOUND.Contact instance

**Parameters:**
- `emitter` (DcsObject): DCS Unit
- `coalition` (HoundCoalition): Id of Hound Instace

**Returns:**
- (HOUND.Contact): instance

### `HOUND.Contact.Base:destroy()`

Destructor function

### `HOUND.Contact.Base:getDcsGroupName()`

Get Contact Group Name

**Returns:**
- (Strin): g

### `HOUND.Contact.Base:getDcsName()`

Get the DCS unit name

**Returns:**
- (Strin): g

### `HOUND.Contact.Base:getDcsObject()`

Get the underlying DCS Object

**Returns:**
- (DCS): Unit or DCS staticObject

### `HOUND.Contact.Base:getLastSeen()`

Get last seen in seconds

**Returns:**
- (number): in seconds since contact was last seen

### `HOUND.Contact.Base:getObject()`

get DCS Object instane assoiciated with contact

**Returns:**
- (DCS): object (unit or group)

### `HOUND.Contact.Base:hasPos()`

check if contact has estimated position

**Returns:**
- (type=Bool): True if contact has estimated position

### `HOUND.Contact.Base:getMaxWeaponsRange()`

get max weapons range

**Returns:**
- (Number): max weapon range of contact

### `HOUND.Contact.Base:getRadarDetectionRange()`

get max detection range

**Returns:**
- (Number): max detection range of contact

### `HOUND.Contact.Base:getTypeAssigned()`

get type assinged string

**Returns:**
- (strin): g

### `HOUND.Contact.Base:getDesignation(NATO)`

get designation

**Parameters:**
- `NATO` (type=Bool): return nato designation

**Returns:**
- (Type=String): designation

### `HOUND.Contact.Base:getNatoDesignation()`

get NATO designation

**Returns:**
- (strin): g

### `HOUND.Contact.Base:isActive()`

Check if contact is Active

**Returns:**
- (type=Bool): True if seen in the last 15 seconds

### `HOUND.Contact.Base:isRecent()`

check if contact is recent

**Returns:**
- (type=Bool): True if seen in the last 2 minutes

### `HOUND.Contact.Base:isAccurate()`

check if contact position is accurate

**Returns:**
- (type=bool): - True target is pre briefed

### `HOUND.Contact.Base:getPreBriefed()`

get preBriefed status

**Returns:**
- (type=bool): - True if target is prebriefed

### `HOUND.Contact.Base:setPreBriefed(state)`

set preBriefed status

**Returns:**
- (type=bool): - True if target is prebriefed

### `HOUND.Contact.Base:isTimedout()`

check if contact is timed out

**Returns:**
- (type=Bool): True if timed out

### `HOUND.Contact.Base:getState()`

Get current state

**Returns:**
- (Contact): state in @{HOUND.EVENTS}

### `HOUND.Contact.Base:queueEvent(eventId)`

Queue new event

**Parameters:**
- `d` (eventI): @{HOUND.EVENTS}

### `HOUND.Contact.Base:getEventQueue()`

get event queue

**Returns:**
- (table): of event skeletons

### `HOUND.Contact.Base:getPrimarySector()`

Get primaty sector for contact

**Returns:**
- (name): of sector the position is in

### `HOUND.Contact.Base:getSectors()`

get sectors contact is threatening

**Returns:**
- (list): of sector names

### `HOUND.Contact.Base:isInSector(sectorName)`

check if threatens sector

**Parameters:**
- `]` (type=string): sectorName

**Returns:**
- (Boot): True if theat

### `HOUND.Contact.Base:updateDefaultSector()`

set correct sector 'default position' sector state

*Note: This is a local function*

### `HOUND.Contact.Base:updateSector(sectorName, inSector, threatsSector)`

Update sector data

### `HOUND.Contact.Base:addSector(sectorName)`

add contact to names sector

### `HOUND.Contact.Base:removeSector(sectorName)`

remove contact from named sector

### `HOUND.Contact.Base:isThreatsSector(sectorName)`

check if contact in names sector

**Returns:**
- (type=Bool): True if contact thretens sector

### `HOUND.Contact.Base:removeMarkers()`

Remove all contact's F10 map markers

*Note: This is a local function*

---

## HOUND.Contact.Estimator

HOUND.Contact.Estimator

**File:** `301 - HoundContactEstimator.lua`

### kalman

Legacy Kalman implementation

### UB-PLKF

Pseudo-linear Kalman filter

### Tables

### `HOUND.Contact.Estimator`

**Type:** HOUND.Contact.Datapoint

### `HOUND.Contact.Estimator.Kalman`

Legacy Kalman implementation

### `HOUND.Contact.Estimator.UPLKF`

UB-PLKF (Unbiased Pseudo-Linear Kalman Filter) Implementation of algorithem described in https://www.mdpi.com/2072-4292/13/15/2915

### Functions

### `HOUND.Contact.Estimator.accuracyScore(err)`

Fuzzy logic score

### `HOUND.Contact.Estimator.Kalman.posFilter()`

Kalman Filter implementation for position

**Returns:**
- (Kalman): filter instance

*Note: This is a local function*

### `HOUND.Contact.Estimator.Kalman.AzFilter(noise)`

Kalman Filter implementation for Azimuth

**Parameters:**
- `angular` (noise): error

**Returns:**
- (Kalman): filter instance

*Note: This is a local function*

### `HOUND.Contact.Estimator.Kalman.AzElFilter()`

Kalman Filter implementation for position.

**Returns:**
- (Kalman): filter instance

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:create(p0, v0, timestamp, initialPosError, isMobile)`

Create PLKF instance

**Parameters:**
- `Initial` (p0): position (DCS point)
- `v0` (type=?table): Initial velocity (x,z)
- `timestamp` (type=?number): Initial time
- `initialPosError` (type=?number): Uncertainty of position measurement
- `isMobile` (type=?boolean): Is the platform mobile?

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:getEstimatedPos(state)`

get current estimated position in DCS point from a Kalman state

**Parameters:**
- `state` (type=?table): from which position will be extracted. defaults self.state.

**Returns:**
- (DCS): point.

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF.normalizeAz(azimuth)`

normalize azimuth to East aligned counterclockwise

**Returns:**
- (angle): in radian (-pi to pi) east aligned counterclockwise rotation

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF.bearingToAzimuth(bearing)`

Convert bearing to DCS azimuth

**Returns:**
- (azimuth): in radians (clockwise from North)

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:updateMarker()`

update debug marker draw a debug marker from current self.state

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:getF(deltaT)`

create F matrix

**Returns:**
- (F): matrix

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:getQ(deltaT, sigma)`

create the Q matrix

**Parameters:**
- `deltaT` (type=?number): time from last mesurement. default is 10 seconds
- `sigma` (type=?number): error in mesurment. default is 0.1 radians

**Returns:**
- (Q): matrix

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:predictStep(X, P, timestep, Q)`

Kalman prediction step for provided state

**Parameters:**
- `X` (type=table): state matrix for prediction
- `P` (type=table): state covariance matrix
- `timestep` (type=number): (in seconds)
- `Q` (type=?table): process nose matrix. will be generated with generic settings if not provided

**Returns:**
- (x_hat): the predicted state matrix
- (P_hat): the predicted state covariance matrix

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:predict(timestamp)`

Perform a prediction for the filter and update state

**Parameters:**
- `timestamp` (type=?number): DCS AbsTime timestamp

*Note: This is a local function*

### `HOUND.Contact.Estimator.UPLKF:update(p0, z, timestamp, z_err)`

perform update of state with mesurment

**Parameters:**
- `p0` (type=table): Position of platform (DCS point)
- `z` (type=number): current mesurment
- `timestamp` (type=number): time of mesurment
- `z_err` (type=number): maximum error in mesurment (radians)

*Note: This is a local function*

---

## HOUND.Contact.Datapoint

HOUND.Contact.Datapoint

**File:** `302 - HoundContactDatapoint.lua`

### Tables

### `HOUND.Contact.Datapoint`

@table HOUND.Contact.Datapoint

**Fields:**
- `platformPos`: position of platform at time of sample
- `az`: Azimuth from platformPos to emitter
- `el`: Elevation from platfromPos to emitter
- `t`: Time of sample
- `platformId`: uid of platform DCS unit
- `platformName`: Name of platform DCS unit
- `platformStatic`: True if platform is static object
- `platformPrecision`: Angular resolution of platform in radians
- `estimatedPos`: estimated position of emitter from AZ/EL (if applicable)
- `posPolygon.2D`: estimated position polygon from AZ only info
- `posPolygon.3D`: estimated position polygon from AZ/EL info (if applicable)

### `HOUND.Contact.Datapoint`

**Type:** HOUND.Contact.Datapoint

### Functions

### `HOUND.Contact.Datapoint.New(platform0, p0, az0, el0, s0, t0, angularResolution, isPlatformStatic)`

Create new HOUND.Contact.Datapoint instance

**Parameters:**
- `DCS` (platform0): Unit of locating platform
- `Position` (p0): of platform on detection
- `Azimuth` (az0): (rad) from platform to emitter
- `Elevation` (el0): (rad) from platform to emitter
- `signal` (s0): strength as detected by the platform
- `Abs` (t0): time of datapoint
- `angularResolution` (opt): angular resolution of datapoint
- `isPlatformStatic` (opt): (bool)

**Returns:**
- (Datapoint): instance

### `HOUND.Contact.Datapoint.isStatic(self)`

check if platform is static

**Returns:**
- (type=Bool): True if platform is static

### `HOUND.Contact.Datapoint.getAge(self)`

Get datapoint age in seconds

**Returns:**
- (time): in seconds

### `HOUND.Contact.Datapoint.getPos(self)`

Get datapoint projected position

**Returns:**
- (type=table): DCS point

### `HOUND.Contact.Datapoint.update(self, newAz, predictedAz, processNoise)`

Smooth azimuth using Kalman filter

**Parameters:**
- `Datapoint` (self): instance
- `new` (newAz): Az input
- `predictedAz` (opt): predicted azimuth
- `processNoise` (opt): Process noise

*Note: This is a local function*

---

## HOUND.Contact.Emitter

HOUND.Contact.Emitter (Extends HOUND.Contact.Base) Contact class. containing related functions

**File:** `310 - HoundContactEmitter.lua`

### settings

Getters and Setters

### data_process

Data Processing

### markers

Marker managment

### helpers

Helper functions

### Tables

### `HOUND.Contact.Emitter`

HOUND.Contact decleration (Extends HOUND.Contact.Base) Contact class. containing related functions

**Type:** HOUND.Contact.Emitter

### `self._dataPoints`

if contact wasn't seen for 15 minuts purge all currnent data

### Functions

### `HOUND.Contact.Emitter:New(DcsObject, HoundCoalition, ContactId)`

create new HOUND.Contact instance

**Parameters:**
- `emitter` (DcsObject): DCS Unit
- `coalition` (HoundCoalition): Id of Hound Instace
- `ContactId` (opt): specify uid for the contact. if not present Unit ID will be used

**Returns:**
- (HOUND.Contact): instance

### `HOUND.Contact.Emitter:destroy()`

Destructor function

### `HOUND.Contact.Emitter:getName()`

Get contact name

**Returns:**
- (Strin): g

### `HOUND.Contact.Emitter:getType()`

Get contact type name

**Returns:**
- (Strin): g

### `HOUND.Contact.Emitter:getId()`

Get contact UID

**Returns:**
- (Numbe): r

### `HOUND.Contact.Emitter:getTrackId()`

get Contact Track ID

**Returns:**
- (strin): g

### `HOUND.Contact.Emitter:getPos()`

get current extimted position

**Returns:**
- (DCS): point - estimated position

### `HOUND.Contact.Emitter:getWavelenght(isTracking)`

get radar transmission wavelength

### `HOUND.Contact.Emitter:getElev()`

get current estimated position elevation

**Returns:**
- (type=int): Elevation in ft.

### `HOUND.Contact.Emitter:getLife()`

get unit health

**Returns:**
- (unit): HP points
- (Unit): HP in percent

### `HOUND.Contact.Emitter:isAlive()`

check if contact DCS Unit is still alive

**Returns:**
- (type=bool): True if object is considered Alive

### `HOUND.Contact.Emitter:setDead()`

set internal alive flag to false This is internal function ment to be called on "S_EVENT_DEAD" unit will be changed to Unit.name because DCS will remove the unit at the end of the event.

### `HOUND.Contact.Emitter:updateDeadDcsObject()`

update the internal DCS Object Since March 2022, Dead units are converted to staticObject on delayed death

### `HOUND.Contact.Emitter:CleanTimedout()`

Remove stale datapoints

*Note: This is a local function*

### `HOUND.Contact.Emitter:countPlatforms(skipStatic)`

return number of platforms

**Parameters:**
- `skipStatic` (opt): if true, will ignore static platforms in count

**Returns:**
- (Number): of platfoms

### `HOUND.Contact.Emitter:countDatapoints()`

returns number of datapoints in contact

**Returns:**
- (Number): of datapoint

### `HOUND.Contact.Emitter:AddPoint(datapoint)`

Add Datapoint to content

**Parameters:**
- `t` (datapoin): @{HOUND.Contact.Datapoint}

### `HOUND.Contact.Emitter.triangulatePoints(earlyPoint, latePoint)`

Take two HOUND.Contact.Datapoints and return the location of intersection

**Parameters:**
- `t` (earlyPoin): @{HOUND.Contact.Datapoint}
- `t` (latePoin): @{HOUND.Contact.Datapoint}

**Returns:**
- (Positio): n

*Note: This is a local function*

### `HOUND.Contact.Emitter.calculateEllipse(estimatedPositions, refPos, giftWrapped)`

Calculate Cotact's Ellipse of uncertenty

**Parameters:**
- `List` (estimatedPositions): of estimated positions
- `refPos` (opt): reference position to use for computing the uncertenty ellipse. (will use cluster avarage if none provided)
- `giftWrapped` (opt): pass true if estimatedPosition is just a giftWrap polygon point set (closed polygon, not a point cluster)

**Returns:**
- (None): (updates self.uncertenty_data)

*Note: This is a local function*

### `HOUND.Contact.Emitter:calculateExtrasPosData(pos)`

calculate additional position data

**Parameters:**
- `basic` (pos): position table to be filled with extended data

**Returns:**
- (pos): input object, but with more data

### `HOUND.Contact.Emitter:processIntersection(targetTable, point1, point2)`

process the intersection

**Parameters:**
- `where` (targetTable): should the result be stored
- `@{HOUND.Contact.Datapoint}` (point1): Instance no.1
- `@{HOUND.Contact.Datapoint}` (point2): Instance no.2

### `HOUND.Contact.Emitter:processData()`

process data in contact

**Returns:**
- (HoundEvent): id (@{HOUND.EVENTS})

### `HOUND.Contact.Emitter.calculatePoly(uncertenty_data, numPoints, refPos)`

calculate uncertenty Polygon from data

**Parameters:**
- `uncertenty` (uncertenty_data): data table
- `numPoints` (opt): number of datapoints in the polygon
- `refPos` (opt): center of the polygon (DCS point)

**Returns:**
- (Polygon): created by inputs

*Note: This is a local function*

### `HOUND.Contact.Emitter:drawAreaMarker(numPoints)`

Draw marker Polygon

*Note: This is a local function*

### `HOUND.Contact.Emitter:updateMarker(MarkerType)`

Update marker positions

**Parameters:**
- `type` (MarkerType): of marker to use

### `HOUND.Contact.Emitter:useUnitPos(unitPosMarker)`

Use DCS Unit Position as contact position

**Parameters:**
- `unitPosMarker` (number): marker type to use for unit (see HOUND.MARKER)

### `HOUND.Contact.Emitter:export()`

Generate contact export object

**Returns:**
- (exported): object

---

## HOUND.Contact.Emitter

HOUND.Contact.Emitter_comms

**File:** `311 - HoundContactEmitter_comms.lua`

### Comms

Comms functions

### Functions

### `HOUND.Contact.Emitter:getTextData(utmZone, MGRSdigits)`

return Information used in Text messages Return BE (string) Bullseye position string (eg. "035/15", "187/120")

**Parameters:**
- `(bool)` (utmZone): True will add UTM zone to response
- `(Number)` (MGRSdigits): number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)

**Returns:**
- (GridPos): (string) MGRS grid position (eg. "CY 564 123", "DN 2 4")

### `HOUND.Contact.Emitter:getTtsData(utmZone, MGRSdigits)`

return Information used in TTS messages Return BE (string) Bullseye position string (eg. "Zero Three Five 15")

**Parameters:**
- `(bool)` (utmZone): True will add UTM zone to response
- `(Number)` (MGRSdigits): number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)

**Returns:**
- (GridPos): (string) MGRS grid position (eg. "Charlie Yankee one two   Three  four")

### `HOUND.Contact.Emitter:generateTtsBrief(NATO)`

Generate TTS brief for the contact (for ATIS)

**Parameters:**
- `(bool)` (NATO): True will generate NATO Brevity brief

**Returns:**
- (string): containing

### `HOUND.Contact.Emitter:generateTtsReport(useDMM, preferMGRS, refPos)`

Generate TTS report for the contact (for controller)

**Parameters:**
- `useDMM` (opt): if true. output will be DM.M rather then the default DMS
- `preferMGRS` (opt): if true output will be MGRS rather then Lat/Lon (not Currently used)
- `refPos` (opt): position of reference point for BR (Not Currently Used)

**Returns:**
- (generated): message

### `HOUND.Contact.Emitter:generateTextReport(useDMM, refPos)`

Generate Text report for the contact (for controller)

**Parameters:**
- `useDMM` (opt): if true. output will be DM.M rather then the default DMS
- `refPos` (opt): position of reference point for BR

**Returns:**
- (generated): message

### `HOUND.Contact.Emitter:getRadioItemText()`

generate Text for the Radio menu item

**Returns:**
- (strin): g

### `HOUND.Contact.Emitter:generatePopUpReport(isTTS, sectorName)`

generate PopUp report

**Parameters:**
- `Bool.` (isTTS): If true message will be for TTS. False will make a text message
- `sectorName` (type=string): Name of primary sector if present function will only return sector data

**Returns:**
- (string.): compiled message

### `HOUND.Contact.Emitter:generateDeathReport(isTTS, sectorName)`

generate Radar dead report

**Parameters:**
- `Bool.` (isTTS): If true message will be for TTS. False will make a text message
- `sectorName` (type=string): Name of primary sector if present function will only return sector data

**Returns:**
- (string.): compiled message

### `HOUND.Contact.Emitter:generateIntelBrief()`

Generate Intel brief Message (for export)

**Returns:**
- (string): - compiled message

---

## HOUND.Contact.Site

HOUND.Contact.Site Site class containing related functions

**File:** `320 - HoundContactSite.lua`

### settings

Getters and Setters

### Emitters

Emitter managment

### markers

Marker managment

### Tables

### `HOUND.Contact.Site`

HOUND.Contact.Site  (Extends @{HOUND.Contact.Base}) Site class containing related functions

**Type:** HOUND.Contact.Site

### Functions

### `HOUND.Contact.Site:New(HoundContact, HoundCoalition, SiteId)`

create new HOUND.Contact.Site instance

**Parameters:**
- `emitter` (HoundContact): HoundContact
- `coalition` (HoundCoalition): Id of Hound Instace
- `SiteId` (opt): specify uid for the Site. if not present Group ID will be used

**Returns:**
- (HOUND.Contact.Site): instance

### `HOUND.Contact.Site:destroy()`

Destructor function

### `HOUND.Contact.Site:getName()`

Get site name

**Returns:**
- (Strin): g

### `HOUND.Contact.Site:setName(requestedName)`

set Site Name

**Parameters:**
- `requested` (requestedName): name

### `HOUND.Contact.Site:getType()`

Get site type name

**Returns:**
- (Strin): g

### `HOUND.Contact.Site:getId()`

Get Site GID

**Returns:**
- (Numbe): r

### `HOUND.Contact.Site:getDcsGroupName()`

Get Site Group Name

**Returns:**
- (Strin): g

### `HOUND.Contact.Site:getDcsName()`

Get the DCS unit name

**Returns:**
- (Strin): g

### `HOUND.Contact.Site:getDcsObject()`

Get the underlying DCS Object

**Returns:**
- (DCS): Group or DCS staticObject

### `HOUND.Contact.Site:getLastSeen()`

Get last seen in seconds

**Returns:**
- (number): in seconds since contact was last seen

### `HOUND.Contact.Site:getTypeAssigned()`

get type assinged string

**Returns:**
- (strin): g

### `HOUND.Contact.Site:isActive()`

Check if site is Active

**Returns:**
- (type=Bool): True if seen in the last 15 seconds

### `HOUND.Contact.Site:isRecent()`

check if site is recent

**Returns:**
- (type=Bool): True if seen in the last 2 minutes

### `HOUND.Contact.Site:isAccurate()`

check if site position is accurate

**Returns:**
- (type=bool): - True target is pre briefed

### `HOUND.Contact.Site:isAlive()`

check if contact DCS Unit is still alive

**Returns:**
- (type=bool): True if object is considered Alive

### `HOUND.Contact.Site:isTimedout()`

check if site is timed out

**Returns:**
- (type=Bool): True if timed out

### `HOUND.Contact.Site:getState()`

Get current state

**Returns:**
- (site): state in @{HOUND.EVENTS}

### `HOUND.Contact.Site:getPos()`

get current extimted position of primary

**Returns:**
- (DCS): point - estimated position

### `HOUND.Contact.Site:hasRadarUnits()`

Does site have any living radars still (for DBA)

**Returns:**
- (type=bool): true if any radars are alive in the group

*Note: This is a local function*

### `HOUND.Contact.Site:addEmitter(HoundEmitter)`

Add emitter to site

**Parameters:**
- `@{HOUND.Contact.Emitter}` (HoundEmitter): radar to add

**Returns:**
- (@{HOUND.EVENTS): }

### `HOUND.Contact.Site:removeEmitter(HoundEmitter)`

Add emitter to site

**Parameters:**
- `@{HOUND.Contact.Emitter}` (HoundEmitter): radar to remove

**Returns:**
- (@{HOUND.EVENTS): }

### `HOUND.Contact.Site:gcEmitters()`

Prune Nil emitters

*Note: This is a local function*

### `HOUND.Contact.Site:updateGroupRadars()`

update internal actual radars list

*Note: This is a local function*

### `HOUND.Contact.Site:getPrimary()`

Get site's primary emitter

**Returns:**
- (@{HOUND.Contact.Emitter): }

### `HOUND.Contact.Site:getEmitters()`

get Dict with all emitters in site

**Returns:**
- (#table): @{HOUND.Contact.Emitter}

### `HOUND.Contact.Site:countEmitters()`

get emitter count for site

**Returns:**
- (type=int): number of emitters currently in the site

### `HOUND.Contact.Site:sortEmitters()`

re-sort emitters

*Note: This is a local function*

### `HOUND.Contact.Site:selectPrimaryEmitter()`

select primaty emitter for site

**Returns:**
- (type=Bool): True if primary changed

### `HOUND.Contact.Site:updateTypeAssigned()`

update site type

**Returns:**
- (type=Bool): True if site type changed

### `HOUND.Contact.Site:updatePos()`

update stored site pos

### `HOUND.Contact.Site:ensurePrimaryHasPos(refPos)`

Ensure primay emitter has position

**Parameters:**
- `refPos` (table): DCS Point with adhock position if nothing else is available

### `HOUND.Contact.Site:updateSector()`

Update sector data

### `HOUND.Contact.Site:LaunchDetected(cooldown)`

trigger launch event

**Parameters:**
- `cooldown` (number): interval between alerts. avoid spam

### `HOUND.Contact.Site:processData()`

Process site data (wrapper for consistency)

### `HOUND.Contact.Site:update()`

Update site data

### `HOUND.Contact.Site:drawAreaMarker(numPoints)`

Draw marker Polygon

*Note: This is a local function*

### `HOUND.Contact.Site:updateMarker(MarkerType)`

Update marker positions

**Parameters:**
- `type` (MarkerType): of marker to use

### `HOUND.Contact.Site:updateMarkers(markerType, drawSite)`

update position markers for site and radars

**Parameters:**
- `requested` (markerType): HOUND.MARKER type
- `drawSite` (type=?boolean): requested HOUND.MARKER for the site.

---

## HOUND.Contact.Site

HOUND.Contact.Site_comms

**File:** `321 - HoundContactSite_comms.lua`

### Functions

### `HOUND.Contact.Site:getTextData(utmZone, MGRSdigits)`

return Information used in Text messages primary emitter Return BE (string) Bullseye position string (eg. "035/15", "187/120")

**Parameters:**
- `(bool)` (utmZone): True will add UTM zone to response
- `(Number)` (MGRSdigits): number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)

**Returns:**
- (GridPos): (string) MGRS grid position (eg. "CY 564 123", "DN 2 4")

### `HOUND.Contact.Site:getTtsData(utmZone, MGRSdigits)`

return Information used in TTS messages info will be that of primary emitter Return BE (string) Bullseye position string (eg. "Zero Three Five 15")

**Parameters:**
- `(bool)` (utmZone): True will add UTM zone to response
- `(Number)` (MGRSdigits): number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)

**Returns:**
- (GridPos): (string) MGRS grid position (eg. "Charlie Yankee one two   Three  four")

### `HOUND.Contact.Site:getRadioItemText()`

generate Text for the Radio menu item

**Returns:**
- (strin): g

### `HOUND.Contact.Site:getRadioItemsText()`

Generate text items for entire site

**Returns:**
- (#table): all radio items for site

### `HOUND.Contact.Site:generatePopUpReport(isTTS, sectorName)`

generate PopUp report

**Parameters:**
- `Bool.` (isTTS): If true message will be for TTS. False will make a text message
- `sectorName` (type=string): Name of primary sector if present function will only return sector data

**Returns:**
- (string.): compiled message

### `HOUND.Contact.Site:generateDeathReport(isTTS, sectorName)`

generate Radar dead report

**Parameters:**
- `Bool.` (isTTS): If true message will be for TTS. False will make a text message
- `sectorName` (type=string): Name of primary sector if present function will only return sector data

**Returns:**
- (string.): compiled message

### `HOUND.Contact.Site:generateAsleepReport(isTTS, sectorName)`

generate Radar dead report

**Parameters:**
- `Bool.` (isTTS): If true message will be for TTS. False will make a text message
- `sectorName` (type=string): Name of primary sector if present function will only return sector data

**Returns:**
- (string.): compiled message

### `HOUND.Contact.Site:generateLaunchAlert(isTTS, sectorName)`

Generate a launch alert message.

**Parameters:**
- `(bool)` (isTTS): True if the message is for TTS, false for text message.
- `sectorName` (type=string): Name of the primary sector; if present, the message will include the sector name.

**Returns:**
- (string): Compiled launch alert message.

### `HOUND.Contact.Site:generateIdentReport(isTTS, sectorName)`

generate Ident report

**Parameters:**
- `Bool.` (isTTS): If true message will be for TTS. False will make a text message
- `sectorName` (type=string): Name of primary sector if present function will only return sector data

**Returns:**
- (string.): compiled message

### `HOUND.Contact.Site:generateTtsBrief(NATO)`

Generate TTS brief for the Site (for ATIS)

**Parameters:**
- `(bool)` (NATO): True will generate NATO Brevity brief

**Returns:**
- (string): containing

### `HOUND.Contact.Site:generateIntelBrief()`

Generate Intel brief Message (for export)

**Returns:**
- (string): - compiled multi-line message for site

### `HOUND.Contact.Site:export()`

Generate Site export object

**Returns:**
- (exported): object

---

## HOUND.Comms.Manager

Hound Comms Manager (Base class)

**File:** `400 - HoundCommsManager.lua`

### Control

Control functions

### Settings

Getters and Setters

### Messaging

Message Handling

### abstacts

abstract methods

### Tables

### `HOUND.Comms.Manager`

HOUND.Comms.Manager decleration

**Type:** HOUND.Comms.Manager

### Functions

### `HOUND.Comms.Manager:create(sector, houndConfig, settings)`

HOUND.Comms.Manager create

**Parameters:**
- `HoundConfig` (houndConfig): instance

**Returns:**
- (CommsManager): Instance

### `HOUND.Comms.Manager:updateSettings(settings)`

Update settings

**Parameters:**
- `#table` (settings): a settings table

### `HOUND.Comms.Manager:enable()`

enable comm instance

### `HOUND.Comms.Manager:disable()`

disable comm instance

### `HOUND.Comms.Manager:isEnabled()`

is comm instance enabled

**Returns:**
- (type=Bool): True if enabled

### `HOUND.Comms.Manager:getSettings(key)`

get value of setting in settings

**Parameters:**
- `config` (key): key requested

**Returns:**
- (settings[key): ]

### `HOUND.Comms.Manager:setSettings(key, value)`

set value of setting in settings

**Parameters:**
- `config` (key): key requested
- `desired` (value): value

### `HOUND.Comms.Manager:enableText()`

enable text messages

### `HOUND.Comms.Manager:disableText()`

disable text messages

### `HOUND.Comms.Manager:enableTTS()`

enable text messages

### `HOUND.Comms.Manager:disableTTS()`

disable text messages

### `HOUND.Comms.Manager:enableAlerts()`

enable Alert messages

### `HOUND.Comms.Manager:disableAlerts()`

disable Alert messages

### `HOUND.Comms.Manager:setTransmitter(transmitterName)`

set transmitter

**Parameters:**
- `(String)` (transmitterName): name of the Unit which will be transmitter

### `HOUND.Comms.Manager:removeTransmitter()`

Remove transmitter

### `HOUND.Comms.Manager:getCallsign()`

get configured callsign

**Returns:**
- (string.): currently configured callsign

### `HOUND.Comms.Manager:setCallsign(callsign)`

set callsign

### `HOUND.Comms.Manager:getFreq()`

get first configured frequency

**Returns:**
- (string): first frequency configured

### `HOUND.Comms.Manager:getFreqs()`

get table of all configured frequencies

**Returns:**
- (table): of all configured frequencies

### `HOUND.Comms.Manager:getAlias()`

get configured Frequeny Alias

**Returns:**
- (string.): currently configured Frequeny Alias

### `HOUND.Comms.Manager:setAlias(alias)`

set Frequeny Alias

### `HOUND.Comms.Manager:addMessageObj(obj)`

Add message object to queue

### `HOUND.Comms.Manager:addMessage(coalition, msg, prio)`

add message to queue

### `HOUND.Comms.Manager:addTxtMsg(coalition, msg, prio)`

add text message to queue

### `HOUND.Comms.Manager:getNextMsg()`

Get next message from queue

*Note: This is a local function*

### `HOUND.Comms.Manager:getTransmitterPos()`

returns configured transmitter position

**Returns:**
- (DCS): position of transmitter or nil if none set

*Note: This is a local function*

### `HOUND.Comms.Manager.TransmitFromQueue(gSelf)`

Trsnsmit next message from queue

**Parameters:**
- `#Table` (gSelf): pointer to self

**Returns:**
- (time): of next queue check

*Note: This is a local function*

### `HOUND.Comms.Manager:startCallbackLoop()`

start loop placeholder

*Note: This is a local function*

### `HOUND.Comms.Manager:stopCallbackLoop()`

stop loop placeholder

*Note: This is a local function*

### `HOUND.Comms.Manager:SetMsgCallback()`

SetMsgCallback placeholder

*Note: This is a local function*

### `HOUND.Comms.Manager:runCallback()`

run callback message scheduler placeholder

*Note: This is a local function*

---

## HOUND.Comms.InformationSystem

Hound Information System (extends HOUND.Comms.Manager)

**File:** `410 - HoundCommsInformationSystem.lua`

### Settings

Getters and Setters

### Overrides

Function Overrides

### Tables

### `HOUND.Comms.InformationSystem`

Hound inforamtion System (extends HOUND.Comms.Manager)

### Functions

### `HOUND.Comms.InformationSystem:create(sector, houndConfig, settings)`

HOUND.Comms.InformationSystem create

**Parameters:**
- `HoundConfig` (houndConfig): instance

**Returns:**
- (HOUND.Comms.InformationSystem): Instance

### `HOUND.Comms.InformationSystem:reportEWR(state)`

set reportEWR state

### `HOUND.Comms.InformationSystem:startCallbackLoop()`

Start callback loop Implementation of abstract for ATIS

*Note: This is a local function*

### `HOUND.Comms.InformationSystem:stopCallbackLoop()`

stop callback loop Implementation of abstract for ATIS

*Note: This is a local function*

### `HOUND.Comms.InformationSystem:SetMsgCallback(callback, args)`

configure function for loop Implementation of abstract

### `HOUND.Comms.InformationSystem:runCallback()`

run callback message scheduler Implementation of abstract

**Returns:**
- (time): of next run

*Note: This is a local function*

### `HOUND.Comms.InformationSystem:getNextMsg()`

Get next message from queue override implementation

*Note: This is a local function*

---

## HOUND.Comms.Controller

Hound Controller  (extends HOUND.Comms.Manager)

**File:** `420 - HoundCommsController.lua`

### Tables

### `HOUND.Comms.Controller`

Hound Controller (extends HOUND.Comms.Manager)

### Functions

### `HOUND.Comms.Controller:create(sector, houndConfig, settings)`

Hound Controller Create

**Parameters:**
- `HoundConfig` (houndConfig): instance

**Returns:**
- (HOUND.Comms.Controller): Instance

---

## HOUND.Comms.Notifier

Hound Notifier (extends HOUND.Comms.Manager)

**File:** `421 - HoundCommsNotifier.lua`

### Tables

### `HOUND.Comms.Notifier`

Hound Notifier (extends HOUND.Comms.Manager)

### Functions

### `HOUND.Comms.Notifier:create(sector, houndConfig, settings)`

Hound Notifier Create

**Parameters:**
- `HoundConfig` (houndConfig): instance

**Returns:**
- (HOUND.Comms.Notifier): Instance

---

## HOUND.ElintWorker

HOUND.ElintWorker

**File:** `500 - HoundElintWorker.lua`

### Platforms

Platform Management

### Contacts

Contact Management

### Sites

Site functions

### Worker

Worker functions

### Functions

### `HOUND.ElintWorker:setCoalition(coalitionId)`

set coalition retundent function will change global coalition

### `HOUND.ElintWorker:getCoalition()`

get worker coalition

**Returns:**
- (coalitionI): d

### `HOUND.ElintWorker:getNewTrackId()`

get the next track number

**Returns:**
- (UID): for the contact

### `HOUND.ElintWorker:addPlatform(platformName)`

add platform

**Returns:**
- (type=bool): True if requested platform was added. else false

### `HOUND.ElintWorker:removePlatform(platformName)`

remove specificd platform

**Parameters:**
- `DCS` (platformName): Unit name to remove

**Returns:**
- (type=bool): true if removed, else false

### `HOUND.ElintWorker:platformRefresh()`

make sure all platforms are still alive and relevate

### `HOUND.ElintWorker:removeDeadPlatforms()`

remove dead platforms

### `HOUND.ElintWorker:countPlatforms()`

count number of platforms

**Returns:**
- (type=int): number of platforms

### `HOUND.ElintWorker:listPlatforms()`

list all associated platform unit names

**Returns:**
- (Table): list of active platform names

### `HOUND.ElintWorker:isContact(emitter)`

return if contact exists in the system

**Returns:**
- (type=bool): return True if unit is in the system

### `HOUND.ElintWorker:addContact(emitter)`

add contact to worker

**Parameters:**
- `DCS` (emitter): Unit to add

**Returns:**
- (Name): of added unit

### `HOUND.ElintWorker:getContact(emitter, getOnly)`

get HOUND.Contact from DCS Unit/UID

**Parameters:**
- `DCS` (emitter): Unit/name of radar unit
- `getOnly` (opt): if true function will not create new unit if not exist

**Returns:**
- (@{HOUND.Contact.Emitter}): instance of that Unit

### `HOUND.ElintWorker:removeContact(emitterName)`

remove Contact from tracking

**Returns:**
- (type=bool): true if removed.

### `HOUND.ElintWorker:setPreBriefedContact(emitter)`

set contact as Prebriefed

**Parameters:**
- `DCS` (emitter): Unit/Unit name of radar

### `HOUND.ElintWorker:setDead(emitter)`

set contact as Dead

**Parameters:**
- `DCS` (emitter): Unit/Unit name of radar

### `HOUND.ElintWorker:AlertOnLaunch(fireGrp)`

Send Launch Alert

**Parameters:**
- `DCS` (fireGrp): Group/Group name that is firing

### `HOUND.ElintWorker:isTracked(emitter)`

is contact is tracked

**Parameters:**
- `DCS` (emitter): Unit/UID of requested emitter

**Returns:**
- (type=bool): if Unit is being tracked by current HoundWorker instance.

### `HOUND.ElintWorker:isSite(site)`

return if site exists in the system

**Parameters:**
- `group` (site): name

**Returns:**
- (type=bool): return True if group is in the system

### `HOUND.ElintWorker:addSite(emitter)`

add site to worker

**Parameters:**
- `DCS` (emitter): Unit to add

**Returns:**
- (Name): of added group

### `HOUND.ElintWorker:getSite(emitter, getOnly)`

get HOUND.Contact.Site from DCS Unit/UID

**Parameters:**
- `@{HOUND.Contact.Emitter}` (emitter): or DCS group name or DCS group
- `getOnly` (opt): if true function will not create new unit if not exist

**Returns:**
- (@{HOUND.Contact.Site}): instance of input group

### `HOUND.ElintWorker:removeSite(groupName)`

remove Site from tracking

**Returns:**
- (type=bool): true if removed.

### `HOUND.ElintWorker:UpdateMarkers()`

update markers to all contacts update all emitters

### `HOUND.ElintWorker:Sniff(GroupName)`

Perform a sample of all emitting radars against all platforms generates and stores datapoints as required

### `HOUND.ElintWorker:Process()`

Process function process all the information stored in the system to update all radar positions

---

## HOUND.ElintWorker

HOUND.ElintWorker

**File:** `501 - HoundElintWorker_queries.lua`

### Query

Query functions

### Functions

### `HOUND.ElintWorker:listContactsInSector(sectorName)`

list all contacts is a sector

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

### `HOUND.ElintWorker:listAllContacts(sectorName)`

Return all contacts managed by this instance regardless of sectors

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

### `HOUND.ElintWorker:listAllContactsByRange(sectorName)`

Return all contacts managed by this instance sorted by range

### `HOUND.ElintWorker:countContacts(sectorName)`

return number of contacts tracked

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

### `HOUND.ElintWorker:getContacts(sectorName)`

return list of contacts

**Parameters:**
- `sectorName` (type=?string): sector to filter by

**Returns:**
- (list): of @{HOUND.Contact.Emitter}

### `HOUND.ElintWorker:sortContacts(sortFunc, sectorName)`

return a sorted list of contacts

**Parameters:**
- `Function` (sortFunc): to sort by
- `sectorName` (type=?string): sector to filter by

**Returns:**
- (sorted): list of @{HOUND.Contact.Emitter}

### `HOUND.ElintWorker:countSites(sectorName)`

return number of contacts tracked

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

### `HOUND.ElintWorker:getSites(sectorName)`

return list of contacts

**Parameters:**
- `sectorName` (type=?string): sector to filter by

**Returns:**
- (list): of @{HOUND.Contact.Site}

### `HOUND.ElintWorker:sortSites(sortFunc, sectorName)`

return a sorted list of contacts

**Parameters:**
- `Function` (sortFunc): to sort by
- `sectorName` (type=?string): sector to filter by

**Returns:**
- (sorted): list of @{HOUND.Contact.Emitter}

### `HOUND.ElintWorker:listAllSites(sectorName)`

Return all contacts managed by this instance regardless of sector

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

### `HOUND.ElintWorker:listAllSitesByRange(sectorName)`

return all contacts managed by this instance sorted by range

---

## HOUND.ContactManager

HOUND.ContactManager Wrapper for HOUND.ElintWorker

**File:** `510 - HoundContactManager.lua`

### Tables

### `HOUND.ContactManager`

HOUND.ElintWorker#Wrapper

**Type:** HOUND.ContactManager

### Functions

### `HOUND.ContactManager.get(HoundInstanceId)`

returns ELINT worker for HoundId

**Parameters:**
- `Hound` (HoundInstanceId): Id

**Returns:**
- (@{HOUND.ElintWorker}): for specified HoundInstanceId

*Part of: HOUND.ContactManager*

---

## HOUND.Sector

HOUND.Sector

**File:** `550 - HoundSector.lua`

### Getters_Setters

getters and setters

### Controller

Controller Functions

### ATIS

ATIS Functions

### Notifier

Notifier Functions

### contacs

Contact Functions

### menu

Radio Menu

### messages

Events ----------------------------------- Message generation

### Tables

### `HOUND.Sector`

HOUND.Sector

**Type:** HOUND.Sector

### Functions

### `HOUND.Sector.create(HoundId, name, settings, priority)`

Create sectors

**Parameters:**
- `Hound` (HoundId): Instance ID
- `Sector` (name): name
- `settings` (opt): Sector settings table
- `priority` (opt): Priority for the sector

### `HOUND.Sector:updateSettings(settings)`

Update sectore settings local sectorSettings = { atis = { freq = 123.45 }, controller = { freq = 234.56 }, notifier = { freq = 243.00 } } sector:updateSettings(sectorSettings)

**Parameters:**
- `table` (settings): of settings for internal services

### `HOUND.Sector:destroy()`

Sector "Destructor" cleans up everyting needed for sector to safly be removed

**Returns:**
- (nil): is returned

### `HOUND.Sector:updateServices()`

Update internal services with settings stored in the sector.

### `HOUND.Sector:getName()`

get name

**Returns:**
- (string): name of sector

### `HOUND.Sector:getPriority()`

get priority

**Returns:**
- (type=int): priority of sector

### `HOUND.Sector:setCallsign(callsign, NATO)`

set callsign for sector

### `HOUND.Sector:getCallsign()`

get callsign for sector

**Returns:**
- (string): Callsign for current sector

### `HOUND.Sector:getZone()`

get zone polygon

**Returns:**
- (table): of points or nil

### `HOUND.Sector:hasZone()`

has zone

**Returns:**
- (type=bool): True if sector has zone

### `HOUND.Sector:setZone(zonecandidate)`

Set zone in sector

**Parameters:**
- `(String)` (zonecandidate): DCS group name, or a drawn map freeform Polygon. sector borders will be group waypoints or polygon points

### `HOUND.Sector:removeZone()`

Remove Zone settings from sector

### `HOUND.Sector:setTransmitter(userTransmitter)`

sets transmitter to sector

**Parameters:**
- `(String)` (userTransmitter): Name of the Unit that would be transmitting

### `HOUND.Sector:updateTransmitter()`

updates all available comms with transmitter on file

### `HOUND.Sector:removeTransmitter()`

removes transmitter from sector

### `HOUND.Sector:enableController(userSettings)`

enable controller

**Parameters:**
- `userSettings` (opt): contoller settings

### `HOUND.Sector:disableController()`

disable controller

### `HOUND.Sector:removeController()`

remove controller completly from sector

### `HOUND.Sector:getControllerFreq()`

get controller frequencies

### `HOUND.Sector:hasController()`

checks for controller in sector

**Returns:**
- (true): if Sector has controller

### `HOUND.Sector:isControllerEnabled()`

checks if controller is enabled for the sector

**Returns:**
- (true): if Sector controller is enabled

### `HOUND.Sector:getController()`

If Controller exists on sector, return controller object

**Returns:**
- (HOUND.COMMS.Controlle): r

### `HOUND.Sector:transmitOnController(msg, priority)`

Transmit custom TTS message on controller

**Parameters:**
- `msg` (type=string): string to broadcast
- `priority` (type=?number): message priority, default is 1 (high priority)

### `HOUND.Sector:enableText()`

enable controller text for sector

### `HOUND.Sector:disableText()`

disable controller text for sector

### `HOUND.Sector:enableAlerts()`

enable controller Alerts for sector

### `HOUND.Sector:disableAlerts()`

disable controller  for sector

### `HOUND.Sector:enableTTS()`

enable Controller tts for sector

### `HOUND.Sector:disableTTS()`

disable Controller tts for sector

### `HOUND.Sector:enableAtis(userSettings)`

enable ATIS in sector

**Parameters:**
- `ATIS` (userSettings): settings array

### `HOUND.Sector:disableAtis()`

disable ATIS in sector

### `HOUND.Sector:removeAtis()`

remove ATIS from sector

### `HOUND.Sector:getAtisFreq()`

get ATIS frequencies

### `HOUND.Sector:reportEWR(state)`

Set ATIS EWR report state

### `HOUND.Sector:hasAtis()`

checks for atis in sector

**Returns:**
- (true): if Sector has atis

### `HOUND.Sector:isAtisEnabled()`

checks if ats is enabled for the sector

**Returns:**
- (true): if Sector ats is enabled

### `HOUND.Sector:enableNotifier(userSettings)`

enable Notifier in sector

**Parameters:**
- `userSettings` (opt): table of settings for Notifier

### `HOUND.Sector:disableNotifier()`

disable notifier in sector

### `HOUND.Sector:removeNotifier()`

remove notifier in sector

**Returns:**
- (true): if Sector has notifier

### `HOUND.Sector:getNotifierFreq()`

get Notifier frequencies

### `HOUND.Sector:hasNotifier()`

checks sector for notifier

### `HOUND.Sector:isNotifierEnabled()`

checks if ats is enabled for the sector

**Returns:**
- (true): if Sector ats is enabled

### `HOUND.Sector:getNotifier()`

If notifier exists on sector, return notifier opject

**Returns:**
- (HOUND.COMMS.Notifie): r

### `HOUND.Sector:transmitOnNotifier(msg, priority)`

Transmit custom TTS message on Notifier

**Parameters:**
- `msg` (type=string): string to broadcast
- `priority` (type=number): message priority, default is 1 (high priority)

### `HOUND.Sector:getContacts()`

return a sorted list of all contacts for the sector

### `HOUND.Sector:countContacts()`

count the number of contacts for the sector

### `HOUND.Sector:updateSectorMembership(contact)`

update contact for zone memberships

**Parameters:**
- `HOUND.Contact` (contact): instance

### `HOUND.Sector:getSites()`

return a sorted list of all contacts for the sector

### `HOUND.Sector:countSites()`

count the number of contacts for the sector

**Returns:**
- (type=int): Number of contacts

### `HOUND.Sector.removeRadioMenu(self)`

remove all radio menus for

**Parameters:**
- `f` (sel): HOUND.Sector

*Note: This is a local function*

### `HOUND.Sector:findGrpInPlayerList(grpId, playersList)`

find group in enrolled

**Parameters:**
- `GroupId` (grpId): (int)
- `playersList` (opt): list of mist.DB units to find all the group members in

**Returns:**
- (list): of enrolled players in grp

*Note: This is a local function*

### `HOUND.Sector:getSubscribedGroups()`

get subscribed groups

**Returns:**
- (list): of groupsId

*Note: This is a local function*

### `HOUND.Sector:validateEnrolled()`

clean non existing users from subscribers

*Note: This is a local function*

### `HOUND.Sector.checkIn(args, skipAck)`

check in player to controller

**Parameters:**
- `table` (args): {self=&ltHOUND.Sector&gt,player=&ltplayer&gt}
- `skipAck` (opt): Bool if true do not reply with ack to player

*Note: This is a local function*

### `HOUND.Sector.checkOut(args, skipAck, onlyPlayer)`

check out player's group from controller

**Parameters:**
- `table` (args): {self=&ltHOUND.Sector&gt,player=&ltplayer&gt}
- `skipAck` (opt): Bool if true do not reply with ack to player
- `onlyPlayer` (opt): Bool. if true, only the player and not his flight (eg. slot change for player)

*Note: This is a local function*

### `HOUND.Sector:isNotifiying()`

Check if sector can notify

### `HOUND.Sector:getTransmissionAnnounce(index)`

create randome annouce

**Parameters:**
- `index` (opt): of requested announce

**Returns:**
- (string): Announcement

### `HOUND.Sector:notifyEmitterDead(contact)`

Send dead emitter notification

**Parameters:**
- `HounContact` (contact): instace

### `HOUND.Sector:notifyEmitterNew(contact)`

Send new emitter notification

**Parameters:**
- `HounContact` (contact): instace

### `HOUND.Sector:notifySiteIdentified(site)`

Notify a site was reclassified

**Parameters:**
- `@{HOUND.Contact.Site}` (site): instace

### `HOUND.Sector:notifySiteNew(site)`

Notify a site was created

**Parameters:**
- `@{HOUND.Contact.Site}` (site): instace

### `HOUND.Sector:notifySiteDead(site, isDead)`

Notify a site was destroyed

**Parameters:**
- `@{HOUND.Contact.Site}` (site): instace
- `True` (isDead): is site is removed, false if just asleep

### `HOUND.Sector:notifySiteLaunching(site)`

Notify that a site is launching. This function sends a notification when a site is launching if alerts are enabled. It checks if the sector is set to notify and if the site belongs to the primary sector. The notification is sent to both the controller and notifier if they are enabled.

**Parameters:**
- `@{HOUND.Contact.Site}` (site): The site that is launching.

### `HOUND.Sector:generateAtis(loopData, AtisPreferences)`

Generate Atis message for sector

**Parameters:**
- `HoundInfomationSystem` (loopData): loop table
- `HoundInfomationSystem` (AtisPreferences): settings table

*Note: This is a local function*

### `HOUND.Sector.TransmitSamReport(args)`

transmit SAM report

**Parameters:**
- `table` (args): {self=&ltHOUND.Sector&gt,contact=&ltHOUND.Contact&gt,requester=&ltplayer&gt}

*Note: This is a local function*

### `HOUND.Sector:TransmitCheckInAck(player)`

transmit checkin message

**Parameters:**
- `Player` (player): entity

*Note: This is a local function*

### `HOUND.Sector:TransmitCheckOutAck(player)`

transmit checkout message

**Parameters:**
- `Player` (player): entity

*Note: This is a local function*

---

## HOUND.Sector

HOUND.Sector

**File:** `551 - HoundSector_menu.lua`

### menu

Radio Menu stuff ----------------------------- Radio Menu

### Tables

### `grpMenuDone`

now do work

### Functions

### `HOUND.Sector:getRadioItemsText()`

generate menu cache

**Returns:**
- (#table): radio items text

*Note: This is a local function*

### `HOUND.Sector:createCheckIn()`

create check menu items for players

*Note: This is a local function*

### `HOUND.Sector:populateRadioMenu()`

Populate sector radio menu

### `HOUND.Sector:removeMenuItems(menu, grpId)`

recursivly clean out a menu

**Parameters:**
- `GroupId` (grpId): to remove from

### `HOUND.Sector:getMenuPage(menu, grpId, parent)`

Handle menu pagination

**Parameters:**
- `to` (menu): paginate
- `group` (grpId): Id for menus
- `root` (parent): menu if required

**Returns:**
- (reference): to the current page to use

*Note: This is a local function*

### `HOUND.Sector:getMenuObj()`

get new menu object

**Returns:**
- (tabl): e

*Note: This is a local function*

### `HOUND.Sector:addSiteRadioItems(typeMenu, requester, siteData)`

create site menu item

**Parameters:**
- `table` (typeMenu): containg the assigned type menu
- `MIST` (requester): player object
- `#table` (siteData): of site from menu cache

*Note: This is a local function*

### `HOUND.Sector:removeSiteRadioItems(typeMenu, requester, siteData)`

remove radar menu items

**Parameters:**
- `table` (typeMenu): contaning a menu structure for the group
- `mist` (requester): human player object
- `#table` (siteData): of site from menu cache

*Note: This is a local function*

---

## HoundElint

Hound Main interface Elint system for DCS

**Author:** uri_ba
**Copyright:** uri_ba 2020-2021

**File:** `800 - HoundElint.lua`

### HoundElint

Instance Setup

### platforms

Platforms managment

### contacts

Contact managment

### sectors

Sector managment

### Controller

Controller managment

### ATIS

ATIS managment

### Notifier

Notifier managment

### sectors

Sector managment

### HoundElint

Instance Setup

### HoundTiming

Instance Internal functions

### export

Exports

### Tables

### `HoundElint`

Main entry point

**Type:** HoundElint

### Functions

### `HoundElint:create(platformName)`

create HoundElint instance.

**Parameters:**
- `platformName` (type=int): Platform name or coalition enum

**Returns:**
- (type=tab): HoundElint Instance

### `HoundElint:destroy()`

destructor function initiates cleanup

### `HoundElint:getId()`

get Hound instance ID

**Returns:**
- (type=Int): Int Hound ID

### `HoundElint:getCoalition()`

get Hound instance Coalition

**Returns:**
- (type=int): coalition enum of current hound instance

### `HoundElint:setCoalition(side)`

set coalition for Hound Instance (Internal)

**Parameters:**
- `side` (type=int): coalition side enum

**Returns:**
- (type=bool): Bool. True if coalition was set

### `HoundElint:onScreenDebug(value)`

set onScreenDebug

**Parameters:**
- `value` (type=bool): to set

**Returns:**
- (type=Bool): True if chaned

### `HoundElint:addPlatform(platformName)`

add platform from hound instance

**Returns:**
- (type=bool): True if successfuly added

### `HoundElint:removePlatform(platformName)`

Remove platform from hound instance

**Returns:**
- (type=bool): True if successfuly removed

### `HoundElint:countPlatforms()`

count Platforms

**Returns:**
- (type=int): number of assigned platforms

### `HoundElint:listPlatforms()`

list platforms

**Returns:**
- (type=tab): list of platfoms

### `HoundElint:countContacts(sectorName)`

count contacts

**Parameters:**
- `sectorName` (type=?string): String name or sector to filter by

**Returns:**
- (type=int): number of contacts currently tracked

### `HoundElint:countActiveContacts(sectorName)`

count Active contacts

**Parameters:**
- `sectorName` (type=?string): String name or sector to filter by

**Returns:**
- (type=Int): number of contacts currently Transmitting

### `HoundElint:countPreBriefedContacts(sectorName)`

count preBriefed contacts

**Parameters:**
- `sectorName` (type=?string): String name or sector to filter by

**Returns:**
- (type=int): number of contacts currently in PB status

### `HoundElint:preBriefedContact(DCS_Object_Name, codeName)`

set/create a pre Briefed contacts

**Parameters:**
- `DCS_Object_Name` (type=string): name of DCS Unit or Group to add
- `codeName` (opt): Optional name for site created

### `HoundElint:markDeadContact(radarUnit)`

Mark Radar as dead

**Parameters:**
- `radarUnit` (type=string|tab): DCS Unit, DCS Group or Unit/Group name to mark as dead

### `HoundElint:AlertOnLaunch(fireUnit)`

Issue a Launch Alert

**Parameters:**
- `fireUnit` (type=string|tab): DCS Unit, DCS Group or Unit/Group name currently Launching

### `HoundElint:countSites(sectorName)`

count sites

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

**Returns:**
- (type=int): number of contacts currently tracked

### `HoundElint:addSector(sectorName, sectorSettings, priority)`

Add named sector

**Parameters:**
- `sectorName` (type=string): name of sector to add
- `sectorSettings` (opt): table of sector settings
- `priority` (opt): Sector priority (lower is higher)

**Returns:**
- (type=bool): True if sector successfully added

### `HoundElint:removeSector(sectorName)`

Remove Named sector

**Parameters:**
- `sectorName` (type=string): name of sector to add

**Returns:**
- (type=bool): True if sector successfully added

### `HoundElint:updateSectorSettings(sectorName, sectorSettings, subSettingName)`

Update named sector settings

**Parameters:**
- `sectorName` (type=string|nil): name of sector (nil == "default")
- `subSettingName` (type=?string): update specific setting ("controller", "atis", "notifier")

**Returns:**
- (type=bool): False if an error occurred, true otherwise

### `HoundElint:listSectors(element)`

list all sectors

**Parameters:**
- `element` (type=?string): list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"

**Returns:**
- (list): of sector names

### `HoundElint:getSectors(element)`

get all sectors

**Parameters:**
- `element` (type=?string): list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"

**Returns:**
- (list): of HOUND.Sector instances

### `HoundElint:countSectors(element)`

return number of sectors

**Parameters:**
- `element` (type=?string): count only sectors with specified element ("controller"/"atis"/"notifier"/"zone")

**Returns:**
- (type=int): . number of sectors

### `HoundElint:getSector(sectorName)`

return HOUND.Sector instance

**Returns:**
- (HOUND.Secto): r

### `HoundElint:enableController(sectorName, settings)`

enable controller in sector

**Parameters:**
- `sectorName` (type=?string): name of sector in which a controller is enabled (default is "default") - "all" enable controller on all sectors

### `HoundElint:disableController(sectorName)`

disable controller in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all controllers

### `HoundElint:removeController(sectorName)`

remove controller in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all controllers

### `HoundElint:configureController(sectorName, settings)`

configure controller in sector

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

### `HoundElint:getControllerFreq(sectorName)`

get controller freq

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

**Returns:**
- (frequncies): table for sector's controller

### `HoundElint:getControllerState(sectorName)`

get controller state

**Parameters:**
- `sectorName` (type=?string): name of sector to probe

**Returns:**
- (type=Bool): True = enabled. False is disable or not configured

### `HoundElint:transmitOnController(sectorName, msg, priority)`

Transmit custom TTS message on controller freqency

**Parameters:**
- `sectorName` (type=string): name of the sector to transmit on.
- `msg` (type=string): message to broadcast
- `priority` (type=?number): message priority

### `HoundElint:enableAtis(sectorName, settings)`

enable ATIS in sector

**Parameters:**
- `sectorName` (type=?string): name of sector in which a controller is enabled (default is "default") - "all" enable ATIS on all sectors

### `HoundElint:disableAtis(sectorName)`

disable ATIS in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all ATIS

### `HoundElint:removeAtis(sectorName)`

remove ATIS in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all ATIS

### `HoundElint:configureAtis(sectorName, settings)`

configure ATIS in sector

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

### `HoundElint:getAtisFreq(sectorName)`

get ATIS freq

**Parameters:**
- `sectorName` (type=?string): name of sector to query

**Returns:**
- (frequncies): table for sector's controller

### `HoundElint:reportEWR(name, state)`

set ATIS EWR report state for sector

**Parameters:**
- `name` (type=?string): sector name. valid inputs are sector name, "all". nothing will default to "default"

### `HoundElint:getAtisState(sectorName)`

get ATIS state

**Parameters:**
- `sectorName` (type=?string): name of sector to probe

**Returns:**
- (type=Bool): True = enabled. False is disable or not configured

### `HoundElint:enableNotifier(sectorName, settings)`

enable Notifier in sector Only one notifier is required as it will broadcast on a global frequency (default is guard) controller will also handle alerts for per sector notifications

**Parameters:**
- `sectorName` (type=?string): name of sector in which a Notifier is enabled (default is "default")

### `HoundElint:disableNotifier(sectorName)`

disable Notifier in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all Notifiers

### `HoundElint:removeNotifier(sectorName)`

remove controller in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all Notifiers

### `HoundElint:configureNotifier(sectorName, settings)`

configure Notifier in sector

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

### `HoundElint:getNotifierFreq(sectorName)`

get Notifier freq

**Parameters:**
- `sectorName` (type=?string): name of sector to query

**Returns:**
- (frequncies): table for sector's Notifier

### `HoundElint:getNotifierState(sectorName)`

get Notifier state

**Parameters:**
- `sectorName` (type=?string): name of sector to probe

**Returns:**
- (type=Bool): True = enabled. False is disable or not configured

### `HoundElint:transmitOnNotifier(sectorName, msg, priority)`

Transmit custom TTS message on Notifier freqency

**Parameters:**
- `sectorName` (type=string): name of the sector to transmit on.
- `msg` (type=string): message to broadcast
- `priority` (type=?number): message priority

### `HoundElint:enableText(sectorName)`

enable Text notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to enable (default is "default", "all" will enable on all sectors)

### `HoundElint:disableText(sectorName)`

disable Text notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to disable (default is "default", "all" will enable on all sectors)

### `HoundElint:enableTTS(sectorName)`

enable Text-To-Speach notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to enable (default is "default", "all" will enable on all sectors)

### `HoundElint:disableTTS(sectorName)`

disable Text-to-speach notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to disable (default is "default", "all" will enable on all sectors)

### `HoundElint:enableAlerts(sectorName)`

enable Alert notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to enable (default is "default", "all" will enable on all sectors)

### `HoundElint:disableAlerts(sectorName)`

disable Alert notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to disable (default is "default", "all" will enable on all sectors)

### `HoundElint:setCallsign(sectorName, sectorCallsign)`

Set sector callsign

**Returns:**
- (type=bool): True if callsign was changes. False otherwise

### `HoundElint:getCallsign(sectorName)`

get sector callsign

**Returns:**
- (String): - callsign for sector. will return empty string if err

### `HoundElint:setTransmitter(sectorName, transmitter)`

set transmitter to named sector valid values are name of sector, "all" or nil (will change default)

**Parameters:**
- `sectorName` (type=string): name of sector to apply to.
- `DCS` (transmitter): unit name which will be the transmitter

### `HoundElint:removeTransmitter(sectorName)`

remove transmitter to named sector valid values are name of sector, "all" or nil (will change default)

**Parameters:**
- `sectorName` (type=string): name of sector to apply to.

### `HoundElint:getZone(sectorName)`

get zone of sector

**Parameters:**
- `sectorName` (type=string): to act on

**Returns:**
- (table): of points or nil if no sector set

### `HoundElint:setZone(sectorName, zoneCandidate)`

add zone to sector same as MOOSE. use late activation invisible helicopter group is recommended.

**Parameters:**
- `sectorName` (type=string): to act on
- `DCS` (zoneCandidate): Group name. Group's waypoints will be used.

### `HoundElint:removeZone(sectorName)`

remove zone from sector

**Parameters:**
- `sectorName` (type=string): to act on

### `HoundElint:updateSectorMembership()`

update sector membership for all contacts

*Note: This is a local function*

### `HoundElint:enableMarkers(markerType)`

enable Markers for Hound Instance (default)

**Parameters:**
- `markerType` (opt): change marker type to use

**Returns:**
- (type=Bool): True if changed

### `HoundElint:disableMarkers()`

disable Markers for Hound Instance

**Returns:**
- (type=Bool): True if changed

### `HoundElint:enableSiteMarkers()`

enable Site Markers for Hound Instance (default)

**Returns:**
- (type=Bool): True if changed

### `HoundElint:disableSiteMarkers()`

disable Site Markers for Hound Instance

**Returns:**
- (type=Bool): True if changed

### `HoundElint:setMarkerType(markerType)`

Set marker type for Hound instance

**Parameters:**
- `valid` (markerType): marker type enum

**Returns:**
- (type=Bool): True if changed

**See also:** HOUND.MARKER

### `HoundElint:setTimerInterval(setIntervalName, setValue)`

set intervals

**Parameters:**
- `interval` (setIntervalName): name to change (scan,process,menu,markers)
- `interval` (setValue): in seconds to set.

**Returns:**
- (type=Bool): True if changed

### `HoundElint:enablePlatformPosErrors()`

enable platforms INS position errors

**Returns:**
- (type=bool): if settings was updated

### `HoundElint:disablePlatformPosErrors()`

disable platforms INS position errors

**Returns:**
- (type=bool): if settings was updated

### `HoundElint:getCallsignOverride()`

get current callsign override table

**Returns:**
- (table): current state

### `HoundElint:setCallsignOverride(overrides)`

set callsign override table

**Parameters:**
- `Table` (overrides): of overrides

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:getBDA()`

get current BDA setting state

**Returns:**
- (type=bool): current state

### `HoundElint:enableBDA()`

enable BDA for Hound Instance Hound will notify on radar destruction

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:disableBDA()`

disable BDA for Hound Instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:getNATO()`

Get current state of NATO brevity setting

**Returns:**
- (type=bool): current state

### `HoundElint:enableNATO()`

enable NATO brevity for Hound Instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:disableNATO()`

disable NATO brevity for Hound Instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:getAlertOnLaunch()`

get Alert on launch for Hound Instance

**Returns:**
- (type=Bool): Current state

### `HoundElint:setAlertOnLaunch(value)`

set Alert on Launch for Hound instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:useNATOCallsignes(value)`

set flag if callsignes for sectors under Callsignes would be from the NATO pool

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:setAtisUpdateInterval(value)`

set Atis Update interval

**Parameters:**
- `desired` (value): interval in seconds

**Returns:**
- (true): if change was made

### `HoundElint:setRadioMenuParent(parent)`

Set Main parent menu for hound Instace must be set <b>BEFORE</b> calling <code>enableController()</code>

**Parameters:**
- `desired` (parent): parent menu (pass nil to clear)

**Returns:**
- (type=Bool): True if no errors

### `HoundElint.runCycle(self)`

Scheduled function that runs the main Instance loop

**Returns:**
- (time): of next run

*Note: This is a local function*

### `HoundElint:purgeRadioMenu()`

Purge the root radio menu

*Note: This is a local function*

### `HoundElint:populateRadioMenu()`

Trigger building of radio menu in all sectors

*Note: This is a local function*

### `HoundElint.updateSystemState(params)`

Update the system state (on/off) TODO: remove?

**Parameters:**
- `table` (params): {self=&ltHoundInstance&gt,state=&ltBool&gt}

*Note: This is a local function*

### `HoundElint:systemOn(notify)`

Turn Hound system on

### `HoundElint:systemOff(notify)`

Turn Hound system off

### `HoundElint:isRunning()`

is Instance on

**Returns:**
- (type=bool): , True if system is running

### `HoundElint:getContacts()`

get an exported list of all contacts tracked by the instance

**Returns:**
- (table): of all contact tracked for integration with external tools

### `HoundElint:getSites()`

get an exported list of all sites tracked by the instance

**Returns:**
- (table): of all contact tracked for integration with external tools

### `HoundElint:dumpIntelBrief(filename)`

dump Intel Brief to csv will dump intel summery to CSV in the DCS saved games folder requires desanitization of lfs and io modules

**Parameters:**
- `filename` (opt): target filename. (default: hound_contacts_%d.csv)

### `HoundElint:printDebugging()`

return Debugging information

**Returns:**
- (strin): g

---

## HoundElint

Hound Main interface Elint system for DCS

**Author:** uri_ba
**Copyright:** uri_ba 2020-2021

**File:** `801 - HoundElintEvents.lua`

### eventHandler

EventHandler functions

### Functions

### `HoundElint:onHoundEvent(houndEvent)`

builtin prototype for onHoundEvent function this function does NOTHING out of the box. put you own code here if needed

**Parameters:**
- `incoming` (houndEvent): event

### `HoundElint:onHoundInternalEvent(houndEvent)`

built in onHoundEvent function

**Parameters:**
- `incoming` (houndEvent): event

*Note: This is a local function*

### `HoundElint:onEvent(DcsEvent)`

built in dcs onEvent

**Parameters:**
- `incoming` (DcsEvent): dcs event

*Note: This is a local function*

### `HoundElint:defaultEventHandler(remove)`

enable/disable Hound instance internal event handling

*Note: This is a local function*

---

## HOUND

HOUND

**File:** `999 - Hound_footer.lua`

---
