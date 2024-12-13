function OnMouseDown(self, button)
	if button ~= "RightButton" then
		return
	end
	MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
		rootDescription:CreateTitle("ExperienceLeft")
		rootDescription:CreateButton("Start new session", ResetSessionXP)
		rootDescription:CreateButton("Hide frame", HideFrame)
	end)
end
