--assert(loadfile("F:\\_Google Drive\\DCS Missions\\SydADF2012.lua"))()
--SA6 % availability - 100% is full complement
--SA2 % availability
--SA3 % availability
--SA10 % availability
--EWR % availability

--Editable part v

local SA6pc = 75
local SA2pc = 75
local SA3pc = 75
local SA10pc = 75
local EWRpc = 75

--Editable part ^

SA6sam=SET_GROUP:New():FilterPrefixes("SAM-SA6"):FilterActive(true):FilterOnce()
SA2sam=SET_GROUP:New():FilterPrefixes("SAM-SA2"):FilterActive(true):FilterOnce()
SA3sam=SET_GROUP:New():FilterPrefixes("SAM-SA3"):FilterActive(true):FilterOnce()
SA10sam=SET_GROUP:New():FilterPrefixes("SAM-SA10"):FilterActive(true):FilterOnce()
EWR=SET_GROUP:New():FilterPrefixes("EWR"):FilterActive(true):FilterStart()
--All=SET_GROUP:New():FilterActive(true):FilterStart()

local SA6count=SA6sam:Count()
local SA3count=SA3sam:Count()
local SA2count=SA2sam:Count()
local SA10count=SA10sam:Count()
local EWRcount=EWR:Count()


--We will reduce the complement of the SAM's by the fixed percentage requested above by removing some


local SA6toKeep = UTILS.Round(SA6count/100*SA6pc, 0)

--if SA6toKeep>0 then
local SA6toDestroy = SA6count - SA6toKeep
  for i = 1, SA6toDestroy do
    local grpObj = SA6sam:GetRandom()
    --env.info(grpObj:GetName())
    grpObj:Destroy(true)

  end
--end 

local SA2toKeep = UTILS.Round(SA2count/100*SA2pc, 0)

--if SA2toKeep>0 then
local SA2toDestroy = SA2count - SA2toKeep
  for i = 1, SA2toDestroy do
   local grpObj = SA2sam:GetRandom()
    --env.info(grpObj:GetName())
    grpObj:Destroy(true)

  end
--end 

local SA3toKeep = UTILS.Round(SA3count/100*SA3pc, 0)

--if SA3toKeep>0 then
local SA3toDestroy = SA3count - SA3toKeep
  for i = 1, SA3toDestroy do
    local grpObj = SA3sam:GetRandom()
    --env.info(grpObj:GetName())
    grpObj:Destroy(true)

  end
--end 

local SA10toKeep = UTILS.Round(SA10count/100*SA10pc, 0)

--if SA10toKeep>0 then
local SA10toDestroy = SA10count - SA10toKeep
  for i = 1, SA10toDestroy do
    local grpObj = SA10sam:GetRandom()
    --env.info(grpObj:GetName())
    grpObj:Destroy(true)

  end
--end

local EWRtoKeep = UTILS.Round(EWRcount/100*EWRpc, 0)

--if EWRtoKeep>0 then
local EWRtoDestroy = EWRcount - EWRtoKeep
  for i = 1, EWRtoDestroy do
    local grpObj = EWR:GetRandom()
    --env.info(grpObj:GetName())
    grpObj:Destroy(true)

  end
--end 

redIADS = SkynetIADS:create('SYRIA')
redIADS:setUpdateInterval(15)
redIADS:addEarlyWarningRadarsByPrefix('EWR')
redIADS:addSAMSitesByPrefix('SAM')
redIADS:getSAMSitesByNatoName('SA-2'):setGoLiveRangeInPercent(80)
redIADS:getSAMSitesByNatoName('SA-3'):setGoLiveRangeInPercent(80)
redIADS:getSAMSitesByNatoName('SA-10'):setGoLiveRangeInPercent(80)
redIADS:activate()
-- redIADS = MANTIS:New('SYRIA','SAM','EWR',nil,"red",false,nil,true)
-- redIADS:Start()
-- local iadsDebug = redIADS:getDebugSettings()
-- iadsDebug.IADSStatus = true
-- iadsDebug.radarWentDark = true
-- iadsDebug.contacts = true
-- iadsDebug.radarWentLive = true
-- iadsDebug.noWorkingCommmandCenter = true
-- iadsDebug.samNoConnection = true
-- iadsDebug.jammerProbability = true
-- iadsDebug.addedEWRadar = true
-- iadsDebug.harmDefence = true

