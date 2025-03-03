--> external libraries:
    local love = require("love")
    local u    = require("utils")
    local m    = require("mathmaker")
    local c    = require("clock")
    local t    = require("triggers")

--> external lists:
    local enemies = require("assets.lists.enemyList")
    local items   = require("assets.lists.itemsList")

-- Getting randomseed:
math.randomseed(os.time() + os.clock() * 717171)

function love.load()
    -- Setting eventtables:
    _G.mainclock  = c.newClock()
    _G.triggtable = {}

    --> Setting up small objects:
        -- game :I
        _G.game              = {}
        -- Can be "battle" (v) "paused" (v) "world" (...)
        game.state           = "loading"
        game.stage           = 1
        game.stages          = {
            {enemyname="dummemaus", won=false},
            {enemyname="troublemaker", won=false},
            {enemyname="pistolet", won=false},
            {enemyname="catsaw", won=false}
        } -- For now, it's almost a debug tool.
        game.isComplete      = false
        game.completedEventPlayed = false

        --> player:
            do -- battlemalusfelis
                _G.malusfelis        = {}
                malusfelis.equipment = {}
                    malusfelis.equipment.weaponname = nil
                    malusfelis.equipment.armorname  = nil
                    malusfelis.equipment.weapon     = items[malusfelis.equipment.weaponname] and items[malusfelis.equipment.weaponname].dmg_plus or 0
                    malusfelis.equipment.armor      = items[malusfelis.equipment.armorname]  and items[malusfelis.equipment.armorname].health_plus or 0
                malusfelis.dftHealth = 22 + malusfelis.equipment.armor
                malusfelis.dmg       = -2 + malusfelis.equipment.weapon
                malusfelis.health     = malusfelis.dftHealth
                malusfelis.bsprs      = {}
                --- position:
                    malusfelis.battlepos       = {}
                    malusfelis.battlepos.x     = 96
                    malusfelis.battlepos.y     = 352
                -- Can be "idle" "dmgd" "winn"
                malusfelis.state      = "idle"
                malusfelis.isDead     = false
            end

        -- enemy (done in external library `enemyList.lua`):
        _G.enemy             = {}

        -- messages:
        _G.timeMesg, _G.healthMesg       = {}, {}
        timeMesg.mesg, healthMesg.mesg   = "", ""
        timeMesg.color, healthMesg.color = {1, 1, 1, 1}, {1, 1, 1, 1}

        healthMesg.pos = {136, 104}
        timeMesg.pos   = {368, 104}

    --> Importing Assets:

        -- img
        malusfelis.bsprs.idle = love.graphics.newImage("assets/img/malusfelis.png")
        malusfelis.bsprs.dmgd = love.graphics.newImage("assets/img/malusfelis dmgd.png")
        malusfelis.bsprs.dead = love.graphics.newImage("assets/img/malusfelis dead.png")
        malusfelis.bsprs.winn = love.graphics.newImage("assets/img/malusfelis winn.png")
        malusfelis.worldspr   = love.graphics.newImage("assets/img/malusfelis world.png")
        _G.worldbackground = love.graphics.newImage("assets/img/world.png")
        _G.background  = love.graphics.newImage("assets/img/background.png")
        _G.finalScreen = love.graphics.newImage("assets/img/theEnd.png")
        _G.HUD         = love.graphics.newImage("assets/img/HUD.png")
        _G.trophy      = love.graphics.newImage("assets/img/trophy.png")
        _G.clock       = love.graphics.newImage("assets/img/clock.png")

        -- fonts
        _G.mediumFont  = love.graphics.newFont("assets/fonts/04B_03_.TTF", 64)
        _G.smallFont   = love.graphics.newFont("assets/fonts/04B_03_.TTF", 32)

    --> functions:
        function _G.newQuestion()
            -- Reseting guess
            _G.guess = ""

            -- Using the mathmaker functions, defines a 70% percent change of deepness 2 problem (gosh, I need to explain this way better mwahah)
            local _answer, _content, _posPoints, _negPoints = m.createProblem(enemy.operation_max)
            local randomDeepness = math.floor(math.random() / 0.7)
            question.answer, question.content, question.posPoints, question.negPoints = m.deepProblem(_answer, _content, _posPoints, _negPoints, randomDeepness, enemy.operation_max)
        end

        function _G.loadBattle(enemyname)
            u.restartBattle(enemies[enemyname])
            question.active = true
            game.state      = "battle"
            _G.enemy        = enemies[enemyname]()
            newQuestion()
        end

    -- the 'question' structure
    do
        _G.guess = ""

        _G.question   = {}

        question.dftTime     = 45
        question.time        = question.dftTime
        question.timeblow    = 10

        question.active      = true
    end

    --> texts:
        _G.pausedtext = love.graphics.newText(mediumFont, "PAUSED!")
        _G.escResume  = love.graphics.newText(smallFont, "ESC: Resume")
        _G.spaceMap   = love.graphics.newText(smallFont, "M: Back to map")

    game.state = "world"
