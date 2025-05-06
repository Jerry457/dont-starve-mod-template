
GLOBAL.setfenv(1, GLOBAL)

if IS_DEV then
    return
end

local UIAnim = require("widgets/uianim")

local SkillTreeBuilder = require("widgets/redux/skilltreebuilder")

local skilltreedefs = require("prefabs/skilltree_defs")

local TILESIZE = 32
local TILESIZE_FRAME = TILESIZE + 8
local INFOGRAPHIC_RATIO = 80 / 64 -- frame size / background size
local TILESIZE_INFOGRAPHIC = TILESIZE - 5
local TILESIZE_INFOGRAPHIC_CIRCLE = TILESIZE_INFOGRAPHIC * SQRT2
local TILESIZE_INFOGRAPHIC_FRAME = TILESIZE_INFOGRAPHIC_CIRCLE * INFOGRAPHIC_RATIO - 4 -- Small overlap for icon frame to cover edges.
local LOCKSIZE = 24
local SPACE = 5

local ATLAS = "images/skilltree.xml"
local IMAGE_LOCKED = "locked.tex"
local IMAGE_LOCKED_OVER = "locked_over.tex"
local IMAGE_UNLOCKED = "unlocked.tex"
local IMAGE_UNLOCKED_OVER = "unlocked_over.tex"

local IMAGE_QUESTION = "question.tex"
local IMAGE_QUESTION_OVER = "question_over.tex"

local IMAGE_SELECTED = "selected.tex"
local IMAGE_SELECTED_OVER = "selected_over.tex"
local IMAGE_UNSELECTED = "unselected.tex"
local IMAGE_UNSELECTED_OVER = "unselected_over.tex"
local IMAGE_SELECTABLE = "selectable.tex"
local IMAGE_SELECTABLE_OVER = "selectable_over.tex"
local IMAGE_X = "locked.tex"
local IMAGE_FRAME = "frame.tex"
local IMAGE_FRAME_LOCK = "frame_octagon.tex"

local IMAGE_INFOGRAPHIC = "infographic.tex"
local IMAGE_INFOGRAPHIC_OVER = "infographic_over.tex"
local IMAGE_INFOGRAPHIC_ON = "infographic_on.tex"
local IMAGE_INFOGRAPHIC_ON_OVER = "infographic_on_over.tex"
local IMAGE_INFOGRAPHIC_OFF = "infographic_off.tex"
local IMAGE_INFOGRAPHIC_OFF_OVER = "infographic_off_over.tex"
local IMAGE_INFOGRAPHIC_FRAME = "frame_infographic.tex"

local look_skills = {
    ["wendy_smallghost_3"] = true,
    ["wendy_sisturn_3"] = true,
    ["wendy_ghostcommand_3"] = true,
    ["wendy_gravestone_1"] = true,
    ["wendy_makegravemounds"] = true,
}

