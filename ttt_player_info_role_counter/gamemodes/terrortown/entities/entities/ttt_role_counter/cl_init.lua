-- author "Zaratusa"
-- contact "http://steamcommunity.com/profiles/76561198032479768"

-- save colors and strings for easy access
local teams = {
	[ROLE_TEAM_INNOCENT] = {string = " innocent", color = GetRoleTeamColor(ROLE_TEAM_INNOCENT)},
	[ROLE_TEAM_DETECTIVE] = {string = " detective", color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)},
	[ROLE_TEAM_TRAITOR] = {string = " traitor", color = GetRoleTeamColor(ROLE_TEAM_TRAITOR)},
	[ROLE_TEAM_INDEPENDENT] = {string = " other role", color = GetRoleTeamColor(ROLE_TEAM_INDEPENDENT)},
	[ROLE_NONE] = {color = Color(255, 255, 0, 255)}
}

net.Receive("TTT_RoleCount_Start", function()
	local innocents = net.ReadUInt(6)
	local detectives = net.ReadUInt(6)
	local traitors = net.ReadUInt(6)
	local others = net.ReadUInt(6)
	local spectators = net.ReadUInt(6)

	chat.AddText(
			color_white, "There are ",
			teams[ROLE_TEAM_INNOCENT].color, innocents .. teams[ROLE_TEAM_INNOCENT].string .. "(s)",
			color_white,", ",
			teams[ROLE_TEAM_DETECTIVE].color, detectives .. teams[ROLE_TEAM_DETECTIVE].string .. "(s)",
			color_white, ", ",
			teams[ROLE_TEAM_TRAITOR].color, traitors .. teams[ROLE_TEAM_TRAITOR].string .. "(s)",
			color_white, ", and ",
			teams[ROLE_TEAM_INDEPENDENT].color, others .. teams[ROLE_TEAM_INDEPENDENT].string .. "(s)",
			color_white, " this round!"
	)

	if (spectators ~= 1) then
		chat.AddText(
			teams[ROLE_NONE].color, spectators .. " players",
			color_white, " are spectating the Trouble in this Terrorist Town."
		)
	else
		chat.AddText(
			teams[ROLE_NONE].color, "1 player",
			color_white, " is spectating the Trouble in this Terrorist Town."
		)
	end
end)

net.Receive("TTT_RoleCount_Say", function()
	local innocents = net.ReadUInt(6)
	local detectives = net.ReadUInt(6)
	local traitors = net.ReadUInt(6)
	local others = net.ReadUInt(6)

	chat.AddText(
			color_white, "There are currently ",
			teams[ROLE_TEAM_INNOCENT].color, innocents .. teams[ROLE_TEAM_INNOCENT].string .. "(s)",
			color_white,", ",
			teams[ROLE_TEAM_DETECTIVE].color, detectives .. teams[ROLE_TEAM_DETECTIVE].string .. "(s)",
			color_white, ", ",
			teams[ROLE_TEAM_TRAITOR].color, traitors .. teams[ROLE_TEAM_TRAITOR].string .. "(s)",
			color_white, ", and ",
			teams[ROLE_TEAM_INDEPENDENT].color, others .. teams[ROLE_TEAM_INDEPENDENT].string .. "(s)",
			color_white, " this round!"
	)
end)

net.Receive("TTT_RoleCount_Wait_Spam", function()
	chat.AddText(color_white, "Please wait a few seconds before you request the role distribution again.")
end)

net.Receive("TTT_RoleCount_Wait", function()
	chat.AddText(color_white, "Please wait until the round has started.")
end)

local function PrintToChat(team, alive, endtext)
	local starttext = "A"
	if (team == ROLE_TEAM_INNOCENT) then
		starttext = starttext .. "n"
	end

	if (alive ~= nil) then
		if (alive) then
			endtext = endtext .. "they were still alive."
		else
			endtext = endtext .. "they were already dead."
		end
	end

	chat.AddText(
			color_white, starttext,
			GetRoleTeamColor(team), GetRoleTeamName(team),
			color_white, endtext
	)
end

net.Receive("TTT_RoleCount_Spectate", function()
	PrintToChat(net.ReadUInt(3), nil, " has switched to the spectators.")
end)

net.Receive("TTT_RoleCount_Leave", function()
	PrintToChat(net.ReadUInt(3), net.ReadBool(), " has left the server, ")
end)
