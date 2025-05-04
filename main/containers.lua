GLOBAL.setfenv(1, GLOBAL)

local containers = require("containers")
local params = containers.params

local _elixir_container_itemtestfn = params.elixir_container.itemtestfn
function params.elixir_container.itemtestfn(container, item, slot, ...)
    return
        (item and (item:HasTag("petal") or item:HasTag("mourningflower")))
        or _elixir_container_itemtestfn(container, item, slot, ...)
end

local _sisturn_itemtestfn = params.sisturn.itemtestfn
function params.sisturn.itemtestfn(...)
    return HookSkillTreeUpdaterIsActivated("wendy_sisturn_3", "wendy_sisturn_2", _sisturn_itemtestfn, ...)
end
