function OnDragStart(self)
	if IsShiftKeyDown() then
		self:StartMoving()
	end
end
