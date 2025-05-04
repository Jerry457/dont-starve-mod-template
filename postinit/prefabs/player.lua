local AddPlayerPostInit = AddPlayerPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnInit(inst)
    inst:AddTag(tostring(inst.userid))
end

AddPlayerPostInit(function(player)
    player:DoTaskInTime(0, OnInit)
end)
