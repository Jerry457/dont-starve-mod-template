GLOBAL.setfenv(1, GLOBAL)

local containers = require("containers")
local params = containers.params

local _elixir_container_itemtestfn = params.elixir_container.itemtestfn
function params.elixir_container.itemtestfn(container, item, slot, ...)
    return
        (item and (item:HasTag("petal") or item:HasTag("mourningflower")))
        or _elixir_container_itemtestfn(container, item, slot, ...)
end

local elixir_container_bg = { image = "elixir_slot.tex", atlas = "images/ws_inventoryimages.xml" }
params.elixir_container.widget.slotbg = {}
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.elixir_container.widget.slotbg, elixir_container_bg)
    end
end

local _sisturn_itemtestfn = params.sisturn.itemtestfn
function params.sisturn.itemtestfn(...)
    return HookSkillTreeUpdaterIsActivated("wendy_sisturn_3", "wendy_sisturn_2", _sisturn_itemtestfn, ...)
end
