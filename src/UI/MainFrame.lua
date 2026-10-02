local addonName, addon = ...

local MainFrame = {}
addon.MainFrame = MainFrame

local BAR_WIDTH = 480
local BAR_HEIGHT = 10
local FRAME_HEIGHT = 50

local frame
local timeSinceLastUpdate = 0

local function ConfigureText(fontString)
	fontString:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	fontString:SetShadowColor(0, 0, 0, 1)
	fontString:SetShadowOffset(1, -1)
end

local function GetColor(ratio)
	ratio = math.max(0, math.min(1, ratio))

	if ratio < 0.5 then
		return 1, ratio * 2, 0
	end

	return (1 - ratio) * 2, 1, 0
end

local function OnMouseDown(self, button)
	if button ~= "RightButton" then
		return
	end

	MenuUtil.CreateContextMenu(self, function(ownerRegion, root)
		root:CreateTitle("ExperienceLeft 0.6.0")

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

local function Update()
	if addon.XPStats:IsMaxLevel() then
		return
	end

	local levelExperience = addon.XPStats:GetLevelExperience()
	local potentialQuestXP, completedQuestXP = addon.Quests:GetExperience()
	local questXpRatio = addon.XPStats:GetQuestExperienceRatio(potentialQuestXP, completedQuestXP)
	local xpPerSecond = addon.XPStats:GetXPPerSecond(addon.XPTracker:GetSessionValues())
	local r, g, b = GetColor(levelExperience.ratio)

	frame.progressContainer:SetWidth(frame:GetWidth() * levelExperience.ratio)
	frame.progress:SetColorTexture(r, g, b, 1)
	frame.currentXPText:SetText(
		addon.FormatLargeNumber(levelExperience.currentXP, 2)
			.. "/"
			.. addon.FormatLargeNumber(levelExperience.maxXP, 1)
			.. " ("
			.. addon.Round(100 * levelExperience.ratio)
			.. "%)"
	)
	frame.xpLeftText:SetText(addon.FormatLargeNumber(levelExperience.xpLeft, 2))
	frame.questXPText:SetText(
		addon.FormatLargeNumber(completedQuestXP, 2)
			.. "/"
			.. addon.FormatLargeNumber(potentialQuestXP, 2)
			.. " ("
			.. addon.Round(100 * questXpRatio)
			.. "%)"
	)
	frame.sessionText:SetText(
		addon.FormatLargeNumber(3600 * xpPerSecond, 2)
			.. " XP/h · "
			.. addon.XPStats:GetTimeToLevelText(xpPerSecond, levelExperience.xpLeft)
	)
end

function MainFrame:ShowTooltip()
	if IsShiftKeyDown() then
		return
	end

	local levelExperience = addon.XPStats:GetLevelExperience()
	local potentialQuestXP, completedQuestXP = addon.Quests:GetExperience()
	local xpPerSecond = addon.XPStats:GetXPPerSecond(addon.XPTracker:GetSessionValues())

	GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOM")
	GameTooltip:AddLine("ExperienceLeft", 1, 1, 1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine("XP on current level", addon.FormatLargeNumber(levelExperience.currentXP, 2))
	GameTooltip:AddDoubleLine("XP required for level up", addon.FormatLargeNumber(levelExperience.xpLeft, 2))
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine("Completed quest XP", addon.FormatLargeNumber(completedQuestXP, 2))
	GameTooltip:AddDoubleLine("Potential quest XP", addon.FormatLargeNumber(potentialQuestXP, 2))
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine("XP per hour", addon.FormatLargeNumber(3600 * xpPerSecond, 2))
	GameTooltip:AddDoubleLine(
		"Time left for level up",
		addon.XPStats:GetTimeToLevelText(xpPerSecond, levelExperience.xpLeft)
	)

	GameTooltip:Show()
end

function MainFrame:Create()
	frame = CreateFrame("Frame", "ExperienceLeftMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

	frame:SetSize(BAR_WIDTH, FRAME_HEIGHT)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")

	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -20)
	background:SetSize(BAR_WIDTH, BAR_HEIGHT)
	background:SetColorTexture(0.10, 0.10, 0.10, 1)

	local progressContainer = CreateFrame("Frame", nil, frame)
	progressContainer:SetPoint("TOPLEFT", background, "TOPLEFT")
	progressContainer:SetSize(0, BAR_HEIGHT)
	progressContainer:SetClipsChildren(true)

	local segmentOverlay = CreateFrame("Frame", nil, frame)
	segmentOverlay:SetPoint("TOPLEFT", background, "TOPLEFT")
	segmentOverlay:SetPoint("BOTTOMRIGHT", background, "BOTTOMRIGHT")
	segmentOverlay:SetFrameLevel(progressContainer:GetFrameLevel() + 10)

	for i = 1, 9 do
		local separator = segmentOverlay:CreateTexture(nil, "OVERLAY")

		separator:SetPoint("TOPLEFT", segmentOverlay, "TOPLEFT", BAR_WIDTH * i / 10, 0)
		separator:SetPoint("BOTTOMLEFT", segmentOverlay, "BOTTOMLEFT", BAR_WIDTH * i / 10, 0)
		separator:SetWidth(1)

		if i == 5 then
			separator:SetColorTexture(1, 1, 1, 0.75)
		else
			separator:SetColorTexture(0.5, 0.5, 0.5, 0.35)
		end
	end

	local progress = progressContainer:CreateTexture(nil, "ARTWORK")
	progress:SetAllPoints()
	progress:SetColorTexture(1, 0.82, 0, 1)

	local highlight = progressContainer:CreateTexture(nil, "OVERLAY")
	highlight:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 1, -1)
	highlight:SetPoint("TOPRIGHT", progressContainer, "TOPRIGHT", -1, -1)
	highlight:SetHeight(math.min(3, BAR_HEIGHT / 3))
	highlight:SetColorTexture(1, 1, 1, 0.18)

	local shadow = progressContainer:CreateTexture(nil, "OVERLAY")
	shadow:SetPoint("BOTTOMLEFT", progressContainer, "BOTTOMLEFT", 1, 1)
	shadow:SetPoint("BOTTOMRIGHT", progressContainer, "BOTTOMRIGHT", -1, 1)
	shadow:SetHeight(3)
	shadow:SetColorTexture(0, 0, 0, 0.25)

	local borderTop = frame:CreateTexture(nil, "OVERLAY")
	borderTop:SetPoint("TOPLEFT", background, "TOPLEFT")
	borderTop:SetPoint("TOPRIGHT", background, "TOPRIGHT")
	borderTop:SetHeight(1)
	borderTop:SetColorTexture(1, 1, 1, 0.12)

	local borderBottom = frame:CreateTexture(nil, "OVERLAY")
	borderBottom:SetPoint("BOTTOMLEFT", background, "BOTTOMLEFT")
	borderBottom:SetPoint("BOTTOMRIGHT", background, "BOTTOMRIGHT")
	borderBottom:SetHeight(1)
	borderBottom:SetColorTexture(0, 0, 0, 0.5)

	local borderLeft = frame:CreateTexture(nil, "OVERLAY")
	borderLeft:SetPoint("TOPLEFT", background, "TOPLEFT")
	borderLeft:SetPoint("BOTTOMLEFT", background, "BOTTOMLEFT")
	borderLeft:SetWidth(1)
	borderLeft:SetColorTexture(0, 0, 0, 0.5)

	local borderRight = frame:CreateTexture(nil, "OVERLAY")
	borderRight:SetPoint("TOPRIGHT", background, "TOPRIGHT")
	borderRight:SetPoint("BOTTOMRIGHT", background, "BOTTOMRIGHT")
	borderRight:SetWidth(1)
	borderRight:SetColorTexture(0, 0, 0, 0.5)

	local currentXPText = frame:CreateFontString(nil, "OVERLAY")
	currentXPText:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 4)
	ConfigureText(currentXPText)

	local xpLeftText = frame:CreateFontString(nil, "OVERLAY")
	xpLeftText:SetPoint("BOTTOMRIGHT", background, "TOPRIGHT", 0, 4)
	ConfigureText(xpLeftText)

	local questXPText = frame:CreateFontString(nil, "OVERLAY")
	questXPText:SetPoint("TOPLEFT", background, "BOTTOMLEFT", 0, -4)
	ConfigureText(questXPText)

	local sessionText = frame:CreateFontString(nil, "OVERLAY")
	sessionText:SetPoint("TOPRIGHT", background, "BOTTOMRIGHT", 0, -4)
	ConfigureText(sessionText)

	frame.background = background
	frame.progressContainer = progressContainer
	frame.progress = progress
	frame.highlight = highlight
	frame.shadow = shadow

	frame.currentXPText = currentXPText
	frame.xpLeftText = xpLeftText
	frame.questXPText = questXPText
	frame.sessionText = sessionText

	frame:SetScript("OnUpdate", function(_, elapsed)
		timeSinceLastUpdate = timeSinceLastUpdate + elapsed

		if timeSinceLastUpdate < 1 and not addon.shouldUpdateOnNextTick then
			return
		end

		addon.shouldUpdateOnNextTick = false
		timeSinceLastUpdate = 0

		Update()
	end)

	frame:SetScript("OnMouseDown", OnMouseDown)
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", OnHide)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)

	frame:SetScript("OnEnter", function()
		self:ShowTooltip()
	end)

	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

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
