local love = require("love")

-- Totally unfinished. Seriously.

local itemsList = {}

itemsList.shield = {
    -- denomination:
    type    = "armor",
    desc    = "A simple, generic and 'uncreative' shield. There's literally nothing special in it, ugh",
    -- attributes:
    health_plus = 10,
}
itemsList.sword = {
    -- denomination:
    type    = "weapon",
    desc    = "A simple, generic and 'uncreative' sword. There's literally nothing special in it, ugh",
    -- attributes:
    dmg_plus = -2,
}

return itemsList