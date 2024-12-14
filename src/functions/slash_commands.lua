SLASH_EXPERIENCELEFT1 = "/xpleft"
SlashCmdList["EXPERIENCELEFT"] = function(msg, editBox)
	if IsMaxLevel then
		return
	end

	local commands = {
		show = function()
			XpLeftFrame:Show()
		end,
		hide = HideFrame,
		center = function()
			XpLeftFrame:ClearAllPoints()
			XpLeftFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end,
		reset = ResetSessionXP,
	}

	if commands[msg] == nil then
		print("|cFFFFFF00ExperienceLeft commands:|r")
		print("|cFFFF9900/xpleft|r |cFFBBBBBB- Show this help|r")
		print("|cFFFF9900/xpleft show|r |cFFBBBBBB- Show the addon main frame|r")
		print("|cFFFF9900/xpleft hide|r |cFFBBBBBB- Hide the addon main frame|r")
		print("|cFFFF9900/xpleft center|r |cFFBBBBBB- Center the frame on the screen|r")
		print("|cFFFF9900/xpleft reset|r |cFFBBBBBB- Reset saved xp rates from previous sessions|r")
	else
		commands[msg]()
	end
end
