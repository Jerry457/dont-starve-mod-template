local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local PetHealthBar = require("components/pethealthbar")

local function OnSymbolDirty3(inst)
    inst:PushEvent("clientpethealthsymboldirty", { symbol3 = inst.components.pethealthbar:GetSymbol3() })
end

local function OnSymbolDirty4(inst)
    inst:PushEvent("clientpethealthsymboldirty", { symbol4 = inst.components.pethealthbar:GetSymbol4() })
end

function PetHealthBar:SetSymbol3(symbol)
    if self.ismastersim and self._symbol3:value() ~= symbol then
        self._symbol3:set(symbol)
        OnSymbolDirty3(self.inst)
    end
end

function PetHealthBar:SetSymbol4(symbol)
    if self.ismastersim and self._symbol4:value() ~= symbol then
        self._symbol4:set(symbol)
        OnSymbolDirty4(self.inst)
    end
end

function PetHealthBar:GetSymbol3()
    return self._symbol3:value()
end

function PetHealthBar:GetSymbol4()
    return self._symbol4:value()
end

AddComponentPostInit("pethealthbar", function(self)
    self._symbol3 = net_hash(self.inst.GUID, "pethealthbar._symbol3", "pethealthsymbol3dirty")
    self._symbol4 = net_hash(self.inst.GUID, "pethealthbar._symbol4", "pethealthsymbol4dirty")

    if not self.ismastersim then
        self.inst:ListenForEvent("pethealthsymbol3dirty", OnSymbolDirty3)
        self.inst:ListenForEvent("pethealthsymbol4dirty", OnSymbolDirty4)
    end
end)
