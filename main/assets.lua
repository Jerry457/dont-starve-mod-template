modimport("main/prefab_files")

Assets = {
    Asset("IMAGE", "images/ws_inventoryimages.xml"),
    -- Asset("ATLAS", "images/minimap.xml" ),
    Asset("ATLAS", "images/wendy_skillicons.xml" ),

    Asset("ANIM", "anim/player_pray.zip" ),
    Asset("ANIM", "anim/player_prayonly.zip" ),
}

PreloadAssets = {
}

ReloadPreloadAssets()

modimport("main/glassic_api_loader")

-- AddMinimapAtlas("images/gk_minimap.xml")
GlassicAPI.RegisterItemAtlas("ws_inventoryimages", Assets)
