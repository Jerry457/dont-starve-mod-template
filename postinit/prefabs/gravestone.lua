local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

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

-- NOTES(DiogoW): This used to be TheCamera:GetDownVec()*.5, probably legacy code from DS,
-- since TheCamera:GetDownVec() would always return the values below.
local MOUND_POSITION_OFFSET = { 0.45355339059327, 0, 0.45355339059327 }
local function initiate_flower_state(inst, flower)
    TheWorld.components.decoratedgrave_ghostmanager:RegisterDecoratedGrave(inst)

    if inst.components.timer:TimerExists("spawn_petals_evil") then
        inst.grave_bouquet = inst:SpawnChild("grave_bouquet_evil")
    else
        inst.grave_bouquet = inst:SpawnChild("grave_bouquet")
    end

    inst.grave_bouquet.Follower:FollowSymbol(inst.GUID, "gravestone01", 0, 0, 0)
    -- inst.grave_bouquet.Transform:SetPosition(unpack(MOUND_POSITION_OFFSET))
end

local function OnDecorated(inst, upgrade_performer, flower)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)

    if not inst.components.timer:TimerExists("grave_bouquet_decay") then
        inst.components.timer:StartTimer("grave_bouquet_decay", flower.components.perishable.perishremainingtime)
    end

    if not inst.components.timer:TimerExists("spawn_" .. flower.prefab) then
        inst.components.timer:StartTimer("spawn_" .. flower.prefab, 240)
    end

    initiate_flower_state(inst)
end

local function OnTimerDone(inst, data)
    if data.name == "grave_bouquet_decay" then
        local x, y, z = inst.grave_bouquet.Transform:GetWorldPosition()
        inst.grave_bouquet:Remove()
        inst.grave_bouquet = nil
        SpawnPrefab("ghostflower").Transform:SetPosition(x, y, z)

        inst.components.upgradeable:SetStage(1)
        inst.components.timer:StopTimer("spawn_petals_evil")
        inst.components.timer:StopTimer("spawn_petals")
    elseif data.name == "spawn_petals_evil" or data.name == "spawn_petals" then
        TrySpawnFlower(inst, string.gsub(data.name, "spawn_petals", "flower"))
        inst.components.timer:StartTimer(data.name, 240)
    end
end

AddPrefabPostInit("gravestone", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.mound:AddTag("has_gravestone")
    inst:AddTag("grave_relocation")

    GlassicAPI.UpvalueUtil.SetUpvalue(inst.components.upgradeable.onstageadvancefn, "initiate_flower_state", initiate_flower_state)
    inst.components.upgradeable.upgradesperstage = 1
    inst.components.upgradeable.onstageadvancefn = nil
    inst.components.upgradeable:SetOnUpgradeFn(OnDecorated)

    inst:ListenForEvent("timerdone", OnTimerDone)
end)
