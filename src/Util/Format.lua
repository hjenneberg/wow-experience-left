local addonName, addon = ...

function addon.Round(value)
	return math.floor(value + 0.5)
end

function addon.FormatLargeNumber(number, numDecimalPlaces)
	numDecimalPlaces = numDecimalPlaces or 0

	if number >= 1000 then
		return string.format("%." .. numDecimalPlaces .. "fk", number / 1000)
	end

	return addon.Round(number)
end
