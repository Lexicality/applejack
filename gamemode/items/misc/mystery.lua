--[[
	~°'¨¤ MYSTERY ITEM ¤¨'°~ 	
	~ Applejack ~
--]]


ITEM.Name			= "Alien Balls";
ITEM.Size			= 0;
ITEM.Cost			= 2000000;
ITEM.Model			= "models/gibs/gunship_gibs_sensorarray.mdl";
ITEM.Plural			= "Alien Ballses";
ITEM.Description	= "A pair of glittry alien balls, easily worth at least $2,000,000!"
ITEM.Store 			= true;
ITEM.Batch 			= 1;
-- Called when a player uses the item
function ITEM:onUse(player)
	player:Emote("holds aloft "..player._GenderWord.." shining pair of alien balls.");
	cider.chatBox.addInRadius(nil, "action", "The balls glitter.", player:GetPos(), GM.Config["Talk Radius"]);
	return false;
end
	
-- Called when a player drops the item.
function ITEM:onDrop(player, position, amount)
	player:Emote("drops "..player._GenderWord.." balls on the ground.");
	cider.chatBox.addInRadius(nil, "action", "The balls glitter.", player:GetPos(), GM.Config["Talk Radius"]);
	return true
end

-- Called when a player destroys the item.
function ITEM:onDestroy(player)
	player.NotifyAll(player:Name().." just DESTROYED $1,000,000 worth of shiny alien balls!!!",1);
	player:Notify("You realise you just destroyed $1,000,000 for which there is no refund, right?",1);
end
