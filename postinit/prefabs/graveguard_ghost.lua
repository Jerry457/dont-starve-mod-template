local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local accept_items = {
    petals = 2,
    petals_evil = 2,
    moon_tree_blossom = 3,
}

local accepted_items = {}
for k, v in pairs(accept_items) do
    accepted_items[k] = 0
end

for item in pairs(accept_items) do
    AddPrefabPostInit(item, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("graveguard_ghost_item")
    end)
end

local function AcceptTest(inst, item)
    if accepted_items[item.prefab] >= 3 then
        return false, "ENOUGH"
    end

    accepted_items[item.prefab] = accepted_items[item.prefab] + 1

    if item.components.stackable then
        item.components.stackable:Get():Remove()
    else
        item:Remove()
    end

    for i = 1, accept_items[item.prefab] do
        inst.components.lootdropper:SpawnLootPrefab("ghostflower")
    end

    return true
end

AddPrefabPostInit("graveguard_ghost", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("lootdropper")

    inst.AcceptTest = AcceptTest
end)

local function OnCyclesChanged(inst)
    for k, v in pairs(accept_items) do
        accepted_items[k] = 0
    end
end

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:WatchWorldState("cycles", OnCyclesChanged)
end)
