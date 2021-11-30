-- author "Zaratusa"
-- contact "http://steamcommunity.com/profiles/76561198032479768"

local ROLE_SPECTATOR = 3
-- save colors and strings for easy access
local teams = {
	[TEAM_INNOCENT] = {string = " innocent", color = GetRoleTeamColor(ROLE_TEAM_INNOCENT)},
	[TEAM_DETECTIVE] = {string = " detective", color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)},
	[TEAM_TRAITOR] = {string = " traitor", color = GetRoleTeamColor(ROLE_TEAM_TRAITOR)},
	[TEAM_OTHER] = {string = " other role", color = GetRoleTeamColor(ROLE_TEAM_INDEPENDENT)},
	[TEAM_SPECTATOR] = {color = Color(255, 255, 0, 255)}
}

net.Receive("TTT_RoleCount_Start", function()
	local innocents = net.ReadUInt(6)
	local detectives = net.ReadUInt(6)
	local traitors = net.ReadUInt(6)
	local others = net.ReadUInt(6)
	local spectators = net.ReadUInt(6)

	chat.AddText(
			color_white, "There are ",
			teams[TEAM_INNOCENT].color, innocents .. teams[TEAM_INNOCENT].string .. "(s)",
			color_white,", ",
			teams[TEAM_DETECTIVE].color, detectives .. teams[TEAM_DETECTIVE].string .. "(s)",
			color_white, ", ",
			teams[TEAM_TRAITOR].color, traitors .. teams[TEAM_TRAITOR].string .. "(s)",
			color_white, ", and ",
			teams[TEAM_OTHER].color, others .. teams[TEAM_OTHER].string .. "(s)",
			color_white, " this round!"
	)

	if (spectators ~= 1) then
		chat.AddText(
			roles[ROLE_SPECTATOR].color, spectators .. " players",
			color_white, " are spectating the Trouble in this Terrorist Town."
		)
	else
		chat.AddText(
			roles[ROLE_SPECTATOR].color, "1 player",
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
			teams[TEAM_INNOCENT].color, innocents .. teams[TEAM_INNOCENT].string .. "(s)",
			color_white,", ",
			teams[TEAM_DETECTIVE].color, detectives .. teams[TEAM_DETECTIVE].string .. "(s)",
			color_white, ", ",
			teams[TEAM_TRAITOR].color, traitors .. teams[TEAM_TRAITOR].string .. "(s)",
			color_white, ", and ",
			teams[TEAM_OTHER].color, others .. teams[TEAM_OTHER].string .. "(s)",
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
