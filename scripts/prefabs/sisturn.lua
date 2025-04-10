require "prefabutil"

local prefabs =
{
    "collapse_small",
    "sisturn_moon_petal_fx",
}

local assets =
{
    Asset("ANIM", "anim/petals_fx.zip"),
    Asset("ANIM", "anim/evil_petals_fx.zip"),
    Asset("ANIM", "anim/sisturn.zip"),
    Asset("ANIM", "anim/ui_chest_2x2.zip"),
}

local FLOWER_LAYERS =
{
    "flower1_roof",
    "flower2_roof",
    "flower1",
    "flower2",
}

local function OnFlowerPerished(item)
    item.components.perishable.onperishreplacement = "ghostflower"
end

-- Skill tree reactions
local function ConfigureSkillTreeUpgrades(inst, builder)
    local skilltreeupdater = (builder and builder.components.skilltreeupdater) or nil

    local petal_preserve = (skilltreeupdater and skilltreeupdater:IsActivated("wendy_sisturn_1")) or nil
    local wendy_sisturn_3 = (skilltreeupdater and skilltreeupdater:IsActivated("wendy_sisturn_3")) or nil

    local dirty = (inst._petal_preserve ~= petal_preserve) or (inst._wendy_sisturn_3 ~= wendy_sisturn_3)

    inst._wendy_sisturn_3 = wendy_sisturn_3
    inst._petal_preserve = petal_preserve

    return dirty
end

local function ApplySkillModifiers(inst)
    inst.components.preserver:SetPerishRateMultiplier(inst._petal_preserve and TUNING.WENDY_SISTURN_PETAL_PRESRVE or 1)
    if inst._petal_preserve then
        for i = 1, inst.components.container.numslots do
            local item = inst.components.container.slots[i]
            if item then
                if not item.perished_listend then
                    item.perished_listend = true
                    inst:ListenForEvent("perished", OnFlowerPerished, item)
                end
            end
        end
    end
end

local function IsFullOfFlowers(inst)
    return inst.components.container ~= nil and inst.components.container:IsFull()
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker, workleft)
    if workleft > 0 and not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/hit")
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")

        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
        end
    end
end

local function on_built(inst, data)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/hit")

    if not data.builder then return end
    inst._builder_id = data.builder.userid
    if ConfigureSkillTreeUpgrades(inst, data.builder) then
        ApplySkillModifiers(inst)
    end
end

local function getsisturnfeel(inst)
    local evil = inst.components.container:FindItems(function(item)
        if item.prefab == "petals_evil" then
            return true
        end
    end)

    local blossom = inst.components.container:FindItems(function(item)
        if item.prefab == "moon_tree_blossom" then
            return true
        end
    end)

    local petals = inst.components.container:FindItems(function(item)
        if item.prefab == "petals" then
            return true
        end
    end)

    if #evil > 3 then
        return "EVIL", "evil_petals_fx"
    elseif #blossom > 3 then
        return "BLOSSOM"
    elseif #petals > 3 then
        return "PETALS", "petals_fx"
    else
        return "NORMAL"
    end
end

local function update_sanityaura(inst)
    if IsFullOfFlowers(inst) and getsisturnfeel(inst) ~= "EVIL" then
        if not inst.components.sanityaura then
            inst:AddComponent("sanityaura")
        end
        inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
    elseif inst.components.sanityaura ~= nil then
        inst:RemoveComponent("sanityaura")
    end
end

local function update_idle_anim(inst)
    if inst:HasTag("burnt") then
        return
    end

    if IsFullOfFlowers(inst) then
        inst.AnimState:PlayAnimation("on_pre")
        inst.AnimState:PushAnimation("on", true)
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/LP","sisturn_on")
    else
        inst.AnimState:PlayAnimation("on_pst")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("sisturn_on")
    end
end

