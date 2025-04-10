local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnSisturnStateChanged(inst, data)
    if not data then
        return
    end
    local is_active = data.is_active
    local state = data.state
    local ghost = inst.components.ghostlybond and inst.components.ghostlybond.ghost or nil
    if not ghost then
        return
    end

    ghost:SetToNormal()

    if inst.components.skilltreeupdater then
        local wendy_sisturn_3 = inst.components.skilltreeupdater:IsActivated("wendy_sisturn_3")
        if wendy_sisturn_3 and is_active then
            -- ghost:PushEvent("flicker")
            ghost:AddTag("player_damagescale")
        else
            ghost:RemoveTag("player_damagescale")
        end

        local wendy_lunar_3 = inst.components.skilltreeupdater:IsActivated("wendy_lunar_3")
        local wendy_shadow_3 = inst.components.skilltreeupdater:IsActivated("wendy_shadow_3")
        if wendy_lunar_3 and state == "BLOSSOM" then
            ghost:SetToGestalt()
        elseif wendy_shadow_3 and state == "EVIL" then
            ghost:SetToShadow()
        end
    end

    ghost:updatehealingbuffs()
    inst.components.ghostlybond:SetBondTimeMultiplier("sisturn", is_active and TUNING.ABIGAIL_BOND_LEVELUP_TIME_MULT or nil)
end

AddPrefabPostInit("wendy", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("spiritualism")

    local checkforshadowsacrifice = inst:GetEventCallbacks("murdered", inst, "scripts/prefabs/wendy.lua")
    inst:RemoveEventCallback("murdered", checkforshadowsacrifice)

    local update_sisturn_state = inst:GetEventCallbacks("onsisturnstatechanged", TheWorld, "scripts/prefabs/wendy.lua")
    inst:RemoveEventCallback("onsisturnstatechanged", update_sisturn_state, TheWorld)

    inst:ListenForEvent("onsisturnstatechanged", OnSisturnStateChanged)
end)
