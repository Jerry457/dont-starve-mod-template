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

local function ConfigureSkillTreeUpgrades(inst, builder)
    local skilltreeupdater = (builder and builder.components.skilltreeupdater) or nil

    local petal_preserve = (skilltreeupdater and skilltreeupdater:IsActivated("wendy_sisturn_1")) or nil
    local sanityaura_size = nil

    local dirty = (inst._petal_preserve ~= petal_preserve) or (inst._sanityaura_size ~= sanityaura_size)

    inst._petal_preserve = petal_preserve
    inst._sanityaura_size = sanityaura_size

    return dirty
end

AddPrefabPostInit("sisturn", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("itemget", OnItemGet)
    inst:ListenForEvent("itemlose", OnItemLose)

    local on_built = inst:GetEventCallbacks("onbuilt", inst, "scripts/prefabs/sisturn.lua")
    GlassicAPI.UpvalueUtil.SetUpvalue(on_built, "ConfigureSkillTreeUpgrades", ConfigureSkillTreeUpgrades)
end)
