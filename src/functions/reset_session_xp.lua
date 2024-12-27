function ResetSessionXP()
	IsPaused = false

	SessionValues = {}

	if ExperienceLeftDB then
		ExperienceLeftDB.SessionValues = {}
	end

	ShouldUpdateOnNextTick = true

	print(ColorPrimary .. "Experience left|r |cFFBBBBBB- Session XP has been reset" .. ColorEnd)
end
