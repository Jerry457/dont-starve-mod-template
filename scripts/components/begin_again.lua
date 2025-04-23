function HookDebuff(inst, hook, buff_prefab, ...)
    local _GetDebuff = inst.GetDebuff
    function inst:GetDebuff(name, ...)
        if name == "elixir_buff" then
            local player_to_ghost_elixir_buff = _GetDebuff(self, "player_to_ghost_elixir_buff", ...)
            if player_to_ghost_elixir_buff
                and (not buff_prefab or player_to_ghost_elixir_buff.prefab == buff_prefab)
            then
                return player_to_ghost_elixir_buff
            end
        end
        return _GetDebuff(self, name, ...)
    end
    hook(...)
    inst.GetDebuff = _GetDebuff
end

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

    local buff_type = "player_to_ghost_elixir_buff"

    local buff = ghost:AddDebuff(buff_type, self.record_elixir_buff, { player_to_ghost = true}, nil, function()
        local cur_buff = ghost:GetDebuff(buff_type)
        if cur_buff ~= nil and cur_buff.prefab ~= self.record_elixir_buff then
            ghost:RemoveDebuff(buff_type)
        end
    end)

    if buff then
        local new_buff = ghost:GetDebuff(buff_type)
        new_buff:buff_skill_modifier_fn(self.inst, ghost)
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
