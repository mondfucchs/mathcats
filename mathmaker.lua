local u = require("utils")

math.randomseed(os.time() * 717171)

local mathmaker = {}

mathmaker.createProblem = function(operation_max)
    local operations = {
        -- sum
        {
            points = {
                pos = 1,
                neg = -2
            },
            func   = function(n, m)
                return n + m, n .. " + " .. m
            end
        },
        -- sub
        {
            points = {
                pos = 1,
                neg = -1
            },
            func   = function(n, m)
                return n - m, n .. " - " .. m
            end
        },
        -- mul
        {
            points = {
                pos = 2,
                neg = -1
            },
            func   = function(n, m)
                return (m > 25 or n > 25) and math.ceil(m / 10) * n or m * n, (m > 25 or n > 25) and math.ceil(m / 10) .. " * " .. n or m .. " * " .. n 
            end
        },
        -- simple-div
        {
            points = {
                pos = 1,
                neg = -1
            },
            func   = function(n, m)
                return m > n and math.floor(m / n) or math.floor(n / m), m > n and m .. " // " .. n or n .. " // " .. m
            end
        },
        -- deep(1)-div
        {
            points = {
                pos = 5,
                neg = -1
            },
            func   = function(n, m)
                return m > n and u.roundTo(m / n, 0.1) or u.roundTo(n / m, 0.1), m > n and m .. " / " .. n or n .. " / " .. m
            end
        }
    }

    local o = math.random(1, operation_max)
    local n = math.random(1, 50)
    local m = math.random(1, 50)

    local answer, content = operations[o].func(n, m)
    local posPoints, negPoints = operations[o].points.pos, operations[o].points.neg

    return answer, content, posPoints, negPoints
end

mathmaker.deepProblem = function(answer, content, posPoints, negPoints, deepness, operation_max)
    local appendingOperations = {
        -- sum
        {
            points = {
                pos = 1,
                neg = -1
            },
            func   = function(ans, con, a)
                return ans + a, "(" .. con .. ")" .. " + " .. a
            end
        },
        -- sub
        {
            points = {
                pos = 2,
                neg = -1
            },
            func   = function(ans, con, a)
                return ans - a, "(" .. con .. ")" .. " - " .. a
            end
        },
        -- mul
        {
            points = {
                pos = 4,
                neg = -1
            },
            func   = function(ans, con, a)
                return ans * a, "(" .. con .. ")" .. " * " .. a
            end
        },
        -- simple-div
        {
            points = {
                pos = 2,
                neg = -1
            },
            func   = function(ans, con, a)
                return ans > a and math.floor(ans / a) or math.floor(a / ans), ans > a and "(" .. con .. ")" .. " // " .. a or a .. " // " .. "(" .. con .. ")"
            end
        },
        -- deep(1)-div
        {
            points = {
                pos = 7,
                neg = -1
            },
            func   = function(ans, con, a)
                return ans > a and u.roundTo(ans / a, 0.1) or u.roundTo(a / ans, 0.1), ans > a and "(" .. con .. ")" .. " / " .. a or a .. " / " .. "(" .. con .. ")"
            end
        }
    }

    local _answer, _content, _posPoints, _negPoints, _deepness = answer, content, posPoints, negPoints, deepness

    for i = 1, _deepness do
        local a = math.random(1, 50)
        local o = math.random(1, operation_max)

        _answer, _content = appendingOperations[o].func(_answer, _content, a)
        _posPoints, _negPoints = _posPoints + appendingOperations[o].points.pos, _negPoints + appendingOperations[o].points.neg
    end

    return _answer, _content, _posPoints, _negPoints
end

return mathmaker