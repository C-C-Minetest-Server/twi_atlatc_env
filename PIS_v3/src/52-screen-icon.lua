assert(is_loading)

-- 12x12 icons and fonts

F.screen_icons = {
    font_not_found = {
        { false, false, false,    false,    false,    false,    false,    false,    false,    false,    false, false },
        { false, false, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, false, false },
        { false, false, 0x000000, 0x000000, false,    false,    false,    false,    0x000000, 0x000000, false, false },
        { false, false, 0x000000, false,    0x000000, false,    false,    0x000000, false,    0x000000, false, false },
        { false, false, 0x000000, false,    false,    0x000000, 0x000000, false,    false,    0x000000, false, false },
        { false, false, 0x000000, false,    false,    0x000000, 0x000000, false,    false,    0x000000, false, false },
        { false, false, 0x000000, false,    false,    0x000000, 0x000000, false,    false,    0x000000, false, false },
        { false, false, 0x000000, false,    false,    0x000000, 0x000000, false,    false,    0x000000, false, false },
        { false, false, 0x000000, false,    0x000000, false,    false,    0x000000, false,    0x000000, false, false },
        { false, false, 0x000000, 0x000000, false,    false,    false,    false,    0x000000, 0x000000, false, false },
        { false, false, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, false, false },
        { false, false, false,    false,    false,    false,    false,    false,    false,    false,    false, false },
    },
    subway = {
        { false, false, false,    false,    false,    false,    false,    false,    false,    false,    false, false },
        { false, false, false,    false,    false,    false,    false,    false,    false,    false,    false, false },
        { false, false, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, false, false },
        { false, false, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000, false, false },
        { false, false, 0x000000, 0xFFFFFF, 0xE8E8E8, 0xE8E8E8, 0xE8E8E8, 0xE8E8E8, 0xFFFFFF, 0x000000, false, false },
        { false, false, 0x000000, 0xFFFFFF, 0xE8E8E8, 0xE8E8E8, 0xE8E8E8, 0xE8E8E8, 0xFFFFFF, 0x000000, false, false },
        { false, false, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000, false, false },
        { false, false, 0x000000, 0x000000, 0xDFFF00, 0x000000, 0x000000, 0xDFFF00, 0x000000, 0x000000, false, false },
        { false, false, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000, false, false },
        { false, false, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, false, false },
        { false, false, false,    false,    0x000000, false,    false,    0x000000, false,    false,    false, false },
        { false, false, false,    false,    false,    false,    false,    false,    false,    false,    false, false },
    },
    high_speed_rail = {
        { false,    false,    false,    false,    false,    false,    false,    false,    false,    false,    false,    false },
        { false,    false,    false,    false,    false,    false,    false,    false,    false,    false,    false,    false },
        { false,    false,    false,    false,    false,    0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000 },
        { false,    false,    false,    false,    0x000000, 0xFFFFFF, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000 },
        { false,    false,    false,    0x000000, 0xFFFFFF, 0xFFFFFF, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000 },
        { false,    false,    0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000 },
        { false,    0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000 },
        { 0x000000, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x56B300, 0x000000 },
        { 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000 },
        { 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000 },
        { false,    false,    false,    0x000000, false,    false,    false,    false,    false,    0x000000, false,    false },
        { false,    false,    false,    false,    false,    false,    false,    false,    false,    false,    false,    false },
    },
}
