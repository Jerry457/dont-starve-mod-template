local Begin_Again = Class(function(self, inst)
    self.inst = inst
    self.record_elixir_buff = nil
end)

function Begin_Again:RecordElixirBuff(buff_prefab)
    self.record_elixir_buff = buff_prefab
end

function Begin_Again:ApplyElixirBuff()
    if not self.record_elixir_buff then
        return false
    end

    local ghost = self.inst.components.ghostlybond and self.inst.components.ghostlybond.ghost
    if not ghost then
        return false
    end

    local buff_type = inst.potion_tunings.buff_type or "elixir_buff"

    local buff = target:AddDebuff(buff_type, inst.buff_prefab, nil, nil, function()
        local cur_buff = target:GetDebuff(buff_type)
        if cur_buff ~= nil and cur_buff.prefab ~= inst.buff_prefab then
            target:RemoveDebuff(buff_type)
        end
    end)

    if buff then
        if target == giver and giver.components.begin_again then
            giver.components.begin_again:RecordElixirBuff(buff_type)
        end
        local new_buff = target:GetDebuff(buff_type)
        new_buff:buff_skill_modifier_fn(giver, target)
        return buff
    end
end

function Begin_Again:OnSave()
    return {
        record_elixir_buff = self.record_elixir_buff or nil,
    }
end

function Begin_Again:OnLoad(data)
    if not data then
        return
    end
    self.record_elixir_buff = data.record_elixir_buff or nil
end

return Begin_Again
