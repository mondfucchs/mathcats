local love = require("love")

function love.conf(app)
    app.window.width  = 800
    app.window.height = 600
    app.console       = false
    app.window.icon   = "assets/img/gameicon.png"

    app.window.title  = "Mathcats - Cats, mathematics!"
end