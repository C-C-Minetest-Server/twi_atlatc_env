F.passing_loop({
    signal = POS(-4068, 30, 494),
    default_route = "C",

    after_signall = POS(-4068, 30, 430),
    after_default_route = "C",

    custom_set_route = function(train)
        if train:has_rc("L-S21") or train:has_rc("B-MOS-T2S") then
            return "MOT-T2S"
        elseif train:has_rc("B-MOS-T1S") then
            return "MOT-T1S"
        end
    end,

    checked_sections = {
        "81609531",
        "94237997",
        "58986607",
        "66294252",
        "19320484",
        "33318720",
        "50616713",
        "99034954",
        "83611064",
        "74977768",
        "42918772",
        "34055472",
        "59173950",
        "63647683",
        "48879652",
        "28434089",
        "60408240",
        "31145024",
        "44331562",
    },

    passing_loops = {
        ["MOT-T2S"] = {
            max_tl = 49,
        },
    },
})