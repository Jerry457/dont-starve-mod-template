local Assets = Assets
GLOBAL.setfenv(1, GLOBAL)
local fx = require("fx")

local function mourningflower_spirit_fx(inst)
    inst.AnimState:OverrideSymbol("spirit_out3", "mourningflower_spirit_fx", "spirit_out3")
    inst.AnimState:OverrideSymbol("spirit_out4", "mourningflower_spirit_fx", "spirit_out4")
end

local fxs = {
    {
        name = "mourningflower_spirit1_fx",
        bank = "ghostflower",
        build = "ghostflower",
        anim = "fx1",
        sound = "dontstarve/characters/wendy/small_ghost/wisp",
        fn = mourningflower_spirit_fx,
    },
    {
        name = "mourningflower_spirit2_fx",
        bank = "ghostflower",
        build = "ghostflower",
        anim = "fx1",
        sound = "dontstarve/characters/wendy/small_ghost/wisp",
        fn = mourningflower_spirit_fx,
    },
    {
        name = "ghostlyelixir_revive_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_speed",
        sound = "dontstarve/characters/wendy/abigail/buff/shield",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_revive_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_revive_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_revive_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_player_revive_fx",
        bank = "player_vial_fx",
        build = "player_vial_fx",
        anim = "buff_speed",
        sound = "dontstarve/characters/wendy/abigail/buff/retaliation",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_revive_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_player_revive_dripfx",
        bank = "player_elixir_buff_drip",
        build = "player_vial_fx",
        anim = "player_elixir_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_revive_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_lunar_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_lunar",
        sound = "wilson_rework/ui/lunar_skill",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_player_lunar_fx",
        bank = "player_vial_fx",
        build = "player_vial_fx",
        anim = "buff_speed",
        sound = "wilson_rework/ui/lunar_skill",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_lunar_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_player_lunar_dripfx",
        bank = "player_elixir_buff_drip",
        build = "player_vial_fx",
        anim = "player_elixir_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_lunar_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_shadow_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_lunar",
        sound = "wilson_rework/ui/shadow_skill",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_lunar_02", "abigail_vial_fx", "fx_shadow_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_player_shadow_fx",
        bank = "player_vial_fx",
        build = "player_vial_fx",
        anim = "buff_speed",
        sound = "wilson_rework/ui/shadow_skill",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_shadow_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ghostlyelixir_player_shadow_dripfx",
        bank = "player_elixir_buff_drip",
        build = "player_vial_fx",
        anim = "player_elixir_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_shadow_02")
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "gravestone_light_loop",
        bank = "gravestone_light_loop",
        build = "gravestones",
        anim = "gravestone_light_loop",
        fn = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, .5)
            inst.AnimState:SetFinalOffset(-1)
        end,
    },

}

for _, v in ipairs(fxs) do
    table.insert(fx, v)
    if Settings.last_asset_set ~= nil then
        table.insert(Assets, Asset("ANIM", "anim/" .. v.build .. ".zip"))
    end
end