local function update_abigail_status(inst)
   local is_full = IsFullOfFlowers(inst)
   local state, petal_fx_symbol = getsisturnfeel(inst)
    if is_full and state ~= "NORMAL" then
        if not inst.petal_fx then
            inst.petal_fx = SpawnPrefab("sisturn_moon_petal_fx")
            inst:AddChild(inst.petal_fx)
        end

        if petal_fx_symbol then
            inst.petal_fx.AnimState:OverrideSymbol("flowers_lunar", petal_fx_symbol, petal_fx_symbol)
        else
            inst.petal_fx.AnimState:ClearOverrideSymbol("flowers_lunar")
        end
        inst.petal_fx.done = false
        if inst.petal_fx.AnimState:IsCurrentAnimation("lunar_fx_pst") then
            inst.petal_fx.SoundEmitter:KillSound("loop")
            inst.petal_fx.SoundEmitter:PlaySound("meta5/wendy/sisturn_moonblossom_LP","loop")
            inst.petal_fx.AnimState:PlayAnimation("lunar_fx_pre")
            inst.petal_fx.AnimState:PushAnimation("lunar_fx_loop")
        end
    else
        if inst.petal_fx then
            inst.petal_fx.done = true
        end
   end
end

local function onsisturnstatechanged(inst, player)
    player:PushEvent("onsisturnstatechanged", {is_active = IsFullOfFlowers(inst), state = getsisturnfeel(inst)})
end

local function remove_decor(inst, data)
    for player in pairs(inst.components.attunable.attuned_players) do
        onsisturnstatechanged(inst, player)
    end

    local item = data and data.prev_item
    if item and item.components.perishable and item.perished_listend then
        item.perished_listend = false
        inst:RemoveEventCallback("perished", OnFlowerPerished, item)
    end

    if data ~= nil and data.slot ~= nil and FLOWER_LAYERS[data.slot] then
        inst.AnimState:Hide(FLOWER_LAYERS[data.slot])
        inst.SoundEmitter:PlaySound("meta5/wendy/sisturn_petals_add_remove")
    end
    update_sanityaura(inst)
    update_idle_anim(inst)
    update_abigail_status(inst)
end

local function add_decor(inst, data)
    for player in pairs(inst.components.attunable.attuned_players) do
        onsisturnstatechanged(inst, player)
    end

    if inst._petal_preserve then
        local item = data and data.item
        if item and item:HasTag("petal") and item.components.perishable and inst._petal_preserve then
            item.perished_listend = true
            inst:ListenForEvent("perished", OnFlowerPerished, item)
        end
    end

    if data ~= nil and data.slot ~= nil and FLOWER_LAYERS[data.slot] and not inst:HasTag("burnt") then
        inst.AnimState:Show(FLOWER_LAYERS[data.slot])
        inst.SoundEmitter:PlaySound("meta5/wendy/sisturn_petals_add_remove")
        local item = inst.components.container.slots[data.slot]
        if item then
            if item.prefab == "petals_evil" then
                inst.AnimState:OverrideSymbol("flowers_0"..data.slot, "sisturn", "flowers_evil")
            elseif item.prefab == "moon_tree_blossom" then
                inst.AnimState:OverrideSymbol("flowers_0"..data.slot, "sisturn", "flowers_lunar")
            else
                inst.AnimState:ClearOverrideSymbol("flowers_0"..data.slot)
            end
        end
    end

    update_sanityaura(inst)
    update_idle_anim(inst)
    update_abigail_status(inst)

    local is_full = IsFullOfFlowers(inst)
    local doer = (is_full and inst.components.container ~= nil and inst.components.container.currentuser) or nil
    if doer ~= nil and doer.components.talker ~= nil and doer:HasTag("ghostlyfriend") then

        if getsisturnfeel(inst) == "EVIL" then
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_SISTURN_FULL_EVIL"), nil, nil, true)
        elseif getsisturnfeel(inst) == "BLOSSOM" then
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_SISTURN_FULL_BLOSSOM"), nil, nil, true)
        else
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_SISTURN_FULL"), nil, nil, true)
        end
    end
end

local function onopen(inst, doer)
    if doer.userid == inst._builder_id and inst._wendy_sisturn_3 then
        inst.components.attunable:LinkToPlayer(doer)
    end
