local addonName, addon = ...

addon.name = addonName
addon.ColorPrimary = "|cFFFFFF00"
addon.ColorEnd = "|r"

addon.shouldUpdateOnNextTick = false

function addon.round(num, numDecimalPlaces)
	local multi = 10 ^ (numDecimalPlaces or 0)

	return math.floor(num * multi + 0.5) / multi
end
