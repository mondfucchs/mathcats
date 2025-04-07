local utils = {}

-- Unpacks 't' (for LÖVE2D)
utils.unpackLove = function(t, _i)
    local i = _i or 1

    local n = #t
    if i > n then
        return nil
    end

    return t[i], utils.unpackLove(t, i + 1)
end
-- Round 'n' to 'm'
utils.roundTo = function(n, m)
    local div = n / m
    return (div > 0) and math.floor(div) * m or math.ceil(div) * m
end
-- Adds 'm' to 'n' without 'n' getting bigger than 'min' or 'max':
utils.addInInterval = function(n, m, min, max)
    local sum = n + m
    if     sum > max then return max
    elseif sum < min then return min
    else   return sum end
end
-- Limit 'n' to 'max' and 'min', very similar to ```addInInterval()```.
utils.limitTo = function(n, min, max)
    if     n > max then return max
    elseif n < min then return min
    else   return n end 
end

utils.restartBattle = function(enemyfunc)
        -- Setting eventtables:
    _G.mainclock  = {}

    --> Setting up small objects:
        game.state           = "battle"

        malusfelis.dftHealth = 22 + malusfelis.equipment.armor
        malusfelis.dmg       = -2 + malusfelis.equipment.weapon

        malusfelis.health    = malusfelis.dftHealth
            malusfelis.x     = 96
            malusfelis.y     = 352
        malusfelis.state     = "idle"
        malusfelis.isDead    = false

        _G.enemy             = enemyfunc()

        _G.timeMesg, _G.healthMesg       = {}, {}
        timeMesg.mesg, healthMesg.mesg   = "", ""
        timeMesg.color, healthMesg.color = {1, 1, 1, 1}, {1, 1, 1, 1}

        healthMesg.pos = {136, 104}
        timeMesg.pos   = {368, 104}

    do
        _G.guess = ""

        _G.question   = {}

        question.dftTime     = 45
        question.time        = question.dftTime
        question.timeblow    = 10

        question.active      = true

        question.posHealth   = 1
        question.negHealth   = -2

        question.posTime     = 3
        question.negTime     = -2

        question.dftPoints   = {phealth= 1, nhealth=-2, ptime=1, ntime=-2}

        newQuestion()
    end

    _G.triggtable = {}
end

return utils