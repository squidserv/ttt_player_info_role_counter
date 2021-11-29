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
	local roles = {}
	roles[ROLE_INNOCENT] = 0
	roles[ROLE_DETECTIVE] = 0
	roles[ROLE_TRAITOR] = 0

	local role
	for _, ply in pairs(plyInRound) do
		role = ply:GetRole()
		roles[role] = roles[role] + 1
	end

	net.WriteUInt(roles[ROLE_INNOCENT], 6)
	net.WriteUInt(roles[ROLE_DETECTIVE], 6)
	net.WriteUInt(roles[ROLE_TRAITOR], 6)
end

hook.Add("TTTBeginRound", "TTT_RoleCount_Start", function()
	spamProtection = {}
	plyInRound = {}
	local spectators = 0

	for _, ply in pairs(player.GetAll()) do
		if (!ply:IsSpec()) then
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
						net.WriteUInt(ply:GetRole(), 3)
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
				net.WriteUInt(ply:GetRole(), 3)
				-- Spectator Deathmatch support
				if (file.Exists("sh_spectator_deathmatch.lua", "LUA")) then
					net.WriteBool(!ply:IsGhost() and ply:Alive())
				else
					net.WriteBool(ply:Alive())
				end
			net.Broadcast()
		end
	end
end)