end

function love.update(dt)
    if     game.state == "battle" then
        c.runClock(mainclock, dt)
        t.triggtableUpdate(triggtable)

        -- Making the enemy nearer:
        if not enemy.isDead then enemy.x, enemy.y = enemy.movefunc(enemy.x, enemy.y) end

        for _, message in pairs({timeMesg, healthMesg}) do
            message.color[4] = message.color[4] - dt
        end

        if question.active then
            question.time = question.time - dt
        end

        --> Checking damage:

            -- Checking if time exploded:
            if math.floor(question.time) <= 0 then
                malusfelis.health = malusfelis.health - question.timeblow
                question.time = question.dftTime

                malusfelis.state = "dmgd"
                c.addTimer(mainclock, 0.75, function() malusfelis.state = "idle" end)
            end

            -- Checking if enemy attacked:

            if enemy.x - enemy.spr:getWidth() / 2 <= malusfelis.battlepos.x + malusfelis.bsprs.idle:getWidth() / 2 then
                malusfelis.health = u.addInInterval(malusfelis.health, enemy.dmg, 0, malusfelis.dftHealth)

                malusfelis.state = "dmgd"
                c.addTimer(mainclock, 0.75, function() malusfelis.state = "idle" end)

                healthMesg.mesg  = tostring(enemy.dmg)
                healthMesg.color = {200/256, 65/256, 50/256, 1}

                t.triggerEvent(triggtable, "enemyReturn", {enemy})
            end

        --> Checking if malusfelis died:
        if malusfelis.health <= 0 and not malusfelis.isDead then
            malusfelis.health = 0

            question.active = false
            malusfelis.isDead = true

            t.triggerEvent(triggtable, "deathScreen", {enemies[enemy.name]})
        end

        --> Checking if enemy died:
        if enemy.health <= 0 and not enemy.isDead then
            enemy.health = 0

            question.active             = false
            enemy.isDead                = true
            game.stages[game.stage].won = true

            malusfelis.state = "winn"

            c.addTimer(mainclock, 2, function() t.triggerEvent(triggtable, "winScreen", {}) end, "atEnd")
            t.triggerEvent(triggtable, "objTakeOut", {enemy})
        end

    elseif game.state == "paused" then
        -- hmmm... just wait?
    elseif game.state == "world"  then
        t.triggtableUpdate(triggtable)
        c.runClock(mainclock, dt)

        --> Checking if user entered a battle:
            if love.keyboard.isDown("space") then
                t.triggerEvent(triggtable, "darkScreen", {function() loadBattle(game.stages[game.stage].enemyname) end})
            end

        --> Checking if user concluded the game:
            if game.isComplete and not game.completedEventPlayed then
                c.addTimer(mainclock, 0.5, function() t.triggerEvent(triggtable, "darkScreen", {function() game.state = "theEnd" end}) end, "atEnd")
                game.completedEventPlayed = true
            end
    end
end

