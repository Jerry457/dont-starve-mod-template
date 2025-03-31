﻿local files = {
    "postinit/entityscript.lua",
    "postinit/loottables.lua",
    "postinit/stategraphs/SGcommon.lua",
    "postinit/stategraphs/SGwilson.lua",
    "postinit/stategraphs/SGwilson_client.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
