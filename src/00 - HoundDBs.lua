-- --------------------------------------
-- Radar Database
do
    HoundSamDB = {
        -- EWR --
        ['p-19 s-125 sr'] = {
            ['Name'] = "Flat Face",
            ['Assigned'] = "SA-2/3",
            ['Role'] = "SR"
        },
        ['1L13 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR"
        },
        ['55G6 EWR'] = {
            ['Name'] = "EWR",
            ['Assigned'] = "EWR",
            ['Role'] = "EWR"
        },
        -- SAM radars --
        ['SNR_75V'] = {
            ['Name'] = "Fan-song",
            ['Assigned'] = "SA-2",
            ['Role'] = "SNR"
        },
        ['snr s-125 tr'] = {
            ['Name'] = "Low Blow",
            ['Assigned'] = "SA-3",
            ['Role'] = "TR"
        },
        ['Kub 1S91 str'] = {
            ['Name'] = "Straight Flush",
            ['Assigned'] = "SA-6",
            ['Role'] = "STR"
        },
        ['Osa 9A33 ln'] = {
            ['Name'] = "Osa",
            ['Assigned'] = "SA-8",
            ['Role'] = "STR"
        },
        ['S-300PS 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR"
        },
        ['S-300PS 64H6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR"
        },
        ['S-300PS 40B6M tr'] = {
            ['Name'] = "Tomb Stone",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR"
        },

        ['SA-11 Buk SR 9S18M1'] = {
            ['Name'] = "Snow Drift",
            ['Assigned'] = "SA-11",
            ['Role'] = "SR"
        },
        ['SA-11 Buk LN 9A310M1'] = {
            ['Name'] = "SA-11 LN/TR",
            ['Assigned'] = "SA-11",
            ['Role'] = "TR"
        },
        ['Tor 9A331'] = {
            ['Name'] = "Tor",
            ['Assigned'] = "SA-15",
            ['Role'] = "STR"
        },
        ['Strela-1 9P31'] = {
            ['Name'] = "SA-9",
            ['Assigned'] = "SA-9",
            ['Role'] = "TR"
        },
        ['Strela-10M3'] = {
            ['Name'] = "SA-13",
            ['Assigned'] = "SA-13",
            ['Role'] = "TR"
        },
        ['Patriot str'] = {
            ['Name'] = "Patriot",
            ['Assigned'] = "Patriot",
            ['Role'] = "STR"
        },
        ['Hawk sr'] = {
            ['Name'] = "Hawk SR",
            ['Assigned'] = "Hawk",
            ['Role'] = "SR"
        },
        ['Hawk tr'] = {
            ['Name'] = "Hawk TR",
            ['Assigned'] = "Hawk",
            ['Role'] = "TR"
        },
        ['Hawk cwar'] = {
            ['Name'] = "Hawk CWAR",
            ['Assigned'] = "Hawk",
            ['Role'] = "TR"
        },
        ['Roland ADS'] = {
            ['Name'] = "Roland TR",
            ['Assigned'] = "Roland",
            ['Role'] = "TR"
        },
        ['Roland Radar'] = {
            ['Name'] = "Roland SR",
            ['Assigned'] = "Roland",
            ['Role'] = "SR"
        },
        ['Gepard'] = {
            ['Name'] = "Gepard",
            ['Assigned'] = "Gepard",
            ['Role'] = "STR"
        },
        ['rapier_fsa_blindfire_radar'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = "Rapier",
            ['Role'] = "TR"
        },
        ['rapier_fsa_launcher'] = {
            ['Name'] = "Rapier",
            ['Assigned'] = "Rapier",
            ['Role'] = "TR"
        },
        ['HQ-7_STR_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = "HQ-7",
            ['Role'] = "STR"
        },
        ['HQ-7_LN_SP'] = {
            ['Name'] = "HQ-7",
            ['Assigned'] = "HQ-7",
            ['Role'] = "TR"
        },
        ['2S6 Tunguska'] = {
            ['Name'] = "Tunguska",
            ['Assigned'] = "Tunguska",
            ['Role'] = "STR"
        },
        ['ZSU-23-4 Shilka'] = {
            ['Name'] = "Shilka",
            ['Assigned'] = "Shilka",
            ['Role'] = "TR"
        },
        ['Dog Ear radar'] = {
            ['Name'] = "AAA SR",
            ['Assigned'] = "AAA",
            ['Role'] = "SR"
        },
        -- highdigitsams radars --
        ['S-300PS 64H6E TRAILER sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR"
        },
        ['S-300PS SA-10B 40B6MD MAST sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR"
        },
        ['S-300PS 40B6M MAST tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR"
        },
        ['S-300PS 30H6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR"
        },
        ['S-300PS 30N6 TRAILER tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR"
        },
        ['S-300PMU1 40B6MD sr'] = {
            ['Name'] = "Clam Shell",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR"
        },
        ['S-300PMU1 64N6E sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-10",
            ['Role'] = "SR"
        },
        ['S-300PMU1 30N6E tr'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR"
        },
        ['S-300PMU1 40B6M tr'] = {
            ['Name'] = "Grave Stone",
            ['Assigned'] = "SA-10",
            ['Role'] = "TR"
        },
        ['S-300V 9S15 sr'] = {
            ['Name'] = 'Bill Board',
            ['Assigned'] = "SA-12",
            ['Role'] = "SR"
        },
        ['S-300V 9S19 sr'] = {
            ['Name'] = 'High Screen',
            ['Assigned'] = "SA-12",
            ['Role'] = "SR"
        },
        ['S-300V 9S32 tr'] = {
            ['Name'] = 'Grill Pan',
            ['Assigned'] = "SA-12",
            ['Role'] = "TR"
        },
        ['S-300PMU2 92H6E tr'] = {
            ['Name'] = 'Grave Stone',
            ['Assigned'] = "SA-20B",
            ['Role'] = "TR"
        },
        ['S-300PMU2 64H6E2 sr'] = {
            ['Name'] = "Big Bird",
            ['Assigned'] = "SA-20B",
            ['Role'] = "SR"
        },
        ['S-300VM 9S15M2 sr'] = {
            ['Name'] = 'Bill Board M',
            ['Assigned'] = "SA-23",
            ['Role'] = "SR"
        },
        ['S-300VM 9S19M2 sr'] = {
            ['Name'] = 'High Screen M',
            ['Assigned'] = "SA-23",
            ['Role'] = "SR"
        },
        ['S-300VM 9S32ME tr']  = {
            ['Name'] = 'Grill Pan M',
            ['Assigned'] = "SA-23",
            ['Role'] = "TR"
        },
        ['SA-17 Buk M1-2 LN 9A310M1-2'] = {
            ['Name'] = "SA-17 LN/TR",
            ['Assigned'] = "SA-17",
            ['Role'] = "TR"
        },
        ['34Ya6E Gazetchik E decoy'] = {
            ['Name'] = "Flap Lid",
            ['Assigned'] = "SA-10",
            ['Role'] = "Decoy"
        },
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

do
    PlatformData = {
        [Object.Category.STATIC] = {["Comms tower M"] = {precision = 0.15}},
        [Object.Category.UNIT] = {
            -- Ground Units
            ["MLRS FDDM"] = {precision = 0.5},
            ["SPK-11"] = {precision = 0.5},
            -- Helicopters
            ["CH-47D"] = {precision = 2.5},
            ["CH-53E"] = {precision = 2.5},
            ["MIL-26"] = {precision = 2.5},
            ["SH-60B"] = {precision = 4.0},
            ["UH-60A"] = {precision = 4.0},
            ["Mi-8MT"] = {precision = 4.0},
            ["UH-1H"] = {precision = 6.0},
            ["KA-27"] = {precision = 6.0},
            -- Airplanes
            ["C-130"] = {precision = 1.0},
            ["C-17A"] = {precision = 1.0},
            ["S-3B"] = {precision = 1.5},
            ["E-3A"] = {precision = 2.0},
            ["E-2D"] = {precision = 2.0},
            ["Tu-95MS"] = {precision = 1.0},
            ["Tu-142"] = {precision = 1.0},
            ["IL-76MD"] = {precision = 1.0},
            ["An-30M"] = {precision = 1.0},
            ["A-50"] = {precision = 2.0},
            ["An-26B"] = {precision = 2.0},
            ["Su-25T"] = {precision = 2.5},
            ["AJS37"] = {precision = 2.5}
        }
    }
end
