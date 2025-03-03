local love = require("love")

local enemyList = {}

enemyList.troublemaker = function()
    local dftHealth      = 48
    return {
        name           = "troublemaker",
        dftHealth      = dftHealth,
        health         = dftHealth,
        x              = 852,
        y              = 416,
        dmg            = -7,
        spr      = love.graphics.newImage("assets/img/troublemaker.png"),
        movefunc       = function(x, y)
            local nx = x - math.abs(math.sin(os.clock())) * 0.5 * ((question.dftTime - question.time) / 15)
            local ny = y + math.cos(os.clock()) * 0.25

            return nx, ny
        end,
        isDead         = false,
        rot            = 0,
        operation_max  = 3,
        operation_min  = 1
    }
end

enemyList.pistolet     = function()
    local dftHealth      = 64
    return {
        name           = "pistolet",
        dftHealth      = dftHealth,
        health         = dftHealth,
        x              = 852,
        y              = 380,
        dmg            = -9,
        spr      = love.graphics.newImage("assets/img/pistolet.png"),
        movefunc       = function(x, y)
            local nx = x - math.abs(math.sin(os.clock())) * 0.75 * ((question.dftTime - question.time) / 15)
            local ny = y + math.cos(os.clock()) * 0.1

            return nx, ny
        end,
        isDead         = false,
        rot            = 0,
        operation_max  = 5,
        operation_min  = 1
    }
end

enemyList.catsaw       = function()
    local dftHealth    = 80
    return {
        name           = "catsaw",
        dftHealth      = dftHealth,
        health         = dftHealth,
        x              = 852,
        y              = 380,
        dmg            = -11,
        spr      = love.graphics.newImage("assets/img/catsaw.png"),
        movefunc       = function(x, y)
            local nx = x - math.abs(math.sin(os.clock())) * 0.75 * ((question.dftTime - question.time) / 15)
            local ny = y + math.cos(os.clock()) * 0.05

            return nx, ny
        end,
        isDead         = false,
        rot            = 0,
        operation_max  = 5,
        operation_min  = 2
    }
end

enemyList.dummemaus    = function()
    local dftHealth      = 32
    return {
        name           = "dummemaus",
        dftHealth      = dftHealth,
        health         = dftHealth,
        x              = 852,
        y              = 416,
        dmg            = -5,
        spr      = love.graphics.newImage("assets/img/dummemaus.png"),
        movefunc       = function(x, y)
            local nx = x - (math.sin(os.clock()) + 1.25) * 0.25 * ((question.dftTime - question.time) / 15)
            local ny = y + math.cos(os.clock()) * 0.1

            return nx, ny
        end,
        isDead         = false,
        rot            = 0,
        operation_max  = 3,
        operation_min  = 1
    }
end

return enemyList