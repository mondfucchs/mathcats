local clock = {}

-- Quite useless, just for organization :/
clock.newClock = function()
    return {}
end

-- Runs and deal with every clock in 'forClock'
clock.runClock = function(forClock, deltaTime)
    for k, timer in pairs(forClock) do
        timer.time = timer.time - deltaTime

        if timer.type == "untilEnd" then
            if timer.callback then
                timer.callback()
            end
        end

        if timer.time <= 0 then
            if timer.callback and timer.type == "atEnd" then
                timer.callback()
            end

            table.remove(forClock, k)
        end
    end
end

-- Add a new timer to 'toClock': types: "atEnd", "untilEnd"
clock.addTimer = function(toClock, seconds, callback, type)
    local t = type or "atEnd"
    table.insert(toClock, {time=seconds, callback=callback, type=t})
end

return clock