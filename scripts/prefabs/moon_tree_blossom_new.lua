
local assets = {
    Asset("ANIM", "anim/moon_tree_blossom_new.zip"),
}

local rets = {}
for i = 1, 6 do
    local function fn()
        local inst = Prefabs["moon_tree_blossom"].fn()

        inst:AddTag("flower")

        inst.AnimState:SetBank("moon_tree_blossom_new")
        inst.AnimState:SetBuild("moon_tree_blossom_new")
        inst.AnimState:PlayAnimation("idle" .. i)

        inst:SetPrefabNameOverride("moon_tree_blossom")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.perishable:StopPerishing()

        return inst
    end
    table.insert(rets, Prefab("moon_tree_blossom_".. i, fn, assets))
end

return unpack(rets)
