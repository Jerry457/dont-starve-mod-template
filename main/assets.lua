modimport("main/prefab_files")

Assets = {
    -- Asset("IMAGE", "images/inventoryimages.xml"),
    -- Asset("ATLAS", "images/minimap.xml" ),
    Asset("ATLAS", "images/wendy_skillicons.xml" ),

}

PreloadAssets = {
}

ReloadPreloadAssets()

modimport("main/glassic_api_loader")

-- AddMinimapAtlas("images/gk_minimap.xml")
-- GlassicAPI.RegisterItemAtlas("inventoryimages", Assets)