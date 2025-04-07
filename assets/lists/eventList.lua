local love = require("love")
local u    = require("utils")
local c    = require("tools.clock")

local eventList = {}

eventList.enemyRetreat = function(enemy)
    return {
        data = {
            --type = undrawy
            movx   = 45,
            active = true
        },

        update = function(self)
            -- deactivating condition (deco*)
            if self.data.movx <= 0.25 then
                self.data.active = false
            end

            -- running process (rupr*)
            enemy.x = u.addInInterval(enemy.x, self.data.movx, 0, 875)
            self.data.movx = self.data.movx / 1.35
        end,
    }
end

eventList.objTakeOut   = function(obj)
    return {
        data = {
            --type = undrawy
            movx   = 2,
            movy   = 5,
            t      = 0,
            active = true
        },

        update = function(self)
            -- deactivating condition (deco*)
            if obj.y > love.graphics.getHeight() * 2 then
                self.data.active = false
            end

            -- running process (rupr*)
            self.data.t = self.data.t + 1 / love.timer.getFPS()
            obj.rot     = obj.rot + self.data.t / 60

            obj.y = obj.y + ((self.data.t - 8 / 60)^2 - 64 / 60) * self.data.movy
            obj.x = obj.x + self.data.movx
        end,
    }
end

eventList.enemyReturn  = function(enemy)
    return {
        data = {
            --type = undrawy
            movx   = 45,
            active = true
        },

        update = function(self)
            -- deactivating condition (deco*)
            if self.data.movx <= 0.25 then
                self.data.active = false
            end

            -- running process (rupr*)
            enemy.x = enemy.x + self.data.movx
            self.data.movx = self.data.movx / 1.1
        end,
    }
end

eventList.deathScreen  = function(enemyfunc)
    return {
        data = {
            -- type= drawy
            opc    = 0,
            opt    = 1,
            text_y = 0,
            movety = 30,
            -- "loading" "running"
            part   = "loading",
            active = true
        },

        update = function(self)
            -- deactivating condition (!deco*)
                if self.data.part == "ending" then
                    self.data.active = false
                end

            -- running process (rupr*)
                if self.data.part     == "loading" and self.data.opc <= 1 then
                    self.data.opc = u.addInInterval(self.data.opc, 1 / love.timer.getFPS(), 0, 1)
                    self.data.text_y = self.data.text_y + self.data.movety
                    self.data.movety = self.data.movety / 1.15

                elseif self.data.part == "running" then
                    -- part changer (rupr*pc)
                    if love.keyboard.isDown("space") and self.data.opt == 1 then
                        self.data.part = "ending"
                        u.restartBattle(enemyfunc)

                    elseif love.keyboard.isDown("space") and self.data.opt == 2 then
                        -- huh... you, shouldn't do that, actually.

                    elseif love.keyboard.isDown("down") then
                        self.data.opt = 2

                    elseif love.keyboard.isDown("up") then
                        self.data.opt = 1
                    end
                end

                -- part changer (rupr*pc)
                if self.data.opc >= 1 and self.data.part == "loading" then
                    self.data.part = "running"
                end
        end,

        draw = function(self)
            love.graphics.setColor(0.05, 0.05, 0.05, self.data.opc)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1)

                love.graphics.printf("YOU DIED!", 0, self.data.text_y, love.graphics.getWidth(), "center")

                love.graphics.setFont(smallFont)

                love.graphics.setColor(0.1, 0.1, 0.1)
                love.graphics.printf("(press space)", 0, self.data.text_y - 45, love.graphics.getWidth(), "center")

                    if self.data.opt == 1 then love.graphics.setColor(244/256, 180/256, 27/256) else love.graphics.setColor(1, 1, 1) end
                    love.graphics.printf("Try Again", 0, self.data.text_y + 64, love.graphics.getWidth(), "center")

                    if self.data.opt == 2 then love.graphics.setColor(244/256, 180/256, 27/256) else love.graphics.setColor(1, 1, 1) end
                    love.graphics.printf("Cry", 0, self.data.text_y + 100, love.graphics.getWidth(), "center")
        end
    }
end

eventList.winScreen    = function()
    return {
        data   = {
            --type = drawy
            vel    = love.graphics.getWidth() * (1/10),
            size   = 0,
            texty  = 0,
            clock  = {},
            active = true,
            -- "loading" "running" "ending"
            part   = "loading"
        },

        update = function(self)
            -- deactivating condition (deco*)
                if self.data.part == "ending" and self.data.size <= 0 then
                    self.data.active = false
                end

            -- part changer
                if self.data.size >= love.graphics.getWidth() - 1 then
                    self.data.part = "running"
                    c.addTimer(self.data.clock, 1.5, function() self.data.part = "ending"; self.data.vel = love.graphics.getWidth() * (1/10); game.state = "world" end)
                end
            -- running process (rupr*)
                c.runClock(self.data.clock, love.timer.getDelta())

                if self.data.part     == "loading" then
                    self.data.size  = self.data.size + self.data.vel
                    self.data.vel   = self.data.vel * (9/10)
                    self.data.texty = math.floor(self.data.texty + self.data.vel / 2.8)

                elseif self.data.part == "ending" then
                    self.data.size  = self.data.size - self.data.vel
                    self.data.vel   = self.data.vel * (9/10)
                    self.data.texty = math.floor(self.data.texty - self.data.vel)
                end
        end,

        draw   = function(self)
            love.graphics.setColor(244/256, 180/256, 27/256)
            love.graphics.rectangle("fill", 0, 0, self.data.size, love.graphics.getHeight())

            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("YOU WON!", 0, self.data.texty, love.graphics.getWidth(), "center")

            love.graphics.setColor(1, 1, 1)
        end
    }
end

eventList.darkScreen  = function(action)
    return {
        data = {
            -- type= drawy
            opc    = 0,
            -- "loading" "ending"
            part   = "loading",
            active = true
        },

        update = function(self)
            -- running process (rupr*)
                if self.data.part     == "loading" then
                    self.data.opc = u.addInInterval(self.data.opc, 1 / love.timer.getFPS(), 0, 1)
                    -- part changer (rupr*pc)
                    if self.data.opc == 1 then
                        if action then action() end
                        self.data.part = "ending"
                    end

                elseif self.data.part == "ending" then
                    self.data.opc = u.addInInterval(self.data.opc, -1 / love.timer.getFPS(), 0, 1)
                    -- (deco*)
                    if self.data.opc == 0 then
                        self.data.active = false
                    end
                end
        end,

        draw = function(self)
            love.graphics.setColor(0.05, 0.05, 0.05, self.data.opc)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1)
        end
    }
end

return eventList