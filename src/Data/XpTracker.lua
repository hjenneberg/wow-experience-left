local addonName, addon = ...

local XPTracker = {}
addon.XPTracker = XPTracker

local MAX_SESSION_VALUES = 100

function XPTracker:Initialize(savedVariables)
	self.db = savedVariables

	self.currentLevel = UnitLevel("player")
	self.currentXP = UnitXP("player")
	self.currentXPMax = UnitXPMax("player")

	self.sessionValues = savedVariables.SessionValues or {}
	self.pausedAt = savedVariables.PausedAt
	self.pauseReason = self.pausedAt and (savedVariables.PauseReason or "manual") or nil

	if savedVariables.AutoResume == nil then
		savedVariables.AutoResume = true
	end

	if savedVariables.AutoPauseFishing == nil then
		savedVariables.AutoPauseFishing = true
	end

	self:RestoreSessionValues()
end

function XPTracker:ShiftSessionValues(diff)
	for i, value in ipairs(self.sessionValues) do
		self.sessionValues[i] = {
			time = value.time + diff,
			xp = value.xp,
		}
	end

	self.db.SessionValues = self.sessionValues
end

function XPTracker:RestoreSessionValues()
	if #self.sessionValues == 0 then
		if self.pausedAt then
			self:SetPausedAt(time())
		end

		return
	end

	local diff = time() - self.sessionValues[#self.sessionValues].time

	self:ShiftSessionValues(diff)

	-- Keep the distance between the last value and the pause start, so the frozen rate stays identical.
	if self.pausedAt then
		self:SetPausedAt(self.pausedAt + diff)
	end
end

function XPTracker:SetPausedAt(pausedAt)
	self.pausedAt = pausedAt
	self.db.PausedAt = pausedAt
end

function XPTracker:SetPauseReason(reason)
	self.pauseReason = reason
	self.db.PauseReason = reason
end

function XPTracker:IsPaused()
	return self.pausedAt ~= nil
end

-- "manual" for pauses started by the player, otherwise the trigger of an automatic pause (e.g. "fishing").
function XPTracker:GetPauseReason()
	return self.pauseReason
end

function XPTracker:Pause(reason)
	if self:IsPaused() then
		return
	end

	self:SetPausedAt(time())
	self:SetPauseReason(reason or "manual")
end

function XPTracker:Resume()
	if not self:IsPaused() then
		return
	end

	self:ShiftSessionValues(time() - self.pausedAt)
	self:SetPausedAt(nil)
	self:SetPauseReason(nil)
end

-- Automatic pauses always end on XP gain, manual pauses only with auto-resume enabled.
function XPTracker:ShouldResumeOnXPGain()
	if not self:IsPaused() then
		return false
	end

	return self.pauseReason ~= "manual" or self:IsAutoResumeEnabled()
end

function XPTracker:IsAutoPauseFishingEnabled()
	return self.db.AutoPauseFishing ~= false
end

function XPTracker:SetAutoPauseFishingEnabled(enabled)
	self.db.AutoPauseFishing = enabled and true or false
end

function XPTracker:OnFishingStarted()
	-- Never override a running pause, especially not a manual one.
	if not self:IsAutoPauseFishingEnabled() or self:IsPaused() then
		return
	end

	self:Pause("fishing")

	print(addon.ColorPrimary .. "Experience left|r: Session paused (fishing).")
end

function XPTracker:TogglePause()
	if self:IsPaused() then
		self:Resume()
	else
		self:Pause()
	end
end

-- Reference time for rate calculations: frozen at the pause start while paused.
function XPTracker:GetCurrentTime()
	return self.pausedAt or time()
end

function XPTracker:IsAutoResumeEnabled()
	return self.db.AutoResume ~= false
end

function XPTracker:SetAutoResumeEnabled(enabled)
	self.db.AutoResume = enabled and true or false
end

function XPTracker:Update()
	local currentLevel = UnitLevel("player")
	local currentXP = UnitXP("player")
	local currentXPMax = UnitXPMax("player")

	local xpGained = 0

	if currentLevel == self.currentLevel then
		xpGained = currentXP - self.currentXP
	else
		xpGained = (self.currentXPMax - self.currentXP) + currentXP
	end

	self.currentLevel = currentLevel
	self.currentXP = currentXP
	self.currentXPMax = currentXPMax

	if xpGained > 0 and self.pendingDeaths then
		local now = GetTime()
		local newestDeath = nil

		for i = #self.pendingDeaths, 1, -1 do
			local death = self.pendingDeaths[i]

			if now - death.time > 3 then
				table.remove(self.pendingDeaths, i)
			elseif not newestDeath then
				newestDeath = death
			end
		end

		if newestDeath then
			self.lastMob = { name = newestDeath.name, xp = xpGained }
			self.pendingDeaths = {}
		end
	end

	if xpGained > 0 and self:ShouldResumeOnXPGain() then
		self:Resume()

		print(addon.ColorPrimary .. "Experience left|r: Session resumed (XP gained).")
	end

	-- XP gained while paused is not counted towards the rate.
	if self:IsPaused() then
		return
	end

	self:AddSessionValue(xpGained)
end

function XPTracker:AddSessionValue(xp)
	table.insert(self.sessionValues, {
		time = time(),
		xp = xp,
	})

	if #self.sessionValues > MAX_SESSION_VALUES then
		table.remove(self.sessionValues, 1)
	end

	self.db.SessionValues = self.sessionValues
end

function XPTracker:ResetSession()
	self.sessionValues = {}

	self.currentLevel = UnitLevel("player")
	self.currentXP = UnitXP("player")
	self.currentXPMax = UnitXPMax("player")

	self.db.SessionValues = self.sessionValues
	self:SetPausedAt(nil)
	self:SetPauseReason(nil)
end

function XPTracker:GetSessionValues()
	return self.sessionValues
end

local function FindUnitNameByGUID(guid)
	if not guid or (issecretvalue and issecretvalue(guid)) then
		return nil
	end

	local units = { "target", "focus", "mouseover" }

	for i = 1, 40 do
		units[#units + 1] = "nameplate" .. i
	end

	for _, unit in ipairs(units) do
		if UnitExists(unit) then
			local unitGUID = UnitGUID(unit)

			if unitGUID and not (issecretvalue and issecretvalue(unitGUID)) and unitGUID == guid then
				local name = UnitName(unit)

				if name and not (issecretvalue and issecretvalue(name)) then
					return name
				end
			end
		end
	end

	return nil
end

function XPTracker:OnUnitDied(unitGUID)
	local name = FindUnitNameByGUID(unitGUID)

	if not name then
		return
	end

	self.pendingDeaths = self.pendingDeaths or {}
	table.insert(self.pendingDeaths, { name = name, time = GetTime() })
end

function XPTracker:GetLastMob()
	return self.lastMob
end
