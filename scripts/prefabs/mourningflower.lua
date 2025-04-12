local assets =
{
    Asset("ANIM", "anim/mourningflower.zip"),
    Asset("ANIM", "anim/mourningflower_spirit_fx.zip"),
}

local function DoFx(inst)
    if not inst.inlimbo then
        local fx = SpawnPrefab("mourningflower_spirit" .. tostring(math.random(2)) .. "_fx")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst:DoTaskInTime(3 + math.random() * 6, DoFx) -- the min delay needs to be greater than the grow animation + it's delay
    end
end

local function ToGround(inst)
    inst:DoTaskInTime(3 + math.random() * 6, DoFx)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("mourningflower")
    inst.AnimState:SetBuild("mourningflower")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    MakeInventoryPhysics(inst)

    -- inst.scrapbook_deps = {"ghostflower","nightmarefuel"}

    -- inst.MiniMapEntity:SetIcon("mourningflower.tex")

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

    inst:AddTag("mourningflower")
    -- inst:AddTag("give_dolongaction")
    -- inst:AddTag("ghostlyelixirable") -- for ghostlyelixirable component

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("lootdropper")

    inst:AddComponent("mourningflower")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:ListenForEvent("ondropped", ToGround)
    ToGround(inst)
    -- MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    -- inst.components.burnable.fxdata = {}
    -- inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))

    -- MakeSmallPropagator(inst)
    -- MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mourningflower", fn, assets)
