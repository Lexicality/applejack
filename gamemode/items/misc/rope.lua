--
-- ~ Rope ~
-- ~ Applejack ~
--
ITEM.Name = "Spool of Rope";
ITEM.Size = 1;
ITEM.Cost = 200;
ITEM.Model = "models/props_lab/pipesystem03d.mdl";
ITEM.Batch = 10;
ITEM.Store = true;
ITEM.Plural = "Spools of Rope";
ITEM.Description = "Can be used for tying people up"; -- Tie dem bitches up like da hoes they are
ITEM.Base = "item";

local function conditional(ply, victim, plypos, victimpos)
	return ply:IsValid() and victim:IsValid() and ply:GetPos() == plypos and
       		victim:GetPos() == victimpos;
end
local function success(ply, victim)
	victim:TieUp();
	ply:Emote("completes the final loop and pulls the knot tight");
	victim.tying.perpetrator = NULL;
	ply.tying.victim = NULL;
	gamemode.Call("PlayerTied", ply, victim);
end
local function failure(ply, victim)
	if (IsValid(victim)) then
		victim:Emote("breaks free and throws the rope to the floor.");
		GAMEMODE.Items["rope"]:Make(victim:GetPos());
		victim.tying.perpetrator = NULL;
		SendUserMessage("MS CancelTie", ply);
	end
	if (IsValid(ply)) then
		ply.tying.victim = NULL;
		SendUserMessage("MS CancelTie", victim);
	end
end

-- TODO: Ballgag item
function ITEM:onUse(ply)
	local tr = ply:GetEyeTraceNoCursor();
	local victim = tr.Entity;
	-- Validity checks
	if (IsPlayer(victim._Player)) then
		victim = victim._Player;
	elseif (not IsPlayer(victim)) then
		ply:Notify("You must be looking at a player to tie them up!", NOTIFY_ERROR);
		return false;
	end
	-- Distance/direction tests
	if (tr.StartPos:Distance(tr.HitPos) > 128) then
		ply:Notify("You must be closer than that!", NOTIFY_ERROR);
		return false;
	end
	-- Activity tests
	if (not ply:Alive()) then
		ply:Notify("Why're you trying to tie up corpses you sick fuck", NOTIFY_ERROR);
		return false;
	elseif (IsValid(ply.tying.victim)) then
		ply:Notify("You are already tying someone up!", NOTIFY_ERROR);
		return false;
	elseif (IsValid(victim.tying.perpetrator)) then
		ply:Notify("That person is already being tied up!", NOTIFY_ERROR);
		return false;
	elseif (victim:Tied()) then
		ply:Notify("They're already tied up!", NOTIFY_ERROR);
		return false;
	end
	-- Gamemode tests
	if (not gamemode.Call("PlayerCanTie", ply, victim)) then
		return false;
	end
	-- Add RP so people don't have to
	ply:Emote("grabs " .. victim:Name() .. "'s arms and starts tying them up");
	-- Make note
	ply.tying.victim = victim;
	victim.tying.perpetrator = ply;
	-- Tell the people involved
	SendUserMessage("MS DoTie", ply);
	SendUserMessage("MS BeTie", victim);
	-- Set up a timer to validate it
	timer.Conditional(
		ply:UniqueID() .. " Tying Timer", MS.Config["Tying Timeout"], conditional,
		success, failure, ply, victim, ply:GetPos(), victim:GetPos()
	);
	-- Use up the item
	return true;
end
