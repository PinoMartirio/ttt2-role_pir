if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_cap.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(136, 81, 50, 255)

	self.abbr = "cap" -- abbreviation
	self.defaultTeam = TEAM_PIRATE -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 2 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.unknownTeam = true -- player don't know their teammates
	self.preventWin = not GetConVar("ttt_pir_win_alone"):GetBool()
	self.avoidTeamIcons = false
	self.notSelectable = true -- role cant be selected!

	self.conVarData = {
		credits = 0, -- the starting credits of a specific role
		shopFallback = SHOP_DISABLED
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_PIRATE)

	if CLIENT then
		-- Role specific language elements
		LANG.AddToLanguage("English", PIRATE_CAPTAIN.name, "Pirate Captain")
		LANG.AddToLanguage("English", "info_popup_" .. PIRATE_CAPTAIN.name, [[You ARRR a Pirate Captain! Search someone to fight for - earn gold and points.]])
		LANG.AddToLanguage("English", "body_found_" .. PIRATE_CAPTAIN.abbr, "This was an Pirate Captain...")
		LANG.AddToLanguage("English", "search_role_" .. PIRATE_CAPTAIN.abbr, "This person was an Pirate Captain!")
		LANG.AddToLanguage("English", "target_" .. PIRATE_CAPTAIN.name, "Pirate Captain")
		LANG.AddToLanguage("English", "ttt2_desc_" .. PIRATE_CAPTAIN.name, [[The Pirate Captain is a neutral role. He doesn’t really care about what’s good and what’s evil… 
		all that matters is, that there’s money involved. As long as another person owns the Pirate Captain’s contract, all pirates are on the same team as them.]])
		
		LANG.AddToLanguage("Italian", PIRATE_CAPTAIN.name, "Capo Pirata")
		LANG.AddToLanguage("Italian", "info_popup_" .. PIRATE_CAPTAIN.name, [[Tu sei un Capo Pirata! Cerca qualcuno per cui combattere - guadagna oro e punti.]])
		LANG.AddToLanguage("Italian", "body_found_" .. PIRATE_CAPTAIN.abbr, "Era un Capo Pirata...")
		LANG.AddToLanguage("Italian", "search_role_" .. PIRATE.abbr, "Questa persona era un Capo Pirata!")
		LANG.AddToLanguage("Italian", "target_" .. PIRATE_CAPTAIN.name, "Capo Pirata")
		LANG.AddToLanguage("Italian", "ttt2_desc_" .. PIRATE_CAPTAIN.name, [[Il Capo Pirata è un ruolo neutrale. Non gli interessa tanto chi è buono o cattivo… 
		tutto quello che conta è, che ci siano dei soldi. Finché un'altra persona ha il contratto del Capo Pirata, tutti i pirati sono nella sua stessa squadra.]])

		LANG.AddToLanguage("Deutsch", PIRATE_CAPTAIN.name, "Piraten Kapitän")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. PIRATE_CAPTAIN.name, [[Du bist ein Piraten Kapitän! Tu dich mit jemandem zusammen und kämpfe für Gold und Punkte.]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. PIRATE_CAPTAIN.abbr, "Er war ein Piraten Kapitän...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. PIRATE_CAPTAIN.abbr, "Diese Person war ein Piraten Kapitän!")
		LANG.AddToLanguage("Deutsch", "target_" .. PIRATE_CAPTAIN.name, "Piraten Kapitän")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. PIRATE_CAPTAIN.name, [[ Der Piraten Kapitän ist neutral. Er kümmert sich nicht um gut und böse... das Geld muss stimmen.
		So lange eine andere Person einen Vertrag mit dem Piraten Kapitän geschlossen hat, kämpfen alle Piraten für sein Team.]])
	end
end

function ROLE:GiveRoleLoadout(ply, isRoleChange)
	if not isRoleChange then
		ply:SetRole(ROLE_PIRATE, TEAM_PIRATE)
		SendFullStateUpdate()
	end
end

function ROLE:RemoveRoleLoadout(ply, isRoleChange)
	if not IsValid(ply.pir_contract) then
		return
	end

	local contract = ply.pir_contract
	local master = contract:GetOwner()
	if IsValid(master) then
		net.Start("TTT2PirContractTerminatedMaster")
		net.WriteEntity(ply)
		net.Send(master)
		master.is_pir_master = false
		ply.pirate_master = nil
	end
	contract:Remove()

	for _, pir in ipairs(player.GetAll()) do
		if pir:GetBaseRole() == ROLE_PIRATE then
			pir:UpdateTeam(TEAM_PIRATE)
		end
	end

	PIRATE.preventWin = not GetConVar("ttt_pir_win_alone"):GetBool()
	PIRATE_CAPTAIN.preventWin = not GetConVar("ttt_pir_win_alone"):GetBool()
	PIRATE.unknownTeam = false
	PIRATE_CAPTAIN.unknownTeam = false

	SendFullStateUpdate()

	ChooseNewCaptain()
end