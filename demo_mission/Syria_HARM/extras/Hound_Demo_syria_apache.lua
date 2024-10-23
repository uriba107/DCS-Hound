do
    ----- Apache playground -----
    HOUND_MISSION.PLAYGROUND = {
        unitCounter = 0,
        ranges = {
            Hula = {zone='PlayGround_Hula',level='EASY'},
            Golan = {zone='PlayGround_Golan',level='EASY'}
        },
        vehicleTypes = {
            EASY = {
                'T-72B3','T-55',
                'BMP-2','BMP-2','BTR-80','BTR-80',
                'Ural-375','Ural-375','Ural-375',
                'ZIL-135','ZIL-135'
            },
            MEDIUM = {
                'T-72B3','T-80UD','T-72B3','T-80UD',
                'BMP-2','BMP-2','BTR-80','BTR-80',
                'Strela-10M3','Strela-1 9P31',
                'ZSU-23-4 Shilka','ZSU-23-4 Shilka'
            },
            HARD = {
                'T-72B3','T-80UD','T-72B3','T-80UD',
                'BTR-80','BTR-80',
                'Strela-10M3','Strela-10M3',
                'ZSU-23-4 Shilka','ZSU-23-4 Shilka',
                '2S6 Tunguska'
            },
        }
    }

    function HOUND_MISSION.PLAYGROUND.getId()
        HOUND_MISSION.PLAYGROUND.unitCounter = HOUND_MISSION.PLAYGROUND.unitCounter + 1
        return HOUND_MISSION.PLAYGROUND.unitCounter
    end

    function HOUND_MISSION.PLAYGROUND.updateRangeLevel(args)
        if #args < 2 then return end
        local rangeName = args[1]
        local level = args[2]
        if not HOUND_MISSION.PLAYGROUND.ranges[rangeName] or type(level) ~= "string" then return end
        level = level:upper()
        if HOUND_MISSION.PLAYGROUND.vehicleTypes[level] then
            HOUND_MISSION.PLAYGROUND.ranges[rangeName].level = level
        end
        HOUND_MISSION.PLAYGROUND.buildRangeMenu()
    end

    function HOUND_MISSION.PLAYGROUND.buildRangeMenu()
        if not MAIN_MENU.apache then
            MAIN_MENU.apache = {}
            MAIN_MENU.apache.root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Spawn Apache Targets")
        end

        for rangeName,rangeData in pairs(HOUND_MISSION.PLAYGROUND.ranges) do
            if not MAIN_MENU.apache[rangeName] then
                MAIN_MENU.apache[rangeName] = {}
            end
            if MAIN_MENU.apache[rangeName].main then
                MAIN_MENU.apache[rangeName].main = missionCommands.removeItemForCoalition(coalition.side.BLUE,MAIN_MENU.apache[rangeName].main)
            end
            MAIN_MENU.apache[rangeName].main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,rangeName .. " Range (" .. rangeData.level:upper() .. ")",MAIN_MENU.apache.root)
            MAIN_MENU.apache[rangeName].spawn = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Spawn Group",MAIN_MENU.apache[rangeName].main,HOUND_MISSION.PLAYGROUND.spawnGroup,rangeName)

            MAIN_MENU.apache[rangeName].level = {}
            MAIN_MENU.apache[rangeName].level.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Set difficulty",MAIN_MENU.apache[rangeName].main)
            for _,level in ipairs({'EASY','MEDIUM','HARD'}) do
                MAIN_MENU.apache[rangeName].level[level] = missionCommands.addCommandForCoalition(coalition.side.BLUE,level,MAIN_MENU.apache[rangeName].level.main,HOUND_MISSION.PLAYGROUND.updateRangeLevel,{rangeName,level})
            end
        end
    end

    function HOUND_MISSION.PLAYGROUND.createUnitList(pos,radius,innerradius,difficulty)
        local unitList = {}
        local level = difficulty or "EASY"
        if type(radius) == "number" and type(pos) == "table" then
            for i=1,math.random(4,8) do
                local unitPos = mist.getRandPointInCircle(pos,radius,innerradius)
                local unitType = HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.vehicleTypes[level])
                local unitData = {
                    ["type"] = unitType,
                    ["transportable"] =
                    {
                        ["randomTransportable"] = false,
                    }, -- end of ["transportable"]
                    ["unitId"] = i,
                    ["skill"] = "Random",
                    ["y"] = unitPos.y,
                    ["x"] = unitPos.x,
                    ["name"] = unitType .. HOUND_MISSION.PLAYGROUND.getId(),
                    ["playerCanDrive"] = true,
                    ["heading"] = math.random() * math.pi * 2,
                }
                table.insert(unitList,unitData)
            end
        end
        return unitList
    end

    function HOUND_MISSION.PLAYGROUND.spawnGroup(rangeName)
        local rangeData = HOUND_MISSION.PLAYGROUND.ranges[rangeName] or HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.ranges)
        local zone = rangeData.zone
        local level = rangeData.level
        local pos = mist.getRandomPointInZone(zone, 750)
        local grpData = {
            units = HOUND_MISSION.PLAYGROUND.createUnitList(pos,200,25,level),
            country = 'syria',
            category = 'VEHICLE'
        }
        local grp = mist.dynAdd(grpData)
        if type(grp) == "table" and type(grp['name']) == "string" then
            local control = Group.getByName(grp['name']):getController()
            if control then
                control:setOnOff(true)
                control:setOption(0,2) -- ROE, Open_file
                control:setOption(9,2) -- Alarm_State, RED
            end
            trigger.action.outText("Apache Targets group has spawned in " .. rangeName , 15)
        end
    end

    HOUND_MISSION.PLAYGROUND.buildRangeMenu()

end