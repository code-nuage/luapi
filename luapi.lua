local Menus = require("menus")
local Data = require("data")

local App = {}

function App:load()
    Data.init()

    App:run()
end

function App:run()
    Menus.HOME()
end

App:load()