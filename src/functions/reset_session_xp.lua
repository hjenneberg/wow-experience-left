function ResetSessionXP()
	PreviousSessionXp = 0
	PreviousSessionTime = 0
	SessionStartTime = time()
	SessionTime = 0
	SessionXp = 0

	if ExperienceLeftDB then
		ExperienceLeftDB.sessionXp = 0
		ExperienceLeftDB.sessionTime = 0
	end

	print(ColorPrimary .. "Experience left|r |cFFBBBBBB- Session XP has been reset" .. ColorEnd)
end
