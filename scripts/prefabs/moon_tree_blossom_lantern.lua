local assets =
{
    Asset("ANIM", "anim/moon_tree_blossom_lantern.zip"),
}

local function OnPerishChange(inst, data)
    local percent = data and data.percent or 1
    if percent < 0.3 then
        inst.AnimState:PlayAnimation("idle" .. inst.anim_index .. "_less", true)
    elseif percent < 0.8 then
        inst.AnimState:PlayAnimation("idle" .. inst.anim_index .. "_half", true)
    else
        inst.AnimState:PlayAnimation("idle" .. inst.anim_index .. "_full", true)
    end
end

local function ReskinToolFilterFn(inst)
    inst.anim_index = inst.anim_index + 1
    if inst.anim_index > 3 then
        inst.anim_index = 1
    end
    OnPerishChange(inst, {
        percent = inst.components.perishable:GetPercent()
    })
end

local function SetOrientation(inst)
    inst.scale = -inst.scale
    inst.AnimState:SetScale(inst.scale, 1, 1)
end

local function OnLoad(inst, data)
    if data then
        inst.idle_anim = data.idle_anim or "idle" .. math.random(1, 3)
        inst.scale = data.scale or 1
        inst.AnimState:PlayAnimation("idle" .. inst.anim_index .. "_full", true)
        inst.AnimState:SetScale(inst.scale, 1, 1)
    end
end

local function OnSave(inst, data)
    data.idle_anim = inst.idle_anim
    data.scale = inst.scale
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .2)
    MakeInventoryFloatable(inst, "small")

    inst.AnimState:SetBank("moon_tree_blossom_lantern")
    inst.AnimState:SetBuild("moon_tree_blossom_lantern")

    inst.Light:SetIntensity(0.819375)
    inst.Light:SetRadius(0.7125)
    inst.Light:SetFalloff(0.7)
    inst.Light:SetColour(0.01, 0.35, 1)

    inst:AddTag("structure")
    inst:AddTag("rotatableobject")
    inst:AddTag("reskin_tool_target")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scale = 1
    inst.anim_index = math.random(1, 3)
    inst.AnimState:PlayAnimation("idle" .. inst.anim_index .. "_full", true)
    inst:AddComponent("inspectable")

    inst:AddComponent("burnable")
    inst.components.burnable.fxprefab = nil
    -- inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))
    inst.components.burnable:Ignite()

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "ghostflower"

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE

    inst:ListenForEvent("perishchange", OnPerishChange)

    inst.ReskinToolFilterFn = ReskinToolFilterFn
    inst.SetOrientation = SetOrientation
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:DoTaskInTime(0, inst.PushEvent, "on_landed")

    return inst
end

return Prefab("moon_tree_blossom_lantern", fn, assets)
