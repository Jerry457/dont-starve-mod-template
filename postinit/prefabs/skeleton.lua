local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local skeletons = {
    "skeleton",
    "skeleton_player",
    "skeleton_notplayer",
    "skeleton_notplayer_1",
    "skeleton_notplayer_2",
}

for i, skeleton in ipairs(skeletons) do
    AddPrefabPostInit(skeleton, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:AddTag("grave_relocation")
    end)
end
