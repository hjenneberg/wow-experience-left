ColorPrimary = "|cFFFFFF00"
ColorEnd = "|r"

IsMaxLevel = false
IsPaused = false

ShouldUpdateOnNextTick = false

PreviousSessionXp = 0
PreviousSessionTime = 0
SessionStartTime = time()
SessionTime = 0
SessionXp = 0

XpLeftFrame = CreateFrame("Frame", "ExperienceLeftMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
XpLeftFrame:SetSize(200, 70)
XpLeftFrame:EnableMouse(true)
XpLeftFrame:SetMovable(true)
XpLeftFrame:RegisterForDrag("LeftButton")
XpLeftFrame:SetScript("OnDragStart", OnDragStart)
XpLeftFrame:SetScript("OnDragStop", OnDragStop)
XpLeftFrame:SetScript("OnShow", OnShow)
XpLeftFrame:SetScript("OnHide", OnHide)
XpLeftFrame:SetScript("OnMouseDown", OnMouseDown)

FrameLabel = {
	{ key = "currentXp", title = "Current XP", value = "0" },
	{ key = "xpLeft", title = "XP left", value = "0" },
	{ key = "xpPerTime", title = "XP/h", value = "0" },
	{ key = "timeLeft", title = "Time left", value = "0" },
}

local lableCount = 4
local lineHeight = 16
local lineNumber = 0

for i = 1, lableCount do
	local key = FrameLabel[i]["key"]

	XpLeftFrame[key .. "title"] = XpLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	XpLeftFrame[key .. "title"]:SetFont(XpLeftFrame[key .. "title"]:GetFont() or "fonts/frizqt__.ttf", 12, "OUTLINE")
	XpLeftFrame[key .. "title"]:SetPoint("TOPLEFT", XpLeftFrame, "TOPLEFT", 5, -5 - lineHeight * lineNumber)

	XpLeftFrame[key .. "value"] = XpLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	XpLeftFrame[key .. "value"]:SetFont(XpLeftFrame[key .. "title"]:GetFont() or "fonts/frizqt__.ttf", 12, "OUTLINE")
	XpLeftFrame[key .. "value"]:SetPoint("TOPRIGHT", XpLeftFrame, "TOPRIGHT", 5, -5 - lineHeight * lineNumber)

	lineNumber = lineNumber + 1
end

local currentLevel = 0
local currentXp = 0
local currentXpMax = 0
local timeSinceLastUpdate = 0

XpLeftFrame:SetScript("OnUpdate", function(self, elapsed)
	if IsMaxLevel then
		return
	end

	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if timeSinceLastUpdate < 1 and not ShouldUpdateOnNextTick then
		return
	end

	ShouldUpdateOnNextTick = false

	--Update calculation

	if IsPaused then
		SessionTime = 0
	else
		SessionTime = time() - SessionStartTime
	end

	local xpPerSecond = (SessionXp + PreviousSessionXp) / math.max((SessionTime + PreviousSessionTime), 1)
	local xpLeftToLevel = currentXpMax - currentXp
	local xpAsRatio = currentXp / currentXpMax
	if ExperienceLeftDB then
		ExperienceLeftDB.sessionXp = SessionXp + PreviousSessionXp
		ExperienceLeftDB.sessionTime = SessionTime + PreviousSessionTime
	end
	timeSinceLastUpdate = 0

	--Update frame

	local colorText
	if IsPaused then
		colorText = "|cFF888888"
	else
		if xpAsRatio < 0.5 then
			colorText = "|cFFFF" .. string.format("%02x", xpAsRatio * 2 * 255) .. "00"
		else
			colorText = "|cFF" .. string.format("%02x", (1 - xpAsRatio) * 2 * 255) .. "FF00"
		end
	end

	FrameLabel[1].value = colorText
		.. FormatLargeNumber(currentXp)
		.. "/"
		.. FormatLargeNumber(currentXpMax)
		.. " ("
		.. round(100 * xpAsRatio)
		.. "%)"
	FrameLabel[2].value = FormatLargeNumber(xpLeftToLevel)
	FrameLabel[3].value = FormatLargeNumber(3600 * xpPerSecond)
	FrameLabel[4].value = TimeToLevelText(xpPerSecond, xpLeftToLevel)

	for i = 1, lableCount do
		local key = FrameLabel[i]["key"]
		local value = FrameLabel[i]

		XpLeftFrame[key .. "title"]:SetText(colorText .. value["title"] .. ":" .. ColorEnd)
		XpLeftFrame[key .. "value"]:SetText(colorText .. value["value"] .. ColorEnd)
	end
end)

XpLeftFrame:RegisterEvent("ADDON_LOADED")
XpLeftFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
XpLeftFrame:RegisterEvent("PLAYER_XP_UPDATE")

local function eventHandler(self, event, args, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		currentLevel = UnitLevel("player")
		currentXp = UnitXP("player")
		currentXpMax = UnitXPMax("player")

		---@diagnostic disable-next-line: undefined-global
		local maxLevel = MAX_PLAYER_LEVEL_TABLE[#MAX_PLAYER_LEVEL_TABLE]
		if maxLevel ~= nil and maxLevel == currentLevel then
			IsMaxLevel = true
		end

		if IsMaxLevel then
			XpLeftFrame:Hide()
		end
	end
	if event == "ADDON_LOADED" and args == "ExperienceLeft" then
		if not ExperienceLeftDB then
			ExperienceLeftDB = {}
		end

		PreviousSessionXp = 0
		if ExperienceLeftDB.sessionXp then
			PreviousSessionXp = ExperienceLeftDB.sessionXp
		end
		PreviousSessionTime = 0
		if ExperienceLeftDB.sessionTime then
			PreviousSessionTime = ExperienceLeftDB.sessionXp
		end

		local relativePoint = "CENTER"
		if ExperienceLeftDB.relativePoint then
			relativePoint = ExperienceLeftDB.relativePoint
		end
		local xOffset = 0
		if ExperienceLeftDB.xOffset then
			xOffset = ExperienceLeftDB.xOffset
		end
		local yOffset = 0
		if ExperienceLeftDB.yOffset then
			yOffset = ExperienceLeftDB.yOffset
		end
		XpLeftFrame:SetPoint("CENTER", UIParent, relativePoint, xOffset, yOffset)
	end
	if event == "PLAYER_XP_UPDATE" then
		if UnitLevel("player") == currentLevel then
			if not IsPaused then
				SessionXp = SessionXp + (UnitXP("player") - currentXp)
			end
		else
			if not IsPaused then
				SessionXp = SessionXp + (currentXpMax - currentXp) + UnitXP("player")
			end
			currentLevel = UnitLevel("player")
			currentXpMax = UnitXPMax("player")
		end
		currentXp = UnitXP("player")
	end
end

XpLeftFrame:SetScript("OnEvent", eventHandler)
