local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local accept_items = {
    petals = 2,
    petals_evil = 2,
    moon_tree_blossom = 3,
}

local function ShouldAcceptItem(inst, item, giver, count)
    local skilltreeupdater = (giver and giver.components.skilltreeupdater) or nil

    if skilltreeupdater and skilltreeupdater:IsActivated("wendy_smallghost_2") then
        if target:HasTag("grave_relocation") and not target:HasTag("has_gravestone") then
            table.insert(actions, ACTIONS.GRAVE_RELOCATION)
        end
    end

    if accept_items[item.prefab] then
        return false
    end

    if inst.items[item.prefab] >= accept_items[item.prefab] then
        if giver and giver.components.talker then
            giver.components.talker:Say(Getstrings())
        end
        return false
    end

    return
end

local function OnGetItemFromPlayer(inst, giver, item)

end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

AddPrefabPostInit("graveguard_ghost", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.items = {}
    for k, v in pairs(accept_items) do
        inst.items[k] = 0
    end

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = true
end)
