if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_pir.vmt")
end

-- creates global var "TEAM_PIRATE" and other required things
-- TEAM_[name], data: e.g. icon, color,...
roles.InitCustomTeam(ROLE.name, { -- this creates var "TEAM_PIRATE"
		icon = "vgui/ttt/dynamic/roles/icon_pir",
		color = Color(207, 148, 68, 255)
})

local ttt_pir_win_alone = CreateConVar("ttt_pir_win_alone", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local ttt_pir_see_contractor_team = CreateConVar("ttt_pir_see_contractor_team", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicPirCVars", function(tbl)
	tbl[ROLE_PIRATE] = tbl[ROLE_PIRATE] or {}

	table.insert(tbl[ROLE_PIRATE], {cvar = "ttt_pir_win_alone", checkbox = true, desc = "Pirates can win as team if they have no live contract (Def. 0)"})
	--table.insert(tbl[ROLE_PIRATE], {cvar = "ttt_pir_see_contractor_team", checkbox = true, desc = "Pirates can see the team of the contractor (Def. 1)"})
end)

cvars.AddChangeCallback(ttt_pir_win_alone:GetName(), function(name, old, new)
	PIRATE.preventWin = not ttt_pir_win_alone:GetBool()
	PIRATE_CAPTAIN.preventWin = not ttt_pir_win_alone:GetBool()
end, "TTT2PirWinAloneCallback")

function ChooseNewCaptain()
	local pirs = {}
	for _, ply in ipairs(player.GetAll()) do
		if ply:GetSubRole() == ROLE_PIRATE_CAPTAIN and ply:Alive() then
			return
		end
		if ply:GetSubRole() == ROLE_PIRATE then
			table.insert(pirs, ply)
		end
	end

	if #pirs > 0 then
		local newCap = table.Random(pirs)
		newCap:SetRole(ROLE_PIRATE_CAPTAIN, TEAM_PIRATE)
		newCap:SetDefaultCredits()
		SendFullStateUpdate()
	end
end

function ROLE:PreInitialize()
	self.color = Color(207, 148, 68, 255)

	self.abbr = "pir" -- abbreviation
	self.defaultTeam = TEAM_PIRATE -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 2 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.unknownTeam = true -- player don't know their teammates
	self.preventWin = not ttt_pir_win_alone:GetBool()
	self.avoidTeamIcons = false

	self.conVarData = {
		pct = 0.17, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		random = 50,
		minPlayers = 7, -- minimum amount of players until this role is able to get selected
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
	}
end

function ROLE:Initialize()
	if CLIENT then
		-- Role specific language elements
		LANG.AddToLanguage("English", PIRATE.name, "Pirate")
		LANG.AddToLanguage("English", "info_popup_" .. PIRATE.name, [[You ARRR a Pirate! Search someone to fight for - earn gold and points.]])
		LANG.AddToLanguage("English", "body_found_" .. PIRATE.abbr, "This was an Pirate...")
		LANG.AddToLanguage("English", "search_role_" .. PIRATE.abbr, "This person was an Pirate!")
		LANG.AddToLanguage("English", "target_" .. PIRATE.name, "Pirate")
		LANG.AddToLanguage("English", "ttt2_desc_" .. PIRATE.name, [[The Pirate is a neutral role. He doesn’t really care about what’s good and what’s evil… 
		all that matters is, that there’s money involved. As long as another person owns the Pirate Captain’s contract, all pirates are on the same team as them.]])
		LANG.AddToLanguage("English", "hilite_win_" .. TEAM_PIRATE, "PIRATES WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.SERIALKILLER.team)[1].name
		LANG.AddToLanguage("English", "win_" .. TEAM_PIRATE, "The Pirates won! ARRRR") -- teamname
		LANG.AddToLanguage("English", "ev_win_" .. TEAM_PIRATE, "The Pirates have claimed their gold!")
		
		LANG.AddToLanguage("Italian", PIRATE.name, "Pirata")
		LANG.AddToLanguage("Italian", "info_popup_" .. PIRATE.name, [[Tu sei un Pirata! Cerca qualcuno per cui combattere - guadagna oro e punti.]])
		LANG.AddToLanguage("Italian", "body_found_" .. PIRATE.abbr, "Era un Pirata...")
		LANG.AddToLanguage("Italian", "search_role_" .. PIRATE.abbr, "Questa persona era un Pirata!")
		LANG.AddToLanguage("Italian", "target_" .. PIRATE.name, "Pirata")
		LANG.AddToLanguage("Italian", "ttt2_desc_" .. PIRATE.name, [[Il Pirata è un ruolo neutrale. Non gli interessa tanto chi è buono o cattivo… 
		tutto quello che conta è, che ci siano dei soldi. Finché un'altra persona ha il contratto del Capo Pirata, tutti i pirati sono nella sua stessa squadra.]])
		LANG.AddToLanguage("Italian", "hilite_win_" .. TEAM_PIRATE, "I PIRATI HANNO VINTO") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.SERIALKILLER.team)[1].name
		LANG.AddToLanguage("Italian", "win_" .. TEAM_PIRATE, "Il Pirata ha vinto! ARRRR") -- teamname
		LANG.AddToLanguage("Italian", "ev_win_" .. TEAM_PIRATE, "I Pirati hanno reclamato il loro oro!")

		LANG.AddToLanguage("Deutsch", PIRATE.name, "Pirat")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. PIRATE.name, [[Du bist ein Pirat! Tu dich mit jemandem zusammen und kämpfe für Gold und Punkte.]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. PIRATE.abbr, "Er war ein Pirat...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. PIRATE.abbr, "Diese Person war ein Pirat!")
		LANG.AddToLanguage("Deutsch", "target_" .. PIRATE.name, "Pirat")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. PIRATE.name, [[Piraten sind neutral. Sie kümmern sich nicht um gut und böse... das Geld muss stimmen.
		So lange eine andere Person einen Vertrag mit dem Piraten geschlossen hat, kämpft er für sein Team.]])
		LANG.AddToLanguage("Deutsch", "hilite_win_" .. TEAM_PIRATE, "PIRATES WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.SERIALKILLER.team)[1].name
		LANG.AddToLanguage("Deutsch", "win_" .. TEAM_PIRATE, "Die Piraten haben gewonnen! ARRRR") -- teamname
		LANG.AddToLanguage("Deutsch", "ev_win_" .. TEAM_PIRATE, "Die Piraten haben sich ihr Gold geholt!")
	end
end

function ROLE:GiveRoleLoadout(ply, isRoleChange)
	ChooseNewCaptain()
end

if SERVER then
	hook.Add("TTTPrepareRound", "TTT2PirPrepRound", function()
		for _, ply in ipairs(player.GetAll()) do
			ply.is_pir_master = nil
			ply.pirate_master = nil
			ply.pir_contract = nil
		end
	end)

	--pirates and master should always see their roles 
	hook.Add("TTT2SpecialRoleSyncing", "TTT2RolePirVis", function(ply, tbl)
		if ply and not ply.is_pir_master and ply:GetBaseRole() ~= ROLE_PIRATE or GetRoundState() == ROUND_POST then return end

		for pir in pairs(tbl) do
			if pir:GetBaseRole() == ROLE_PIRATE or pir.is_pir_master then
				tbl[pir] = {pir:GetSubRole(), pir:GetTeam()}
			end
		end
	end)
end