function CreateMenu(root)
	root:CreateTitle("ExperienceLeft 0.3.0")

	local submenuSession = root:CreateButton("Session")
	if IsPaused then
		submenuSession
			:CreateButton("Continue session", ContinueSession)
			:SetTitleAndTextTooltip("", "Continue current session. I'm back.")
	else
		submenuSession
			:CreateButton("Pause session", PauseSession)
			:SetTitleAndTextTooltip("", "Stop recording session data. I'm AFK or otherwise involved")
	end
	submenuSession:CreateDivider()
	submenuSession
		:CreateButton("Start new session", ResetSessionXP)
		:SetTitleAndTextTooltip("", "Attention, this will delete all previously recorded data.")

	--rootDescription:CreateDivider()
	--local submenu = rootDescription:CreateButton("My Submenu")
	--submenu:CreateButton("Enable", function()
	--	return 1
	--end, true)
	--submenu:CreateButton("Disable", function()
	--	return 1
	--end, false)

	root:CreateDivider()

	local submenuFrame = root:CreateButton("Frame")
	submenuFrame
		:CreateButton("Hide frame", HideFrame)
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
