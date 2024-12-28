function PauseSession()
	PreviousSessionTime = SessionTime + PreviousSessionTime

	ShouldUpdateOnNextTick = true

	IsPaused = not IsPaused
end

function ContinueSession()
	SessionStartTime = time()
	SessionTime = 0

	ShouldUpdateOnNextTick = true

	IsPaused = not IsPaused
end

function OnMouseDown(self, button)
	if button ~= "RightButton" then
		return
	end
	---@diagnostic disable-next-line: param-type-mismatch
	MenuUtil.CreateContextMenu(XpLeftFrame, function(ownerRegion, root)
		root:CreateTitle("ExperienceLeft 0.5.1")

		-- if IsPaused then
		-- 	root:CreateButton("Continue session", ContinueSession)
		-- 		:SetTitleAndTextTooltip("", "Continue current session. I'm back.")
		-- else
		-- 	root:CreateButton("Pause session", PauseSession)
		-- 		:SetTitleAndTextTooltip("", "Stop recording session data. I'm AFK or otherwise involved")
		-- end
		root:CreateButton("Start new session", ResetSessionXP)
			:SetTitleAndTextTooltip("", "This will delete all previously recorded data.")

		root:CreateDivider()

		root:CreateButton("Hide frame", HideFrame)
			:SetTitleAndTextTooltip("", "Hide frame. Use |cFFFF9900/xpleft show|r to show it again.")
	end)
end
