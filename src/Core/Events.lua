local addonName, addon = ...

local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("ADDON_LOADED")
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
	end
end)

local function RegisterRuntimeEvent(event, callback)
	EventRegistry:RegisterFrameEventAndCallback(event, function(_, ...)
		callback(...)
	end, addon)
end

RegisterRuntimeEvent("PLAYER_ENTERING_WORLD", function()
	if addon.XPStats:IsMaxLevel() then
		addon.MainFrame:Hide()
	else
		addon.MainFrame:Show()
		addon.MainFrame:RequestUpdate()
	end
end)

RegisterRuntimeEvent("PLAYER_XP_UPDATE", function()
	addon.XPTracker:Update()
	addon.MainFrame:RequestUpdate()
end)

RegisterRuntimeEvent("UNIT_DIED", function(unitGUID)
	addon.XPTracker:OnUnitDied(unitGUID)
end)
