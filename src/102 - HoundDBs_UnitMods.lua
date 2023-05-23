--- Hound databases (Units modded)
-- @local
-- @module HOUND.DB
-- @field HOUND.DB
do
    -- Community Platform Assets
    -- Helicopters
    HOUND.DB.Platform[Object.Category.UNIT]['UH-60L'] = {antenna = {size = 8, factor = 1},ins_error=0} -- community UH-69L
    -- Fixed Wing
    HOUND.DB.Platform[Object.Category.UNIT]['Hercules'] = {antenna = {size = 35, factor = 1},ins_error=0} -- Anubis' C-130J
    HOUND.DB.Platform[Object.Category.UNIT]['EC130'] = {antenna = {size = 35, factor = 1},ins_error=0}  -- Secret Squirrel EC-130
    HOUND.DB.Platform[Object.Category.UNIT]['RC135RJ'] = {antenna = {size = 40, factor = 1},ins_error=0} -- Secret Squirrel RC-135
    HOUND.DB.Platform[Object.Category.UNIT]['P3C_Orion'] = {antenna = {size = 25, factor = 1},ins_error=0} -- MAM P-3C_Orion
    HOUND.DB.Platform[Object.Category.UNIT]['CLP_P8'] = {antenna = {size = 35, factor = 1},ins_error=0} -- CLP P-8A posidon
    HOUND.DB.Platform[Object.Category.UNIT]['CLP_TU214R'] = {antenna = {size = 40, factor = 1},ins_error=0} -- CLP TU-214R
    HOUND.DB.Platform[Object.Category.UNIT]['EA_6B'] = {antenna = {size = 9, factor = 1},ins_error=0} --VSN EA-6B
    HOUND.DB.Platform[Object.Category.UNIT]['EA-18G'] = {antenna = {size = 14, factor = 1},ins_error=0} --CJS EF-18G

    -- Community Radar systems
    -- highdigitsams radars --
    HOUND.DB.Radars['S-300PS 64H6E TRAILER sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'C',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300PS SA-10B 40B6MD MAST sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'I',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300PS 40B6M MAST tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300PS 30H6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300PS 30N6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300PMU1 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'I',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300PMU1 64N6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'C',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300PMU1 30N6E tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300PMU1 40B6M tr'] = {
            ['Name'] = "Grave Stone",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300V 9S15 sr'] = {
            ['Name'] = 'Bill Board',
            ['Assigned'] = {"SA-12"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'E',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300V 9S19 sr'] = {
            ['Name'] = 'High Screen',
            ['Assigned'] = {"SA-12"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'C',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300V 9S32 tr'] = {
            ['Name'] = 'Grill Pan',
            ['Assigned'] = {"SA-12"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300PMU2 92H6E tr'] = {
            ['Name'] = 'Grave Stone',
            ['Assigned'] = {"SA-20"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'I',
            ['Primary'] = true
        }
    HOUND.DB.Radars['S-300PMU2 64H6E2 sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = {"SA-20"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'C',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300VM 9S15M2 sr'] = {
            ['Name'] = 'Bill Board M',
            ['Assigned'] = {"SA-23"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'E',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300VM 9S19M2 sr'] = {
            ['Name'] = 'High Screen M',
            ['Assigned'] = {"SA-23"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'C',
            ['Primary'] = false
        }
    HOUND.DB.Radars['S-300VM 9S32ME tr'] = {
            ['Name'] = 'Grill Pan M',
            ['Assigned'] = {"SA-23"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'K',
            ['Primary'] = true
        }
    HOUND.DB.Radars['SA-17 Buk M1-2 LN 9A310M1-2'] = {
            ['Name'] = "Fire Dome M",
            ['Assigned'] = {"SA-17"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'H',
            ['Primary'] = false
        }
    HOUND.DB.Radars['34Ya6E Gazetchik E decoy'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = {"SA-10"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Fire Can radar'] = {
            ['Name'] = "Fire Can",
            ['Assigned'] = {"AAA"},
            ['Role'] = {HOUND.DB.RadarType.TRACK},
            ['Band'] = 'E',
            ['Primary'] = true
        }
        -- SAM Assets pack
    HOUND.DB.Radars['EWR 55G6U NEBO-U'] = {
            ['Name'] = "Tall Rack",
            ['Assigned'] = {"EWR"},
            ['Role'] = {HOUND.DB.RadarType.EWR},
            ['Band'] = 'A',
            ['Primary'] = false
        }
    HOUND.DB.Radars['EWR P-37 BAR LOCK'] = {
            ['Name'] = "Bar lock",
            ['Assigned'] = {"EWR","SA-5"},
            ['Role'] = {HOUND.DB.RadarType.EWR,HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'E',
            ['Primary'] = false
        }
    HOUND.DB.Radars['EWR 1L119 Nebo-SVU'] = {
            ['Name'] = "Nebo-SVU",
            ['Assigned'] = {"EWR"},
            ['Role'] = {HOUND.DB.RadarType.EWR},
            ['Band'] = 'A',
            ['Primary'] = false
        }
    HOUND.DB.Radars['EWR Generic radar tower'] = {
            ['Name'] = "Civilian Radar",
            ['Assigned'] = {"EWR"},
            ['Role'] = {HOUND.DB.RadarType.EWR},
            ['Band'] = 'C',
            ['Primary'] = false
        }
        --Military Assets for DCS by Currenthill (Russia)
    HOUND.DB.Radars['PantsirS1'] = {
            ['Name'] = "Pantsir",
            ['Assigned'] = {"SA-22"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH,HOUND.DB.RadarType.TRACK},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['PantsirS2'] = {
            ['Name'] = "Pantsir",
            ['Assigned'] = {"SA-22"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH,HOUND.DB.RadarType.TRACK},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Admiral_Kasatonov'] = {
            ['Name'] = "Gorshkov (FF)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Karakurt_AShM'] = {
            ['Name'] = "Karakurt (FS)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Karakurt_LACM'] = {
            ['Name'] = "Karakurt (FS)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['MonolitB'] = {
            ['Name'] = "Monolit B",
            ['Assigned'] = {"Bastion"},
            ['Role'] = {HOUND.DB.RadarType.ANTISHIP},
            ['Band'] = 'I',
            ['Primary'] = true
        }
        --Military Assets for DCS by Currenthill (USA)
        HOUND.DB.Radars['Arleigh_Burke_Flight_III_AShM'] = {
            ['Name'] = "Arleigh Burke (DD)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Arleigh_Burke_Flight_III_LACM'] = {
            ['Name'] = "Arleigh Burke (DD)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Arleigh_Burke_Flight_III_SAM'] = {
            ['Name'] = "Arleigh Burke (DD)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Ticonderoga_CMP_AShM'] = {
            ['Name'] = "Ticonderoga (CG)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Ticonderoga_CMP_LACM'] = {
            ['Name'] = "Ticonderoga (CG)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Ticonderoga_CMP_SAM'] = {
            ['Name'] = "Ticonderoga (CG)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
        --Military Assets for DCS by Currenthill (UK)
        HOUND.DB.Radars['Type45'] = {
            ['Name'] = "Type 45 (DD)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
        --Military Assets for DCS by Currenthill (Sweden)
    HOUND.DB.Radars['HSwMS_Visby'] = {
            ['Name'] = "Visby (FS)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['LvKv9040'] ={
            ['Name'] = "LvKv9040",
            ['Assigned'] = {"AAA"},
            ['Role'] = {HOUND.DB.RadarType.RANGEFINDER},
            ['Band'] = 'J',
            ['Primary'] = true
        }
    HOUND.DB.Radars['LvS-103_PM103'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = {"Patriot"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH,HOUND.DB.RadarType.TRACK},
            ['Band'] = 'K',
            ['Primary'] = true
        }
    HOUND.DB.Radars['LvS-103_PM103_HX'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = {"Patriot"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH,HOUND.DB.RadarType.TRACK},
            ['Band'] = 'K',
            ['Primary'] = true
        }
    HOUND.DB.Radars['RBS-90'] = {
            ['Name'] = "RBS-90",
            ['Assigned'] = {"SHORAD"},
            ['Role'] = {HOUND.DB.RadarType.RANGEFINDER},
            ['Band'] = 'J',
            ['Primary'] = false
        }
    HOUND.DB.Radars['BV410_RBS90'] = {
            ['Name'] = "RBS-90",
            ['Assigned'] = {"SHORAD"},
            ['Role'] = {HOUND.DB.RadarType.RANGEFINDER},
            ['Band'] = 'J',
            ['Primary'] = false
        }
    HOUND.DB.Radars['UndE23'] = {
            ['Name'] = "UndE23",
            ['Assigned'] = {"SHORAD"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH},
            ['Band'] = 'G',
            ['Primary'] = true
        }
        --Military Assets for DCS by Currenthill (China)
    HOUND.DB.Radars['Type055'] = {
            ['Name'] = "Type 055 (CG)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['Type052D'] = {
            ['Name'] = "Type 052D (DD)",
            ['Assigned'] = {"Naval"},
            ['Role'] = {HOUND.DB.RadarType.NAVAL},
            ['Band'] = 'E',
            ['Primary'] = true
        }
    HOUND.DB.Radars['PGL_625'] = {
            ['Name'] = "PGL-625",
            ['Assigned'] = {"SHORAD"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH,HOUND.DB.RadarType.TRACK},
            ['Band'] = 'F',
            ['Primary'] = true
        }
    HOUND.DB.Radars['HQ17A'] = {
            ['Name'] = "HQ-17",
            ['Assigned'] = {"HQ-17"},
            ['Role'] = {HOUND.DB.RadarType.SEARCH,HOUND.DB.RadarType.TRACK},
            ['Band'] = 'F',
            ['Primary'] = true
        }

end