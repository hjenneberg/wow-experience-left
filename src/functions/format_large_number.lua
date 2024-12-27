function FormatLargeNumber(number, numDecimalPlaces)
	if numDecimalPlaces == nil then
		numDecimalPlaces = 0
	end
	if number > 1000 then
		return string.format("%." .. numDecimalPlaces .. "fk", round(number / 1000, numDecimalPlaces))
	else
		return string.format("%." .. numDecimalPlaces .. "f", round(number, numDecimalPlaces))
	end
end
