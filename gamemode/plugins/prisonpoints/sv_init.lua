--[[
	~ Prison Points Plugin ~
	~ Applejack ~
--]]


PLUGIN.Name = "Prisonpoints";
PLUGIN.Prisonpoints = {};

function PLUGIN:LoadData()
	local path, data, status, results;
	
	path = GM.LuaFolder.."/prisonpoints/"..game.GetMap()..".txt";
	if (not file.Exists(path)) then
		return
	end
	data = file.Read(path);
	status, results = pcall(glon.decode,data);
	if (status == false) then
		error("Error GLON decoding '"..path.."': "..results);
	elseif (not results) then
		return
	end
	self.Prisonpoints = results;
end

function PLUGIN:SaveData()
	local data,status,result,path;
	status, result = pcall(glon.encode,self.Prisonpoints);
	if (status == false) then
		error("["..os.date().."] Prisonpoints Plugin: Error GLON encoding prisonpoints : "..results);
	end
	path = GM.LuaFolder.."/prisonpoints/"..game.GetMap()..".txt";
	if (not result or result == "") then
		if (file.Exists(path)) then
			file.Delete(path);
		end
		return;
	end
	file.Write(path,result);
end

function PLUGIN:PlayerArrested(ply)
	if (table.Count(self.Prisonpoints) < 1) then
		player.NotifyAll("The Prisonpoints plugin is active but has no prison points set!");
		return;
	end
	local data = table.Random(self.Prisonpoints);
	ply:SetPos(data.pos);
	ply:SetAngles(data.ang);
end

local plugin = PLUGIN;
local points = plugin.Prisonpoints;
-- A command to add a player prison point.
cider.command.add("prisonpoint", "a", 1, function(ply,action)
	local pos,count;
	action = action:lower();	
	if (action == "add") then
		local pos = ply:GetPos();
		table.insert(points,{pos = pos, ang = ply:GetAngles()});
		ply:Notify("You have added a prisonpoint where you are standing.");
	elseif (action == "remove") then
		if (not table.Count(points)) then
			return false, "there are no prisonpoints!";
		end
		pos = ply:GetEyeTraceNoCursor().HitPos;
		count = 0;
		for k,data in pairs(points) do
			if ((pos - data.pos):LengthSqr() <= 65536) then
				points[k] = nil;
				count = count + 1;
			end
		end
		if (count > 0) then
			ply:Notify("You removed "..count.." prisonpoints from where you were looking, leaving "..table.Count(points).." left.");
		else
			ply:Notify("There are no prisonpoints where you are looking!");
		end
	else
		return false,"Invalid action specified!";
	end
	plugin:SaveData();
end, "Admin Commands", "<add|remove>", "Add a prisonpoint where you are standing or remove prisonpoints where you look.",true);
