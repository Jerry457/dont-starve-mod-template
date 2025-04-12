local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnRegrow(prefab, modifier)
    return function (inst, doer)
        local ent = SpawnPrefab(prefab)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner() or nil
        local container = owner and (owner.components.inventory or owner.components.container) or nil
        if container then
            container:GiveItem(ent)
        else
            local x, y, z = inst.Transform:GetWorldPosition()
            ent.Transform:SetPosition(x, y, z)
        end

        if modifier and doer.components.talker then
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_REGAIN_GLORY", modifier), nil, true)
        end

        if inst.components.stackable then
            inst.components.stackable:Get():Remove()
        else
            inst:Remove()
        end

        return true
    end
end

local regrow_prefabs = {
    petals = {
        "butterfly",
    },
    petals_evil = {
        "dark_butterfly",
    },
    moon_tree_blossom = {
        "moonbutterfly",
    },
}

for regrow_prefab, data in pairs(regrow_prefabs) do
    AddPrefabPostInit(regrow_prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("regainglory")
        inst.components.regainglory:SetOnRegrowFn(OnRegrow(unpack(data)))
    end)
end

AddPrefabPostInit("fruitflyfruit", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        if inst:HasTag("fruitflyfruit") then
            return false, "HAS_FRUITFLY"
        elseif TheSim:FindFirstEntityWithTag("friendlyfruitfly") then
            return false, "HAS_FRUITFLY"
        end
        return OnRegrow("fruitflyfruit", "FRUITFLY")(inst, doer)
    end)
end)

AddPrefabPostInit("chester_eyebone", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local RespawnChester = GlassicAPI.UpvalueUtil.GetUpvalue(inst.components.inventoryitem.onputininventoryfn, "FixChester.StartRespawn.RespawnChester")

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        if not inst.isOpenEye then
            RespawnChester(inst)
            if doer.components.talker then
                doer.components.talker:Say(GetString(doer, "ANNOUNCE_REGAIN_GLORY", "CHESTER"), nil, true)
            end
            return true
        end
        return false, "HAS_CHESTER"
    end)
end)

AddPrefabPostInit("hutch_fishbowl", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local RespawnHutch = GlassicAPI.UpvalueUtil.GetUpvalue(inst.components.inventoryitem.onputininventoryfn, "FixHutch.StartRespawn.RespawnHutch")

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        if not inst.isFishAlive then
            RespawnHutch(inst)
            if doer.components.talker then
                doer.components.talker:Say(GetString(doer, "ANNOUNCE_REGAIN_GLORY", "HUTCH_FISHBOWL"), nil, true)
            end
            return true
        end
        return false, "HUTCH_FISHBOWL"
    end)
end)
