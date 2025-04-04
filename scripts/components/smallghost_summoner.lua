local SmallGhost_Summoner = Class(function(self, inst)
    self.inst = inst

    if not self.inst.components.timer then
        inst:AddComponent("timer")
    end
end)

function SmallGhost_Summoner:Summon(grave)
    if grave.ghost and grave.ghost:IsValid() then
        return false, "NOTHOME"
    end

    if self.inst.questghost ~= nil then
        return false, "ONEGHOST"
    end

    if self.inst.components.timer:TimerExists("small_ghost_summon_cooldown") then
        return false, "COOLDOWN"
    end

    self.inst.components.timer:StartTimer("small_ghost_summon_cooldown", TUNING.TOTAL_DAY_TIME)

    local x, y, z = grave.Transform:GetWorldPosition()
    local ghost_prefab = grave.grave_bouquet and "graveguard_ghost" or "smallghost"
    local ghost = SpawnPrefab(ghost_prefab)
    grave.ghost = ghost
    grave.ghost.Transform:SetPosition(x + 0.3, y, z + 0.3)
    grave.ghost:LinkToHome(grave)

    if ghost_prefab == "graveguard_ghost" then
        local _decorated_graves = GlassicAPI.UpvalueUtil.GetUpvalue(TheWorld.components.decoratedgrave_ghostmanager.GetDebugString, "_decorated_graves")
        _decorated_graves[grave] = ghost
        TheWorld:ListenForEvent("onremove", function()
            if grave and grave:IsValid() then
                local time = (ghost.components.health:IsDead() and TUNING.WENDYSKILL_GRAVEGHOST_DEADTIME) or 5
                _decorated_graves[grave] = self.inst:DoTaskInTime(time, function()
                    local grave_data = _decorated_graves[grave]
                    if grave_data and type(grave_data) == "table" and not grave_data.prefab then
                        _decorated_graves[grave] = false
                    end
                end)
            end
        end, ghost)
    else
        grave.ghost:DoTaskInTime(0, function(ghost)
            ghost.components.questowner:BeginQuest(self.inst)
        end)
    end

    return true
end

return SmallGhost_Summoner
