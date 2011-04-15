--[[
Name: "sh_jobs.lua".
	~ Applejack ~
--]]
--[[
--defaults
-- If you put any entry to nil, like the citizen does, it will use the values below instead.
male_model_string = GM.Config["Male Citizen Models"]
female_model_string = GM.Config["Female Citizen Models"]
description_string = "N/A."
salary_int = 0
maxplayers_int = 0 --(0 = no limit)
access_string = nil
blacklistable_bool = false
canmake_table = {CATEGORY_VEHICLES,CATEGORY_CONTRABAND}
cantuse_table = {}
timelimit_table = {0,5} --{max job time, time before rejoin of job}
loadout_table = nil
ammo_table = nil
TEAM_GENERIC = cider.team.add("name", Color(255, 255, 255), male_model_string, female_model_string,
	{gang = 0,acces="",leve=1, group = GROUP_GENERIC},description_string, salary_int, maxplayers_int, access_string, blacklistable_bool,	
	canmake_table,cantuse_table,timelimit_table,loadout_table,ammo_table)
access:
b = boss - can demote members of the same level. Restricted to a gang if used on a gang member
d = demote members of lower level. Restricted to a gang if used on a gang member
g = can give/take ents to/from gang
D = underlings can vote to depose 
M = All group-to-group transitions must go through this.
]]
--[[
	NOTE:
		THE ORDER IN WHICH TEAMS ARE IN HERE IS THE ORDER IN WHICH THEY APPEAR ON THE SCOREBOARD AND JOB MENU
		
	RATHER THAN PUTTING JOBS THAT REQUIRE PLUGINS IN THE PLUGIN FOLDER WHERE THEY MIGHT GET MISSED, PUT THEM HERE WITH IFS.
	This is so order may be maintained and all jobs be modified at once.
]]
cider.team.gangs = {}
if (GM or GAMEMODE):GetPlugin("officials") then
	local gangs = {}
	gangs[0] = {"The Officials","models/player/breen.mdl","Enough red tape to drown a continent"}
	gangs[1] = {"The Police","models/player/riot.mdl","Less talk, more action!"}
	GROUP_OFFICIALS 		= cider.team.addGroup("Officials","Join the force for 'Public Good', maintaining law and order.","P")
	TEAM_MAYOR 				= cider.team.add("Mayor", Color(0, 0, 255), "models/player/breen.mdl", "models/player/mossman.mdl",
											{gang = 1, access = "bdgeD", level = 3, group = GROUP_OFFICIALS},"Runs the city and keeps it in shape.", 300, 1, nil, true,
											nil,{CATEGORY_WEAPONS,CATEGORY_ILLEGAL_GOODS,CATEGORY_ILLEGAL_WEAPONS,CATEGORY_POLICE_WEAPONS,CATEGORY_EXPLOSIVES},{0,10}
							)
	TEAM_POLICECOMMANDER 	= cider.team.add("Police Commander", Color(0, 10, 255), "models/player/urban.mdl", "models/player/urban.mdl",
											{gang = 1, access = "deD", level = 3, group = GROUP_OFFICIALS},"Controls the police and criminal justice.", 300, 1, nil, true,
											nil,{CATEGORY_ILLEGAL_GOODS,CATEGORY_EXPLOSIVES},{60,10},{"cider_glock18","cider_baton"},{{"pistol",60},{"smg1",120}}
							)
	TEAM_POLICEOFFICER 		= cider.team.add("Police Officer", Color(100, 155, 255), "models/player/riot.mdl", "models/player/riot.mdl",
											{gang = 1, access = "", level = 2, group = GROUP_OFFICIALS},"Maintains the city and arrests criminals.", 250, 15, nil, true,
											nil,{CATEGORY_ILLEGAL_GOODS,CATEGORY_ILLEGAL_WEAPONS,CATEGORY_EXPLOSIVES},nil,{--"cider_glock18",
																																		"cider_baton"},{{"pistol",60}}
							)
	TEAM_QUARTERMASTER		= cider.team.add("Quartermaster", Color(100,200,255),{"models/player/Hostage/Hostage_02.mdl","models/player/Hostage/Hostage_03.mdl"},{"models/player/Hostage/Hostage_02.mdl","models/player/Hostage/Hostage_03.mdl"},
											{gang = 0, access = "", level = 2, group = GROUP_OFFICIALS},"Supplies the police with their needs", 200,1,nil,true,
											{CATEGORY_VEHICLES,CATEGORY_CONTRABAND,CATEGORY_WEAPONS,CATEGORY_POLICE_WEAPONS,CATEGORY_AMMO},{CATEGORY_ILLEGAL_GOODS,CATEGORY_ILLEGAL_WEAPONS},{10,5}
							)
	TEAM_SECRETARY			= cider.team.add("Secretary",Color(50,200,200),{"models/player/Hostage/Hostage_01.mdl","models/player/Hostage/Hostage_04.mdl"},{"models/player/Hostage/Hostage_01.mdl","models/player/Hostage/Hostage_04.mdl"},
											{gang = 0, access = "", level = 1, group = GROUP_OFFICIALS},"Maintains public relations and does misc jobs",200,nil,nil,nil,
											nil,{CATEGORY_ILLEGAL_GOODS,CATEGORY_ILLEGAL_WEAPONS}
							)
