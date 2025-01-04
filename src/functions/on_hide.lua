function OnHide()
	if UnitIsAFK("player") then
		return
	end

	PlaySound(808)

	print(
		ColorPrimary
			.. "Experience left|r: Frame hidden, use |cFFBBBBBB/xpleft show"
			.. ColorEnd
			.. " to show it again."
	)
end
