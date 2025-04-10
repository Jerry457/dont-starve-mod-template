modimport("main/prefab_files")

Assets = {
    Asset("IMAGE", "images/ws_inventoryimages.xml"),
    -- Asset("ATLAS", "images/minimap.xml" ),
    Asset("ATLAS", "images/wendy_skillicons.xml" ),

    Asset("ANIM", "anim/player_pray.zip" ),
    Asset("ANIM", "anim/player_prayonly.zip" ),

    Asset("ANIM", "anim/abigail_ghost_flicker.zip"),
    Asset("ANIM", "anim/ghost_abigail_gestalt_build.zip"),
    Asset("ANIM", "anim/ghost_abigail_shadow_build.zip"),

    Asset("ANIM", "anim/ghost_abigail_gestalt_human.zip"),
    Asset("ANIM", "anim/ghost_abigail_shadow_human.zip"),
}

PreloadAssets = {
}

ReloadPreloadAssets()

modimport("main/glassic_api_loader")

-- AddMinimapAtlas("images/gk_minimap.xml")
GlassicAPI.RegisterItemAtlas("ws_inventoryimages", Assets)
