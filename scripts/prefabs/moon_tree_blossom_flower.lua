
local assets = {
    Asset("ANIM", "anim/moon_tree_blossom_new.zip"),
}

local rets = {}
for i = 1, 6 do
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst) -- so it can be dropped as loot

        inst.AnimState:SetBank("moon_tree_blossom_new")
        inst.AnimState:SetBuild("moon_tree_blossom_new")
        inst.AnimState:PlayAnimation("idle" .. i)
        inst.AnimState:SetRayTestOnBB(true)

        inst.pickupsound = "vegetation_grassy"

        inst:SetPrefabNameOverride("moon_tree_blossom")

        inst:AddTag("cattoy")
        inst:AddTag("vasedecoration")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("pickable")
        -- inst.components.pickable.picksound = "vegetation_grassy"
        inst.components.pickable:SetUp("moon_tree_blossom", 10)
        inst.components.pickable.remove_when_picked = true
        inst.components.pickable.quickpick = true
        inst.components.pickable.wildfirestarter = true

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)

        MakeHauntableLaunch(inst)

        return inst
    end
    table.insert(rets, Prefab("moon_tree_blossom_flower_".. i, fn, assets))
end

return unpack(rets)
