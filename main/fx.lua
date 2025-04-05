local Assets = Assets
GLOBAL.setfenv(1, GLOBAL)
local fx = require("fx")

local function FinalOffset3(inst)
    inst.AnimState:SetFinalOffset(3)
end

local fxs = {
    {
        name = "ghostlyelixir_revive_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_speed",
        -- sound = "dontstarve/characters/wendy/abigail/buff/speed",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_revive_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_revive_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_revive_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_player_revive_fx",
        bank = "player_vial_fx",
        build = "player_vial_fx",
        anim = "buff_speed",
        -- sound = "dontstarve/characters/wendy/abigail/buff/speed",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_revive_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_player_revive_dripfx",
        bank = "player_elixir_buff_drip",
        build = "player_vial_fx",
        anim = "player_elixir_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_revive_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_player_lunar_fx",
        bank = "player_vial_fx",
        build = "player_vial_fx",
        anim = "buff_speed",
        -- sound = "dontstarve/characters/wendy/abigail/buff/speed",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_lunar_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_player_lunar_dripfx",
        bank = "player_elixir_buff_drip",
        build = "player_vial_fx",
        anim = "player_elixir_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_lunar_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_player_shadow_fx",
        bank = "player_vial_fx",
        build = "player_vial_fx",
        anim = "buff_speed",
        -- sound = "dontstarve/characters/wendy/abigail/buff/speed",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_speed_02", "abigail_vial_fx", "fx_shadow_02")
            FinalOffset3(inst)
        end,
    },
    {
        name = "ghostlyelixir_player_shadow_dripfx",
        bank = "player_elixir_buff_drip",
        build = "player_vial_fx",
        anim = "player_elixir_buff_drip",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_shadow_02")
            FinalOffset3(inst)
        end,
    },
}

for _, v in ipairs(fxs) do
    table.insert(fx, v)
    if Settings.last_asset_set ~= nil then
        table.insert(Assets, Asset("ANIM", "anim/" .. v.build .. ".zip"))
    end
end
