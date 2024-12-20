function CreateMenu(root)
	root:CreateTitle("ExperienceLeft 0.4.0")

	if IsPaused then
		root:CreateButton("Continue session", ContinueSession)
			:SetTitleAndTextTooltip("", "Continue current session. I'm back.")
	else
		root:CreateButton("Pause session", PauseSession)
			:SetTitleAndTextTooltip("", "Stop recording session data. I'm AFK or otherwise involved")
	end
	root:CreateButton("Start new session", ResetSessionXP)
		:SetTitleAndTextTooltip("", "This will delete all previously recorded data.")

	root:CreateDivider()

	root:CreateButton("Hide frame", HideFrame)
		:SetTitleAndTextTooltip("", "Hide frame. Use |cFFFF9900/xpleft show|r to show it again.")
end

function PauseSession(root)
	PreviousSessionTime = SessionTime + PreviousSessionTime

	ShouldUpdateOnNextTick = true

	IsPaused = not IsPaused
	CreateMenu(root)
end

function ContinueSession(root)
	SessionStartTime = time()
	SessionTime = 0

	ShouldUpdateOnNextTick = true

	IsPaused = not IsPaused
	CreateMenu(root)
end

function OnMouseDown(self, button)
	if button ~= "RightButton" then
		return
	end
	---@diagnostic disable-next-line: param-type-mismatch
	MenuUtil.CreateContextMenu(XpLeftFrame, function(ownerRegion, root)
		CreateMenu(root)
	end)
end
