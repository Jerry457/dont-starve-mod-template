local Grave_Relocation_Item = Class(function(self, inst)
    self.inst = inst
end)

function Grave_Relocation_Item:Relocation(doer, grave, ghostflower)
    if grave:HasTag("skeleton") then  -- "收殓"
        doer.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")
        doer.SoundEmitter:PlaySound("meta5/wendy/place_gravestone")
    elseif grave.prefab == "mound" then -- "移灵"
        doer.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")
        doer.SoundEmitter:PlaySound("dontstarve/common/plant")
    else  -- "改葬"
        doer.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")
        doer.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop")
    end

    local grave_pos = grave:GetPosition()
    if grave:HasTag("skeleton") then
        grave:Remove()
        grave = SpawnPrefab("mound")
    end
    local grave_data = grave:GetSaveRecord()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(grave_pos:Get())
    self.inst.SoundEmitter:PlaySound("meta5/wendy/tombstone_place")
    grave:Remove()

    WS_UTIL.RemoveOneItem(ghostflower)

    local possessed_ghostflower = SpawnPrefab("possessed_ghostflower_" .. grave.prefab)
    possessed_ghostflower.grave_data = grave_data
    doer.components.inventory:GiveItem(possessed_ghostflower, nil, grave_pos)
end

return Grave_Relocation_Item
