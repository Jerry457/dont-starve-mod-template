GLOBAL.setfenv(1, GLOBAL)

local GHOSTCOMMAND_DEFS = require("prefabs/ghostcommand_defs")
local BASECOMMANDS = GHOSTCOMMAND_DEFS.GetBaseCommands()

local skill_map = {
    wendy_ghostcommand_2 = "wendy_ghostcommand_1",
    wendy_ghostcommand_3 = "wendy_ghostcommand_2",
}

local _GetGhostCommandsFor = GHOSTCOMMAND_DEFS.GetGhostCommandsFor
function GHOSTCOMMAND_DEFS.GetGhostCommandsFor(...)
    return HookSkillTreeUpdaterIsActivated(skill_map, nil, _GetGhostCommandsFor, ...)
end

-- local function DoGhostSpell(doer, event, state, ...)
--     local spellbookcooldowns = doer.components.spellbookcooldowns
--     local ghostlybond = doer.components.ghostlybond

--     if spellbookcooldowns ~= nil and (spellbookcooldowns:IsInCooldown("ghostcommand") or spellbookcooldowns:IsInCooldown(event or state)) then
--         return false
--     end

--     if ghostlybond == nil or ghostlybond.ghost == nil then
--         return false
--     end

--     if ghostlybond.ghost.components.health:IsDead() then
--         return false
--     end

--     if event ~= nil then
--         ghostlybond.ghost:PushEvent(event, ...)

--     elseif state ~= nil then
--         ghostlybond.ghost.sg:GoToState(state, ...)
--     end

--     if spellbookcooldowns ~= nil then
--         spellbookcooldowns:RestartSpellCooldown(event or state, TUNING.WENDYSKILL_COMMAND_COOLDOWN)
--     end

--     return true
-- end

local SKILLTREE_COMMAND_DEFS = GlassicAPI.UpvalueUtil.GetUpvalue(_GetGhostCommandsFor, "SKILLTREE_COMMAND_DEFS")
-- local DoGhostSpell = GlassicAPI.UpvalueUtil.SetUpvalue(SKILLTREE_COMMAND_DEFS["wendy_ghostcommand_1"].onselect, "GhostEscapeSpell.DoGhostSpell", DoGhostSpell)
