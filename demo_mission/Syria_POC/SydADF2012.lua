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

SA6sam=SET_GROUP:New():FilterPrefixes("SAM SA-6"):FilterActive(true):FilterOnce()
SA2sam=SET_GROUP:New():FilterPrefixes("SAM SA-2"):FilterActive(true):FilterOnce()
SA3sam=SET_GROUP:New():FilterPrefixes("SAM SA-3"):FilterActive(true):FilterOnce()
SA10sam=SET_GROUP:New():FilterPrefixes("SAM SA-10"):FilterActive(true):FilterOnce()
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

redIADS = MANTIS:New('SYRIA','SAM','EWR',nil,"red",false,nil,true)
redIADS:SetDetectInterval(15)
redIADS:SetSAMRange(80)
redIADS:Start()

-- GCI/CAP system (replaces legacy AI_A2A_DISPATCHER with EASYGCICAP)
-- ME REQUIREMENTS:
--   1. Place a STATIC WAREHOUSE on each airbase, unit name must match the airbase name
--   2. Squadron templates ("54 Squadron", "698 Squadron", etc.) must be late-activated groups in ME
--   3. Create trigger zones named "CAP-Marj Ruhayyil", "CAP-Al-Dumayr", etc. for CAP patrol points
--   4. "SyAF-GCI" group with waypoints defining the RED-BORDER polygon must exist in ME

local redGCI = EASYGCICAP:New("SyAF-GCI", "Marj Ruhayyil", "red", "EWR")

-- Additional airwings (one per airbase)
redGCI:AddAirwing("Al-Dumayr")
redGCI:AddAirwing("An Nasiriyah")
redGCI:AddAirwing("Bassel Al-Assad")

-- Squadrons (TemplateName, SquadName, AirbaseName, AirFrames, Skill)
redGCI:AddSquadron("54 Squadron", "54 Sqn", "Marj Ruhayyil", 2, AI.Skill.GOOD)       --mig23
redGCI:AddSquadron("698 Squadron", "698 Sqn", "Al-Dumayr", 2, AI.Skill.GOOD)          --mig29a
redGCI:AddSquadron("695 Squadron", "695 Sqn", "An Nasiriyah", 2, AI.Skill.GOOD)        --mig23
redGCI:AddSquadron("Russia GCI", "Russian Sqn", "Bassel Al-Assad", 2, AI.Skill.HIGH)   --su30

-- CAP patrol points (AirbaseName, Coordinate, Altitude ft, Speed kn, Heading deg, Leg NM)
-- TODO: adjust CAP zone names/coordinates to match your ME trigger zones
redGCI:AddPatrolPointCAP("Marj Ruhayyil", ZONE:FindByName("CAP-Marj Ruhayyil"):GetCoordinate(), 25000, 450, 270, 20)
redGCI:AddPatrolPointCAP("Al-Dumayr", ZONE:FindByName("CAP-Al-Dumayr"):GetCoordinate(), 25000, 450, 270, 20)
redGCI:AddPatrolPointCAP("An Nasiriyah", ZONE:FindByName("CAP-An Nasiriyah"):GetCoordinate(), 25000, 450, 270, 20)
redGCI:AddPatrolPointCAP("Bassel Al-Assad", ZONE:FindByName("CAP-Bassel Al-Assad"):GetCoordinate(), 25000, 450, 270, 20)

-- Border zone
redGCI:AddAcceptZone(ZONE_POLYGON:New("RED-BORDER", GROUP:FindByName("SyAF-GCI")))

-- Defaults
redGCI:SetDefaultCAPGrouping(2)
redGCI:SetDefaultEngageRange(97)    -- ~180km in NM
redGCI:SetDefaultMissionRange(54)   -- ~100km in NM
redGCI:SetDefaultDespawnAfterLanding()

redGCI:Start()

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