--
-- ~ Shared Team Library ~
-- ~ Applejack ~
--
GM.Teams = {};
GM.Gangs = {};
GM.Groups = {};
GROUP_BASE = 1; -- Base team member, all other teams in this group brach off it. There can only be one.
GROUP_MERCHANT = 2; -- Sells stuff. At the moment, this is identical to TWIG.
GROUP_TWIG = 2; -- A twig below the team base. Not a gang member but at the same level
GROUP_GANGMEMBER = 2; -- A base member of a gang
GROUP_GANGBOSS = 3; -- The boss of a gang, able to demote their subordinates.

local compatMeta = {
	__index = function(self, key)
		if (key == "Group") then
			return GM.Groups[self.GroupID];
		elseif (key == "Gang") then
			return GM.Gangs[self.GangID];
		end
		return nil;
	end,
}

do
	local newgroup, newgang, newteam;
	local GROUPCOUNT, GANGCOUNT, TEAMCOUNT = 0, 0, 0

	local lastTeamID = 0;
	local function loadTeams(path, files)
		local prefix = (GANG and "    " or "   ")
		local new = "";
		local changed = "";
		for _, filename in pairs(files) do
			if (not validfile(filename) or filename == "init.lua") then
				continue;
			end

			local teamID = string.lower(string.gsub(filename, "(.*)%.lua", "%1"));
			local globalID = "TEAM_" .. string.upper(teamID);

			-- If the gamemode is reloading this will be set but there won't be
			-- anything in GM.Teams. It's vital that we maintain numeric IDs across
			-- reloads, so preserve that.
			local numericID = _G[globalID];
			if (not numericID) then
				lastTeamID = lastTeamID + 1;
				numericID = lastTeamID;
			end

			local updating = false;
			if (GM.Teams[teamID]) then
				updating = true;
				_G.TEAM = GM.Teams[teamID];
			else
				_G.TEAM = newteam();
				_G.TEAM.TeamID = numericID;
				_G.TEAM.UniqueID = teamID;
				_G.TEAM.GroupID = _G.GROUP.GroupID;
				if (_G.GANG) then
					_G.TEAM.GangID = _G.GANG.GangID;
				end
			end

			includecs(path .. filename);

			if (not TEAM.Valid) then
				_G.TEAM = nil;
				MsgN(prefix, "Canceled team ", teamID);
				continue;
			end

			if (not updating) then
				new = new .. _G.TEAM.Name .. ", ";
				table.insert(_G.GROUP.Teams, _G.TEAM);
				if (_G.GANG) then
					table.insert(_G.GANG.Teams, _G.TEAM);
				end
				if (_G.TEAM.GroupLevel == GROUP_BASE) then
					_G.GROUP.BaseTeam = _G.TEAM;
				end
				if (TEAM.Default) then
					_G.TEAM_DEFAULT = numericID;
				end
				GM.Teams[teamID] = _G.TEAM;
				_G[globalID] = numericID;
				team.SetUp(numericID, _G.TEAM.Name, _G.TEAM.Color);
				TEAMCOUNT = TEAMCOUNT + 1;
			else
				changed = changed .. _G.TEAM.Name .. ", ";
			end
			_G.TEAM = nil;
		end
		if (new ~= "") then
			MsgN(prefix, "Created teams: ", new:sub(1, -3));
		end
		if (changed ~= "") then
			MsgN(prefix, "Modified teams: ", changed:sub(1, -3));
		end
	end

	-- Loads all the teams, gangs and groups. If you are not sh_init.lua during the initial startup phase, do not call this.
	function GM:LoadTeams()
		MsgN("Applejack: Loading Teams.");
		local toSearch = {};
		for _, plugin in pairs(self.Plugins) do
			if (plugin._HasTeams) then
				table.insert(toSearch, plugin);
			end
		end
		table.sort(
			toSearch, function(a, b)
				return a.Folder < b.Folder
			end
		);

		table.insert(
			toSearch, 1,
			{Name = "the gamemode", FullPath = self.LuaFolder .. "/gamemode"}
		)

		for _, searchItem in ipairs(toSearch) do
			local path = searchItem.FullPath .. "/teams/";
			MsgN(" Looking in ", searchItem.Name);
			local _, groupFolders = file.Find(path .. "*", "LUA");
			for _, groupName in ipairs(groupFolders) do
				local groupPath = path .. groupName .. "/";
				local groupID = string.lower(groupName);
				_G.GROUP = self.Groups[groupID];
				local updating = _G.GROUP ~= nil;
				local exists = file.Exists(groupPath .. "init.lua", "LUA")

				if (not exists and not updating) then
					ErrorNoHalt("  Warning! Unknown group ", groupName, " with no init.lua!\n");
					continue;
				elseif (exists) then
					if (not _G.GROUP) then
						_G.GROUP = newgroup();
						_G.GROUP.UniqueID = groupID;
						_G.GROUP.GroupID = groupID;
					end

					includecs(groupPath .. "init.lua");
				end

				if (not _G.GROUP.Valid) then
					_G.GROUP = nil;
					MsgN("  Canceled the load of group ", groupName);
					continue;
				end

				if (not updating) then
					MsgN("  Loaded group ", _G.GROUP.Name);
					self.Groups[groupID] = _G.GROUP;
					GROUPCOUNT = GROUPCOUNT + 1;
				else
					MsgN("  Modified group ", _G.GROUP.Name);
				end

				local files, folders = file.Find(groupPath .. "*", "LUA");
				for _, gangName in ipairs(folders) do
					local gangPath = groupPath .. gangName .. "/";
					local gangID = string.lower(gangName);
					_G.GANG = self.Gangs[gangID];
					local updating = _G.GANG ~= nil;
					local exists = file.Exists(gangPath .. "init.lua", "LUA")

					if (not exists and not updating) then
						ErrorNoHalt("   Warning! Unknown gang ", gangName, " with no init.lua!\n");
						continue;
					elseif (exists) then
						if (not _G.GANG) then
							_G.GANG = newgang();
							_G.GANG.UniqueID = gangID;
							_G.GANG.GangID = gangID;
							_G.GANG.GroupID = _G.GROUP.GroupID;
						end

						includecs(gangPath .. "init.lua");
					end

					if (not _G.GANG.Valid) then
						_G.GANG = nil;
						MsgN("   Canceled the load of gang ", gangName);
						continue;
					end

					if (not updating) then
						MsgN("   Loaded gang ", _G.GANG.Name);
						self.Gangs[gangID] = _G.GANG;
						table.insert(_G.GROUP.Gangs, _G.GANG);
						GANGCOUNT = GANGCOUNT + 1;
					else
						MsgN("   Modified gang ", _G.GANG.Name);
					end
					local files = file.Find(gangPath .. "*", "LUA");
					loadTeams(gangPath, files);
					_G.GANG = nil;
				end
				loadTeams(groupPath, files);
				_G.GROUP = nil;
			end
		end
		MsgN(
			"Applejack: Loaded ", GROUPCOUNT, " groups, ", GANGCOUNT, " gangs and ",
			TEAMCOUNT, " teams.\n"
		);
		GROUPCOUNT, GANGCOUNT, TEAMCOUNT = nil;
	end

	function newteam()
		local TEAM = {}
		TEAM.Name = "Example Team";
		TEAM.Description =
			"This team is an example to demonstrate the new team system";
		TEAM.Color = color_white; -- This team shows up as white in the scoreboard / ooc
		TEAM.Salary = 200; -- Players get $200 every payday when in this team.
		TEAM.Models = {
			Male = GM.Config["Male Citizen Models"], -- This job uses the default male citzien models
			Female = GM.Config["Female Citizen Models"], -- This job uses the default female citizen models
		};
		TEAM.StartingEquipment = {
			Ammo = {}, -- This team has no ammo granted (Syntax [type] = amount, eg ["smg1"] = 200,)
			Weapons = {}, -- This team has no special weapons granted.
		}
		TEAM.PossessiveString = "The %ss"; -- A format string for this team possessing things.
		TEAM.CanMake = {}; -- Members of this team can't make anything special
		TEAM.CantUse = {}; -- There are no categories that members of this team cannot use
		TEAM.GroupLevel = GROUP_TWIG; -- This team is a twig of a group (Other options include GROUP_MERCHANT, GROUP_BASE, GROUP_GANGMEMBER and GROUP_GANGBOSS)
		TEAM.SizeLimit = 0; -- Any number of players can join this team.
		TEAM.TimeLimit = 0; -- Players can stay on this job as long as they want
		TEAM.Cooldown = 300; -- Players have to wait 5 minutes (300 seconds) befrore rejoining this team
		TEAM.Access = GM.Config["Base Access"]; -- You only need the default access to join this team.
		TEAM.Whitelist = false; -- This team does not require a whitelist to join
		TEAM.Blacklist = true; -- Players can be blacklisted from this team
		TEAM.Valid = true; -- This is a valid team
		TEAM.Default = false; -- This is not the default starting team
		TEAM.Invisible = false; -- This team is not hidden from the client's dermas
		TEAM.IsTeam = true;
		TEAM.Type = "Team";
		TEAM.SortWeight = 0;
		return setmetatable(TEAM, compatMeta);
	end
	function newgang()
		local GANG = {}
		GANG.Name = "Example Gang";
		GANG.Description = "An example gang to demonstrate the new team system";
		GANG.CanMake = {} -- Members of this gang can't make anything in particular
		GANG.CantUse = {} -- There's notthing special for these guys not to make
		GANG.StartingEquipment = {
			Ammo = {}, -- This gang has no ammo granted (Syntax {type,amount}; eg {"smg1", 200})
			Weapons = {}, -- This gang has no special weapons granted.
		}
		GANG.Whitelist = false; -- This gang does not require a whitelist to join
		GANG.Blacklist = true; -- Players can be blacklisted from this gang
		GANG.Valid = true; -- This is a valid gang
		GANG.Model = "error.mdl"; -- The model this gang will be represented by on the client
		GANG.Invisible = false -- This gang is not hidden from the client's dermas
		GANG.IsGang = true;
		GANG.Type = "Gang";
		GANG.SortWeight = 0;
		GANG.Teams = {};
		return setmetatable(GANG, compatMeta);
	end
	function newgroup()
		local GROUP = {}
		GROUP.Name = "Example Group"
		GROUP.Description = "An example group to demonstrate the new team system."
		GROUP.CanMake = {CATEGORY_CONTRABAND}; -- Members of this group can make cars and contraband
		GROUP.CantUse = {} -- There's nothing special for members of this group not to use
		GROUP.StartingEquipment = {
			Ammo = {}, -- This group has no ammo granted (Syntax {type,amount}; eg {"smg1", 200})
			Weapons = {}, -- This group has no special weapons granted.
		}
		GROUP.Whitelist = false; -- This group does not require a whitelist to join
		GROUP.Blacklist = true; -- Players can be blacklisted from this group
		GROUP.Model = "error.mdl"; -- The model this group will be represented by on the client
		GROUP.Valid = true; -- This is a valid group
		GROUP.Invisible = false; -- This group is not hidden from the client's dermas
		GROUP.IsGroup = true;
		GROUP.Type = "Group";
		GROUP.SortWeight = 0;
		GROUP.Gangs = {};
		GROUP.Teams = {};
		return GROUP;
	end
