-- author "Zaratusa"
-- contact "http://steamcommunity.com/profiles/76561198032479768"

AddCSLuaFile("cl_init.lua")

util.AddNetworkString("TTT_RoleCount_Start")
util.AddNetworkString("TTT_RoleCount_Say")
util.AddNetworkString("TTT_RoleCount_Wait")
util.AddNetworkString("TTT_RoleCount_Wait_Spam")
util.AddNetworkString("TTT_RoleCount_Spectate")
util.AddNetworkString("TTT_RoleCount_Leave")

local ChatCommands = {
	"!roles",
	"/roles",
	"roles"
}

local plyInRound = {} -- the players that were active at round start

local spamProtection = {}
local waitTime = 20 -- time before one of the chat commands can be used again

local function WriteRoleDistribution()
	local teams = {}
	teams[ROLE_TEAM_INNOCENT] = #player.GetTeamPlayers(ROLE_TEAM_INNOCENT, false, false)
	teams[ROLE_TEAM_DETECTIVE] = #player.GetTeamPlayers(ROLE_TEAM_DETECTIVE, false, false)
	teams[ROLE_TEAM_TRAITOR] = #player.GetTeamPlayers(ROLE_TEAM_TRAITOR, false, false)

	local indep = #player.GetTeamPlayers(ROLE_TEAM_INDEPENDENT, false, false)
	local monster = #player.GetTeamPlayers(ROLE_TEAM_MONSTER, false, false)
	local jester = #player.GetTeamPlayers(ROLE_TEAM_JESTER, false, false)
	teams[ROLE_TEAM_INDEPENDENT] = indep + monster + jester

	net.WriteUInt(teams[ROLE_TEAM_INNOCENT], 6)
	net.WriteUInt(teams[ROLE_TEAM_DETECTIVE], 6)
	net.WriteUInt(teams[ROLE_TEAM_TRAITOR], 6)
	net.WriteUInt(teams[ROLE_TEAM_INDEPENDENT], 6)
end

hook.Add("TTTBeginRound", "TTT_RoleCount_Start", function()
	spamProtection = {}
	plyInRound = {}
	local spectators = 0

	for _, ply in pairs(player.GetAll()) do
		if (not ply:IsSpec()) then
			plyInRound[ply:EntIndex()] = ply
		else
			spectators = spectators + 1
		end
	end

	net.Start("TTT_RoleCount_Start")
		WriteRoleDistribution()
		net.WriteUInt(spectators, 6)
	net.Broadcast()
end)

hook.Add("PlayerSay", "TTT_RoleCount_Say", function(ply, text)
	if (table.HasValue(ChatCommands, string.lower(text))) then
		if (GetRoundState() == ROUND_ACTIVE) then
			local index = ply:EntIndex()
			local CurTime = CurTime()
			if (spamProtection[index] == nil or spamProtection[index] <= CurTime) then
				spamProtection[index] = CurTime + waitTime

				net.Start("TTT_RoleCount_Say")
					WriteRoleDistribution()
			else
				net.Start("TTT_RoleCount_Wait_Spam")
			end
		else
			net.Start("TTT_RoleCount_Wait")
		end
		net.Send(ply)

		return ""
	end
end)

local nextCheck = 0
hook.Add("Think", "TTT_CheckForceSpectator", function()
	if (nextCheck <= CurTime() and GetRoundState() == ROUND_ACTIVE) then
		nextCheck = CurTime() + 2 -- only check all 2 seconds
		for _, ply in pairs(player.GetAll()) do
			if (ply:GetForceSpec()) then
				local index = ply:EntIndex()
				if (plyInRound[index] ~= nil) then
					plyInRound[index] = nil

					net.Start("TTT_RoleCount_Spectate")
						net.WriteUInt(ply:GetRoleTeam(), 3)
					net.Broadcast()
				end
			end
		end
	end
end)

hook.Add("PlayerDisconnected", "TTT_RoleCount_Leave", function(ply)
	if (GetRoundState() == ROUND_ACTIVE) then
		local index = ply:EntIndex()
		if (plyInRound[index] ~= nil) then
			plyInRound[index] = nil

			net.Start("TTT_RoleCount_Leave")
				net.WriteUInt(ply:GetRoleTeam(), 3)
				-- Spectator Deathmatch support
				if (file.Exists("sh_spectator_deathmatch.lua", "LUA")) then
					net.WriteBool(not ply:IsGhost() and ply:Alive())
				else
					net.WriteBool(ply:Alive())
				end
			net.Broadcast()
		end
	end
end)
