--
-- Base entity for all gamemode ents
-- This is basically base_lexentity but with no wire support
-- ~ Moonshine ~
--
AddCSLuaFile();
DEFINE_BASECLASS "base_gmodentity";

ENT.Type = "anim";
ENT.PrintName = "Base Moonshine Entity";
ENT.Author = "Lex Robinson";
ENT.Contact = "lexi@lexi.org.uk";
ENT.Purpose = "Abstracting away annoying features";
ENT.Spawnable = false;
ENT.DisableDuplicator = true;

-- Sandbox's player system, revamped a little
function ENT:SetPlayer(ply)
	self.Founder = ply;
	if (IsValid(ply)) then
		self:SetNWString("FounderName", ply:Nick());
		self.FounderSID = ply:SteamID64();
		-- Legacy
		self.FounderIndex = ply:UniqueID();
	else
		self:SetNWString("FounderName", "");
		self.FounderSID = "";
		self.FounderIndex = 0;
	end
end

function ENT:GetPlayer()
	if (self.Founder == nil) then
		-- SetPlayer has not been called
		return NULL;
	elseif (IsValid(self.Founder)) then
		-- Normal operations
		return self.Founder;
	end
	-- See if the player has left the server then rejoined
	local ply = player.GetBySteamID64(self.FounderSID);
	if (not IsValid(ply)) then
		-- Oh well
		return NULL;
	end
	-- Save us the check next time
	self:SetPlayer(ply);
	return ply;
end

function ENT:GetPlayerName()
	local ply = self:GetPlayer()
	if (IsValid(ply)) then
		return ply:Nick()
	end

	return self:GetNWString("FounderName")
end

-- All or nothing GetPhysicsObject
function ENT:GetValidPhysicsObject()
	local phys = self:GetPhysicsObject();
	if (not phys:IsValid()) then
		local mdl = self:GetModel();
		self:Remove();
		error(
			"No Physics Object available for entity '" .. self.ClassName ..
				"'! Do you have the model '" .. mdl .. "' installed?", 2
		);
	end
	return phys;
end
