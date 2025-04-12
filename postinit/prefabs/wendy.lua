local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local moon_states = {
    reverse = "REVERSE",
    normal = "NORMAL",
    strong = "STRONG"
}

local last_moon_state
local function CheckMoonState(inst, nosay)
    if not inst.components.ghostlybond then
        return
    end
    local ghost = inst.components.ghostlybond.ghost
    local summoned = inst.components.ghostlybond.summoned

    if not ghost then
        return
    end

    local is_cave = TheWorld:HasTag("cave")
    local is_waxing_moon = not TheWorld:HasTag("cave") and TheWorld.state.iswaxingmoon and not TheWorld.state.isnewmoon
    local is_waning_moon = not is_cave and not TheWorld.state.iswaxingmoon and not TheWorld.state.isfullmoon

    local is_gestalt = ghost:HasTag("gestalt")
    local is_shadow = ghost:HasTag("shadow_abigail")

    local elixir_buff = ghost:GetDebuff("elixir_buff")

    local moon_state = moon_states.reverse
    if is_gestalt then
        if TheWorld.state.isfullmoon then
            moon_state = moon_states.strong
        elseif is_waxing_moon or (elixir_buff and elixir_buff.prefab == "ghostlyelixir_lunar_buff") then
            moon_state = moon_states.normal
        end
    elseif is_shadow then
        if TheWorld.state.isnewmoon or TheWorld.state.isnightmarewild then
            moon_state = moon_states.strong
        elseif (elixir_buff and elixir_buff.prefab == "ghostlyelixir_shadow_buff") or is_waning_moon or TheWorld.state.isnightmarewarn or TheWorld.state.isnightmaredawn then
            moon_state = moon_states.normal
        end
    end

    if last_moon_state == moon_state then
        return
    end
    last_moon_state = moon_state

    local function say(stringtype)
        -- if elixir_buff then
        --     if elixir_buff.prefab == "ghostlyelixir_lunar_buff" or elixir_buff.prefab == "ghostlyelixir_shadow_buff" then
        --         return
        --     end
        -- end
        if not nosay and summoned and inst.components.talker then
            if is_gestalt then
                inst.components.talker:Say(GetString(inst, stringtype, is_cave and "GESTALT_CAVE" or "GESTALT"))
            end
            if is_shadow then
                inst.components.talker:Say(GetString(inst, stringtype, is_cave and "SHADOW_CAVE" or "SHADOW"))
            end
        end
    end

    TUNING.ABIGAIL_SHADOW_VEX_PLANAR_DAMAGE = 10
    if moon_state == moon_states.reverse then

        ghost.components.planardamage:RemoveBonus(ghost, "ghostlyelixir_lunarbonus")
        ghost:RemoveTag("abigail_vex_shadow")

        say("ANNOUNCE_ABIGAIL_REVERSE_MOON")
    else -- if moon_state == moon_states.normal or moon_state == moon_states.strong then
        if is_gestalt then
            ghost.components.planardamage:AddBonus(ghost, TUNING.SKILLS.WENDY.LUNARELIXIR_DAMAGEBONUS_GESTALT, "ghostlyelixir_lunarbonus")
        end
        if is_shadow then
            ghost:AddTag("abigail_vex_shadow")
        end

        if moon_state == moon_states.strong then
            say("ANNOUNCE_ABIGAIL_STRONG_MOON")

            if is_gestalt then
            end
            if is_shadow then
                TUNING.ABIGAIL_SHADOW_VEX_PLANAR_DAMAGE = 15
            end
        else
            say("ANNOUNCE_ABIGAIL_NORMAL_MOON")
        end
    end
end

local function OnMoonStateChange(inst)
    if TheWorld.state.isnight or TheWorld:HasTag("cave") then
        inst:DoTaskInTime(0, CheckMoonState)
    end
end

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
    CheckMoonState(inst, true)

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

    local OnSkillTreeInitialized = inst:GetEventCallbacks("ms_skilltreeinitialized", inst, "scripts/prefabs/wendy.lua")
    GlassicAPI.UpvalueUtil.SetUpvalue(OnSkillTreeInitialized, "SKILL_CHANGE_EVENTS", { "wendy_sisturn", "wendy_shadow", "wendy_lunar" })

    inst:ListenForEvent("onsisturnstatechanged", OnSisturnStateChanged)

    inst.CheckMoonState = CheckMoonState
    -- inst:WatchWorldState("moonphase", CheckMoonState)
    -- inst:WatchWorldState("cavemoonphase", CheckMoonState)
    if TheWorld:HasTag("cave") then
        inst:WatchWorldState("nightmarephase", OnMoonStateChange)
    else
        inst:WatchWorldState("isnight", OnMoonStateChange)
    end
end)
