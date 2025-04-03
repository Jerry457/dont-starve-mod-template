local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnOpen(inst, data)
end

AddPrefabPostInit("elixir_container", function(inst)
    inst:AddTag("fridge")

    inst.components.container.restrictedtag = nil

    inst:ListenForEvent("onopen", OnOpen)
end)
