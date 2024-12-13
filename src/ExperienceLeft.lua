ColorPrimary = "|cFFFFFF00"
ColorEnd = "|r"

local isMaxLevel = false

PreviousSessionXp = 0
PreviousSessionTime = 0
SessionStartTime = time()
SessionTime = 0
SessionXp = 0

XpLeftFrame = CreateFrame("Frame", "ExperienceLeftMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
XpLeftFrame:SetSize(300, 250)
XpLeftFrame:EnableMouse(true)
XpLeftFrame:SetMovable(true)
XpLeftFrame:RegisterForDrag("LeftButton")
XpLeftFrame:SetScript("OnDragStart", OnDragStart)
XpLeftFrame:SetScript("OnDragStop", OnDragStop)
XpLeftFrame:SetScript("OnShow", OnShow)
XpLeftFrame:SetScript("OnHide", OnHide)
XpLeftFrame:SetScript("OnMouseDown", OnMouseDown)

SLASH_EXPERIENCELEFT1 = "/xpleft"
local function slashCommandHandler(msg, editBox)
	if isMaxLevel then
		return
	end
	if msg == "show" then
		XpLeftFrame:Show()
	elseif msg == "hide" then
		HideFrame()
	elseif msg == "center" then
		XpLeftFrame:ClearAllPoints()
		XpLeftFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	elseif msg == "reset" then
		ResetSessionXP()
	else
		print("|cFFFFFF00ExperienceLeft commands:|r")
		print("|cFFFF9900/xpleft|r |cFFBBBBBB- Show this help|r")
		print("|cFFFF9900/xpleft show|r |cFFBBBBBB- Show the addon main frame|r")
		print("|cFFFF9900/xpleft hide|r |cFFBBBBBB- Hide the addon main frame|r")
		print("|cFFFF9900/xpleft center|r |cFFBBBBBB- Center the frame on the screen|r")
		print("|cFFFF9900/xpleft reset|r |cFFBBBBBB- Reset saved xp rates from previous sessions|r")
	end
end
SlashCmdList["EXPERIENCELEFT"] = slashCommandHandler

XpLeftFrame.lableCurrentXp = XpLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
XpLeftFrame.lableCurrentXp:SetPoint("TOPLEFT", XpLeftFrame, "TOPLEFT", 5, -5)
XpLeftFrame.lableXpLeftToLevel = XpLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
XpLeftFrame.lableXpLeftToLevel:SetPoint("TOPLEFT", XpLeftFrame, "TOPLEFT", 5, -20)
XpLeftFrame.lableXpPerSecond = XpLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
XpLeftFrame.lableXpPerSecond:SetPoint("TOPLEFT", XpLeftFrame, "TOPLEFT", 5, -35)
XpLeftFrame.lableTimeLeftToLevel = XpLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
XpLeftFrame.lableTimeLeftToLevel:SetPoint("TOPLEFT", XpLeftFrame, "TOPLEFT", 5, -50)

local currentLevel = 0
local currentXp = 0
local currentXpMax = 0

local timeSinceLastUpdate = 0

-- functions

---@diagnostic disable-next-line: lowercase-global
function formatNumber(number)
	if number > 1000 then
		return round(number / 1000, 1) .. "k"
	else
		return round(number)
	end
end

XpLeftFrame:SetScript("OnUpdate", function(self, elapsed)
	if isMaxLevel then
		return
	end

	timeSinceLastUpdate = timeSinceLastUpdate + elapsed

	if timeSinceLastUpdate > 1 then
		SessionTime = time() - SessionStartTime
		local xpPerSecond = (SessionXp + PreviousSessionXp) / math.max((SessionTime + PreviousSessionTime), 1)
		local xpLeftToLevel = currentXpMax - currentXp
		local xpAsRatio = currentXp / currentXpMax

		local textColor = "|cFF"
		if xpAsRatio < 0.5 then
			textColor = textColor .. "FF" .. string.format("%02x", xpAsRatio * 2 * 255) .. "00"
		else
			textColor = textColor .. string.format("%02x", (1 - xpAsRatio) * 2 * 255) .. "FF00"
		end

		self.lableCurrentXp:SetText(
			textColor
				.. "Current XP: "
				.. formatNumber(currentXp)
				.. "/"
				.. formatNumber(currentXpMax)
				.. " ("
				.. round(100 * xpAsRatio)
				.. "%)"
				.. ColorEnd
		)
		self.lableXpLeftToLevel:SetText(
			textColor .. "XP left to next level: " .. formatNumber(xpLeftToLevel) .. ColorEnd
		)
		self.lableXpPerSecond:SetText(textColor .. "XP/h: " .. formatNumber(3600 * xpPerSecond) .. ColorEnd)
		self.lableTimeLeftToLevel:SetText(
			textColor .. "Time left: " .. TimeToLevelText(xpPerSecond, xpLeftToLevel) .. ColorEnd
		)

		if ExperienceLeftDB then
			ExperienceLeftDB.sessionXp = SessionXp + PreviousSessionXp
			ExperienceLeftDB.sessionTime = SessionTime + PreviousSessionTime
		end

		timeSinceLastUpdate = 0
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
			isMaxLevel = true
		end

		if isMaxLevel then
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
			SessionXp = SessionXp + (UnitXP("player") - currentXp)
		else
			SessionXp = SessionXp + (currentXpMax - currentXp) + UnitXP("player")
			currentLevel = UnitLevel("player")
			currentXpMax = UnitXPMax("player")
		end
		currentXp = UnitXP("player")
	end
end

XpLeftFrame:SetScript("OnEvent", eventHandler)