-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:FilterPrefixes("EWR")
DetectionSetGroup:FilterStart()
-- Setup the detection and group targets to a 30km range!
Detection = DETECTION_AREAS:New( DetectionSetGroup, 10000 )
-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
-- Set 100km as the radius to engage any target by airborne friendlies.
A2ADispatcher:SetEngageRadius(180000) -- 100000 is the default value.
-- Set 200km as the radius to ground control intercept.
A2ADispatcher:SetGciRadius(100000) -- 200000 is the default value.
A2ADispatcher:SetDefaultTakeoffFromParkingCold()
A2ADispatcher:SetDefaultLandingAtEngineShutdown()
BorderZone = ZONE_POLYGON:New( "RED-BORDER", GROUP:FindByName( "SyAF-GCI" ) )
A2ADispatcher:SetBorderZone( BorderZone )
--SQNs
A2ADispatcher:SetSquadron( "54 Squadron", "Marj Ruhayyil", { "54 Squadron" }, 2 ) --mig23
A2ADispatcher:SetSquadronGrouping( "54 Squadron", 2 )
A2ADispatcher:SetSquadronGci( "54 Squadron", 900, 1200 )

A2ADispatcher:SetSquadron( "698 Squadron", "Al-Dumayr", { "698 Squadron" }, 2 ) --mig29a
A2ADispatcher:SetSquadronGrouping( "698 Squadron", 2 )
A2ADispatcher:SetSquadronGci( "698 Squadron", 900, 1200 )

A2ADispatcher:SetSquadron( "695 Squadron", "An Nasiriyah", { "695 Squadron" }, 2 ) --mig23
A2ADispatcher:SetSquadronGrouping( "695 Squadron", 2 )
A2ADispatcher:SetSquadronGci( "695 Squadron", 900, 1200 )

A2ADispatcher:SetSquadron( "Russia GCI", "Bassel Al-Assad", { "Russia GCI" }, 2 ) --su30
A2ADispatcher:SetSquadronGrouping( "Russia GCI", 2 )
A2ADispatcher:SetSquadronGci( "Russia GCI", 900, 1200 )

--A2ADispatcher:SetTacticalDisplay(true)
A2ADispatcher:Start()


-- add the MOOSE SET_GROUP to the IADS
--redIADS:addMooseSetGroup(DetectionSetGroup)

local Zone={}
Zone.Alpha   = ZONE:New("Aleppo")   --Core.Zone#ZONE
Zone.Bravo   = ZONE:New("Golan")   --Core.Zone#ZONE
--Zone.Charlie = ZONE:New("Zone Charlie") --Core.Zone#ZONE
--Zone.Delta   = ZONE:New("Zone Delta")   --Core.Zone#ZONE
-- Set of all zones defined in the ME
local AllZones=SET_ZONE:New():FilterOnce()

SCHEDULER:New( nil, function()
  local mission=AUFTRAG:NewCAS(Zone.Alpha)
  local fg=FLIGHTGROUP:New("2 Squadron-4")
  fg:AddMission(mission)
  
  local mission=AUFTRAG:NewCAS(Zone.Alpha)
  local fg=FLIGHTGROUP:New("turkishCAS")
  fg:AddMission(mission)  
  
  local mission=AUFTRAG:NewCAS(Zone.Bravo)
  local fg=FLIGHTGROUP:New("976 Squadron AI")
  fg:AddMission(mission) 
end, {},4, 900, .8)

SCHEDULER:New( nil, function()
  local mission=AUFTRAG:NewCAS(Zone.Alpha)
  local fg=FLIGHTGROUP:New("825 Squadron-7")
  fg:AddMission(mission)
 
  local mission=AUFTRAG:NewCAS(Zone.Alpha)
  local fg=FLIGHTGROUP:New("Warthog-6")
  fg:AddMission(mission) 
  
  local mission=AUFTRAG:NewCAS(Zone.Bravo)
  local fg=FLIGHTGROUP:New("767 Squadron")
  fg:AddMission(mission) 
end, {},300, 900, .8)

--Aleppo
SPAWN:New('defenders'):InitLimit(8,0):SpawnScheduled(600,.9)
SPAWN:New('attackers'):InitLimit(8,0):SpawnScheduled(600,.9)
SPAWN:New('defenders-1'):InitLimit(8,0):SpawnScheduled(600,.9)
SPAWN:New('attackers-1'):InitLimit(8,0):SpawnScheduled(600,.9)

--Golan
SPAWN:New('defenders-2'):InitLimit(7,0):SpawnScheduled(600,.9)
SPAWN:New('defenders-3'):InitLimit(7,0):SpawnScheduled(600,.9)
SPAWN:New('attackers-4'):InitLimit(8,0):SpawnScheduled(600,.9)