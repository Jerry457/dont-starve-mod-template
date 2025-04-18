local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

AddClassPostConstruct("widgets/badge", function(self)
	self.inst:DoTaskInTime(0,function()
        if self.bg then
            self.bg:MoveToBack()
        end
	end)
end)