end

do
	local function genericget(id, tab)
		if (istable(id)) then
			return id;
		end
		id = string.lower(id);
		if (tab[id]) then
			return tab[id];
		end
		local ret, retLen;
		for _, data in pairs(tab) do
			local name = string.lower(data.Name);
			if (id == name) then
				return data;
			elseif (string.find(name, id)) then
				local len = name:len();
				if (not ret or len < retLen) then
					ret = data;
					retLen = len;
				end
			end
		end
		return ret;
	end
	---
	-- Gets a group by it's ID
	-- @param id The ID
	-- @return The group in question
	function GM:GetGroup(id)
		return genericget(id, self.Groups);
	end

	---
	-- Gets a gang by it's ID
	-- @param id The ID
	-- @return The gang in question
	function GM:GetGang(id)
		return genericget(id, self.Gangs);
	end

	---
	-- Gets a team by it's ID
	-- @param id The ID
	-- @return The team in question
	function GM:GetTeam(id)
		local numericID = tonumber(id);
		if (numericID) then
			for _, teamData in pairs(self.Teams) do
				if (teamData.TeamID == numericID) then
					return teamData;
				end
			end
		end
		return genericget(id, self.Teams);
	end
end

---
-- Queries a group table
-- @param id The ID of the table
-- @param key The key to ask for
-- @param default The default value to return if the key is missing.
-- @return The value from the table, or the default value.
function GM:QueryGroup(id, key, default)
	local group = self:GetGroup(id);
	if (not group or group[key] == nil) then
		return default;
	end
	return group[key];
