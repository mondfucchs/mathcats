local love      = require("love")
local u         = require("utils")
local c         = require("tools.clock")
local eventList = require("assets.lists.eventList")

local triggers = {}

-- Triggers 'eventname' into triggtable. Some events may need extra arguments
triggers.triggerEvent     = function(triggtable, eventname, eventargs)
    triggtable[eventname] = eventList[eventname](u.unpackLove(eventargs))
end

-- Abruptstop 'eventname' out of triggtable
triggers.abrubtstopEvent  = function(triggtable, eventname)
    triggtable[eventname] = nil
end

-- Run all events' updates inside 'triggtable'
triggers.triggtableUpdate = function(triggtable)

    for pos, event in pairs(triggtable) do
        if event.data.active then
            -- do (rupr*)
            event:update()
        else
            -- felt into (deco*)
            triggtable[pos] = nil
        end
    end

end

-- Run all events' draws inside 'triggtable'
triggers.triggtableDraw   = function(triggtable)

    for pos, event in pairs(triggtable) do
        -- if drawy:
        if event.draw then
            event:draw()
        end
    end

end

return triggers