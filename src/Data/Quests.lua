local addonName, addon = ...

local Quests = {}
addon.Quests = Quests

function Quests:GetExperience()
	local potentialXP = 0
	local completedXP = 0

	local numEntries = C_QuestLog.GetNumQuestLogEntries()

	for index = 1, numEntries do
		local info = C_QuestLog.GetInfo(index)

		if info and info.questID and not info.isHeader then
			local questID = info.questID

			if HaveQuestRewardData(questID) then
				local xp = GetQuestLogRewardXP(questID) or 0

				potentialXP = potentialXP + xp

				if C_QuestLog.IsComplete(questID) then
					completedXP = completedXP + xp
				end
			end
		end
	end

	return potentialXP, completedXP
end