end

local function onlink(inst, player, isloading)
    onsisturnstatechanged(inst, player)
end

local function onunlink(inst, player, isloading)
    player:PushEvent("onsisturnstatechanged", {is_active = false})
end

local function getstatus(inst)
    local container = inst.components.container
    local num_decor = (container ~= nil and container:NumItems()) or 0
    local num_slots = (container ~= nil and container.numslots) or 1
    return num_decor >= num_slots and  getsisturnfeel(inst) == "EVIL" and "LOTS_OF_FLOWERS_EVIL"
            or num_decor >= num_slots and  getsisturnfeel(inst) == "BLOSSOM" and "LOTS_OF_FLOWERS_BLOSSOM"
            or num_decor >= num_slots and "LOTS_OF_FLOWERS"
            or num_decor > 0 and "SOME_FLOWERS"
            or nil
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end

    data.preserve_rate = inst._preserve_rate
    data.builder_id = inst._builder_id
    data.petal_preserve = inst._petal_preserve
    data.wendy_sisturn_3 = inst._wendy_sisturn_3
end

local function OnLoad(inst, data)
    if data then
        if data.burnt and inst.components.burnable then
            inst.components.burnable.onburnt(inst)
        else
            inst._builder_id = data.builder_id
            inst._preserve_rate = data.preserve_rate
            inst._petal_preserve = data.petal_preserve
            inst._wendy_sisturn_3 = data.wendy_sisturn_3

            ApplySkillModifiers(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .5)

    inst:AddTag("structure")

    inst.AnimState:SetBank("sisturn")
    inst.AnimState:SetBuild("sisturn")
    inst.AnimState:PlayAnimation("idle")
    for _, layer_name in ipairs(FLOWER_LAYERS) do
        inst.AnimState:Hide(layer_name)
    end

    inst.MiniMapEntity:SetIcon("sisturn.png")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("container")
    inst.components.container.onopefn = onopen
    inst.components.container:WidgetSetup("sisturn")

    inst:AddComponent("attunable")
    inst.components.attunable:SetAttunableTag("sisturn")
    inst.components.attunable:SetOnLinkFn(onlink)
    inst.components.attunable:SetOnUnlinkFn(onunlink)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("preserver")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    inst:ListenForEvent("itemget", add_decor)
    inst:ListenForEvent("itemlose", remove_decor)
    inst:ListenForEvent("onbuilt", on_built)

    inst.getsisturnfeel = getsisturnfeel

    inst:ListenForEvent("wendy_sisturnskillchanged", function(_, user)
        if user.userid == inst._builder_id and not inst:HasTag("burnt")
                and ConfigureSkillTreeUpgrades(inst, user) then
            ApplySkillModifiers(inst)
        end
    end, TheWorld)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")

    inst.AnimState:SetBank("sisturn")
    inst.AnimState:SetBuild("sisturn")
    inst.AnimState:PlayAnimation("lunar_fx_pre")
    inst.AnimState:PushAnimation("lunar_fx_loop")

    inst.SoundEmitter:PlaySound("meta5/wendy/sisturn_moonblossom_LP","loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", function()
        if inst.done and inst.AnimState:IsCurrentAnimation("lunar_fx_pst") then

            if inst.parent then
                inst.parent.petal_fx = false
            end
            inst:Remove()
        elseif inst.AnimState:IsCurrentAnimation("lunar_fx_loop") then
            if inst.done then
                inst.AnimState:PlayAnimation("lunar_fx_pst")
                inst.SoundEmitter:KillSound("loop")
                inst.SoundEmitter:PlaySound("meta5/wendy/sisturn_moonblossom_pst")
            else
                inst.AnimState:PlayAnimation("lunar_fx_loop")
            end
        end

    end)

    inst.persists = false

    return inst
end

return Prefab("sisturn", fn, assets, prefabs),
    MakePlacer("sisturn_placer", "sisturn", "sisturn", "placer"),
    Prefab("sisturn_moon_petal_fx", fxfn, assets, prefabs)