function love.draw()
    if     game.state == "battle" then
        love.graphics.draw(background, 0, math.sin(os.clock()) * 15 - 20)

        love.graphics.setFont(mediumFont)

        --> Objects:
            -- Player:
            do
                if     malusfelis.isDead          then love.graphics.draw(malusfelis.bsprs.dead, malusfelis.battlepos.x, malusfelis.battlepos.y, nil, nil, nil, nil, 8 * math.sin(os.clock()))
                elseif malusfelis.state == "dmgd" then love.graphics.draw(malusfelis.bsprs.dmgd, malusfelis.battlepos.x, malusfelis.battlepos.y, nil, nil, nil, nil, 8 * math.sin(os.clock()))
                elseif malusfelis.state == "idle" then love.graphics.draw(malusfelis.bsprs.idle, malusfelis.battlepos.x, malusfelis.battlepos.y, nil, nil, nil, nil, 8 * math.sin(os.clock()))
                elseif malusfelis.state == "winn" then love.graphics.draw(malusfelis.bsprs.winn, malusfelis.battlepos.x, malusfelis.battlepos.y, nil, nil, nil, nil, 8 * math.sin(os.clock()))
                end
            end

            -- Enemy:
            love.graphics.draw(enemy.spr, enemy.x, enemy.y, enemy.rot, nil, nil, enemy.spr:getWidth() / 2, enemy.spr:getHeight() / 2)

        --> Question Structure:
            love.graphics.setColor(224/256, 219/256, 210/256)

            love.graphics.printf(question.content, 0, 160, love.graphics.getWidth(), "center")
            love.graphics.printf(guess, 0, 256, love.graphics.getWidth(), "center")

            love.graphics.setColor(1, 1, 1)

        --> HUD:
            love.graphics.draw(HUD, 0, 0)

            love.graphics.draw(clock, 400, 52, -math.floor(question.time) * math.pi / 2, nil, nil, clock:getWidth() / 2, clock:getHeight() / 2)

            love.graphics.setColor(200/256, 65/256, 50/256)
            love.graphics.rectangle("fill", 152, 32, (22/ malusfelis.dftHealth) * malusfelis.health * 8, 40)

            love.graphics.setColor(57/256, 128/256, 168/256)
            love.graphics.rectangle("fill", 592, 528, (22 / enemy.dftHealth) * enemy.health * 8, 40)

            love.graphics.setColor(224/256, 219/256, 210/256)
            love.graphics.print(math.floor(question.time), 464, 24)

            for _, message in pairs({timeMesg, healthMesg}) do
                love.graphics.setColor(u.unpackLove(message.color))
                love.graphics.print(message.mesg, u.unpackLove(message.pos))
            end

            t.triggtableDraw(triggtable)

            love.graphics.setColor(1, 1, 1)
    elseif game.state == "paused" then
        love.graphics.setBackgroundColor(0.05, 0.05, 0.05)

        love.graphics.setColor(224/256, 219/256, 210/256)
        love.graphics.draw(pausedtext, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 32, nil, nil, nil, pausedtext:getWidth() / 2, pausedtext:getHeight() / 2)
        love.graphics.draw(escResume, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 64, nil, nil, nil, escResume:getWidth() / 2, escResume:getHeight() / 2)
        love.graphics.draw(spaceMap, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 96, nil, nil, nil, spaceMap:getWidth() / 2, spaceMap:getHeight() / 2)
    elseif game.state == "world"  then
        love.graphics.draw(worldbackground, 0, 0)
        -- Player
        love.graphics.draw(malusfelis.worldspr, 15*8 + 20*8*(game.stage-1), 35*8)

        love.graphics.setFont(mediumFont)

        --> Info
            -- Won stages:
            game.isComplete = true
            for n, stage in pairs(game.stages) do
                if stage.won then
                    love.graphics.draw(trophy, 15*8 + 20*8*(n-1), 56*8)
                else
                    game.isComplete = false
                end
            end

            love.graphics.setColor(224/256, 219/256, 210/256)

            love.graphics.printf("Stage " .. game.stage, 0, 100, love.graphics.getWidth(), "center")
            love.graphics.printf(string.upper(game.stages[game.stage].enemyname), 0, 180, love.graphics.getWidth(), "center")

            love.graphics.setFont(smallFont)
            love.graphics.printf("Press SPACE to start the battle!", 0, love.graphics.getHeight() - 48, love.graphics.getWidth(), "center")
            love.graphics.setFont(mediumFont)

            love.graphics.setColor(1, 1, 1)

        -- Triggtable
            t.triggtableDraw(triggtable)
    
    elseif game.state == "theEnd" then
        love.graphics.draw(finalScreen, 0, 0)
    end
end

function love.textinput(key)
    if question.active and game.state == "battle" and (tonumber(key) ~= nil or key == '-' or key == '.') then _G.guess = guess .. key end
end

function love.keypressed(key)
    if     question.active and game.state == "battle" then
        if key == "backspace" then
            _G.guess = string.sub(guess, 1, #guess - 1)

        elseif key == "return" then
            local healthAdd = (tonumber(guess) == question.answer) and question.posPoints or question.negPoints
            local timeAdd   = (tonumber(guess) == question.answer) and question.posPoints or question.negPoints

            if timeAdd > 0 then
                timeMesg.mesg = "+" .. timeAdd
                timeMesg.color = {113/256, 170/256, 52/256, 1}

            else
                timeMesg.mesg = tostring(timeAdd)
                timeMesg.color = {200/256, 65/256, 50/256, 1}
            end

            if healthAdd > 0 then
                healthMesg.mesg  = "+" .. healthAdd
                enemy.health = u.addInInterval(enemy.health, malusfelis.dmg, 0, enemy.dftHealth)
                healthMesg.color = {113/256, 170/256, 52/256, 1}

                if enemy.health > 0 then
                    t.triggerEvent(triggtable, 'enemyRetreat', {enemy})
                end
            else
                malusfelis.state = "dmgd"
                c.addTimer(mainclock, 0.75, function() malusfelis.state = "idle" end)

                healthMesg.mesg  = tostring(healthAdd)
                healthMesg.color = {200/256, 65/256, 50/256, 1}
            end

            question.time     = u.addInInterval(question.time, timeAdd, 0, question.dftTime)
            malusfelis.health = u.addInInterval(malusfelis.health, healthAdd, 0, malusfelis.dftHealth)

            newQuestion()
        elseif key == "escape" then
            game.state = "paused"
        end
    elseif game.state == "world" then
        if     key == "left"  or key == "a" then game.stage = u.addInInterval(game.stage, -1, 1, 4)
        elseif key == "right" or key == "d" then game.stage = u.addInInterval(game.stage, 1, 1, 4) end
    elseif game.state == "paused" then
        if     key == "m"      then game.state = "battle"; t.triggerEvent(triggtable, "darkScreen", {function() game.state = "world" end})
        elseif key == "escape" then game.state = "battle" end

    elseif game.state == "theEnd" then
        game.state = "world"
    end
end