local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnRemove(inst)
    TheWorld:DoTaskInTime(0, TheWorld.PushEvent, "spiritualperceptionchange")
end

AddPrefabPostInit("nightlight", function(inst)
    inst:AddTag("nightlight")

    inst:ListenForEvent("onremove", OnRemove)
end)
