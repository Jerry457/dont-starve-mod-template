local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
    ActionHandler(ACTIONS.SUMMON_SMALLGHOST, "dolongaction"),
    ActionHandler(ACTIONS.GRAVE_RELOCATION, "dolongaction"),
    ActionHandler(ACTIONS.PRESENT, "give"),
}

local states = {
}

for _, state in ipairs(states) do
    AddStategraphState("wilson_client", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson_client", actionhandler)
end

AddStategraphPostInit("SGwilson_client", function(sg)
end)
