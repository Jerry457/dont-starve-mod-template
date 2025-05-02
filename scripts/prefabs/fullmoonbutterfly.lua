local assets =
{
    Asset("ANIM", "anim/fullmoonbutterfly.zip"),
}

SetSharedLootTable("fullmoonbutterfly",
{
    {"fullmoonbutterflywings", 1.0},
    {"moonglass", 1.0},
})

local brain = require("brains/fullmoonbutterflybrain")

local LIGHT_RADIUS = .5
local LIGHT_INTENSITY = .5
local LIGHT_FALLOFF = .8

local function OnUpdateFlicker(inst, starttime)
    local time = starttime ~= nil and (GetTime() - starttime) * 15 or 0
    local flicker = math.sin(time * 0.7 + math.sin(time * 6.28)) -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetIntensity(LIGHT_INTENSITY + .05 * flicker)
end

-- local function WatchMoon(inst)
--     if not inst:IsInLimbo()
--     and (TheWorld:HasTag("cave") or TheWorld.state.isnewmoon)
--     then
--         inst.components.health:SetVal(0)
--     end
-- end

local function OnDropped(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
    inst.Light:Enable(true)

    inst.sg:GoToState("idle")

    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end

    while inst.components.stackable:StackSize() > 1 do
        local item = inst.components.stackable:Get()
        if item ~= nil then
        item.Physics:Teleport(inst.Transform:GetWorldPosition())
            if item.components.inventoryitem ~= nil then
                item.components.inventoryitem:OnDropped()
            end
        end
    end

    -- WatchMoon(inst)
end

local function OnPickedUp(inst)
    inst.Light:Enable(false)
end

local function OnWorked(inst, worker)
    if worker.components.inventory ~= nil then
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
        worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
    end
end

local function OnDeploy(inst, pt, deployer)

    local sapling = SpawnPrefab("moonbutterfly_sapling")
    sapling.Transform:SetPosition(pt:Get())

    sapling:DoTaskInTime(10*FRAMES, function()
        local moontree = SpawnPrefab("moon_tree")
        moontree.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
        moontree.Transform:SetPosition(pt:Get())
        moontree:growfromseed()
        sapling:Remove()
        moontree:DoTaskInTime(16*FRAMES, function()
            moontree.components.growable:DoGrowth()
            moontree:DoTaskInTime(21*FRAMES, function()
                moontree.components.growable:DoGrowth()
            end)
        end)
    end)
    WS_UTIL.RemoveOneItem(inst)
end

local function OnDeath(inst)
    inst.Light:Enable(false)
    inst.AnimState:SetLightOverride(0)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/break")
end

local function fn()
    local inst = CreateEntity()

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
    MakeTinyFlyingCharacterPhysics(inst, 1, .5)

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBuild("fullmoonbutterfly")
    inst.AnimState:SetBank("butterfly")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetLightOverride(0.15)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetIntensity(LIGHT_INTENSITY)
    inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:SetColour(0.3, 0.55, 0.45)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst:AddTag("butterfly")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")
    inst:AddTag("wildfireprotected")
    inst:AddTag("show_spoilage")
    inst:AddTag("small_livestock")
    inst:AddTag("deployedplant")

    inst:DoPeriodicTask(.1, OnUpdateFlicker, nil, GetTime())
    OnUpdateFlicker(inst)

    MakeInventoryFloatable(inst)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.MOONBUTTERFLY_SPEED

    inst:AddComponent("stackable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.pushlandedevents = false

    inst:AddComponent("health")
    inst.components.health.murdersound = "turnoftides/common/together/moon_glass/break"
    inst.components.health:SetMaxHealth(1)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "butterfly_body"

    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "butterfly_body")
    MakeTinyFreezableCharacter(inst, "butterfly_body")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("fullmoonbutterfly")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

    MakeHauntablePanicAndIgnite(inst)
    MakeFeedableSmallLivestock(inst, TUNING.BUTTERFLY_PERISH_TIME, OnPickedUp, OnDropped)

    inst:SetStateGraph("SGbutterfly")
    inst:SetBrain(brain)

    inst:ListenForEvent("death", OnDeath)
    -- inst:WatchWorldState("isnewmoon", WatchMoon)
    -- WatchMoon(inst)

    return inst
end

return Prefab("fullmoonbutterfly", fn, assets),
    MakePlacer("fullmoonbutterfly_placer", "moon_tree", "moon_tree", "idle_tall")
