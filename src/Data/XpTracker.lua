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
	self:RestoreSessionValues()
end

function XPTracker:RestoreSessionValues()
	if #self.sessionValues == 0 then
		return
	end

	local diff = time() - self.sessionValues[#self.sessionValues].time

	for i, value in ipairs(self.sessionValues) do
		self.sessionValues[i] = {
			time = value.time + diff,
			xp = value.xp,
		}
	end
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
