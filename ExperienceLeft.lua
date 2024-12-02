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
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

mainFrame.lablePlayerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lablePlayerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
mainFrame.lableCurrentXp = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableCurrentXp:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -55)
mainFrame.lableXpLeftToLevel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableXpLeftToLevel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -75)
mainFrame.lableXpPerSecond = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableXpPerSecond:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -95)
mainFrame.lableTimeLeftToLevel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.lableTimeLeftToLevel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -115)

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
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed

    if (timeSinceLastUpdate > 1) then
        sessionTime = time() - sessionStartTime
        local xpPerSecond = (sessionXp + previousSessionXp) / (sessionTime + previousSessionTime)
        local xpLeftToLevel = currentXpMax - currentXp
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

        self.lablePlayerName:SetText("Character: " .. UnitName("player") .. " (Level " .. currentLevel .. ")")
        self.lableCurrentXp:SetText("Current XP: " .. currentXp .. "/" .. currentXpMax .. " (" .. math.floor(100 * currentXp / currentXpMax) .. "%)")
        self.lableXpLeftToLevel:SetText("XP left to next level: " .. xpLeftToLevel)
        self.lableXpPerSecond:SetText("XP/h: " .. math.floor(3600 * xpPerSecond))
        self.lableTimeLeftToLevel:SetText("Time left: " .. timeLeftAsText)

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

        print("ExperienceLeft loaded")
    end
    if event == "PLAYER_XP_UPDATE" then
        if (UnitLevel("player") == currentLevel)
        then
            sessionXp = sessionXp + (UnitXP("player") - currentXp)
        else
            print("Session XP: " .. sessionXp)
            print("Level UP")

            sessionXp = sessionXp + (currentXpMax - currentXp) + UnitXP("player")

            print("Session XP: " .. sessionXp)
            print("XP gain before: " .. (currentXpMax - currentXp))
            print("XP gain after: " .. UnitXP("player"))

            currentLevel = UnitLevel("player")
            currentXpMax = UnitXPMax("player")
        end
        currentXp = UnitXP("player")
    end
end

mainFrame:SetScript("OnEvent", eventHandler);
