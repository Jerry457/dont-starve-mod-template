local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnSisturnperishChange(parent, data)
    parent.player_classified.sisturnperish:set(data.percent)
    parent.player_classified.sisturnstate:set(data.state)
end

local function OnSisturnPerishDirty(inst)
    if inst._parent then
        inst._parent:PushEvent("sisturnperishchange", { percent = inst.sisturnperish:value(), state = inst.sisturnstate:value() })
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
    inst.sisturnstate = net_string(inst.GUID, "sisturn.state", "sisturnperishdirty")
    inst.sisturnperish = net_float(inst.GUID, "sisturn.perish", "sisturnperishdirty")

    inst.sisturnstate:set("NORMAL")
    inst.sisturnperish:set(0)

    inst:DoTaskInTime(0, RegisterNetListeners)
end)
