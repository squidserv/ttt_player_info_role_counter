-- author "Zaratusa"
-- contact "http://steamcommunity.com/profiles/76561198032479768"

local ROLE_SPECTATOR = 3
-- save colors and strings for easy access
local roles = {
	[ROLE_INNOCENT] = {string = " innocent", color = Color(0, 255, 0, 255)},
	[ROLE_DETECTIVE] = {string = " detective", color = Color(0, 0, 255, 255)},
	[ROLE_TRAITOR] = {string = " traitor", color = Color(255, 0, 0, 255)},
	[ROLE_SPECTATOR] = {color = Color(255, 255, 0, 255)}
}

net.Receive("TTT_RoleCount_Start", function()
	local innocents = net.ReadUInt(6)
	local detectives = net.ReadUInt(6)
	local traitors = net.ReadUInt(6)
	local spectators = net.ReadUInt(6)

	chat.AddText(
		color_white, "There are ",
		roles[ROLE_INNOCENT].color, innocents .. roles[ROLE_INNOCENT].string .. "(s)",
		color_white,", ",
		roles[ROLE_DETECTIVE].color, detectives .. roles[ROLE_DETECTIVE].string .. "(s)",
		color_white, " and ",
		roles[ROLE_TRAITOR].color, traitors .. roles[ROLE_TRAITOR].string .. "(s)",
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

	chat.AddText(
		color_white, "There are currently ",
		roles[ROLE_INNOCENT].color, innocents .. roles[ROLE_INNOCENT].string .. "(s)",
		color_white,", ",
		roles[ROLE_DETECTIVE].color, detectives .. roles[ROLE_DETECTIVE].string .. "(s)",
		color_white, " and ",
		roles[ROLE_TRAITOR].color, traitors .. roles[ROLE_TRAITOR].string .. "(s)",
		color_white, " this round!"
	)
end)

net.Receive("TTT_RoleCount_Wait_Spam", function()
	chat.AddText(color_white, "Please wait a few seconds before you request the role distribution again.")
end)

net.Receive("TTT_RoleCount_Wait", function()
	chat.AddText(color_white, "Please wait until the round has started.")
end)

local function PrintToChat(role, alive, endtext)
	local starttext = "A"
	if (role == ROLE_INNOCENT) then
		starttext = starttext .. "n"
	end

	if (alive ~= nil) then
		if (alive) then
			endtext = endtext .. "he was still alive."
		else
			endtext = endtext .. "he was already dead."
		end
	end

	chat.AddText(
		color_white, starttext,
		roles[role].color, roles[role].string,
		color_white, endtext
	)
end

net.Receive("TTT_RoleCount_Spectate", function()
	PrintToChat(net.ReadUInt(3), nil, " has switched to the spectators.")
end)

net.Receive("TTT_RoleCount_Leave", function()
	PrintToChat(net.ReadUInt(3), net.ReadBool(), " has left the server, ")
end)
