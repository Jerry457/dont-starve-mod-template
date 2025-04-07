local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnFlowerPerished(item)
    item.components.perishable.onperishreplacement = "ghostflower"
end

local function OnItemGet(inst, data)
    local item = data and data.item
    if item and item:HasTag("petal") and item.components.perishable and inst._petal_preserve then
        inst:ListenForEvent("perished", OnFlowerPerished, item)
    end
end

local function OnItemLose(inst, data)
    local item = data and data.prev_item
    if item and item.components.perishable then
        inst:RemoveEventCallback("perished", OnFlowerPerished, item)
    end
end

AddPrefabPostInit("sisturn", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("itemget", OnItemGet)
    inst:ListenForEvent("itemlose", OnItemLose)
end)
