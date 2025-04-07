local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function SetbonusHaelath(target, value)
    target.bonus_max_health = value

    local health = target.components.health
    if health then
        if health:IsDead() then
            health.maxhealth = target.base_max_health + target.bonus_max_health
        else
            local health_percent = health:GetPercent()
            health:SetMaxHealth(target.base_max_health + target.bonus_max_health)
            health:SetPercent(health_percent, true)
        end

        if target._playerlink ~= nil and target._playerlink.components.pethealthbar ~= nil then
            target._playerlink.components.pethealthbar:SetMaxHealth(health.maxhealth)
        end
    end
end


local potions_hook = false
local function HookPotions(inst)
    if potions_hook then
        return
    end

    potions_hook = true

    local potion_tunings = GlassicAPI.UpvalueUtil.GetUpvalue(Prefabs["ghostlyelixir_slowregen"].fn, "potion_tunings")
    potion_tunings["ghostlyelixir_fastregen"].skill_modifier_long_duration = true

    potion_tunings["ghostlyelixir_revive"].fx = "ghostlyelixir_revive_fx"
    potion_tunings["ghostlyelixir_revive"].dripfx = "ghostlyelixir_revive_dripfx"
    potion_tunings["ghostlyelixir_revive"].fx_player = "ghostlyelixir_player_revive_fx"
    potion_tunings["ghostlyelixir_revive"].dripfx_player = "ghostlyelixir_player_revive_dripfx"
    potion_tunings["ghostlyelixir_revive"].ONAPPLY = function(inst, target)
        SetbonusHaelath(target, 300)
    end
    potion_tunings["ghostlyelixir_revive"].ONDETACH = function(inst, target)
        SetbonusHaelath(target, 0)
    end
    potion_tunings["ghostlyelixir_revive"].DURATION = 9999
end


local potions = {
    "slowregen",
    "fastregen",
    "shield",
    "attack",
    "speed",
    "retaliation",
    "shadow",
    "lunar",
    "revive",
}

for _, name in ipairs(potions) do
    local potion_prefab = "ghostlyelixir_" .. name
	local buff_prefab = potion_prefab .. "_buff"

    AddPrefabPostInit(potion_prefab, HookPotions)
    AddPrefabPostInit(buff_prefab, HookPotions)
end