function SkillTreeBuilder:RefreshTree(skillschanged)
    local characterprefab, availableskillpoints, activatedskills, skilltreeupdater
    local frontend = self.fromfrontend
    local readonly = self.readonly

    if readonly then
        -- Read only content uses self.target and self.targetdata to infer what it knows.
        self.root.xp:Hide()

        characterprefab = self.targetdata.prefab
        activatedskills = TheSkillTree:GetNamesFromSkillSelection(self.targetdata.skillselection, characterprefab)
        availableskillpoints = 0
    else
    	characterprefab = self.target
        -- Write enabled content uses ThePlayer to use what it knows.
        self.root.xp:Show()

        if frontend then
        	skilltreeupdater = TheSkillTree
    	else
    		skilltreeupdater = ThePlayer and ThePlayer.components.skilltreeupdater or nil
    	end

        if skilltreeupdater == nil then
            print("Weird state for skilltreebuilder missing skilltreeupdater component?")
            return -- FIXME(JBK): See if this panel should disappear at this time?
        end

        availableskillpoints = skilltreeupdater:GetAvailableSkillPoints(characterprefab)
        -- NOTES(JBK): This is not readonly so the player accessing it has access to its state and it is safe to assume TheSkillTree here.
        activatedskills = TheSkillTree:GetActivatedSkills(characterprefab)
    end

    if not self.button_decorations_init then
        self.button_decorations_init = true
        for _, graphics in pairs(self.skillgraphics) do
            if graphics.button_decorations ~= nil then
                if graphics.button_decorations.init ~= nil then
                    graphics.button_decorations.init(graphics.button, self.skilltreewidget.midlay, self.fromfrontend, characterprefab, activatedskills)
                end
            end
        end
    end

	local function make_connected_clickable(skill)
		if self.skilltreedef[skill].connects then
			for i,connected_skill in ipairs(self.skilltreedef[skill].connects)do
                if not look_skills[connected_skill] then
                    self.skillgraphics[connected_skill].status.activatable = true
                end
			end
		end
	end

	for skill,graphics in pairs(self.skillgraphics) do
		if graphics.status then
			graphics.oldstatus = graphics.status
		end
		graphics.status = {}
	end

	for skill,graphics in pairs(self.skillgraphics) do
		-- ROOT ITEMS ARE ACTIVATABLE
        -- NOTES(JBK): But only if they have an rpc_id.
		if self.skilltreedef[skill].root then
			graphics.status.activatable = not look_skills[skill] and self.skilltreedef[skill].rpc_id ~= nil
		end
        -- NOTES(JBK): All infographics are highlighted.
        if self.skilltreedef[skill].infographic then
            graphics.status.activated = true
            graphics.status.infographic = true
            -- Make them not resize or move when hovering or clicking.
            graphics.button.scale_on_focus = false
            graphics.button.move_on_click = false
        end
	end

	for skill,graphics in pairs(self.skillgraphics) do
        if readonly then
            if activatedskills[skill] then
                graphics.status.activated = true
                --make_connected_clickable(skill)
            end
            if self.skilltreedef[skill].lock_open then
            	graphics.status.lock = true
            	local lockstatus = self.skilltreedef[skill].lock_open(characterprefab, activatedskills, readonly)
				graphics.status.lock_open = lockstatus

			end
        else
        	if self.skilltreedef[skill].lock_open then
        		-- MARK LOCKS and ACTIVATE CONNECTED ITEMS WHEN NOT LOCKED
				graphics.status.lock = true
				if self.skilltreedef[skill].lock_open(characterprefab, activatedskills, readonly) then
					graphics.status.lock_open = true
					make_connected_clickable(skill)
				end
            elseif skilltreeupdater:IsActivated(skill, characterprefab) then
				graphics.status.activated = true
				make_connected_clickable(skill)
            end
        end
	end

	for skill,graphics in pairs(self.skillgraphics) do
		if self.skilltreedef[skill].locks then
			graphics.status.activatable = not look_skills[skill] and self.skilltreedef[skill].rpc_id ~= nil
			for i,lock in ipairs(self.skilltreedef[skill].locks) do
				if not self.skillgraphics[lock].status.lock_open then
					graphics.status.activatable = false
					break
				end
			end
		end
	end

	for skill,graphics in pairs(self.skillgraphics) do
		graphics.button:Hide()
		graphics.frame:Hide()

		if self.selectedskill and self.selectedskill == skill and not TheInput:ControllerAttached() then
			graphics.frame:Show()
		end

		if graphics.status.lock then
			graphics.button:Show()
			if graphics.status.lock_open then
				if graphics.status.lock_open == "question" then
					graphics.button:SetTextures(ATLAS, IMAGE_QUESTION, IMAGE_QUESTION_OVER,IMAGE_QUESTION,IMAGE_QUESTION,IMAGE_QUESTION)
				else
                    if graphics.status.infographic then
                        graphics.button:SetTextures(ATLAS, IMAGE_INFOGRAPHIC_ON, IMAGE_INFOGRAPHIC_ON_OVER, IMAGE_INFOGRAPHIC_ON, IMAGE_INFOGRAPHIC_ON, IMAGE_INFOGRAPHIC_ON)
                    else
                        graphics.button:SetTextures(ATLAS, IMAGE_UNLOCKED, IMAGE_UNLOCKED_OVER, IMAGE_UNLOCKED, IMAGE_UNLOCKED, IMAGE_UNLOCKED)
                    end
				end


				if graphics.oldstatus and graphics.oldstatus.lock_open == nil then

                    if graphics.status.infographic then
                        graphics.button:SetTextures(ATLAS, IMAGE_INFOGRAPHIC_OFF, IMAGE_INFOGRAPHIC_OFF_OVER, IMAGE_INFOGRAPHIC_OFF, IMAGE_INFOGRAPHIC_OFF, IMAGE_INFOGRAPHIC_OFF)
                    else
                        graphics.button:SetTextures(ATLAS, IMAGE_LOCKED, IMAGE_LOCKED_OVER, IMAGE_LOCKED, IMAGE_LOCKED, IMAGE_LOCKED)
                    end
					self.inst:DoTaskInTime(0.5, function()
						TheFrontEnd:GetSound():PlaySound("wilson_rework/ui/unlock_gatedskill")
						local pos = graphics.button:GetPosition()
					    local unlockfx = self:AddChild(UIAnim())
					    unlockfx:GetAnimState():SetBuild("skill_unlock")
					    unlockfx:GetAnimState():SetBank("skill_unlock")
					    unlockfx:GetAnimState():PushAnimation("idle")
					    unlockfx:SetPosition(pos.x,pos.y)
					    unlockfx.inst:ListenForEvent("animover", function()
					    	unlockfx:Kill()
					    end)
					end)
					self.inst:DoTaskInTime(13/30, function()
                        if graphics.status.infographic then
                            graphics.button:SetTextures(ATLAS, IMAGE_INFOGRAPHIC_ON, IMAGE_INFOGRAPHIC_ON_OVER, IMAGE_INFOGRAPHIC_ON, IMAGE_INFOGRAPHIC_ON, IMAGE_INFOGRAPHIC_ON)
                        else
                            graphics.button:SetTextures(ATLAS, IMAGE_UNLOCKED, IMAGE_UNLOCKED_OVER, IMAGE_UNLOCKED, IMAGE_UNLOCKED, IMAGE_UNLOCKED)
                        end
					end)
                    if graphics.button_decorations ~= nil then
                        if graphics.button_decorations.onunlocked ~= nil then
                            graphics.button_decorations.onunlocked(graphics.button, false, self.fromfrontend)
                        end
                    end
                else
                    if graphics.button_decorations ~= nil then
                        if graphics.button_decorations.onunlocked ~= nil then
                            graphics.button_decorations.onunlocked(graphics.button, true, self.fromfrontend)
                        end
                    end
				end
			else
                if graphics.status.infographic then
                    graphics.button:SetTextures(ATLAS, IMAGE_INFOGRAPHIC_OFF, IMAGE_INFOGRAPHIC_OFF_OVER, IMAGE_INFOGRAPHIC_OFF, IMAGE_INFOGRAPHIC_OFF, IMAGE_INFOGRAPHIC_OFF)
                else
                    graphics.button:SetTextures(ATLAS, IMAGE_LOCKED, IMAGE_LOCKED_OVER, IMAGE_LOCKED, IMAGE_LOCKED, IMAGE_LOCKED)
                end
                if graphics.button_decorations ~= nil then
                    if graphics.button_decorations.onlocked ~= nil then
                        graphics.button_decorations.onlocked(graphics.button, graphics.oldstatus == nil or graphics.oldstatus.lock_open == graphics.status.lock_open, self.fromfrontend)
                    end
                end
			end
		elseif graphics.status.activated then
			graphics.button:Show()
            if graphics.status.infographic then
                graphics.button:SetTextures(ATLAS, IMAGE_INFOGRAPHIC, IMAGE_INFOGRAPHIC_OVER, IMAGE_INFOGRAPHIC, IMAGE_INFOGRAPHIC, IMAGE_INFOGRAPHIC)
            else
                graphics.button:SetTextures(ATLAS, IMAGE_SELECTED, IMAGE_SELECTED_OVER, IMAGE_SELECTED, IMAGE_SELECTED, IMAGE_SELECTED)
            end
            if graphics.button_decorations ~= nil then
                if graphics.button_decorations.onunlocked ~= nil then
                    graphics.button_decorations.onunlocked(graphics.button, true, self.fromfrontend)
                end
            end
		elseif graphics.status.activatable and availableskillpoints > 0 then
			graphics.button:Show()
			graphics.button:SetTextures(ATLAS, IMAGE_SELECTABLE, IMAGE_SELECTABLE_OVER,IMAGE_SELECTABLE,IMAGE_SELECTABLE,IMAGE_SELECTABLE)
            if graphics.button_decorations ~= nil then
                if graphics.button_decorations.onlocked ~= nil then
                    graphics.button_decorations.onlocked(graphics.button, true, self.fromfrontend)
                end
            end
		else
			graphics.button:Show()
			graphics.button:SetTextures(ATLAS, IMAGE_UNSELECTED, IMAGE_UNSELECTED_OVER,IMAGE_UNSELECTED,IMAGE_UNSELECTED,IMAGE_UNSELECTED)
            if graphics.button_decorations ~= nil then
                if graphics.button_decorations.onlocked ~= nil then
                    graphics.button_decorations.onlocked(graphics.button, true, self.fromfrontend)
                end
            end
		end
	end

    if skillschanged then
        for _, graphics in pairs(self.skillgraphics) do
            if graphics.button_decorations ~= nil then
                if graphics.button_decorations.onskillschanged ~= nil then
                    graphics.button_decorations.onskillschanged(graphics.button, self.selectedskill, self.fromfrontend, characterprefab, activatedskills)
                end
            end
        end
    end

	self.root.xptotal:SetString(availableskillpoints)
	if availableskillpoints <= 0 and TheSkillTree:GetSkillXP(characterprefab) >= TUNING.FIXME_DO_NOT_USE_FOR_MODS_NEW_MAX_XP_VALUE then -- >= TheSkillTree:GetMaximumExperiencePoints() then
		self.root.xp_tospend:SetString(STRINGS.SKILLTREE.KILLPOINTS_MAXED)
		local w, h = self.root.xp_tospend:GetRegionSize()
   		self.root.xp_tospend:SetPosition(30+(w/2),-3)
	else
		self.root.xp_tospend:SetString(STRINGS.SKILLTREE.SKILLPOINTS_TO_SPEND)
		local w, h = self.root.xp_tospend:GetRegionSize()
		self.root.xp_tospend:SetPosition(30+(w/2),-3)
	end


	if self.selectedskill  then
		if TheInput:ControllerAttached() then
			self.skillgraphics[self.selectedskill].button:SetHelpTextMessage("")
		end
	end

	if self.infopanel then
		self.infopanel.title:Hide()
		self.infopanel.activatebutton:Hide()
		self.infopanel.activatedtext:Hide()
		self.infopanel.respec_button:Hide()
		self.infopanel.activatedbg:Hide()

		if self.fromfrontend then
            if skilltreedefs.FN.CountSkills(self.target, activatedskills) > 0 then
                self.infopanel.respec_button:Show()
            end
            if self.sync_status then
                self.sync_status:Show()
            end
        else
            if self.sync_status then
                self.sync_status:Hide()
            end
		end

		if self.selectedskill  then
			self.infopanel.title:Show()
			self.infopanel.title:SetString(gettitle(self.selectedskill, self.target, self.skillgraphics) )
			self.infopanel.desc:Show()
			self.infopanel.desc:SetMultilineTruncatedString(getdesc(self.selectedskill, self.target), 3, 400, nil, nil, true, 6)
			self.infopanel.intro:Hide()

            if not readonly then
                if availableskillpoints > 0 and self.skillgraphics[self.selectedskill].status.activatable and not skilltreeupdater:IsActivated(self.selectedskill, characterprefab) then

                	self.infopanel.activatedbg:Hide()
                    self.infopanel.activatebutton:Show()
                    self.infopanel.activatebutton:SetOnClick(function()
                    	self:LearnSkill(skilltreeupdater,characterprefab)
                    end)
					if TheInput:ControllerAttached() then
						self.skillgraphics[self.selectedskill].button:SetHelpTextMessage(STRINGS.SKILLTREE.ACTIVATE)
						self.infopanel.activatebutton:SetText(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.infopanel.activatebutton.control, false, false ).." "..STRINGS.SKILLTREE.ACTIVATE)
					end
                end
            end

			if self.skillgraphics[self.selectedskill].status.activated and not self.skilltreedef[self.selectedskill].infographic then
				self.infopanel.activatedtext:Show()
				self.infopanel.activatedbg:Show()
			end
		else
			self.infopanel.desc:SetMultilineTruncatedString(STRINGS.SKILLTREE.INFOPANEL_DESC, 3, 240, nil,nil,true,6)
		end
	end
end
