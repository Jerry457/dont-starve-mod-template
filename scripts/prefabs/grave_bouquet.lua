local assets =
{
    Asset("ANIM", "anim/grave_bouquet.zip"),
}

local FLOWER_TAG = {"flower"}
local FLOWER_SPAWN_RADIUS = 1.5
local function TrySpawnFlower(inst, prefab)
    if TheWorld.state.iswinter then return end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    if TheSim:CountEntities(ix, iy, iz, 2 * FLOWER_SPAWN_RADIUS, FLOWER_TAG) < 12 then
        local random_angle = PI2 * math.random()
        ix = ix + (FLOWER_SPAWN_RADIUS * math.cos(random_angle))
        iz = iz - (FLOWER_SPAWN_RADIUS * math.sin(random_angle))
        local flower = SpawnPrefab(prefab)
        flower.Transform:SetPosition(ix, iy, iz)
        SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)
    end
end

local function OnReplaced(inst, goop)
    local x, y, z = inst.Transform:GetWorldPosition()
    goop.Transform:SetPosition(x + 0.8, y, z + 0.8)
end

local function OnLoad(inst, data)
    if data and data.anim then
        inst.AnimState:PlayAnimation(data.anim)
    end
end

local function OnSave(inst, data)
    data.anim = inst.anim
end

local function MakeGraveHouquet(petals, flower)
    local function OnTimerDone(inst, data)
        TrySpawnFlower(inst, flower)
        inst.components.timer:StartTimer(data.name, 240)
    end

    local function OnPerishChange(inst)
        local percent = inst.components.perishable:GetPercent()
        if percent <= 0.3 then
            inst.AnimState:OverrideSymbol("petals", "grave_bouquet", petals .. "_decay")
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddFollower()
        inst.entity:AddNetwork()

        inst:AddTag("Fx")
        inst:AddTag("NOBLOCK")
        inst:AddTag("NOCLICK")

        inst.AnimState:SetBank("grave_bouquet")
        inst.AnimState:SetBuild("grave_bouquet")

        inst.AnimState:SetFinalOffset(2)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst.anim = "idle" .. math.random(1, 3)
        inst.AnimState:OverrideSymbol("petals", "grave_bouquet", petals)
        inst.AnimState:PlayAnimation(inst.anim)

        inst:AddComponent("perishable")
        inst.components.perishable.perishtime = TUNING.PERISH_FAST
        inst.components.perishable.onperishreplacement = "ghostflower"
        inst.components.perishable.onreplacedfn = OnReplaced

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("spawn_flower", 240)

        inst:ListenForEvent("timerdone", OnTimerDone)
        inst:ListenForEvent("perishchange", OnPerishChange)

        inst.OnPerishChange = OnPerishChange

        -- call save and load by gravestone
        inst.OnLoad = OnLoad
        inst.OnSave = OnSave

        return inst
    end

    return Prefab("grave_bouquet" .. petals, fn, assets)
end

return MakeGraveHouquet("petals_evil", "flower_evil"),
    MakeGraveHouquet("petals", "flower")
