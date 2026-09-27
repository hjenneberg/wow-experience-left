local addonName, addon = ...

local MainFrame = {}
addon.MainFrame = MainFrame

local frame
local timeSinceLastUpdate = 0

local labels = {
	{ key = "currentXp", title = "Current XP", value = "0" },
	{ key = "xpLeft", title = "XP left", value = "0" },
	{ key = "questXP", title = "Quest XP", value = "0" },
	{ key = "xpPerTime", title = "XP/h", value = "0" },
	{ key = "timeLeft", title = "Time left", value = "0" },
}

local LINE_HEIGHT = 16

local function GetColorText(ratio)
	if addon.isPaused then
		return "|cFF888888"
	end

	if ratio < 0.5 then
		return "|cFFFF" .. string.format("%02x", ratio * 2 * 255) .. "00"
	end

	return "|cFF" .. string.format("%02x", (1 - ratio) * 2 * 255) .. "FF00"
end

local function UpdateLabels()
	local levelExperience = addon.XPStats:GetLevelExperience()
	local potentialQuestXP, completedQuestXP = addon.Quests:GetExperience()
	local questXpRatio = addon.XPStats:GetQuestExperienceRatio(potentialQuestXP, completedQuestXP)
	local xpPerSecond = addon.XPStats:GetXPPerSecond(addon.XPTracker:GetSessionValues())
	local colorText = GetColorText(levelExperience.ratio)

	labels[1].value = colorText
		.. addon.FormatLargeNumber(levelExperience.currentXP, 2)
		.. "/"
		.. addon.FormatLargeNumber(levelExperience.maxXP, 1)
		.. " ("
		.. addon.round(100 * levelExperience.ratio)
		.. "%)"

	labels[2].value = addon.FormatLargeNumber(levelExperience.xpLeft, 2)

	labels[3].value = addon.FormatLargeNumber(completedQuestXP, 2)
		.. "/"
		.. addon.FormatLargeNumber(potentialQuestXP, 2)
		.. " ("
		.. addon.round(100 * questXpRatio)
		.. "%)"

	labels[4].value = addon.FormatLargeNumber(3600 * xpPerSecond, 2)

	labels[5].value = addon.XPStats:GetTimeToLevelText(xpPerSecond, levelExperience.xpLeft)

	for _, label in ipairs(labels) do
		frame[label.key .. "title"]:SetText(colorText .. label.title .. ":" .. addon.ColorEnd)

		frame[label.key .. "value"]:SetText(colorText .. label.value .. addon.ColorEnd)
	end
end

local function CreateLabels()
	for index, label in ipairs(labels) do
		local yOffset = -5 - LINE_HEIGHT * (index - 1)

		frame[label.key .. "title"] = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

		frame[label.key .. "title"]:SetFont(
			frame[label.key .. "title"]:GetFont() or "fonts/frizqt__.ttf",
			12,
			"OUTLINE"
		)

		frame[label.key .. "title"]:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, yOffset)

		frame[label.key .. "value"] = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

		frame[label.key .. "value"]:SetFont(
			frame[label.key .. "value"]:GetFont() or "fonts/frizqt__.ttf",
			12,
			"OUTLINE"
		)

		frame[label.key .. "value"]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, yOffset)
	end
end

local function OnMouseDown(self, button)
	if button ~= "RightButton" then
		return
	end

	MenuUtil.CreateContextMenu(self, function(ownerRegion, root)
		root:CreateTitle("ExperienceLeft 0.5.2")

		root:CreateButton("Start new session", function()
			addon.XPTracker:ResetSession()
			addon.MainFrame:RequestUpdate()
		end):SetTitleAndTextTooltip("", "This will delete all previously recorded data.")

		root:CreateDivider()

		root:CreateButton("Hide frame", function()
			addon.MainFrame:Hide()
		end):SetTitleAndTextTooltip("", "Hide frame. Use |cFFFF9900/xpleft show|r to show it again.")
	end)
end

local function OnShow()
	PlaySound(808)
end

local function OnHide()
	if UnitIsAFK("player") then
		return
	end

	PlaySound(808)

	print(
		addon.ColorPrimary
			.. "Experience left|r: Frame hidden, use |cFFBBBBBB/xpleft show"
			.. addon.ColorEnd
			.. " to show it again."
	)
end

local function OnDragStart(self)
	if IsShiftKeyDown() then
		self:StartMoving()
	end
end

local function OnDragStop(self)
	self:StopMovingOrSizing()

	local _, _, relativePoint, xOffset, yOffset = self:GetPoint(1)

	addon.db.relativePoint = relativePoint
	addon.db.xOffset = xOffset
	addon.db.yOffset = yOffset
end

function MainFrame:Create()
	frame = CreateFrame("Frame", "ExperienceLeftMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

	frame:SetSize(200, 70)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")

	CreateLabels()

	frame:SetScript("OnUpdate", function(_, elapsed)
		if addon.XPStats:IsMaxLevel() then
			return
		end

		timeSinceLastUpdate = timeSinceLastUpdate + elapsed

		if timeSinceLastUpdate < 1 and not addon.shouldUpdateOnNextTick then
			return
		end

		addon.shouldUpdateOnNextTick = false

		UpdateLabels()

		timeSinceLastUpdate = 0
	end)

	frame:SetScript("OnMouseDown", OnMouseDown)
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", OnHide)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)

	self.frame = frame
end

function MainFrame:GetFrame()
	return self.frame
end

function MainFrame:Show()
	self.frame:Show()
end

function MainFrame:Hide()
	self.frame:Hide()
end

function MainFrame:RequestUpdate()
	addon.shouldUpdateOnNextTick = true
end
