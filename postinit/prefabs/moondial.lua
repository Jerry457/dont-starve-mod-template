
local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnRemove(inst)
    TheWorld:DoTaskInTime(0, TheWorld.PushEvent, "remove_moondial")
end

AddPrefabPostInit("moondial", function(inst)
    inst:AddTag("moondial")

    TheWorld:PushEvent("spawn_moondial")
    inst:ListenForEvent("onremove", OnRemove)
end)
