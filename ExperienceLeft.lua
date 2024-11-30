local frame = CreateFrame("FRAME", "XpAddonFrame");
frame:RegisterEvent("PLAYER_XP_UPDATE");

sessionStartTime = time()
sessionXp = 0

currentXp = UnitXP("player")
currentLevel = UnitLevel("player")
currentXpMax = UnitXPMax("player")

print(currentXpMax)

function eventHandler(self, event, ...)
    if (UnitLevel("player") == currentLevel)
    then
        sessionXp = sessionXp + (UnitXP("player") - currentXp)
    else
        sessionXp = sessionXp + (currentXpMax - currentXp) + UnitXP("player")
        currentLevel = UnitLevel("player")
        currentXpMax = UnitXPMax("player")
    end
    currentXp = UnitXP("player")

    local xpPerSecond = sessionXp / (time() - sessionStartTime)
    local xpLeftToLevel = UnitXPMax("player") - currentXp
    local timeLeftToLevel = xpLeftToLevel / xpPerSecond

    local timeLeft = timeLeftToLevel
    local timeLeftAsText = "Verbleibende Zeit: "
    if timeLeft < 60
    then
        timeLeftAsText = timeLeftAsText .. math.floor(timeLeft) .. " Sekunden"
    elseif timeLeft < 3600
    then
        local minutes = math.floor(timeLeft / 60)
        timeLeftAsText = timeLeftAsText .. minutes .. " Minuten"
    else
        local hours = math.floor(timeLeft / 3600)
        local minutes = math.floor((timeLeft - hours * 3600) / 60)
        timeLeftAsText = timeLeftAsText .. hours .. " Stunden, " .. minutes .. " Minuten"
    end

    print("|c0074C365" .. timeLeftAsText .. " (" .. math.floor(60 * xpPerSecond) .. " XP/min)" .."|r")
end

frame:SetScript("OnEvent", eventHandler);