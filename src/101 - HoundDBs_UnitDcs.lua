--- Hound databases (Units DCS)
-- @local
-- @module HOUND.DB
-- @field HOUND.DB
do
    --- Radar database
    -- @table HOUND.DB.Radars
    -- @field @string Name NATO Name
    -- @field #table Assigned Which Battery this radar can belong to
    -- @field #table Role Role of radar in battery
    -- @field #table Band Radio Band the radar operates in true is when tracking target
    -- @field #bool Primary set to True if this is a primary radar for site (usually FCR)
    -- @usage
    -- ['p-19 s-125 sr'] = {
    --     ['Name'] = "Flat Face",
    --     ['Assigned'] = {"SA-2","SA-3"},
    --     ['Role'] = {HOUND.DB.RadarType.SEARCH},
    --     ['Band'] = {
    --          [true] = HOUND.DB.Bands.C,
    --          [false] = HOUND.DB.Bands.C
    --      },
    --     ['Primary'] = false
    -- }
    HOUND.DB.Radars = {
        -- EWR --
        ['1L13 EWR'] = {
            ['Name'] = "Box Spring",
            ['Assigned'] = { "EWR" },
            ['Role'] = { HOUND.DB.RadarType.EWR },
            ['Band'] = {
                [true] = { 1.362693, 0.302821 },
                [false] = { 1.362693, 0.302821 },
            },
            ['Primary'] = false
        },
        ['55G6 EWR'] = {
            ['Name'] = "Tall Rack",
            ['Assigned'] = { "EWR" },
            ['Role'] = { HOUND.DB.RadarType.EWR },
            ['Band'] = {
                [true] = { 0.999308, 8.993774 },
                [false] = { 0.999308, 8.993774 }
            },
            ['Primary'] = false
        },
        ['FPS-117'] = {
            ['Name'] = "Seek Igloo",
            ['Assigned'] = { "EWR" },
            ['Role'] = { HOUND.DB.RadarType.EWR },
            ['Band'] = {
                [true] = { 0.214137, 0.032605 },
                [false] = { 0.214137, 0.032605 },
            },
            ['Primary'] = false
        },
        ['FPS-117 Dome'] = {
            ['Name'] = "Seek Igloo",
            ['Assigned'] = { "EWR" },
            ['Role'] = { HOUND.DB.RadarType.EWR },
            ['Band'] = {
                [true] = { 0.214137, 0.032605 },
                [false] = { 0.214137, 0.032605 },
            },
            ['Primary'] = false
        },
        -- SAM radars --
        ['p-19 s-125 sr'] = {
            ['Name'] = "Flat Face",
            ['Assigned'] = { "SA-2", "SA-3" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.342620, 0.018576 },
                [false] = { 0.342620, 0.018576 }
            },
            ['Primary'] = false
        },
        ['SNR_75V'] = {
            ['Name'] = "Fan-song",
            ['Assigned'] = { "SA-2" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.058898, 0.002159 },
                [false] = { 0.058898, 0.000940 }
            },
            ['Primary'] = true
        },
        ['RD_75'] = {
            ['Name'] = "Amazonka",
            ['Assigned'] = { "SA-2" },
            ['Role'] = { HOUND.DB.RadarType.RANGEFINDER },
            ['Band'] = {
                [true] = HOUND.DB.Bands.G,
                [false] = HOUND.DB.Bands.G
            },
            ['Primary'] = false
        },
        ['snr s-125 tr'] = {
            ['Name'] = "Low Blow",
            ['Assigned'] = { "SA-3" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.031893, 0.001417 },
                [false] = { 0.031893, 0.001417 }
            },
            ['Primary'] = true
        },
        ['Kub 1S91 str'] = {
            ['Name'] = "Straight Flush",
            ['Assigned'] = { "SA-6" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.I,
                [false] = HOUND.DB.Bands.C
            },
            ['Primary'] = true
        },
        ['Osa 9A33 ln'] = {
            ['Name'] = "Osa",
            ['Assigned'] = { "SA-8" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.020256, 0.000856 },
                [false] = HOUND.DB.Bands.C
            },
            ['Primary'] = true
        },
        ['S-300PS 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = { "SA-10" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.090846, 0.012531 },
                [false] = { 0.090846, 0.012531 }
            },
            ['Primary'] = false
        },
        ['S-300PS 64H6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = { "SA-10" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.090846, 0.012531 },
                [false] = { 0.090846, 0.012531 }
            },
            ['Primary'] = false
        },
        ['RLS_19J6'] = {
            ['Name'] = "Tin Shield",
            ['Assigned'] = { "SA-5" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.093685, 0.011505 },
                [false] = { 0.093685, 0.011505 }
            },
            ['Primary'] = false
        },
        ['S-300PS 40B6MD sr_19J6'] = {
            ['Name'] = "Tin Shield",
            ['Assigned'] = { "SA-10" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.093685, 0.011505 },
                [false] = { 0.093685, 0.011505 }
            },
            ['Primary'] = false
        },
        ['S-300PS 40B6M tr'] = {
            ['Name'] = "Tomb Stone",
            ['Assigned'] = { "SA-10" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.014990, 0.022484 },
                [false] = { 0.014990, 0.022484 }
            },
            ['Primary'] = true
        },
        ['S-300PS 5H63C 30H6_tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = { "SA-10" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.014990, 0.022484 },
                [false] = { 0.014990, 0.022484 }
            },
            ['Primary'] = true
        },
        ['SA-11 Buk SR 9S18M1'] = {
            ['Name'] = "Snow Drift",
            ['Assigned'] = { "SA-11" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.033310, 0.016655 },
                [false] = HOUND.DB.Bands.F
            },
            ['Primary'] = true
        },
        ['SA-11 Buk LN 9A310M1'] = {
            ['Name'] = "Fire Dome",
            ['Assigned'] = { "SA-11" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.033310, 0.016655 },
                [false] = { 0.029979, 0.019986 }
            },
            ['Primary'] = false
        },
        ['Tor 9A331'] = {
            ['Name'] = "Tor",
            ['Assigned'] = { "SA-15" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = {0.037474,0.037474}, -- G+H
                [false] = HOUND.DB.Bands.F
            },
            ['Primary'] = true
        },
        ['Strela-1 9P31'] = {
            ['Name'] = "SA-9",
            ['Assigned'] = { "Strela" },
            ['Role'] = { HOUND.DB.RadarType.RANGEFINDER },
            ['Band'] = {
                [true] = HOUND.DB.Bands.K,
                [false] = HOUND.DB.Bands.K
            },
            ['Primary'] = false
        },
        ['Strela-10M3'] = {
            ['Name'] = "SA-13",
            ['Assigned'] = { "Strela" },
            ['Role'] = { HOUND.DB.RadarType.RANGEFINDER },
            ['Band'] = {
                [true] = HOUND.DB.Bands.J,
                [false] = HOUND.DB.Bands.J
            },
            ['Primary'] = false
        },
        ['Patriot str'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = { "Patriot" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.055008, 0.011910 },
                [false] = { 0.055008, 0.011910 }
            },
            ['Primary'] = true
        },
        ['Hawk sr'] = {
            ['Name'] = "Hawk SR",
            ['Assigned'] = { "Hawk" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = HOUND.DB.Bands.C,
                [false] = HOUND.DB.Bands.C
            },
            ['Primary'] = false
        },
        ['Hawk tr'] = {
            ['Name'] = "Hawk TR",
            ['Assigned'] = { "Hawk" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['Hawk cwar'] = {
            ['Name'] = "Hawk CWAR",
            ['Assigned'] = { "Hawk" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.J,
                [false] = HOUND.DB.Bands.J
            },
            ['Primary'] = false
        },
        ['RPC_5N62V'] = {
            ['Name'] = "Square Pair",
            ['Assigned'] = { "SA-5" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = {0.044087,0.002755},
                [false] = {0.044087,0.002755}
            },
            ['Primary'] = true
        },
        ['Roland ADS'] = {
            ['Name'] = "Roland TR",
            ['Assigned'] = { "Roland" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = HOUND.DB.Bands.D
            },
            ['Primary'] = true
        },
        ['Roland Radar'] = {
            ['Name'] = "Roland SR",
            ['Assigned'] = { "Roland" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = HOUND.DB.Bands.D,
                [false] = HOUND.DB.Bands.D
            },
            ['Primary'] = false
        },
        ['Gepard'] = {
            ['Name'] = "Gepard",
            ['Assigned'] = { "Gepard" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.J,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['rapier_fsa_blindfire_radar'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = { "Rapier" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.F,
                [false] = HOUND.DB.Bands.F
            },
            ['Primary'] = true
        },
        ['rapier_fsa_launcher'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = { "Rapier" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.074948, 0.224844 },
                [false] = { 0.074948, 0.224844 }
            },
            ['Primary'] = false
        },
        ['NASAMS_Radar_MPQ64F1'] = {
            ['Name'] = "Sentinel",
            ['Assigned'] = { "NASAMS" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['HQ-7_STR_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = { "HQ-7" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = {0.516884,0.082701},
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = false
        },
        ['HQ-7_LN_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = { "HQ-7" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.J,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['HQ-7_LN_P'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = { "HQ-7" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.E,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['2S6 Tunguska'] = {
            ['Name'] = "Tunguska",
            ['Assigned'] = { "Tunguska" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH, HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = HOUND.DB.Bands.J,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['ZSU-23-4 Shilka'] = {
            ['Name'] = "Shilka",
            ['Assigned'] = { "AAA" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.019217, 0.001316 },
                [false] = { 0.019217, 0.001316 }
            },
            ['Primary'] = true
        },
        ['HEMTT_C-RAM_Phalanx'] = {
            ['Name'] = "Phalanx C-RAM",
            ['Assigned'] = { "AAA" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.016655, 0.008328 },
                [false] = { 0.016655, 0.008328 }
            },
            ['Primary'] = true
        },
        ['Dog Ear radar'] = {
            ['Name'] = "Dog Ear",
            ['Assigned'] = { "AAA" },
            ['Role'] = { HOUND.DB.RadarType.SEARCH },
            ['Band'] = {
                [true] = { 0.049965, 0.049965 },
                [false] = { 0.049965, 0.049965 }
            },
            ['Primary'] = true
        },
        ['SON_9'] = {
            ['Name'] = "Fire Can",
            ['Assigned'] = { "AAA" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.103377, 0.007658 },
                [false] = { 0.103377, 0.007658 }
            },
            ['Primary'] = true
        },
        -- non AA radars
        ['Silkworm_SR'] = {
            ['Name'] = "Silkworm",
            ['Assigned'] = { "Silkworm" },
            ['Role'] = { HOUND.DB.RadarType.ANTISHIP },
            ['Band'] = {
                [true] = HOUND.DB.Bands.K,
                [false] = HOUND.DB.Bands.K
            },
            ['Primary'] = true
        },
        -- WWII stuff
        ['FuSe-65'] = {
            ['Name'] = "Würzburg",
            ['Assigned'] = { "AAA" },
            ['Role'] = { HOUND.DB.RadarType.TRACK },
            ['Band'] = {
                [true] = { 0.535344, 0.000000 },
                [false] = { 0.535344, 0.000000 }
            },
            ['Primary'] = false
        },
        ['FuMG-401'] = {
            ['Name'] = "EWR",
            ['Assigned'] = { "EWR" },
            ['Role'] = { HOUND.DB.RadarType.EWR },
            ['Band'] = {
                [true] = { 2.306096, 0.192175 },
                [false] = { 2.306096, 0.192175 }
            },
            ['Primary'] = false
        },
        ['Flakscheinwerfer_37'] = {
            ['Name'] = "AAA Searchlight",
            ['Assigned'] = { "AAA" },
            ['Role'] = { HOUND.DB.RadarType.NONE },
            ['Band'] = {
                [true] = HOUND.DB.Bands.L,
                [false] = HOUND.DB.Bands.L
            },
            ['Primary'] = false
        },
        -- Naval Assets --
        ['Type_052B'] = {
            ['Name'] = "Luyang-1 (DD)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = {0.033310,0.016655},
                [false] = HOUND.DB.Bands.F
            },
            ['Primary'] = true
        },
        ['Type_052C'] = {
            ['Name'] = "Luyang-2 (DD)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['Type_054A'] = {
            ['Name'] = "Jiangkai (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = {0.033310,0.016655},
                [false] = HOUND.DB.Bands.F
            },
            ['Primary'] = true
        },

        ['Type_093'] = {
            ['Name'] = "Shang Submarine",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = HOUND.DB.Bands.E,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['USS_Arleigh_Burke_IIa'] = {
            ['Name'] = "Arleigh Burke (DD)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['CV_1143_5'] = {
            ['Name'] = "Kuznetsov (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['KUZNECOW'] = {
            ['Name'] = "Kuznetsov (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['Forrestal'] = {
            ['Name'] = "Forrestal (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['VINSON'] = {
            ['Name'] = "Nimitz (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.318251, 0.034446 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['CVN_71'] = {
            ['Name'] = "Nimitz (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['CVN_72'] = {
            ['Name'] = "Nimitz (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['CVN_73'] = {
            ['Name'] = "Nimitz (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['Stennis'] = {
            ['Name'] = "Nimitz (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['CVN_75'] = {
            ['Name'] = "Nimitz (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        ['La_Combattante_II'] = {
            ['Name'] = "La Combattante (FC)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = {0.024983,0.012491},
                [false] = {0.049965,0.007687}
            },
            ['Primary'] = true
        },
        ['ALBATROS'] = {
            ['Name'] = "Grisha (FC)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = HOUND.DB.Bands.H,
                [false] = HOUND.DB.Bands.H
            },
            ['Primary'] = true
        },
        ['MOLNIYA'] = {
            ['Name'] = "Molniya (FC)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['MOSCOW'] = {
            ['Name'] = "Moskva (CG)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['NEUSTRASH'] = {
            ['Name'] = "Neustrashimy (DD)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['PERRY'] = {
            ['Name'] = "Oliver H. Perry (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.028552, 0.000696 },
                [false] = { 0.028552, 0.000696 }
            },
            ['Primary'] = true
        },
        ['PIOTR'] = {
            ['Name'] = "Kirov (CG)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.024983, 0.012491 }
            },
            ['Primary'] = true
        },
        ['REZKY'] = {
            ['Name'] = "Krivak (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = HOUND.DB.Bands.H,
                [false] = HOUND.DB.Bands.H
            },
            ['Primary'] = true
        },
        ['LHA_Tarawa'] = {
            ['Name'] = "Tarawa (LHA)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['TICONDEROG'] = {
            ['Name'] = "Ticonderoga (CG)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.024983, 0.012491 },
                [false] = { 0.318251, 0.034446 }
            },
            ['Primary'] = true
        },
        -- South Atlantic naval assets
        ['hms_invincible'] = {
            ['Name'] = "Invincible (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['leander-gun-achilles'] = {
            ['Name'] = "Leander (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['leander-gun-andromeda'] = {
            ['Name'] = "Leander (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['leander-gun-ariadne'] = {
            ['Name'] = "Leander (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['leander-gun-condell'] = {
            ['Name'] = "Condell (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['leander-gun-lynch'] = {
            ['Name'] = "Condell (FF)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.516884, 0.082701 }
            },
            ['Primary'] = true
        },
        ['ara_vdm'] = {
            ['Name'] = "Veinticinco de Mayo (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = { 0.516884, 0.082701 },
                [false] = { 0.136269, 0.013627 }
            },
            ['Primary'] = true
        },
        ['santafe'] = {
        ['Name'] = "Balao Class (SS)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = {0.136269,0.013627},
                [false] = {0.136269,0.013627}
        },
        ['Primary'] = true
        },
        -- WWII Naval vessels
        ['Essex'] = {
            ['Name'] = "Essex (CV)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                    [true] = {0.516884,0.082701},
                    [false] = {0.136269,0.013627}
            },
            ['Primary'] = true
        },
        -- None Combat vessels
        ['BDK-775'] = {
            ['Name'] = "Ropucha (LS)",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = HOUND.DB.Bands.E,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['Type_071'] = {
            ['Name'] = "Yuzhao transport",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = HOUND.DB.Bands.E,
                [false] = HOUND.DB.Bands.E
            },
            ['Primary'] = true
        },
        ['atconveyor'] = {
            ['Name'] = "SS Atlantic Conveyor",
            ['Assigned'] = { "Naval" },
            ['Role'] = { HOUND.DB.RadarType.NAVAL },
            ['Band'] = {
                [true] = HOUND.DB.Bands.D,
                [false] = HOUND.DB.Bands.D
            },
            ['Primary'] = true
        },
    }

    --- Valid platform parameters
    -- @table HOUND.DB.Platform
    -- @field UnitTypeName contains table of properties
    -- @usage ['C-130'] = {antenna = {size = 35, factor = 1}}

    HOUND.DB.Platform = {
        [Object.Category.STATIC] = {
            ['Comms tower M']   = { antenna = { size = 107, factor = 1 }, ins_error = 0 },
            ['.Command Center'] = { antenna = { size = 62, factor = 1 }, ins_error = 0 },
            ['Cow']             = { antenna = { size = 1000, factor = 10 }, ins_error = 0 },
            -- ['m1_vla'] = {antenna = {size = 15, factor = 1},ins_error=0}, --waiting for ED to fix their bugs
            ['TV tower']        = { antenna = { size = 235, factor = 1 }, ins_error = 0 },
        },
        [Object.Category.UNIT] = {
            -- Ground Units
            ['Patriot AMG'] = { antenna = { size = 15, factor = 1 }, ins_error = 0 },
            ['SPK-11'] = { antenna = { size = 15, factor = 1 }, ins_error = 0 },
            -- Helicopters
            ['CH-47D'] = { antenna = { size = 12, factor = 1 }, ins_error = 0 },
            ['CH-53E'] = { antenna = { size = 10, factor = 1 }, ins_error = 0 },
            ['MIL-26'] = { antenna = { size = 20, factor = 1 }, ins_error = 50 },
            ['SH-60B'] = { antenna = { size = 8, factor = 1 }, ins_error = 0 },
            ['UH-60A'] = { antenna = { size = 8, factor = 1 }, ins_error = 0 },
            ['Mi-8MT'] = { antenna = { size = 8, factor = 1 }, ins_error = 0 },
            ['UH-1H'] = { antenna = { size = 4, factor = 1 }, ins_error = 50 },
            ['KA-27'] = { antenna = { size = 4, factor = 1 }, ins_error = 50 },
            -- Airplanes
            ['C-130'] = { antenna = { size = 35, factor = 1 }, ins_error = 0 },
            -- ['KC135MPRS'] = {antenna = {size = 40, factor = 1}, require = { TASK={'~Refueling'}}},
            -- ['KC-135'] = {antenna = {size = 40, factor = 1}, require = { TASK={'~Refueling'}}}
            ['C-17A'] = { antenna = { size = 40, factor = 1 }, ins_error = 0 }, -- stand-in for RC-135, tuned antenna size to match
            ['S-3B'] = { antenna = { size = 18, factor = 0.8 }, ins_error = 0 },
            ['E-3A'] = { antenna = { size = 9, factor = 0.5 }, ins_error = 0 },
            ['E-2C'] = { antenna = { size = 7, factor = 0.5 }, ins_error = 0 },
            ['Tu-95MS'] = { antenna = { size = 50, factor = 1 }, ins_error = 50 },
            ['Tu-142'] = { antenna = { size = 50, factor = 1 }, ins_error = 0 },
            ['IL-76MD'] = { antenna = { size = 48, factor = 0.8 }, ins_error = 50 },
            ['H-6J'] = { antenna = { size = 3.5, factor = 1 }, require = { Payload = {'PHANTASM'} }, ins_error = 100 },
            ['Su-24M'] = { antenna = { size = 3.5, factor = 1 }, require = { Payload = {'PHANTASM'} }, ins_error = 50 },
            ['Su-24MR'] = { antenna = { size = 4.5, factor = 1 }, require = { Payload = {'TANGAZH'} }, ins_error = 50 },
            ['Su-25TM'] = { antenna = { size = 3.5, factor = 1 }, require = { Payload = {'PHANTASM'} }, ins_error = 50 },
            ['An-30M'] = { antenna = { size = 25, factor = 1 }, ins_error = 50 },
            ['A-50'] = { antenna = { size = 9, factor = 0.5 }, ins_error = 0 },
            ['An-26B'] = { antenna = { size = 26, factor = 1 }, ins_error = 100 },
            ['C-47'] = { antenna = { size = 12, factor = 1 }, ins_error = 100 },
            -- Fighters
            ['Su-25T'] = { antenna = { size = 3.5, factor = 1 }, require = { Payload = {'PHANTASM'} }, ins_error = 50 },
            ['AJS37'] = { antenna = { size = 4.5, factor = 1 }, require = { Payload = {'U22/A Jammer Pod','U22 Jammer'} }, ins_error = 50 },
            ['F-16C_50'] = { antenna = { size = 1.45, factor = 1 }, require = { Payload = {'f-16c_hts_pod'} }, ins_error = 0 },
            ['JF-17'] = { antenna = { size = 3.25, factor = 1 }, require = { Payload = {'KG-600'} }, ins_error = 0 },
            -- Mirage F1 placeholders. Thanks Viboa and Aerges for supplying the typeNames for the module's aircrafts.
            -- ['Mirage-F1CE'] = {antenna = {size = 3.7, factor = 1}, require = {Payload={'TMV_018_Syrel_POD'}},ins_error=100}, -- temporary for intial release, CE had not INS, therefor could not do ELINT.
            ['Mirage-F1EE'] = { antenna = { size = 3.7, factor = 1 }, require = { Payload = {'TMV_018_Syrel_POD'} }, ins_error = 50 },  -- does not reflect features in actual released product
            ['Mirage-F1M-CE'] = { antenna = { size = 3.7, factor = 1 }, require = { Payload = {'TMV_018_Syrel_POD'} }, ins_error = 0 }, -- does not reflect features in actual released product
            ['Mirage-F1M-EE'] = { antenna = { size = 3.7, factor = 1 }, require = { Payload = {'TMV_018_Syrel_POD'} }, ins_error = 0 }, -- does not reflect features in actual released product
            ['Mirage-F1CR'] = { antenna = { size = 4, factor = 1 }, require = { Payload = {'ASTAC_POD'} }, ins_error = 0 },             -- AI only (FAF)
            ['Mirage-F1EQ'] = { antenna = { size = 3.7, factor = 1 }, require = { Payload = {'TMV_018_Syrel_POD'} }, ins_error = 50 },  -- AI only (Iraq)
            ['Mirage-F1EDA'] = { antenna = { size = 3.7, factor = 1 }, require = { Payload = {'TMV_018_Syrel_POD'} }, ins_error = 50 }, -- AI only (Qatar)
        }
    }
end
