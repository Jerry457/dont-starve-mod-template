local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

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
        end
    end
end

local function OnDebuffRemoved(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "ghostlyelixir_revive_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol3(0)
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

    -- 原版月亮药剂的效果
    -- inst.components.planardamage:AddBonus(inst, TUNING.SKILLS.WENDY.LUNARELIXIR_DAMAGEBONUS, "ghostlyelixir_lunarbonus")
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

        -- 原版月亮药剂的效果
        -- inst.components.planardamage:RemoveBonus(inst, "ghostlyelixir_lunarbonus")
    elseif inst:HasTag("shadow_abigail") then
        inst:RemoveDebuff("abigail_murder_buff")
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
    function inst:LinkToPlayer(player, ...)
        if player.components.pethealthbar ~= nil then
            local revive_buff = inst:GetDebuff("ghostlyelixir_revive_buff")
            if revive_buff then
                player.components.pethealthbar:SetSymbol3(revive_buff.prefab)
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
end)
