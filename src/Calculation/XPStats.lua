local addonName, addon = ...

local XPStats = {}
addon.XPStats = XPStats

function XPStats:GetQuestExperienceRatio(potentialXP, completedXP)
	if potentialXP <= 0 then
		return 0
	end

	return completedXP / potentialXP
end

function XPStats:GetXPPerSecond(sessionValues)
	local xpSum = 0

	for _, value in ipairs(sessionValues) do
		xpSum = xpSum + value.xp
	end

	if #sessionValues == 0 then
		return 0
	end

	local duration = math.max(time() - sessionValues[1].time, 1)

	return xpSum / duration
end

function XPStats:GetLevelExperience()
	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")

	local xpLeft = maxXP - currentXP
	local ratio = 0

	if maxXP > 0 then
		ratio = currentXP / maxXP
	end

	return {
		currentXP = currentXP,
		maxXP = maxXP,
		xpLeft = xpLeft,
		ratio = ratio,
	}
end

function XPStats:IsMaxLevel()
	return UnitLevel("player") >= GetMaxPlayerLevel()
end

function XPStats:GetTimeToLevelText(xpPerSecond, xpLeftToLevel)
	if xpPerSecond <= 0 then
		return "n/a"
	end

	local timeLeftToLevel = xpLeftToLevel / xpPerSecond

	if timeLeftToLevel < 60 then
		return math.floor(timeLeftToLevel) .. "s"
	end

	if timeLeftToLevel < 3600 then
		local minutes = math.floor(timeLeftToLevel / 60)

		return minutes .. "m"
	end

	if timeLeftToLevel < 86400 then
		local hours = math.floor(timeLeftToLevel / 3600)
		local minutes = math.floor((timeLeftToLevel - hours * 3600) / 60)

		local text = hours .. "h"

		if minutes > 0 then
			text = text .. " " .. minutes .. "m"
		end

		return text
	end

	local days = math.floor(timeLeftToLevel / 86400)
	local hours = math.floor((timeLeftToLevel - days * 86400) / 3600)

	local text = days .. "d"

	if hours > 0 then
		text = text .. " " .. hours .. "h"
	end

	return text
end
