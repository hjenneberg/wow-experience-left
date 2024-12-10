local MainFrame = _G.MainFrame

function MainFrame:getTimeLeftToLevelAsString(xpPerSecond, xpLeftToLevel)
    if xpPerSecond == 0 then return "n/a" end

    local timeLeftToLevel = xpLeftToLevel / xpPerSecond
    local timeLeftAsText

    if timeLeftToLevel < 60 then
        timeLeftAsText = math.floor(timeLeftToLevel) .. "s"
    elseif timeLeftToLevel < 3600 then
        local minutes = math.floor(timeLeftToLevel / 60)
        timeLeftAsText = minutes .. "m"
    else
        local hours = math.floor(timeLeftToLevel / 3600)
        local minutes = math.floor((timeLeftToLevel - hours * 3600) / 60)
        timeLeftAsText = hours .. "h"
        if minutes > 0 then timeLeftAsText = timeLeftAsText .. " " .. minutes .. "m" end
    end

    return timeLeftAsText
end

