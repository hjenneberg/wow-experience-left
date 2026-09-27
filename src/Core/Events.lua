local addonName, addon = ...

local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_XP_UPDATE")

EventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" then
		local loadedAddon = ...

		if loadedAddon ~= addonName then
			return
		end

		ExperienceLeftDB = ExperienceLeftDB or {}
		addon.db = ExperienceLeftDB

		addon.XPTracker:Initialize(ExperienceLeftDB)

		addon.MainFrame:Create()
		local relativePoint = ExperienceLeftDB.relativePoint or "CENTER"
		local xOffset = ExperienceLeftDB.xOffset or 0
		local yOffset = ExperienceLeftDB.yOffset or 0
		addon.MainFrame:GetFrame():SetPoint("CENTER", UIParent, relativePoint, xOffset, yOffset)

		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		if addon.XPStats:IsMaxLevel() then
			addon.MainFrame:Hide()
		else
			addon.MainFrame:Show()
			addon.MainFrame:RequestUpdate()
		end

		return
	end

	if event == "PLAYER_XP_UPDATE" then
		addon.XPTracker:Update()
		addon.MainFrame:RequestUpdate()
	end
end)
