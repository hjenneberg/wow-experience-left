function TimeToLevelText(xpPerSecond, xpLeftToLevel)
	if xpPerSecond == 0 then
		return "n/a"
	end

	local timeLeftToLevel = xpLeftToLevel / xpPerSecond
	local timeLeftText

	if timeLeftToLevel < 60 then
		timeLeftText = math.floor(timeLeftToLevel) .. "s"
	elseif timeLeftToLevel < 3600 then
		local minutes = math.floor(timeLeftToLevel / 60)
		timeLeftText = minutes .. "m"
	elseif timeLeftToLevel < 86400 then
		local hours = math.floor(timeLeftToLevel / 3600)
		local minutes = math.floor((timeLeftToLevel - hours * 3600) / 60)
		timeLeftText = hours .. "h"
		if minutes > 0 then
			timeLeftText = timeLeftText .. " " .. minutes .. "m"
		end
	else
		local days = math.floor(timeLeftToLevel / 86400)
		local hours = math.floor((timeLeftToLevel - days * 86400) / 3600)
		timeLeftText = days .. "d"
		if hours > 0 then
			timeLeftText = timeLeftText .. " " .. hours .. "h"
		end
	end

	return timeLeftText
end
