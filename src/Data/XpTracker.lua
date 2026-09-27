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
