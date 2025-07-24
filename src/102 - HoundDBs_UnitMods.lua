--- Hound databases (Units modded)
-- @local
-- @module HOUND.DB
-- @field HOUND.DB
do
    -- Community Platform Assets
    -- Helicopters
    HOUND.DB.Platform[Object.Category.UNIT]['UH-60L'] = { antenna = { size = 8, factor = 1 }, ins_error = 0 }      -- community UH-69L
    -- Fixed Wing
    HOUND.DB.Platform[Object.Category.UNIT]['Hercules'] = { antenna = { size = 35, factor = 1 }, ins_error = 0 }   -- Anubis' C-130J
    HOUND.DB.Platform[Object.Category.UNIT]['EC130'] = { antenna = { size = 35, factor = 1 }, ins_error = 0 }      -- Secret Squirrel EC-130
    HOUND.DB.Platform[Object.Category.UNIT]['RC135RJ'] = { antenna = { size = 40, factor = 1 }, ins_error = 0 }    -- Secret Squirrel RC-135
    HOUND.DB.Platform[Object.Category.UNIT]['P3C_Orion'] = { antenna = { size = 25, factor = 1 }, ins_error = 0 }  -- MAM P-3C_Orion
    HOUND.DB.Platform[Object.Category.UNIT]['CLP_P8'] = { antenna = { size = 35, factor = 1 }, ins_error = 0 }     -- CLP P-8A posidon
    HOUND.DB.Platform[Object.Category.UNIT]['CLP_TU214R'] = { antenna = { size = 40, factor = 1 }, ins_error = 0 } -- CLP TU-214R
    HOUND.DB.Platform[Object.Category.UNIT]['EA_6B'] = { antenna = { size = 9, factor = 1 }, ins_error = 0 }       --VSN EA-6B
    HOUND.DB.Platform[Object.Category.UNIT]['EA-18G'] = { antenna = { size = 14, factor = 1 }, ins_error = 0 }     --CJS EF-18G
    HOUND.DB.Platform[Object.Category.UNIT]['Shavit'] = { antenna = { size = 30, factor = 1 }, ins_error = 0 }     --IDF_Mods Shavit


    -- Community Radar systems
    -- highdigitsams radars --
    HOUND.DB.Radars['S-300PS 64H6E TRAILER sr'] = {
        ['Name'] = "Big Bird",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.C,
            [false] = HOUND.DB.Bands.C
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300PS SA-10B 40B6MD MAST sr'] = {
        ['Name'] = "Clam Shell",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.I,
            [false] = HOUND.DB.Bands.I
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300PS 40B6M MAST tr'] = {
        ['Name'] = "Flap Lid",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300PS 30H6 TRAILER tr'] = {
        ['Name'] = "Flap Lid",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300PS 30N6 TRAILER tr'] = {
        ['Name'] = "Flap Lid",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300PMU1 40B6MD sr'] = {
        ['Name'] = "Clam Shell",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.I,
            [false] = HOUND.DB.Bands.I
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300PMU1 64N6E sr'] = {
        ['Name'] = "Big Bird",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.C,
            [false] = HOUND.DB.Bands.C
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300PMU1 30N6E tr'] = {
        ['Name'] = "Flap Lid",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300PMU1 40B6M tr'] = {
        ['Name'] = "Grave Stone",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300V 9S15 sr'] = {
        ['Name'] = 'Bill Board',
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300V 9S19 sr'] = {
        ['Name'] = 'High Screen',
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.C,
            [false] = HOUND.DB.Bands.C
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300V 9S32 tr'] = {
        ['Name'] = 'Grill Pan',
        ['Assigned'] = { "SA-12" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300PMU2 92H6E tr'] = {
        ['Name'] = 'Grave Stone',
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.I,
            [false] = HOUND.DB.Bands.I
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['S-300PMU2 64H6E2 sr'] = {
        ['Name'] = "Big Bird",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.C,
            [false] = HOUND.DB.Bands.C
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300VM 9S15M2 sr'] = {
        ['Name'] = 'Bill Board M',
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300VM 9S19M2 sr'] = {
        ['Name'] = 'High Screen M',
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.C,
            [false] = HOUND.DB.Bands.C
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['S-300VM 9S32ME tr'] = {
        ['Name'] = 'Grill Pan M',
        ['Assigned'] = { "SA-12" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.K,
            [false] = HOUND.DB.Bands.K
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['SA-17 Buk M1-2 LN 9A310M1-2'] = {
        ['Name'] = "Fire Dome M",
        ['Assigned'] = { "SA-11" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.H,
            [false] = HOUND.DB.Bands.H
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['34Ya6E Gazetchik E decoy'] = {
        ['Name'] = "Flap Lid",
        ['Assigned'] = { "SA-10" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['SAMPT_MRI_ARABEL'] = {
        ['Name'] = "SAMP/T",
        ['Assigned'] = { "SAMP/T" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.I,
            [false] = HOUND.DB.Bands.I
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['SAMPT_MRI_GF300'] = {
        ['Name'] = "SAMP/T",
        ['Assigned'] = { "SAMP/T" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.K,
            [false] = HOUND.DB.Bands.K
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Fire Can radar'] = {
        ['Name'] = "Fire Can",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    -- SAM Assets pack
    HOUND.DB.Radars['EWR 55G6U NEBO-U'] = {
        ['Name'] = "Tall Rack",
        ['Assigned'] = { "EWR" },
        ['Role'] = { HOUND.DB.RadarType.EWR },
        ['Band'] = {
            [true] = HOUND.DB.Bands.A,
            [false] = HOUND.DB.Bands.A
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['EWR P-37 BAR LOCK'] = {
        ['Name'] = "Bar lock",
        ['Assigned'] = { "EWR", "SA-5" },
        ['Role'] = { HOUND.DB.RadarType.EWR, HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['EWR 1L119 Nebo-SVU'] = {
        ['Name'] = "Box Spring",
        ['Assigned'] = { "EWR" },
        ['Role'] = { HOUND.DB.RadarType.EWR },
        ['Band'] = {
            [true] = HOUND.DB.Bands.A,
            [false] = HOUND.DB.Bands.A
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['EWR Generic radar tower'] = {
        ['Name'] = "Civilian Radar",
        ['Assigned'] = { "EWR" },
        ['Role'] = { HOUND.DB.RadarType.EWR },
        ['Band'] = {
            [true] = HOUND.DB.Bands.C,
            [false] = HOUND.DB.Bands.C
        },
        ['Primary'] = false
    }
    --Military Assets for DCS by Currenthill (Russia - 1.2.2)
    HOUND.DB.Radars['PantsirS1'] = {
        ['Name'] = "Pantsir",
        ['Assigned'] = { "SA-22" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['PantsirS2'] = {
        ['Name'] = "Pantsir",
        ['Assigned'] = { "SA-22" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Admiral_Kasatonov'] = {
        ['Name'] = "Gorshkov (FF)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.F,
            [false] = HOUND.DB.Bands.F
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Karakurt_AShM'] = {
        ['Name'] = "Karakurt (FS)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Karakurt_LACM'] = {
        ['Name'] = "Karakurt (FS)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['MonolitB'] = {
        ['Name'] = "Monolit B",
        ['Assigned'] = { "Bastion" },
        ['Role'] = { HOUND.DB.RadarType.ANTISHIP },
        ['Band'] = {
            [true] = HOUND.DB.Bands.I,
            [false] = HOUND.DB.Bands.I
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['TorM2'] = {
        ['Name'] = "Tor",
        ['Assigned'] = { "SA-15" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['TorM2K'] = {
        ['Name'] = "Tor",
        ['Assigned'] = { "SA-15" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['TorM2M'] = {
        ['Name'] = "Tor",
        ['Assigned'] = { "SA-15" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }

    HOUND.DB.Radars['CH_BukM3_9A317M'] = {
        ['Name'] = "Fire Dome",
        ['Assigned'] = { "SA-11" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = false

    }
    HOUND.DB.Radars['CH_BukM3_9A317MA'] = {
        ['Name'] = "Fire Dome",
        ['Assigned'] = { "SA-11" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['CH_BukM3_9S18M13'] = {
        ['Name'] = "Snow Drift",
        ['Assigned'] = { "SA-11", "SA-17", "SA-27" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.516884, 0.082701 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_BukM3_9S36M'] = {
        ['Name'] = "Buk M3",
        ['Assigned'] = { "SA-27" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['CH_S350_50N6'] = {
        ['Name'] = "S-350 STR",
        ['Assigned'] = { "SA-25" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true

    }
    HOUND.DB.Radars['CH_S350_96L6'] = {
        ['Name'] = "Cheese Board",
        ['Assigned'] = { "SA-10", "SA-23", "SA-25" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.516884, 0.082701 }
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['CH_Gremyashchiy_AShM'] = {
        ['Name'] = "Gremyashchiy Corvette",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Gremyashchiy_LACM'] = {
        ['Name'] = "Gremyashchiy Corvette",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Grigorovich_AShM'] = {
        ['Name'] = "Krivak 5 (FF)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Grigorovich_LACM'] = {
        ['Name'] = "Krivak 5 (FF)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Project22160'] = {
        ['Name'] = "Project 22160 (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true

    }
    HOUND.DB.Radars['CH_Steregushchiy'] = {
        ['Name'] = "Steregushchiy (FC)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true

    }
    HOUND.DB.Radars['Admiral_Gorshkov'] = {
        ['Name'] = "Admiral Gorshkov (FF)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }

    --Military Assets for DCS by Currenthill (USA - 1.1.8)
    HOUND.DB.Radars['CH_Arleigh_Burke_IIA'] = {
        ['Name'] = "Arleigh Burke (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Arleigh_Burke_III'] = {
        ['Name'] = "Arleigh Burke (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },

        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Constellation'] = {
        ['Name'] = "[CH] Constellation Frigate",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Ticonderoga'] = {
        ['Name'] = "Ticonderoga (CG)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Ticonderoga_CMP'] = {
        ['Name'] = "Ticonderoga (CG)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Arleigh_Burke_Flight_III_AShM'] = {
        ['Name'] = "Arleigh Burke (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Arleigh_Burke_Flight_III_LACM'] = {
        ['Name'] = "Arleigh Burke (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Arleigh_Burke_Flight_III_SAM'] = {
        ['Name'] = "Arleigh Burke (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Ticonderoga_CMP_AShM'] = {
        ['Name'] = "Ticonderoga (CG)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Ticonderoga_CMP_LACM'] = {
        ['Name'] = "Ticonderoga (CG)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Ticonderoga_CMP_SAM'] = {
        ['Name'] = "Ticonderoga (CG)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['MIM104_ANMPQ65'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['MIM104_ANMPQ65A'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['MIM104_LTAMDS'] = {
        ['Name'] = "Patriot LTAMDS",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['MIM104_ANMPQ65A_HEMTT'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['MIM104_ANMPQ65_HEMTT'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }

    HOUND.DB.Radars['MIM104_LTAMDS_HEMTT'] = {
        ['Name'] = "Patriot LTAMDS",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }

    HOUND.DB.Radars['CH_NASAMS3_SR'] = {
        ['Name'] = "Sentinel",
        ['Assigned'] = { "NASAMS" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Centurion_C_RAM'] = {
        ['Name'] = "Centurion C-RAM",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }

    HOUND.DB.Radars['CH_THAAD_ANTPY2'] = {
        ['Name'] = "THAAD STR",
        ['Assigned'] = { "THAAD" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }


    --Military Assets for DCS by Currenthill (UK - 1.1.1)
    HOUND.DB.Radars['Type45'] = {
        ['Name'] = "Type 45 (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Type26'] = {
        ['Name'] = "Type 26 (FF)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_SkySabreGiraffe'] = {
        ['Name'] = "Giraffe",
        ['Assigned'] = { "Sky Sabre" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    --Military Assets for DCS by Currenthill (Sweden 1.1.0)
    HOUND.DB.Radars['HSwMS_Visby'] = {
        ['Name'] = "Visby (FS)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['LvKv9040'] = {
        ['Name'] = "LvKv9040",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.RANGEFINDER },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['LvS-103_PM103'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['LvS-103_PM103_HX'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['RBS-90'] = {
        ['Name'] = "RBS-90",
        ['Assigned'] = { "SHORAD" },
        ['Role'] = { HOUND.DB.RadarType.RANGEFINDER },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['BV410_RBS90'] = {
        ['Name'] = "RBS-90",
        ['Assigned'] = { "SHORAD" },
        ['Role'] = { HOUND.DB.RadarType.RANGEFINDER },
        ['Band'] = {
            [true] = HOUND.DB.Bands.J,
            [false] = HOUND.DB.Bands.J
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['UndE23'] = {
        ['Name'] = "UndE23",
        ['Assigned'] = { "SHORAD" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.G,
            [false] = HOUND.DB.Bands.G
        },
        ['Primary'] = true
    }


    HOUND.DB.Radars['Strb90'] = {
        ['Name'] = "Strb 90 FAC",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = HOUND.DB.Bands.E,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    --Military Assets for DCS by Currenthill (China - 1.1.6)
    HOUND.DB.Radars['CH_Type022'] = {
        ['Name'] = "Type 022 FAC",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Type054B'] = {
        ['Name'] = "Type 054B Frigate",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Type056A'] = {
        ['Name'] = "Type 056A Corvette",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Type055'] = {
        ['Name'] = "Type 055 (CG)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['Type052D'] = {
        ['Name'] = "Type 052D (DD)",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['PGL_625'] = {
        ['Name'] = "PGL-625",
        ['Assigned'] = { "SHORAD" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['HQ17A'] = {
        ['Name'] = "HQ-17",
        ['Assigned'] = { "HQ-17" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_HQ22_SR'] = {
        ['Name'] = "HQ-22 SR",
        ['Assigned'] = { "HQ-22" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.516884, 0.082701 }
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['CH_HQ22_STR'] = {
        ['Name'] = "HQ-22 STR",
        ['Assigned'] = { "HQ-22" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_PGZ09'] = {
        ['Name'] = "PGZ-09",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_PGZ95'] = {
        ['Name'] = "PGZ-95",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_LD3000'] = {
        ['Name'] = "LD-3000 C-RAM",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_LD3000_stationary'] = {
        ['Name'] = "LD-3000 C-RAM",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    --Military Assets for DCS by Currenthill (Germany 1.1.1)
    HOUND.DB.Radars['CH_MIM104_ANMPQ53_KAT1'] = {
        ['Name'] = "Patriot",
        ['Assigned'] = { "Patriot" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_F124'] = {
        ['Name'] = "F124 Frigate",
        ['Assigned'] = { "Naval" },
        ['Role'] = { HOUND.DB.RadarType.NAVAL },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_BoxerSkyranger'] = {
        ['Name'] = "Boxer",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_FlaRakRad'] = {
        ['Name'] = "FlaRakRad",
        ['Assigned'] = { "SHORAD" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.024983, 0.012491 },
            [false] = HOUND.DB.Bands.D
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_SkynexHX'] = {
        ['Name'] = "Skynex",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.136269, 0.013627 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_Skyshield_FCU'] = {
        ['Name'] = "Skyshield",
        ['Assigned'] = { "AAA" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['CH_TRML4D'] = {
        ['Name'] = "IRIS-T",
        ['Assigned'] = { "SHORAD" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = { 0.516884, 0.082701 },
            [false] = { 0.136269, 0.013627 }
        },
        ['Primary'] = true
    }
    -- Iron Dome Mod
    HOUND.DB.Radars['ELM2048_MMR'] = {
        ['Name'] = "Elta MMR",
        ['Assigned'] = { "Sling" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.F,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['ELM2084_MMR_AD_SC'] = {
        ['Name'] = "Elta MMR",
        ['Assigned'] = { "Sling" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.F,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    HOUND.DB.Radars['ELM2084_MMR_AD_RT'] = {
        ['Name'] = "Elta MMR",
        ['Assigned'] = { "Sling" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH },
        ['Band'] = {
            [true] = HOUND.DB.Bands.F,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = false
    }
    HOUND.DB.Radars['ELM2084_MMR_WLR'] = {
        ['Name'] = "Elta MMR",
        ['Assigned'] = { "Sling" },
        ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
        ['Band'] = {
            [true] = HOUND.DB.Bands.F,
            [false] = HOUND.DB.Bands.E
        },
        ['Primary'] = true
    }
    -- P-14 Mod
    HOUND.DB.Radars['EWR P-14 Tall King'] = {
        ['Name'] = "Tall King",
        ['Assigned'] = { "EWR" },
        ['Role'] = { HOUND.DB.RadarType.EWR },
        ['Band'] = {
            [true] = HOUND.DB.Bands.A,
            [false] = HOUND.DB.Bands.A
        },
        ['Primary'] = false
    }
end
