local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnOpen(inst, data)
    local doer = data and data.doer or nil
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if not skilltreeupdater then
        return
    end

    if doer.prefab == "wendy" and doer.components.talker and not skilltreeupdater:IsActivated("wendy_potion_container") then
        doer.components.talker:Say(GetString(doer, "USE_ELIXIR_CONTAINER_WITHNOT_SKILL"))
    end
end

AddPrefabPostInit("elixir_container", function(inst)
    inst:AddTag("fridge")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.container.restrictedtag = nil

    inst:ListenForEvent("onopen", OnOpen)
end)
