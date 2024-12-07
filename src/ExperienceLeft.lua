local isMaxLevel = false

local mainFrame = CreateFrame("Frame", "ExperienceLeftMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
mainFrame:SetSize(300, 250)

mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then self:StartMoving() end
end)
mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
    if ExperienceLeftDB then
        local _, _, relativePoint, xOffset, yOffset = mainFrame:GetPoint(1)
        ExperienceLeftDB.relativePoint = relativePoint
        ExperienceLeftDB.xOffset = xOffset
        ExperienceLeftDB.yOffset = yOffset
    end
end)
mainFrame:SetScript("OnShow", function()
    PlaySound(808)
end)
mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)

SLASH_EXPERIENCELEFT1 = "/xpleft"
SlashCmdList["EXPERIENCELEFT"] = function()
    if isMaxLevel then return end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

mainFrame.lableCurrentXp = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableCurrentXp:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -5)
mainFrame.lableXpLeftToLevel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableXpLeftToLevel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -20)
mainFrame.lableXpPerSecond = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableXpPerSecond:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -35)
mainFrame.lableTimeLeftToLevel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableTimeLeftToLevel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -50)

local sessionStartTime = time()
local sessionTime = 0
local sessionXp = 0

local previousSessionXp = 0
local previousSessionTime = 0

local currentLevel = 0
local currentXp = 0
local currentXpMax = 0

local timeSinceLastUpdate = 0

mainFrame:SetScript("OnUpdate", function(self, elapsed)
    if isMaxLevel then return end

    timeSinceLastUpdate = timeSinceLastUpdate + elapsed

    if (timeSinceLastUpdate > 1) then
        sessionTime = time() - sessionStartTime
        local xpPerSecond = (sessionXp + previousSessionXp) / (sessionTime + previousSessionTime)
        local xpLeftToLevel = currentXpMax - currentXp
        local xpAsRatio = currentXp / currentXpMax
        local timeLeftAsText = ""

        if xpPerSecond == 0 then
            timeLeftAsText = "n/a"
        else
            local timeLeftToLevel = xpLeftToLevel / xpPerSecond
            if timeLeftToLevel < 60
            then
                timeLeftAsText = timeLeftAsText .. math.floor(timeLeftToLevel) .. "s"
            elseif timeLeftToLevel < 3600
            then
                local minutes = math.floor(timeLeftToLevel / 60)
                timeLeftAsText = timeLeftAsText .. minutes .. "m"
            else
                local hours = math.floor(timeLeftToLevel / 3600)
                local minutes = math.floor((timeLeftToLevel - hours * 3600) / 60)
                timeLeftAsText = timeLeftAsText .. hours .. "h"
                if minutes > 0
                then
                    timeLeftAsText = timeLeftAsText .. " " .. minutes .. "m"
                end
            end
        end

        local textColor
        if (xpAsRatio < 0.5) then
            textColor = "FF" .. string.format("%02x", xpAsRatio * 2 * 255) .. "00"
        else
            textColor = string.format("%02x", (1 - xpAsRatio) * 2 * 255) .. "FF00"
        end

        self.lableCurrentXp:SetText("|cFF" .. textColor .. "Current XP: " .. currentXp .. "/" .. currentXpMax .. " (" .. math.floor(100 * xpAsRatio) .. "%)" .. "|r")
        self.lableXpLeftToLevel:SetText("|cFF" .. textColor .. "XP left to next level: " .. xpLeftToLevel .. "|r")
        self.lableXpPerSecond:SetText("|cFF" .. textColor .. "XP/h: " .. math.floor(3600 * xpPerSecond) .. "|r")
        self.lableTimeLeftToLevel:SetText("|cFF" .. textColor .. "Time left: " .. timeLeftAsText .. "|r")

        if ExperienceLeftDB then
            ExperienceLeftDB.sessionXp = sessionXp + previousSessionXp
            ExperienceLeftDB.sessionTime = sessionTime + previousSessionTime
        end

        timeSinceLastUpdate = 0;
    end
end)

mainFrame:RegisterEvent("ADDON_LOADED");
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainFrame:RegisterEvent("PLAYER_XP_UPDATE");

local function eventHandler(self, event, args, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        currentLevel = UnitLevel("player")
        currentXp = UnitXP("player")
        currentXpMax = UnitXPMax("player")

        local maxLevel = MAX_PLAYER_LEVEL_TABLE[#MAX_PLAYER_LEVEL_TABLE]
        if maxLevel ~= nil and maxLevel == currentLevel then
            isMaxLevel = true
        end

        if isMaxLevel then 
            mainFrame:Hide()
        end
    end
    if event == "ADDON_LOADED" and args == "ExperienceLeft" then
        if not ExperienceLeftDB then ExperienceLeftDB = {} end

        previousSessionXp = 0
        if ExperienceLeftDB.sessionXp then previousSessionXp = ExperienceLeftDB.sessionXp end
        previousSessionTime = 0
        if ExperienceLeftDB.sessionTime then previousSessionTime = ExperienceLeftDB.sessionXp end

        local relativePoint = "CENTER"
        if ExperienceLeftDB.relativePoint then relativePoint = ExperienceLeftDB.relativePoint end
        local xOffset = 0
        if ExperienceLeftDB.xOffset then xOffset = ExperienceLeftDB.xOffset end
        local yOffset = 0
        if ExperienceLeftDB.yOffset then yOffset = ExperienceLeftDB.yOffset end
        mainFrame:SetPoint("CENTER", UIParent, relativePoint, xOffset, yOffset)
    end
    if event == "PLAYER_XP_UPDATE" then
        if (UnitLevel("player") == currentLevel)
        then
            sessionXp = sessionXp + (UnitXP("player") - currentXp)
        else
            sessionXp = sessionXp + (currentXpMax - currentXp) + UnitXP("player")
            currentLevel = UnitLevel("player")
            currentXpMax = UnitXPMax("player")
        end
        currentXp = UnitXP("player")
    end
end

mainFrame:SetScript("OnEvent", eventHandler);
