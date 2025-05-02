SetSharedLootTable("evilbutterfly",
{
    {"nightmarefuel", 0.1},
})

SetSharedLootTable("darkbutterfly",
{
    {"nightmarefuel", 0.8},
})

local function OnDroppedFn(inst)
    inst.AnimState:PlayAnimation("build")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
end

local function MakeButterfly(name, deploy_prefab, murdersound)
    local assets =
    {
        Asset("ANIM", "anim/" .. name ..".zip"),
    }

    local function OnDeploy(inst, pt, deployer)
        local flower = SpawnPrefab(deploy_prefab)
        if flower then
            flower.Transform:SetPosition(pt:Get())
            WS_UTIL.RemoveOneItem(inst)
            if deployer and deployer.SoundEmitter then
                deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
            end
        end
    end

    local function OnDeath(inst)
        inst.SoundEmitter:PlaySound(murdersound)
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

        inst.AnimState:SetBuild(name)
        inst.AnimState:SetBank(name)
        inst.AnimState:PlayAnimation("build")
        inst.AnimState:PushAnimation("idle_loop", true)
        inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
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
        inst.components.inventoryitem:SetOnDroppedFn(OnDroppedFn)

        inst:AddComponent("health")
        inst.components.health.murdersound = murdersound
        inst.components.health:SetMaxHealth(1)

        inst:AddComponent("stackable")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable(name)

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = OnDeploy
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

        inst:ListenForEvent("death", OnDeath)

        MakeHauntablePanicAndIgnite(inst)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeButterfly("evilbutterfly", "flower_evil", "dontstarve/impacts/impact_insect_sml_dull"),
    MakeButterfly("darkbutterfly", "flower_rose", "maxwell_rework/shadow_magic/sanity_creature_fx"),
    MakePlacer("evilbutterfly_placer", "flowers_evil", "flowers_evil", "f" .. math.random(8)),
    MakePlacer("darkbutterfly_placer", "flowers", "flowers", "rose")
