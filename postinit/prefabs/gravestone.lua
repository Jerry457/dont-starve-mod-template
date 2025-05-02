local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)


local function SpawnGraveBouquet(inst, record)
    if inst.grave_bouquet then
        inst.grave_bouquet:Remove()
        inst.grave_bouquet = nil
    end

    inst.grave_bouquet = inst:SpawnChild(record.prefab)
    inst.grave_bouquet.gravestone = inst
    if record.data then
        inst.grave_bouquet:SetPersistData(record.data)
    else
        inst.grave_bouquet.components.perishable.perishremainingtime = record.perishremainingtime
        inst.grave_bouquet.components.perishable:StartPerishing()
    end
    inst.grave_bouquet:OnPerishChange()
    inst.grave_bouquet.Follower:FollowSymbol(inst.GUID, "gravestone01", 0, 0, 0)
    inst:ListenForEvent("onremove", function()
        inst.grave_bouquet = nil
        inst.components.upgradeable:SetStage(1)
    end, inst.grave_bouquet)
end

-- NOTES(DiogoW): This used to be TheCamera:GetDownVec()*.5, probably legacy code from DS,
-- since TheCamera:GetDownVec() would always return the values below.
local MOUND_POSITION_OFFSET = { 0.45355339059327, 0, 0.45355339059327 }
local function initiate_flower_state(inst, flower)
    TheWorld.components.decoratedgrave_ghostmanager:RegisterDecoratedGrave(inst)
end

local function OnStageAdvancefn(inst)
    inst.components.upgradeable:SetStage(1)
end

local function OnDecorated(inst, upgrade_performer, flower)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)

    SpawnGraveBouquet(inst, {
        prefab = "grave_bouquet" .. flower.prefab,
        perishremainingtime = flower.components.perishable.perishremainingtime
    })

    initiate_flower_state(inst)
end

local MOON_TREE_BLOSSOM_LANTERN_TAG =  { "moon_tree_blossom_lantern" }
local function HasMoonTreeBlossomLantern(inst)
    if not FindClosestEntity(inst, 1.2, nil, MOON_TREE_BLOSSOM_LANTERN_TAG) then
        if inst.components.timer:TimerExists("spawn_moontree_blossom") then
            inst.components.timer:StopTimer("spawn_moontree_blossom")
        end
        inst:RemoveTag("gravestone_shade")
    else
        inst:AddTag("gravestone_shade")

        local fx = SpawnPrefab("gravestone_light_loop")
        inst:AddChild(fx)
        fx.Transform:SetPosition(0, 0, 0)

        if not inst.components.timer:TimerExists("spawn_moontree_blossom") then
            inst.components.timer:StartTimer("spawn_moontree_blossom", 240)
        end
    end
end

local FLOWER_TAG = {"flower"}
local FLOWER_SPAWN_RADIUS = 1.5
local function OnTimerDone(inst, data)
    if not data or data.name ~= "spawn_moontree_blossom" then
        return
    end

    if TheWorld.state.iswinter then return end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    if TheSim:CountEntities(ix, iy, iz, 2 * FLOWER_SPAWN_RADIUS, FLOWER_TAG) < 12 then
        local random_angle = PI2 * math.random()
        ix = ix + (FLOWER_SPAWN_RADIUS * math.cos(random_angle))
        iz = iz - (FLOWER_SPAWN_RADIUS * math.sin(random_angle))
        local flower = SpawnPrefab("moon_tree_blossom_".. math.random(1, 6))
        flower.Transform:SetPosition(ix, iy, iz)
        SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)
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
    inst.components.upgradeable.onstageadvancefn = OnStageAdvancefn
    inst.components.upgradeable:SetOnUpgradeFn(OnDecorated)

    local _OnLoad = inst.OnLoad
    function inst:OnLoad(data, ...)
        if _OnLoad then
            _OnLoad(self, data, ...)
        end
        if data.grave_bouquet then
            SpawnGraveBouquet(inst, data.grave_bouquet)
        end
    end

    local _OnSave = inst.OnSave
    function inst:OnSave(data, newents, ...)
        local refs
        if _OnSave then
            refs = _OnSave(inst, data, newents, ...)
        end


        if inst and inst.grave_bouquet then
            data.grave_bouquet = inst.grave_bouquet:GetSaveRecord()
        end

        return refs
    end

    inst:DoPeriodicTask(50*FRAMES, HasMoonTreeBlossomLantern)
    inst:ListenForEvent("timerdone", OnTimerDone)
end)
