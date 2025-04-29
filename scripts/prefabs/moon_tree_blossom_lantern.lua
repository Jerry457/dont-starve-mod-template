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
    if percent < 0.3 then
        return "idle_less"
    elseif percent < 0.8 then
        return "idle_half"
    else
        return "idle_full"
    end
end

local function OnPerish(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then
        inst.components.perishable.onperishreplacement = "ghostflower"
    else
        inst:Remove()
    end
end

local function OnPerishChange(inst)
    inst.AnimState:PlayAnimation(inst:GetIdleAnim(), true)
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
        OnPerishChange(inst)
    end
end

local function OnSave(inst, data)
    data.scale = inst.scale
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
    inst.AnimState:OverrideSymbol("fire", "moon_tree_blossom_lantern", "fire_moon")
    inst.AnimState:OverrideSymbol("glow", "moon_tree_blossom_lantern", "glow_moon")
    inst.AnimState:OverrideSymbol("sprk_1 copy", "moon_tree_blossom_lantern", "sprk_1 copy_moon")
    inst.AnimState:OverrideSymbol("sprk_2", "moon_tree_blossom_lantern", "sprk_2_moon")

    inst.Light:SetIntensity(0.819375)
    inst.Light:SetRadius(0.7125)
    inst.Light:SetFalloff(0.7)
    inst.Light:SetColour(0.01, 0.35, 1)

    inst.AnimState:SetSymbolBloom("fire")
    inst.AnimState:SetSymbolLightOverride("fire", .5)
    inst.AnimState:PlayAnimation("idle_full", true)

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

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE

    inst.SetOrientation = SetOrientation
    inst.GetIdleAnim = GetIdleAnim
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("perishchange", OnPerishChange)
    inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab("moon_tree_blossom_lantern", fn, assets),
    MakePlacer("moon_tree_blossom_lantern_placer", "moon_tree_blossom_lantern", "moon_tree_blossom_lantern", "idle_full")
