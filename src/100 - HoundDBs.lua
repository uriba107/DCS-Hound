--- Hound databases
-- @local
-- @module HOUND.DB
-- @field HOUND.DB

do
    HOUND.DB = {}

    --- Enums for Phonetic AlphaBet
    -- @table HOUND.DB.PHONETICS
    -- @field Characters Phonetic representation
    -- @usage  ['A'] = "Alpha"
    HOUND.DB.PHONETICS =  {
        ['A'] = "Alpha",
        ['B'] = "Bravo",
        ['C'] = "Charlie",
        ['D'] = "Delta",
        ['E'] = "Echo",
        ['F'] = "Foxtrot",
        ['G'] = "Golf",
        ['H'] = "Hotel",
        ['I'] = "India",
        ['J'] = "Juliette",
        ['K'] = "Kilo",
        ['L'] = "Lima",
        ['M'] = "Mike",
        ['N'] = "November",
        ['O'] = "Oscar",
        ['P'] = "Papa",
        ['Q'] = "Quebec",
        ['R'] = "Romeo",
        ['S'] = "Sierra",
        ['T'] = "Tango",
        ['U'] = "Uniform",
        ['V'] = "Victor",
        ['W'] = "Whiskey",
        ['X'] = "X ray",
        ['Y'] = "Yankee",
        ['Z'] = "Zulu",
        ['1'] = "One",
        ['2'] = "Two",
        ['3'] = "Three",
        ['4'] = "Four",
        ['5'] = "Five",
        ['6'] = "Six",
        ['7'] = "Seven",
        ['8'] = "Eight",
        ['9'] = "Niner",
        ['0'] = "Zero",
        [' '] = ",",
        ['.'] = "Decimal"
    }

    --- Units that use DMM format
    -- @table HOUND.DB.useDMM
    -- @field UnitType Bool Value
    -- @usage ['F-16C_blk50'] = true
    HOUND.DB.useDMM =  {
        ['F-16C_blk50'] = true,
        ['F-16C_50'] = true,
        ['M-2000C'] = true,
        ['A-10C'] = true,
        ['A-10C_2'] = true,
        ['AH-64D_BLK_II'] = true,
        ['F-15ESE'] = true,
        ['OH58D'] = true,
        ['OH-58D'] = true
    }

    --- Units that prefer MGRS format (not in use)
    -- @table HOUND.DB.useMGRS
    -- @field UnitType Bool value
    -- @usage ['A-10C'] = true
    HOUND.DB.useMGRS = {
        ['A-10C'] = true,
        ['A-10C_2'] = true,
        ['AH-64D_BLK_II'] = true,
        ['OH58D'] = true,
        ['OH-58D'] = true
    }

    --- Band vs wavelength
    -- @table HOUND.DB.Bands
    -- @field Band wavelength in meters of the highest frequency in the range and the diff from the lowest frequency
    -- @usage ['E'] = {0.099931,0.049965}
    HOUND.DB.Bands = {
        ["A"] = {1.199170,8.793912},
        ["B"] = {0.599585,0.599585},
        ["C"] = {0.299792,0.299792},
        ["D"] = {0.149896,0.149896},
        ["E"] = {0.099931,0.049965},
        ["F"] = {0.074948,0.024983},
        ["G"] = {0.049965,0.024983},
        ["H"] = {0.037474,0.012491},
        ["I"] = {0.029979,0.007495},
        ["J"] = {0.014990,0.014990},
        ["K"] = {0.007495,0.007495},
        ["L"] = {0.004997,0.002498},
        ["M"] = {0.002998,0.001999},
    }

    --- Radar types ENUM
    -- @table HOUND.DB.RadarType
    -- @field Radar type in hex
    -- @usage ['EWR'] = 0x01
    HOUND.DB.RadarType = {
        ['NONE'] = 0x00,
        ['EWR'] = 0x01,
        ['RANGEFINDER'] = 0x02,
        ['ANTISHIP'] = 0x04,
        ['SEARCH'] = 0x08,
        ['TRACK'] = 0x10,
        ['NAVAL'] = 0x20
    }

    --- Hound callsigns
    -- @table HOUND.DB.CALLSIGNS
    -- @field NATO list of RC-135 callsigns (source: https://henney.com/chm/callsign.htm)
    -- @field GENERIC list of generic callsigns for hound, mostly vacuum cleaners and fictional detectives
    HOUND.DB.CALLSIGNS = {
        NATO = {
            "ABLOW", "ACTON", "AGRAM", "AMINO", "AWOKE", "BARB", "BART", "BAZOO",
            "BOGUE", "BOOT", "BRAY", "CAMAY", "CAPON", "CASEY", "CHIME", "CHISUM",
            "COBRA", "COSMO", "CRISP", "DAGDA", "DALLY", "DEVON", "DIVE", "DOZER",
            "DUPLE", "EXOR", "EXUDE", "EXULT", "FLOSS", "FLOUT", "FLUKY", "FURR",
            "GENUS", "GOBO", "GOLLY", "GOOFY", "GROUP", "HAKE", "HARMO",
            "HERMA", "HEXAD", "HOLE", "HURDS", "HYMN", "IOTA", "JOSS", "KELT", "LARVA",
            "LUMPY", "MAFIA", "MINE", "MORTY", "MURKY", "NEVIN", "NEWLY", "NORTH",
            "OLIVE", "ORKIN", "PARRY", "PATIO", "PATSY", "PATTY", "PERMA", "PITTS",
            "POKER", "POOK", "PRIME", "PYTHON", "RAGU", "REMUS", "RINGY", "RITZ",
            "RIVET", "ROSE", "RULE", "RUNNY", "SAME", "SAVOY", "SCENT",
            "SCROW", "SEAT", "SLAG", "SLOG", "SNOOP", "SPRY", "STINT", "STOB", "TAKE",
            "TALLY", "TAPE", "TOLL", "TONUS", "TOPCAT", "TORA", "TOTTY", "TOXIC",
            "TRIAL", "TRYST", "VALVO", "VEIN", "VELA", "VETCH", "VINE", "VULCAN",
            "WATT", "WORTH", "ZEPEL", "ZIPPY"
        },
        GENERIC = {
            "VACUUM", "HOOVER", "KIRBY","ROOMBA","DYSON","SHERLOCK","WATSON","GADGET",
            "HORATIO","CAINE","CHRISTIE","BENSON","GIBBS","COLOMBO","HOLT","DIAZ",
            "SCULLY","MULDER","MARVIN","MARS","MORNINGSTAR","STEELE","CASTEL","BECKETT",
            "INDIANA","JONES","LARA","CROFT","VENTURA","SCOOBY","SHAGGY"
        }
    }

    --- Hound Human Units
    -- automatically generate list containing mist style Unit entries for human flights
    -- @table HOUND.DB.HumanUnits
    HOUND.DB.HumanUnits = {
        [coalition.side.NEUTRAL] = {},
        [coalition.side.RED] = {},
        [coalition.side.BLUE] = {}
    }
end
