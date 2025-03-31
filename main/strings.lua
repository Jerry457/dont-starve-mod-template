GLOBAL.setfenv(1, GLOBAL)

local loc = require("languages/loc")

local language = loc.GetLanguage and loc.GetLanguage()
if language == LANGUAGE.CHINESE_S or language == LANGUAGE.CHINESE_S_RAIL then
    require("localization/strings_zh")
else
    require("localization/strings_en")
end