table.insert(cider.team.gangs,gangs)
end

--citizens
local gangs = {}
gangs[0] = {"The Civilians","models/player/Group01/male_07.mdl","Keep me out of this!"}
GROUP_CIVILIANS = cider.team.addGroup("Civilians", "Join the ordinary and generally law-abiding civilians")
TEAM_SUPPLIER 			= cider.team.add("Supplier", Color(255, 200, 50),"models/player/Group02/Male_04.mdl","models/player/Group02/Female_04.mdl",
										{gang = 0, access = "", level = 2, group = GROUP_CIVILIANS},"Sells misc stuff that no one uses much but occasionally needs.",100,6,nil,true,
										{CATEGORY_VEHICLES,CATEGORY_CONTRABAND,CATEGORY_MISC,CATEGORY_PACKAGING},nil,nil--,{"weapon_crowbar"}
						)
TEAM_BUILDER 			= cider.team.add("Builder",Color(90,230,20),"models/player/barney.mdl","models/player/barney.mdl",
										{gang = 0, access = "", level = 2, group = GROUP_CIVILIANS},"Builds props for $150 per prop, non-refundable. 15 Minutes of usage max, 15 props max.",50,2,"pE",true,
										nil,nil,{15,15}	
						)
TEAM_ARMSDEALER 		= cider.team.add("Arms Dealer", Color(150, 25, 25), "models/player/Group02/male_03.mdl", "models/player/Group02/Female_03.mdl",
										{gang = 0, access = "", level = 2, group = GROUP_CIVILIANS},"Deals weapons to the city's inhabitants.", 100, 2, nil, true,
										{CATEGORY_VEHICLES,CATEGORY_CONTRABAND,CATEGORY_WEAPONS,CATEGORY_AMMO},nil,{10,10}
						)
if (GM or GAMEMODE):GetPlugin("hunger") then
TEAM_CHEF 				= cider.team.add("Chef", Color(255, 125, 200), "models/player/group02/male_02.mdl", "models/player/group02/female_07.mdl",
										{gang = 0, access = "", level = 2, group = GROUP_CIVILIANS},"Deals food to the city's inhabitants.", 150, 6, nil, true,
										{CATEGORY_VEHICLES,CATEGORY_CONTRABAND,CATEGORY_FOOD}
						)
end						
TEAM_DOCTOR 			= cider.team.add("Doctor", Color(125, 225, 150), "models/player/Group02/male_08.mdl", "models/player/Group02/Female_02.mdl",
										{gang = 0, access = "", level = 2, group = GROUP_CIVILIANS},"Deals medical supplies to the city's inhabitants.", 150, 6, "h", true,
										{CATEGORY_VEHICLES,CATEGORY_CONTRABAND,CATEGORY_DRUGS}
						)
