-- --------------------------------------
-- Radar Database
HoundDB = {}
do
    HoundDB.Sam = {
        -- EWR --
        ['p-19 s-125 sr'] = {
            ['Name'] = "Flat Face",
            ['Assigned'] = "SA-2/3",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['1L13 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'A'
        },
        ['55G6 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR",
            ['Band'] = 'A'
        },
        -- SAM radars --
        ['SNR_75V'] = {
            ['Name'] = "Fan-song",
            ['Assigned'] = "SA-2",
            ['Role'] = "SNR",
            ['Band'] = 'E'
        },
        ['snr s-125 tr'] = {
            ['Name'] = "Low Blow",
            ['Assigned'] = "SA-3",
            ['Role'] = "TR",
            ['Band'] = 'D'
        },
        ['Kub 1S91 str'] = {
            ['Name'] = "Straight Flush",
            ['Assigned'] = "SA-6",
            ['Role'] = "STR",
            ['Band'] = 'G'
        },
        ['Osa 9A33 ln'] = {
            ['Name'] = "Osa",
            ['Assigned'] = "SA-8",
            ['Role'] = "STR",
            ['Band'] = 'H'
        },
        ['S-300PS 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['S-300PS 64H6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300PS 40B6M tr'] = {
            ['Name'] = "Tomb Stone",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },

        ['SA-11 Buk SR 9S18M1'] = {
            ['Name'] = "Snow Drift",
            ['Assigned'] = "SA-11",
            ['Role'] = "SR",
            ['Band'] = 'G'
        },
        ['SA-11 Buk LN 9A310M1'] = {
            ['Name'] = "SA-11 LN/TR",
            ['Assigned'] = "SA-11",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['Tor 9A331'] = {
            ['Name'] = "Tor",
            ['Assigned'] = "SA-15",
            ['Role'] = "STR",
            ['Band'] = 'F'
        },
        ['Strela-1 9P31'] = {
            ['Name'] = "SA-9",
            ['Assigned'] = "SA-9",
            ['Role'] = "TR",
            ['Band'] = 'K'
        },
        ['Strela-10M3'] = {
            ['Name'] = "SA-13",
            ['Assigned'] = "SA-13",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Patriot str'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = "Patriot",
            ['Role'] = "STR",
            ['Band'] = 'K'
        },
        ['Hawk sr'] = {
            ['Name'] = "Hawk SR",
            ['Assigned'] = "Hawk",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['Hawk tr'] = {
            ['Name'] = "Hawk TR",
            ['Assigned'] = "Hawk",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Hawk cwar'] = {
            ['Name'] = "Hawk CWAR",
            ['Assigned'] = "Hawk",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Roland ADS'] = {
            ['Name'] = "Roland TR",
            ['Assigned'] = "Roland",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['Roland Radar'] = {
            ['Name'] = "Roland SR",
            ['Assigned'] = "Roland",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['Gepard'] = {
            ['Name'] = "Gepard",
            ['Assigned'] = "Gepard",
            ['Role'] = "STR",
            ['Band'] = 'E'
        },
        ['rapier_fsa_blindfire_radar'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = "Rapier",
            ['Role'] = "TR",
            ['Band'] = 'D'
        },
        ['rapier_fsa_launcher'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = "Rapier",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['HQ-7_STR_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = "HQ-7",
            ['Role'] = "SR",
            ['Band'] = 'F'
        },
        ['HQ-7_LN_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = "HQ-7",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['2S6 Tunguska'] = {
            ['Name'] = "Tunguska",
            ['Assigned'] = "Tunguska",
            ['Role'] = "STR",
            ['Band'] = 'F'
        },
        ['ZSU-23-4 Shilka'] = {
            ['Name'] = "Shilka",
            ['Assigned'] = "Shilka",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['Dog Ear radar'] = {
            ['Name'] = "AAA SR",
            ['Assigned'] = "AAA",
            ['Role'] = "SR",
            ['Band'] = 'G'
        },
        -- highdigitsams radars --
        ['S-300PS 64H6E TRAILER sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300PS SA-10B 40B6MD MAST sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['S-300PS 40B6M MAST tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PS 30H6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PS 30N6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PMU1 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'I'
        },
        ['S-300PMU1 64N6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300PMU1 30N6E tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PMU1 40B6M tr'] = {
            ['Name'] = "Grave Stone",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300V 9S15 sr'] = {
            ['Name'] = 'Bill Board',
            ['Assigned'] = "SA-12",
            ['Role'] = "SR",
            ['Band'] = 'E'
        },
        ['S-300V 9S19 sr'] = {
            ['Name'] = 'High Screen',
            ['Assigned'] = "SA-12",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300V 9S32 tr'] = {
            ['Name'] = 'Grill Pan',
            ['Assigned'] = "SA-12",
            ['Role'] = "TR",
            ['Band'] = 'J'
        },
        ['S-300PMU2 92H6E tr'] = {
            ['Name'] = 'Grave Stone',
            ['Assigned'] = "SA-20B",
            ['Role'] = "TR",
            ['Band'] = 'I'
        },
        ['S-300PMU2 64H6E2 sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-20B",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300VM 9S15M2 sr'] = {
            ['Name'] = 'Bill Board M',
            ['Assigned'] = "SA-23",
            ['Role'] = "SR",
            ['Band'] = 'E'
        },
        ['S-300VM 9S19M2 sr'] = {
            ['Name'] = 'High Screen M',
            ['Assigned'] = "SA-23",
            ['Role'] = "SR",
            ['Band'] = 'C'
        },
        ['S-300VM 9S32ME tr'] = {
            ['Name'] = 'Grill Pan M',
            ['Assigned'] = "SA-23",
            ['Role'] = "TR",
            ['Band'] = 'K'
        },
        ['SA-17 Buk M1-2 LN 9A310M1-2'] = {
            ['Name'] = "SA-17 LN/TR",
            ['Assigned'] = "SA-17",
            ['Role'] = "TR",
            ['Band'] = 'H'
        },
        ['34Ya6E Gazetchik E decoy'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "Decoy",
            ['Band'] = 'J'
        }
    }
end

do
    PHONETIC = {
        ["A"] = "Alpha",
        ["B"] = "Bravo",
        ["C"] = "Charlie",
        ["D"] = "Delta",
        ["E"] = "Echo",
        ["F"] = "Foxtrot",
        ["G"] = "Golf",
        ["H"] = "Hotel",
        ["I"] = "India",
        ["J"] = "Juliette",
        ["K"] = "Kilo",
        ["L"] = "Lima",
        ["M"] = "Mike",
        ["N"] = "November",
        ["O"] = "Oscar",
        ["P"] = "Papa",
        ["Q"] = "Quebec",
        ["R"] = "Romeo",
        ["S"] = "Sierra",
        ["T"] = "Tango",
        ["U"] = "Uniform",
        ["V"] = "Victor",
        ["W"] = "Whiskey",
        ["X"] = "X ray",
        ["Y"] = "Yankee",
        ["Z"] = "Zulu",
        ["1"] = "One",
        ["2"] = "two",
        ["3"] = "three",
        ["4"] = "four",
        ["5"] = "five",
        ["6"] = "six",
        ["7"] = "seven",
        ["8"] = "eight",
        ["9"] = "Niner",
        ["0"] = "zero"
    }
end

do useDecMin = {["F-16C_blk50"] = true, ["A-10C"] = true} end

do
    HoundDB.Platform = {
        [Object.Category.STATIC] = {["Comms tower M"] = {precision = 0.15, antenna = {size = 80, factor = 1}}},
        [Object.Category.UNIT] = {
            -- Ground Units
            ["MLRS FDDM"] = {precision = 0.5, antenna = {size = 15, factor = 1}},
            ["SPK-11"] = {precision = 0.5, antenna = {size = 15, factor = 1}},
            -- Helicopters
            ["CH-47D"] = {precision = 2.5, antenna = {size = 12, factor = 1}},
            ["CH-53E"] = {precision = 2.5, antenna = {size = 10, factor = 1}},
            ["MIL-26"] = {precision = 2.5, antenna = {size = 20, factor = 1}},
            ["SH-60B"] = {precision = 4.0, antenna = {size = 8, factor = 1}},
            ["UH-60A"] = {precision = 4.0, antenna = {size = 8, factor = 1}},
            ["Mi-8MT"] = {precision = 4.0, antenna = {size = 9, factor = 1}},
            ["UH-1H"] = {precision = 6.0, antenna = {size = 7, factor = 1}},
            ["KA-27"] = {precision = 6.0, antenna = {size = 6, factor = 1}},
            -- Airplanes
            ["C-130"] = {precision = 1.5, antenna = {size = 35, factor = 1}},
            ["C-17A"] = {precision = 1.5, antenna = {size = 50, factor = 1}},
            ["S-3B"] = {precision = 2.0, antenna = {size = 18, factor = 0.8}},
            ["E-3A"] = {precision = 5.0, antenna = {size = 45, factor = 0.5}},
            ["E-2D"] = {precision = 5.0, antenna = {size = 20, factor = 0.5}},
            ["Tu-95MS"] = {precision = 1.5, antenna = {size = 50, factor = 1}},
            ["Tu-142"] = {precision = 1.5, antenna = {size = 50, factor = 1}},
            ["IL-76MD"] = {precision = 1.5, antenna = {size = 48, factor = 0.8}},
            ["An-30M"] = {precision = 1.5, antenna = {size = 25, factor = 1}},
            ["A-50"] = {precision = 5, antenna = {size = 48, factor = 0.5}},
            ["An-26B"] = {precision = 2.0, antenna = {size = 26, factor = 0.9}},
            ["Su-25T"] = {precision = 2.5, antenna = {size = 4, factor = 0.75}},
            ["AJS37"] = {precision = 2.5, antenna = {size = 4, factor = 0.75}}
        }
    }

    HoundDB.Bands = {
        ["A"] = 1.713100,
        ["C"] = 0.399723,
        ["B"] = 0.799447,
        ["E"] = 0.119917,
        ["D"] = 0.199862,
        ["G"] = 0.059958,
        ["F"] = 0.085655,
        ["I"] = 0.033310,
        ["H"] = 0.042827,
        ["K"] = 0.009993,
        ["J"] = 0.019986,
        ["L"] = 0.005996
    }
end
