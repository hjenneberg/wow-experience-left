function FormatLargeNumber(number, numDecimalPlaces)
	if numDecimalPlaces == nil then
		numDecimalPlaces = 0
	end
	if number > 1000 then
		return string.format("%." .. numDecimalPlaces .. "fk", number / 1000)
	else
		return round(number)
	end
end
