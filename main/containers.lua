GLOBAL.setfenv(1, GLOBAL)

local containers = require("containers")
local params = containers.params

local _elixir_container_itemtestfn = params.elixir_container.itemtestfn
function params.elixir_container.itemtestfn(container, item, slot, ...)
    return
        (item and item:HasTag("petal") and item:HasTag("mourningflower"))
        or _elixir_container_itemtestfn(container, item, slot, ...)
end
