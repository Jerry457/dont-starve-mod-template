local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnSisturnStateChanged(inst, data)
    local is_active = data and data.is_active or false
    local ghost = inst.components.ghostlybond and inst.components.ghostlybond.ghost or nil
    if not ghost then
        return
    end

    inst.components.ghostlybond:SetBondTimeMultiplier("sisturn", is_active and TUNING.ABIGAIL_BOND_LEVELUP_TIME_MULT or nil)

    local is_skilled = inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wendy_sisturn_3") or nil
    if is_active and is_skilled then
        -- ghost:PushEvent("flicker")
        ghost:AddTag("player_damagescale")
    else
        ghost:RemoveTag("player_damagescale")
    end

    ghost:updatehealingbuffs()
end

AddPrefabPostInit("wendy", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("spiritualism")

    local update_sisturn_state = inst:GetEventCallbacks("onsisturnstatechanged", TheWorld, "scripts/prefabs/wendy.lua")
    inst:RemoveEventCallback("onsisturnstatechanged", update_sisturn_state, TheWorld)

    inst:ListenForEvent("onsisturnstatechanged", OnSisturnStateChanged)
end)
