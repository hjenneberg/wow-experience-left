function FormatLargeNumber(number)
	if number > 1000 then
		return round(number / 1000, 1) .. "k"
	else
		return round(number)
	end
end
