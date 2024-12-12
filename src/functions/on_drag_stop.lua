function OnDragStop(self)
	self:StopMovingOrSizing()
	if ExperienceLeftDB then
		local _, _, relativePoint, xOffset, yOffset = XpLeftFrame:GetPoint(1)
		ExperienceLeftDB.relativePoint = relativePoint
		ExperienceLeftDB.xOffset = xOffset
		ExperienceLeftDB.yOffset = yOffset
	end
end
