IS_DEV = not GLOBAL.IsWorkshopMod(modname)
GLOBAL.IS_DEV = IS_DEV

require("utils/ws_util")

modimport("main/assets")
modimport("main/fx")
modimport("main/constants")
modimport("main/tuning")
modimport("main/strings")
modimport("main/characters")
modimport("main/rpc")
modimport("main/prefab_skins")
modimport("main/containers")
modimport("main/recipes")
modimport("main/actions")
modimport("main/cooking")
modimport("main/postinit")