end

---
-- Queries a gang table
-- @param id The ID of the table
-- @param key The key to ask for
-- @param default The default value to return if the key is missing.
-- @return The value from the table, or the default value.
function GM:QueryGang(id, key, default)
	local gang = self:GetGang(id);
	if (not gang) then
		return nil;
	end
	if (gang[key] == nil) then
		return default;
	end
	return gang[key];
end

local function getplayersinteams(teams)
	local res = {};
	for _, data in pairs(teams) do
		table.Add(res, team.GetPlayers(data.TeamID));
	end
	return res;
end

---
-- Gets all the players in a particular gang
-- @param id The ID of the gang in question
-- @return A table of players
function GM:GetGangMembers(id)
	local gang = self:GetGang(id);
	if (not gang) then
		error("Invalid gang ID passed!", 2);
	end
	return getplayersinteams(gang.Teams);
end

---
-- Gets all the players in a particular group
-- @param id The ID of the group in question
-- @return A table of players
function GM:GetGroupMembers(id)
	local group = self:GetGroup(id);
	if (not group) then
		error("Invalid group ID passed!", 2);
	end
	return getplayersinteams(group.Teams);
end

---
-- Gets a team by it's ID
-- @param id The ID
-- @return The team in question
function team.Get(id)
	return GM:GetTeam(id);
end

---
-- Queries a team table
-- @param id The ID of the table
-- @param key The key to ask for
-- @param default The default value to return if the key is missing.
-- @return The value from the table, or the default value.
function team.Query(id, key, default)
	local data = team.Get(id)
	if (not data or data[key] == nil) then
		return default;
	end
	return data[key];
end
