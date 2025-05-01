local assets =
{
    Asset("ANIM", "anim/fullmoonbutterflywings.zip"),
}

local prefabs =
{
    "spoiled_food",
}

AddIngredientValues({"fullmoonbutterflywings"}, {decoration=2})

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("moonbutterfly_wings")
    inst.AnimState:SetBuild("fullmoonbutterflywings")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    MakeInventoryFloatable(inst, "small", 0.03)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 12
    inst.components.edible.hungervalue = 9.375
	inst.components.edible.sanityvalue = 25
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

return Prefab("fullmoonbutterflywings", fn, assets, prefabs)
