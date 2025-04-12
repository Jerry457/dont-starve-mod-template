local RegainGlory = Class(function(self, inst)
    self.inst = inst

    self.onregrowfn = nil
    self.inst:AddTag("regainglory")
end)

function RegainGlory:SetOnRegrowFn(fn)
    self.onregrowfn = fn
end

function RegainGlory:Regrow(doer)
    if self.onregrowfn then
        return self.onregrowfn(self.inst, doer)
    end
    return false
end

return RegainGlory
