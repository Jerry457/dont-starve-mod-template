local SpiritualPerception = require("widgets/spiritual_perception")

AddClassPostConstruct("widgets/statusdisplays", function(self)
    self.spiritual_perception = self:AddChild(SpiritualPerception(self.owner))
    self.spiritual_perception:SetPosition(-125, 35)
end)
