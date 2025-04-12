local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnSisturnperishChange(parent, data)
    parent.player_classified.sisturnperish:set(data.percent)
end

local function OnSisturnPerishDirty(inst)
    if inst._parent then
        inst._parent:PushEvent("sisturnperishchange", { percent = inst.sisturnperish:value() })
    end
end

local function RegisterNetListeners(inst)
    if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()
        inst:ListenForEvent("sisturnperishchange", OnSisturnperishChange, inst._parent)
    else
        inst:ListenForEvent("sisturnperishdirty", OnSisturnPerishDirty)
    end

    if not TheNet:IsDedicated() then

    end
end

AddPrefabPostInit("player_classified", function(inst)
    inst.sisturnperish = net_float(inst.GUID, "sisturn.perish", "sisturnperishdirty")

    inst:DoTaskInTime(0, RegisterNetListeners)
end)
