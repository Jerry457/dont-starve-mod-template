local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnRegrow(prefab, modifier, sound)
    return function(inst, doer)
        if type(prefab) == "function" then
            local success, message = prefab(inst, doer)
            if not success then
                return success, message
            end
        else
            local ent = SpawnPrefab(prefab)
            local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner() or nil
            local container = owner and (owner.components.inventory or owner.components.container) or nil
            if container then
                container:GiveItem(ent)
            else
                local x, y, z = inst.Transform:GetWorldPosition()
                ent.Transform:SetPosition(x, y, z)
            end
            WS_UTIL.RemoveOneItem(inst)
        end

        if modifier and doer.components.talker then
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_REGAIN_GLORY", modifier), nil, true)
        end

        doer.SoundEmitter:PlaySound(sound or "dontstarve/ghost/bloodpump")

        return true
    end
end

local regrow_prefabs = {
    petals = {
        "butterfly",
        "BUTTERFLY",
    }
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

AddPrefabPostInit("petals_evil", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        if (TheWorld.state.isnewmoon or TheWorld.state.isnightmarewild)
            or (
                TheWorld.state.isnight
                and not TheWorld.state.isfullmoon
                and math.random() < 0.1
            )
        then
            return OnRegrow("darkbutterfly", "DARKBUTTERFLY", "maxwell_rework/shadow_magic/cast")(inst, doer)
        end
        return OnRegrow("evilbutterfly", "EVILBUTTERFLY")(inst, doer)
    end)
end)

AddPrefabPostInit("moon_tree_blossom", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        if TheWorld.state.isfullmoon
            or (
                TheWorld.state.isnight
                and not TheWorld.state.isnewmoon
                and not TheWorld:HasTag("cave")
                and math.random() < 0.1
            )
        then
            return OnRegrow("fullmoonbutterfly", "FULLMOONBUTTERFLY", "meta2/wormwood/animation_sendup")(inst, doer)
        end
        return OnRegrow("moonbutterfly", "MOON_TREE_BLOSSOM")(inst, doer)
    end)
end)

AddPrefabPostInit("abigail_flower", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        return false, "ABIGAIL_FLOWER"
    end)
end)

AddPrefabPostInit("glommerflower", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(function(inst, doer)
        if not inst:HasTag("glommerflower") then
            return false, "GLOMMERFLOWERS"
        end
        return false, "GLOMMERFLOWERS"
    end)
end)


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
    inst.components.regainglory:SetOnRegrowFn(OnRegrow(function(inst, doer)
        if inst.isOpenEye then
            return false, "HAS_CHESTER"
        end
        RespawnChester(inst)
        doer.SoundEmitter:PlaySound("dontstarve/ghost/bloodpump")
        return true
    end, "CHESTER"))
end)

AddPrefabPostInit("hutch_fishbowl", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local RespawnHutch = GlassicAPI.UpvalueUtil.GetUpvalue(inst.components.inventoryitem.onputininventoryfn, "FixHutch.StartRespawn.RespawnHutch")

    inst:AddComponent("regainglory")
    inst.components.regainglory:SetOnRegrowFn(OnRegrow(function(inst, doer)
        if inst.isFishAlive then
            return false, "HUTCH_FISHBOWL"
        end
        RespawnHutch(inst)
        doer.SoundEmitter:PlaySound("dontstarve/ghost/bloodpump")
        return true
    end, "HUTCH_FISHBOWL"))
end)
