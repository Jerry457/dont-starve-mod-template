local Grave_Relocation_Item = Class(function(self, inst)
    self.inst = inst
end)

function Grave_Relocation_Item:Relocation(doer, grave, ghostflower)
    local grave_pos = grave:GetPosition()
    if grave:HasTag("skeleton") then
        grave:Remove()
        grave = SpawnPrefab("mound")
    end
    local grave_data = grave:GetSaveRecord()
    grave:Remove()

    ghostflower:Remove()

    local possessed_ghostflower = SpawnPrefab("possessed_ghostflower_" .. grave.prefab)
    possessed_ghostflower.grave_data = grave_data
    doer.components.inventory:GiveItem(possessed_ghostflower, nil, grave_pos)
end

return Grave_Relocation_Item
