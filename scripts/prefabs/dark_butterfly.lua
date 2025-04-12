local assets =
{
    Asset("ANIM", "anim/dark_butterfly.zip"),
}

SetSharedLootTable("dark_butterfly",
{
    {"nightmarefuel", 0.5},
})

local function OnDeploy(inst, pt, deployer)
    local flower = SpawnPrefab(math.random() < 0.9 and "flower_rose" or "flower_evil")
    if flower then
        flower.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        if deployer and deployer.SoundEmitter then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
    MakeTinyFlyingCharacterPhysics(inst, 1, .5)

    inst:AddTag("butterfly")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")
    inst:AddTag("wildfireprotected")
    inst:AddTag("deployedplant")
    inst:AddTag("noember")

    --pollinator (from pollinator component) added to pristine state for optimization
    inst:AddTag("pollinator")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBuild("dark_butterfly")
    inst.AnimState:SetBank("dark_butterfly")
    inst.AnimState:PlayAnimation("build")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst.DynamicShadow:SetSize(.8, .5)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.pushlandedevents = false

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)

    inst:AddComponent("stackable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("dark_butterfly")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

    MakeHauntablePanicAndIgnite(inst)

    return inst
end

return Prefab("dark_butterfly", fn, assets),
    MakePlacer("dark_butterfly_placer", "flowers", "flowers", "rose")
