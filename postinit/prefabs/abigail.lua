local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function ApplyDebuff(inst, data)
    local target = data ~= nil and data.target
    if target ~= nil then
        local buff = "abigail_vex_debuff"

        if inst:HasTag("abigail_vex_shadow") then
            buff = "abigail_vex_shadow_debuff"
        end

        local olddebuff = target:GetDebuff("abigail_vex_debuff")
        if olddebuff then
            if olddebuff.prefab == "abigail_vex_shadow_debuff" and buff == "abigail_vex_debuff" then
                return
            elseif olddebuff.prefab ~= buff then
                target:RemoveDebuff("abigail_vex_debuff")
            end
        end
        target:AddDebuff("abigail_vex_debuff", buff, nil, nil, nil, inst)

        local debuff = target:GetDebuff("abigail_vex_debuff")

        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil and debuff ~= nil then
            debuff.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", inst.GUID, "abigail_attack_fx")
        end
    end
end

local function SetbonusHaelath(inst, value)
    inst.bonus_max_health = value

    local health = inst.components.health
    if health then
        if health:IsDead() then
            health.maxhealth = inst.base_max_health + inst.bonus_max_health
        else
            local health_percent = health:GetPercent()
            health:SetMaxHealth(inst.base_max_health + inst.bonus_max_health)
            health:SetPercent(health_percent, true)
        end

        if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
            inst._playerlink.components.pethealthbar:SetMaxHealth(health.maxhealth)
        end
    end
end

