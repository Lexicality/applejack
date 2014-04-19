--[[
	~ Note Entity ~ Serverside ~
	~ Applejack ~
--]]

includecs("shared.lua");
AddCSLuaFile("cl_init.lua");

-- This is called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_lab/clipboard.mdl");
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	-- Get the physics object of the entity.
	local physicsObject = self:GetPhysicsObject();

	-- Check if the physics object is a valid entity.
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end
end

-- A function to set the text of the note.
local linelength = 30;
function ENT:SetText(text)
	local lines, pos = {}, 1;

	local words = text:sub(pos, pos + linelength);
	while (words ~= "") do
		lines[#lines+1] = words;
		pos = pos + linelength + 1;
		words = text:sub(pos, pos + linelength);
	end

	for i, words in pairs(lines) do
		self:SetNWString("text_" .. i, words);
	end
end

-- Cause notes to slowly fade away
ENT.NextFade = 0;
function ENT:Think()
	local time = CurTime()
	if (self.NextFade > time) then return; end
	local r,g,b,a = self:GetColor();
	a = a - 1
	if (a > 0) then
		self.NextFade = time + GM.Config["Note Fade Speed"];
		self:SetColor(r,g,b,a);
	else
		self:Remove();
	end
end
