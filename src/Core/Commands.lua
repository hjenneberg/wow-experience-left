local addonName, addon = ...

local function ShowFrame()
	addon.MainFrame:Show()
end

local function HideFrame()
	addon.MainFrame:Hide()
end

local function CenterFrame()
	local frame = addon.MainFrame:GetFrame()

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function ResetSession()
	addon.XPTracker:ResetSession()
	addon.MainFrame:RequestUpdate()
end

local commands = {
	show = ShowFrame,
	hide = HideFrame,
	center = CenterFrame,
	reset = ResetSession,
}

local function PrintHelp()
	print("|cFFFFFF00ExperienceLeft commands:|r")
	print("|cFFFF9900/xpleft|r |cFFBBBBBB- Show this help|r")
	print("|cFFFF9900/xpleft show|r |cFFBBBBBB- Show the addon main frame|r")
	print("|cFFFF9900/xpleft hide|r |cFFBBBBBB- Hide the addon main frame|r")
	print("|cFFFF9900/xpleft center|r |cFFBBBBBB- Center the frame on the screen|r")
	print("|cFFFF9900/xpleft reset|r |cFFBBBBBB- Reset saved xp rates from previous sessions|r")
end

SLASH_EXPERIENCELEFT1 = "/xpleft"

SlashCmdList.EXPERIENCELEFT = function(msg)
	if addon.XPStats:IsMaxLevel() then
		return
	end

	local command = commands[msg]

	if command then
		command()
	else
		PrintHelp()
	end
end