TEAM_CITIZEN 			= cider.team.add("Citizen", Color(25, 150, 25), nil, nil,
										{gang = 0, access = "M", level = 1, group = GROUP_CIVILIANS},"A regular Citizen living in the city.", 200, nil, nil, nil, nil,{CATEGORY_ILLEGAL_GOODS,CATEGORY_ILLEGAL_WEAPONS,CATEGORY_EXPLOSIVES,CATEGORY_POLICE_WEAPONS}
						)
table.insert(cider.team.gangs,gangs)
-----------------------------
--	Dissidents
-----------------------------
local gangs = {}
gangs[0] = {"The Underground","models/player/Group03/Male_07.mdl","FUK DA POLIC"}
GROUP_UNDERGROUND 		= cider.team.addGroup("Underground","Join the underground for more fun, but harsher treatment if caught.")
TEAM_ROGUELEADER		= cider.team.add("Rogue Leader", Color(220,50,50),"models/player/leet.mdl","models/player/leet.mdl",
										{gang = 1, access = "bdgeD", level = 3, group = GROUP_UNDERGROUND},"Leader of the Rogues",250,1,nil,true
						)
TEAM_ROGUE				= cider.team.add("Rogue", Color(220,90,50), "models/player/guerilla.mdl","models/player/guerilla.mdl",
										{gang = 1, access = "", level = 2, group = GROUP_UNDERGROUND},"A member of the Rogues gang",225,10,nil,true
						)
gangs[1] = {"The Rogues", "models/player/guerilla.mdl","Lean, mean, red machines!"}
TEAM_RENEGADELEADER		= cider.team.add("Renegade Leader", Color(200,140,40),"models/player/arctic.mdl","models/player/arctic.mdl",
										{gang = 2, access = "bdgeD", level = 3, group = GROUP_UNDERGROUND},"Leader of the Renegades",250,1,nil,true
						)
TEAM_RENEGADE			= cider.team.add("Renegade", Color(220,140,15), "models/player/phoenix.mdl","models/player/phoenix.mdl",
										{gang = 2, access = "", level = 2, group = GROUP_UNDERGROUND},"A member of the Regegades gang",225,10,nil,true
						)
gangs[2] = {"The Renegades", "models/player/phoenix.mdl","We might not be pretty, but we'll kick your asses!"}
TEAM_BLACKMARKETDEALER 	= cider.team.add("Black Market Dealer", Color(125, 125, 125), "models/player/Group03m/Male_04.mdl","models/player/Group03m/Female_04.mdl",
										{gang = 0, access = "", level = 2, group = GROUP_UNDERGROUND},"Deals illegal goods.", 100, 2, nil, true,
										{CATEGORY_VEHICLES,CATEGORY_EXPLOSIVES,CATEGORY_CONTRABAND,CATEGORY_POLICE_WEAPONS,CATEGORY_ILLEGAL_GOODS,CATEGORY_ILLEGAL_WEAPONS,CATEGORY_AMMO},nil,{10,10}
						)
local rebelsf,rebelsm = {	"models/player/Group03/Female_01.mdl",
							"models/player/Group03/Female_02.mdl",
							"models/player/Group03/Female_03.mdl",
							"models/player/Group03/Female_04.mdl",
							"models/player/Group03/Female_06.mdl",
							"models/player/Group03/Female_07.mdl"
						},
						{	"models/player/Group03/Male_01.mdl",
							"models/player/Group03/Male_02.mdl",
							"models/player/Group03/Male_03.mdl",
							"models/player/Group03/Male_04.mdl",
							"models/player/Group03/Male_05.mdl",
							"models/player/Group03/Male_06.mdl",
							"models/player/Group03/Male_07.mdl",
							"models/player/Group03/Male_08.mdl",
							"models/player/Group03/Male_09.mdl"
						}
TEAM_REBEL			= cider.team.add("Rebel", Color(180,180,180), rebelsm,rebelsf,
										{gang = 0, access = "", level = 1, group = GROUP_UNDERGROUND},
										"Unorganised Small-Time Rebel, more likely to get a parking fine than GTA.",75,15, nil, true
					)
table.insert(cider.team.gangs,gangs)
--default REQUIRED
TEAM_DEFAULT = TEAM_CITIZEN