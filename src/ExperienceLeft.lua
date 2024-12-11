local isMaxLevel = false

local cEnd = "|r"

MainFrame = CreateFrame("Frame", "ExperienceLeftMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
MainFrame:SetSize(300, 250)

MainFrame:EnableMouse(true)
MainFrame:SetMovable(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", function(self)
	if IsShiftKeyDown() then
		self:StartMoving()
	end
end)
MainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	if ExperienceLeftDB then
		local _, _, relativePoint, xOffset, yOffset = MainFrame:GetPoint(1)
		ExperienceLeftDB.relativePoint = relativePoint
		ExperienceLeftDB.xOffset = xOffset
		ExperienceLeftDB.yOffset = yOffset
	end
end)
MainFrame:SetScript("OnShow", function()
	PlaySound(808)
end)
MainFrame:SetScript("OnHide", function()
	PlaySound(808)
end)

local previousSessionXp = 0
local previousSessionTime = 0

SLASH_EXPERIENCELEFT1 = "/xpleft"
local function slashCommandHandler(msg, editBox)
	if isMaxLevel then
		return
	end
	if msg == "show" then
		MainFrame:Show()
	elseif msg == "hide" then
		MainFrame:Hide()
	elseif msg == "center" then
		MainFrame:ClearAllPoints()
		MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	elseif msg == "reset" then
		previousSessionXp = 0
		previousSessionTime = 0
		if ExperienceLeftDB then
			ExperienceLeftDB.sessionXp = 0
			ExperienceLeftDB.sessionTime = 0
		end
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

MainFrame.lableCurrentXp = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MainFrame.lableCurrentXp:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 5, -5)
MainFrame.lableXpLeftToLevel = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MainFrame.lableXpLeftToLevel:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 5, -20)
MainFrame.lableXpPerSecond = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MainFrame.lableXpPerSecond:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 5, -35)
MainFrame.lableTimeLeftToLevel = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MainFrame.lableTimeLeftToLevel:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 5, -50)

local sessionStartTime = time()
local sessionTime = 0
local sessionXp = 0

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
		return number
	end
end

MainFrame:SetScript("OnUpdate", function(self, elapsed)
	if isMaxLevel then
		return
	end

	timeSinceLastUpdate = timeSinceLastUpdate + elapsed

	if timeSinceLastUpdate > 1 then
		sessionTime = time() - sessionStartTime
		local xpPerSecond = (sessionXp + previousSessionXp) / (sessionTime + previousSessionTime)
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
				.. cEnd
		)
		self.lableXpLeftToLevel:SetText(textColor .. "XP left to next level: " .. formatNumber(xpLeftToLevel) .. cEnd)
		self.lableXpPerSecond:SetText(textColor .. "XP/h: " .. formatNumber(3600 * xpPerSecond) .. cEnd)
		self.lableTimeLeftToLevel:SetText(
			textColor .. "Time left: " .. timeToLevelText(xpPerSecond, xpLeftToLevel) .. cEnd
		)

		if ExperienceLeftDB then
			ExperienceLeftDB.sessionXp = sessionXp + previousSessionXp
			ExperienceLeftDB.sessionTime = sessionTime + previousSessionTime
		end

		timeSinceLastUpdate = 0
	end
end)

MainFrame:RegisterEvent("ADDON_LOADED")
MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
MainFrame:RegisterEvent("PLAYER_XP_UPDATE")

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
			MainFrame:Hide()
		end
	end
	if event == "ADDON_LOADED" and args == "ExperienceLeft" then
		if not ExperienceLeftDB then
			ExperienceLeftDB = {}
		end

		previousSessionXp = 0
		if ExperienceLeftDB.sessionXp then
			previousSessionXp = ExperienceLeftDB.sessionXp
		end
		previousSessionTime = 0
		if ExperienceLeftDB.sessionTime then
			previousSessionTime = ExperienceLeftDB.sessionXp
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
		MainFrame:SetPoint("CENTER", UIParent, relativePoint, xOffset, yOffset)
	end
	if event == "PLAYER_XP_UPDATE" then
		if UnitLevel("player") == currentLevel then
			sessionXp = sessionXp + (UnitXP("player") - currentXp)
		else
			sessionXp = sessionXp + (currentXpMax - currentXp) + UnitXP("player")
			currentLevel = UnitLevel("player")
			currentXpMax = UnitXPMax("player")
		end
		currentXp = UnitXP("player")
	end
end

MainFrame:SetScript("OnEvent", eventHandler)
