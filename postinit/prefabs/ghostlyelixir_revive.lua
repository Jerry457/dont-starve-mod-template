local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("ghostlyelixir_revive", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    -- separate buff
    inst.components.ghostlyelixir.doapplyelixerfn = function (inst, giver, target)
        local buff = target:AddDebuff(inst.buff_prefab, inst.buff_prefab)
        if buff then
            local new_buff = target:GetDebuff(inst.buff_prefab)
            new_buff:buff_skill_modifier_fn(giver, target)
            return buff
        end
    end
end)
