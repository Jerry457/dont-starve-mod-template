local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)


local function OnDebuffAdded(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "ghostlyelixir_revive_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol3(debuff.prefab)
        end
    end
end

local function OnDebuffRemoved(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "ghostlyelixir_revive_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol3(0)
        end
	end
end

AddPrefabPostInit("abigail", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.UpdateBonusHealth = function(inst, newbonus)
        inst.bonus_max_health = newbonus
    end
    local OnHealthChanged = inst:GetEventCallbacks("pre_health_setval", inst, "scripts/prefabs/abigail.lua")
    inst:RemoveEventCallback("pre_health_setval", OnHealthChanged)

    local _LinkToPlayer = inst.LinkToPlayer
    function inst:LinkToPlayer(player, ...)
        if player.components.pethealthbar ~= nil then
            local revive_buff = inst:GetDebuff("ghostlyelixir_revive_buff")
            if revive_buff then
                player.components.pethealthbar:SetSymbol3(revive_buff.prefab)
            end
        end
        _LinkToPlayer(self, player, ...)
    end

    local _ondebuffadded = inst.components.debuffable.ondebuffadded
    function inst.components.debuffable:ondebuffadded(name, ent, ...)
        _ondebuffadded(self, name, ent, ...)
        OnDebuffAdded(inst, name, ent, ...)
    end

    local _ondebuffremoved = inst.components.debuffable.ondebuffremoved
    function inst.components.debuffable:ondebuffremoved(name, ent, ...)
        _ondebuffremoved(self, name, ent, ...)
        OnDebuffRemoved(inst, name, ent, ...)
    end
end)
