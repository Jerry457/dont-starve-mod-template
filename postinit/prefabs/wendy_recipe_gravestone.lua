local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)


local WENDY_PLACER_SNAP_TAGS = { "grave" }
local WENDY_PLACER_SNAP_DISTANCE = 1.0
local function OnWritingEnded(inst, data)
    if not inst.components.writeable then return end

    local mound = FindClosestEntity(inst, WENDY_PLACER_SNAP_DISTANCE, true, WENDY_PLACER_SNAP_TAGS, nil, nil , function(ent)
        return ent.prefab == "mound"
    end)


    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)

    local gravestone = SpawnPrefab("gravestone")
    gravestone.Transform:SetPosition(ix, iy, iz)
    gravestone.random_stone_choice = tostring(math.random(4))
    gravestone.AnimState:PlayAnimation("grave"..gravestone.random_stone_choice.."_place")
    gravestone.AnimState:PushAnimation("grave"..gravestone.random_stone_choice)
    gravestone.SoundEmitter:PlaySound("meta5/wendy/tombstone_place")

    if mound then
        local mound_data = mound:GetSaveRecord()
        mound:Remove()
        gravestone.mound:SetPersistData(mound_data)
    end

    if inst.components.writeable:IsWritten() then
        local epitaph = inst.components.writeable:GetText()
        gravestone.setepitaph = epitaph
        gravestone.components.inspectable:SetDescription("'"..epitaph.."'")
    end

    inst:DoTaskInTime(0, inst.Remove)
end

AddPrefabPostInit("wendy_recipe_gravestone", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.writeable:SetOnWritingEndedFn(OnWritingEnded)

end)

local function wendy_placer_onupdatetransform(inst)
    local mound = FindClosestEntity(inst, WENDY_PLACER_SNAP_DISTANCE, true, WENDY_PLACER_SNAP_TAGS, nil, nil , function(ent)
        return ent.prefab == "mound"
    end)

    if mound then
        local x, y, z = mound.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x - 0.35355339059327, 0, z - 0.35355339059327)

        inst._accept_placement = true
    else
        inst._accept_placement = false
    end
end

AddPrefabPostInit("wendy_recipe_gravestone_placer", function(inst)
    inst.components.placer.onupdatetransform = wendy_placer_onupdatetransform
end)