local function OnDebuffAdded(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "ghostlyelixir_revive_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol3(debuff.prefab)
        elseif name == "player_to_ghost_elixir_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol4(debuff.prefab)
        end
    end
end

local function OnDebuffRemoved(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "ghostlyelixir_revive_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol3(0)
        elseif name == "player_to_ghost_elixir_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol4(0)
        end
    end
end

local function SetToGestalt(inst)
    inst:AddTag("gestalt")
    -- inst:AddTag("crazy")

    inst.AnimState:ClearOverrideBuild("ghost_abigail_human")

    inst.AnimState:SetBuild("ghost_abigail_gestalt_build")
    inst.AnimState:AddOverrideBuild("ghost_abigail_gestalt_human")
    inst.AnimState:OverrideSymbol("fx_puff2",       "lunarthrall_plant_front",      "fx_puff2")
    inst.AnimState:OverrideSymbol("v1_ball_loop",   "brightmare_gestalt_evolved",   "v1_ball_loop")
    inst.AnimState:OverrideSymbol("v1_embers",      "brightmare_gestalt_evolved",   "v1_embers")
    inst.AnimState:OverrideSymbol("v1_melt2",       "brightmare_gestalt_evolved",   "v1_melt2")

    inst.components.aura:Enable(false)

    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat.attackrange = 6
end

local function SetToShadow(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("abigail_attack_shadow_fx").Transform:SetPosition(x, y, z)
    local fx = SpawnPrefab("abigail_shadow_buff_fx")
    inst:AddChild(fx)
    inst.SoundEmitter:PlaySound("meta5/abigail/abigail_nightmare_buff_stinger")
    inst:AddDebuff("abigail_murder_buff", "abigail_murder_buff")
end

local function SetToNormal(inst)
    if inst:HasTag("gestalt") then
        inst:RemoveTag("gestalt")
        -- inst:RemoveTag("crazy")

        inst.AnimState:ClearOverrideBuild("ghost_abigail_gestalt_human")
        inst.AnimState:ClearOverrideSymbol("fx_puff2")
        inst.AnimState:ClearOverrideSymbol("v1_ball_loop")
        inst.AnimState:ClearOverrideSymbol("v1_embers")
        inst.AnimState:ClearOverrideSymbol("v1_melt2")

        inst.AnimState:SetBuild("ghost_abigail_build")
        inst.AnimState:AddOverrideBuild("ghost_abigail_human")

        inst.components.aura:Enable(true)

        inst.components.combat:SetAttackPeriod(4)
        inst.components.combat.attackrange = 3
    elseif inst:HasTag("shadow_abigail") then
        inst:RemoveDebuff("abigail_murder_buff")
    end
end

local function UpdateDamage(inst)
    local elixir_buff = inst:GetDebuff("elixir_buff")
    local player_to_ghost_elixir_buff = inst:GetDebuff("player_to_ghost_elixir_buff")
    local murderbuff = inst:GetDebuff("abigail_murder_buff")
    local phase = TheWorld.state.phase
    if (elixir_buff and elixir_buff.prefab == "ghostlyelixir_attack_buff")
        or (player_to_ghost_elixir_buff and player_to_ghost_elixir_buff.prefab == "ghostlyelixir_attack_buff")
    then
        phase = "night"
    end
    local modified_damage = (TUNING.ABIGAIL_DAMAGE[phase] or TUNING.ABIGAIL_DAMAGE.day)
    if inst:HasTag("shadow_abigail") then
        modified_damage = (TUNING.SHADOW_ABIGAIL_DAMAGE[phase] or TUNING.SHADOW_ABIGAIL_DAMAGE.day)
    end
    inst.components.combat.defaultdamage = modified_damage --/ (murderbuff and TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD or TUNING.ABIGAIL_VEX_DAMAGE_MOD) -- so abigail does her intended damage defined in tunings.lua --

    inst.attack_level = (phase == "day" and 1)
                        or (phase == "dusk" and 2)
                        or 3


    -- if murderbuff then
    --     inst.components.planardamage:AddBonus(inst, TUNING.ABIGAIL_SHADOW_PLANAR_DAMAGE, "shadow_murder_planar")
    -- else
    --     inst.components.planardamage:AddBonus(inst, 0, "shadow_murder_planar")
    -- end

    -- If the animation fx was already playing we update its animation
    local level_str = tostring(inst.attack_level)
    if inst.attack_fx and not inst.attack_fx.AnimState:IsCurrentAnimation("attack" .. level_str .. "_loop") then
        inst.attack_fx.AnimState:PlayAnimation("attack" .. level_str .. "_loop", true)
    end
end

local function CustomCombatDamage(inst, target)
    local vex_debuff = target:GetDebuff("abigail_vex_debuff")
    if vex_debuff then
        if vex_debuff.prefab == "abigail_vex_shadow_debuff" then
            return 1 / TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD
        elseif vex_debuff.prefab == "abigail_vex_debuff" then
            return 1 / TUNING.ABIGAIL_VEX_DAMAGE_MOD
        end
    end
    return 1
end

local function OnGhostCommandHitOther(inst, data)
    local target = data and data.target or nil
    inst.shadow_command_attack = false
    if inst.gestalt_command_attack then
        if target and target.components.sleeper then
            target.components.sleeper:GoToSleep()
        end
        inst.gestalt_command_attack = false
    end
end

AddPrefabPostInit("abigail", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.UpdateBonusHealth = function(inst, newbonus)
        inst.bonus_max_health = newbonus
    end
    local OnHealthChanged = inst:GetEventCallbacks("pre_health_setval", inst, "scripts/prefabs/abigail.lua")
    inst:RemoveEventCallback("pre_health_setval", OnHealthChanged)

    local _LinkToPlayer = inst.LinkToPlayer
    GlassicAPI.UpvalueUtil.SetUpvalue(_LinkToPlayer, "ApplyDebuff", ApplyDebuff)
    function inst:LinkToPlayer(player, ...)
        if player.components.pethealthbar ~= nil then
            local revive_buff = inst:GetDebuff("ghostlyelixir_revive_buff")
            if revive_buff then
                player.components.pethealthbar:SetSymbol3(revive_buff.prefab)
            end
            local player_to_ghost_elixir_buff = inst:GetDebuff("player_to_ghost_elixir_buff")
            if player_to_ghost_elixir_buff then
                player.components.pethealthbar:SetSymbol4(player_to_ghost_elixir_buff.prefab)
            end
        end
        _LinkToPlayer(self, player, ...)
    end

    local _ondebuffadded = inst.components.debuffable.ondebuffadded
    function inst.components.debuffable:ondebuffadded(name, ent, ...)
        _ondebuffadded(self, name, ent, ...)
        OnDebuffAdded(inst, name, ent, ...)
    end

    local _ondebuffremoved = inst.components.debuffable.ondebuffremoved
    function inst.components.debuffable:ondebuffremoved(name, ent, ...)
        _ondebuffremoved(self, name, ent, ...)
        OnDebuffRemoved(inst, name, ent, ...)
    end

    inst.SetbonusHaelath = SetbonusHaelath

    inst.SetToGestalt = SetToGestalt
    inst.SetToShadow = SetToShadow
    inst.SetToNormal = SetToNormal

    local _UpdateDamage = inst.UpdateDamage
    inst.UpdateDamage = UpdateDamage
    inst:StopWatchingWorldState("phase", _UpdateDamage)
    inst:WatchWorldState("phase", UpdateDamage)
    UpdateDamage(inst, TheWorld.state.phase)

    inst.components.combat.customdamagemultfn = CustomCombatDamage

    local _DoGhostAttackAt = inst:GetEventCallbacks("do_ghost_attackat", inst, "scripts/prefabs/abigail.lua")
    local function DoGhostAttackAt(inst, ...)
        inst.shadow_command_attack = inst:HasTag("shadow_abigail") and inst:HasTag("shadow_shadow")
        inst.gestalt_command_attack = inst:HasTag("gestalt") and inst:HasTag("strong_gestalt")
        return _DoGhostAttackAt(inst, ...)
    end
    inst:ListenForEvent("do_ghost_attackat", DoGhostAttackAt)
    inst:ListenForEvent("onhitother", OnGhostCommandHitOther)
end)


AddPrefabPostInit("abigail_murder_buff", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.murder_buff_OnExtended = function() end
    inst.components.debuff:SetExtendedFn(inst.murder_buff_OnExtended)

    local _onattachedfn = inst.components.debuff.onattachedfn
    GlassicAPI.UpvalueUtil.SetUpvalue(_onattachedfn, "murder_buff_OnExtended", inst.murder_buff_OnExtended)
    GlassicAPI.UpvalueUtil.SetUpvalue(_onattachedfn, "UpdateDamage", UpdateDamage)

    inst.components.debuff.onattachedfn = function(inst, target, ...)
        target:AddTag("shadow_abigail")
        target.AnimState:ClearOverrideBuild("ghost_abigail_human")
        target.AnimState:AddOverrideBuild("ghost_abigail_shadow_human")

        _onattachedfn(inst, target, ...)
        target.components.planardefense:RemoveBonus(inst, "wendymurderbuff")
        local OnDeath = inst:GetEventCallbacks("death", target, "scripts/prefabs/abigail.lua")
        inst:RemoveEventCallback("death", OnDeath, target)
    end

    local _ondetachedfn = inst.components.debuff.ondetachedfn
    inst.components.debuff.ondetachedfn = function(inst, target, ...)
        target:RemoveTag("shadow_abigail")
        target.AnimState:ClearOverrideBuild("ghost_abigail_shadow_human")
        target.AnimState:AddOverrideBuild("ghost_abigail_human")

        inst.decaytimer = inst:DoTaskInTime(0, function() end)
        _ondetachedfn(inst, target, ...)
    end

    inst.GetSaveRecord = function(inst)
        return nil
    end
end)

local function vex_debuff(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _onattachedfn = inst.components.debuff.onattachedfn
    inst.components.debuff.onattachedfn = function(inst, target, followsymbol, followoffset, data, buffer, ...)
        _onattachedfn(inst, target, followsymbol, followoffset, data, buffer, ...)
        if buffer and buffer:HasTag("shadow_abigail") then
            target.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst)
            target.components.combat.externaldamagetakenmultipliers:SetModifier(inst, TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD)
        end
    end

end
AddPrefabPostInit("abigail_vex_debuff", vex_debuff)
AddPrefabPostInit("abigail_vex_shadow_debuff", vex_debuff)
