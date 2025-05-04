local assets =
{
    Asset("ANIM", "anim/moon_tree_blossom_lantern.zip"),
}

local brain = require("brains/moon_tree_blossom_lanternbrain")

local HotSpringTag = { "watersource" }
local function OnInit(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)
    -- inst.SoundEmitter:PlaySound("meta5/wendy/tombstone_place")

    inst:PushEvent("on_landed")

    local target = FindEntity(inst, 2000, function(ent)
        return ent.prefab == "hotspring"
    end, HotSpringTag) or inst

    inst.components.knownlocations:RememberLocation("home", target:GetPosition(), true)
end

local function GetIdleAnim(inst)
    local percent = inst.components.perishable:GetPercent()
    if percent <= 0.3 then
        return "idle_less"
    elseif percent <= 0.8 then
        return "idle_half"
    else
        return "idle_full"
    end
end

local state_color = {
    moon = {0.01, 0.35, 1},
    evil = {0.8, 0.2, 0.4},
    petals = {0.7, 0.7, 0.4}
}

local function SetPercent(inst, percent)  -- set precent but withnot event
    local perishtime = inst.components.perishable.perishtime
	if perishtime then
        percent = math.clamp(percent, 0, 1)
		inst.components.perishable.perishremainingtime = percent * perishtime
    end
end

local function SetState(inst, state, onload)
    if not onload then
        inst.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/fire")
        if inst.state == state then
            local percent = inst.components.perishable:GetPercent()
            if percent > 0.3 and percent <= 0.8 then
                inst:SetPercent(0.29999)
            elseif percent > 0.8 then
                inst:SetPercent(0.79999)
            end
        end
        local idle_anim = inst:GetIdleAnim()
        inst.AnimState:PlayAnimation(idle_anim .. "_attune_off", false)
        inst.AnimState:PushAnimation(idle_anim .. "_attune_on", false)
        inst.AnimState:PushAnimation(inst:GetIdleAnim(), true)
    end

    inst.state = state

    if inst.state ~= "petals" then
        inst.AnimState:OverrideSymbol("fire", "moon_tree_blossom_lantern", "fire_" .. state)
        inst.AnimState:OverrideSymbol("glow", "moon_tree_blossom_lantern", "glow_" .. state)
        inst.AnimState:OverrideSymbol("sprk_1 copy", "moon_tree_blossom_lantern", "sprk_1 copy_" .. state)
        inst.AnimState:OverrideSymbol("sprk_2", "moon_tree_blossom_lantern", "sprk_2_" .. state)
    else
        inst.AnimState:OverrideSymbol("fire", "moon_tree_blossom_lantern", "fire")
        inst.AnimState:OverrideSymbol("glow", "moon_tree_blossom_lantern", "glow")
        inst.AnimState:OverrideSymbol("sprk_1 copy", "moon_tree_blossom_lantern", "sprk_1 copy")
        inst.AnimState:OverrideSymbol("sprk_2", "moon_tree_blossom_lantern", "sprk_2")
    end

    inst.Light:SetColour(unpack(state_color[state]))
end

local function WaxReplenishment(inst)
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_get_bloodpump")

    local percent = inst.components.perishable:GetPercent()
    if percent <= 0.3 then
        inst:SetPercent(0.79999)
    else
        inst:SetPercent(1)
    end

    local idle_anim = inst:GetIdleAnim()
    inst.AnimState:PlayAnimation(idle_anim .. "_attune_on", false)
    inst.AnimState:PushAnimation(idle_anim, true)
end

local function OnPerish(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then
        inst.components.perishable.onperishreplacement = "ghostflower"
    else
        inst:Remove()
    end
end

local function OnHammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function OnPerishChange(inst)
    local animation = inst:GetIdleAnim()
    if not inst.AnimState:IsCurrentAnimation(animation) then
        inst.AnimState:PlayAnimation(animation, true)
    end
end

local function SetOrientation(inst)
    inst.scale = -inst.scale
    inst.AnimState:SetScale(inst.scale, 1, 1)
end

local function OnLoad(inst, data)
    if data then
        inst.scale = data.scale or 1
        inst.AnimState:SetScale(inst.scale, 1, 1)
        if data.honor_the_memory then
            inst:AddTag("honor_the_memory")
        end
        if data.state then
            SetState(inst, data.state, true)
        end
        OnPerishChange(inst)
    end
end

local function OnSave(inst, data)
    data.scale = inst.scale
    data.state = inst.state
    data.honor_the_memory = inst:HasTag("honor_the_memory")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.AnimState:SetBank("moon_tree_blossom_lantern")
    inst.AnimState:SetBuild("moon_tree_blossom_lantern")

    inst.Light:SetIntensity(0.819375)
    inst.Light:SetRadius(0.7125)
    inst.Light:SetFalloff(0.7)
    inst.Light:SetColour(0.01, 0.35, 1)

    inst.AnimState:SetSymbolBloom("fire")
    inst.AnimState:SetSymbolLightOverride("fire", .5)

    SetState(inst, "moon", true)
    inst.AnimState:PlayAnimation("idle_full_attune_on", false)
    inst.AnimState:PushAnimation("idle_full", true)

    inst:AddTag("moon_tree_blossom_lantern")
    inst:AddTag("structure")
    inst:AddTag("rotatableobject")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scale = 1

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = TUNING.MINIBOATLANTERN_SPEED
	inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

	inst:SetStateGraph("SGmoon_tree_blossom_lantern")
	inst:SetBrain(brain)

    inst:AddComponent("knownlocations")

    -- inst:AddComponent("burnable")
    -- inst.components.burnable.fxprefab = nil
    -- inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))
    -- inst.components.burnable:Ignite()

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(OnPerish)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE

    inst.SetPercent = SetPercent
    inst.WaxReplenishment = WaxReplenishment
    inst.SetState = SetState
    inst.SetOrientation = SetOrientation
    inst.GetIdleAnim = GetIdleAnim
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("perishchange", OnPerishChange)
    inst:DoTaskInTime(0, OnInit)

    return inst
end

local function placer_postinit_fn(inst)
    inst.AnimState:Hide("FIRE")
end

return Prefab("moon_tree_blossom_lantern", fn, assets),
    MakePlacer("moon_tree_blossom_lantern_placer", "moon_tree_blossom_lantern", "moon_tree_blossom_lantern", "idle_full", nil, nil, nil, nil, nil, nil, placer_postinit_fn)
