local SmallGhost_Summoner = Class(function(self, inst)
    self.inst = inst

    if not self.inst.components.timer then
        inst:AddComponent("timer")
    end
end)

function SmallGhost_Summoner:Summon(target)
    if target.ghost and target.ghost:IsValid() then
        return false, "NOTHOME"
    end

    if self.inst.components.timer:TimerExists("small_ghost_summon_cooldown") then
        return false, "COOLDOWN"
    end

    self.inst.components.timer:StartTimer("small_ghost_summon_cooldown", TUNING.TOTAL_DAY_TIME)

    local x, y, z = target.Transform:GetWorldPosition()
    target.ghost = SpawnPrefab("smallghost")
    target.ghost.Transform:SetPosition(x + 0.3, y, z + 0.3)
    target.ghost:LinkToHome(target)
    -- target.ghost:DoTaskInTime(0, function(ghost)
    --     ghost.components.questowner:BeginQuest(self.inst)
    -- end)

    return true
end

return SmallGhost_Summoner
