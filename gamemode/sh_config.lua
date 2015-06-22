--[[
	~ Shared Configuration ~
	~ Applejack ~
--]]
local config = {};

-- Player Defaults
config["Default Money"]				= 0; -- The money that each player starts with.
config["Default Job"]				= "Citizen"; -- The job that each player starts with.
config["Default Clan"]				= ""; -- The clan that each player belongs to by default.
config["Inventory Size"]			= 40; -- The default inventory size.
config["Default Access"]			= ""; -- The access flags that each player begins with.

-- Command
config["Base Access"]				= "b"; -- The flag that represents all users. Do not change this.
config["Command Prefix"]			= "/"; -- The prefix that is used for chat commands.
config["Maximum Notes"]				= 2; -- The maximum amount of notes a player can write.
config["Advert Cost"]				= 60; -- The money that it costs to advertise.
config["Advert Timeout"]			= 150 -- How many seconds between adverts
config["OOC Timeout"]				= 10 -- How many seconds between OOC messages
config["Item Timer"]				= 7 -- How many seconds between item uses
config["Item Timer (S)"]			= 20 -- How many seconds between specific item uses
config["Note Fade Speed"]			= 2.353 -- How many seconds to wait between each fade tick. (2.353 roughly = 10mins)

-- Door related things
config["Door Cost"]					= 150; -- The money that it costs to purchase a door.
config["Door Tax"]					= true; -- Whether door taxing is be enabled.
config["Door Tax Amount"]			= 50; -- The amount of money a player is charged in tax per door.
config["Maximum Doors"]				= 5; -- The maximum amount of doors a player can own.
config["Jam Time"]					= 60 -- How many seconds a door is jammed open for
config["Door Autoclose Time"]		= 10 -- How many seconds a door should autoshut after

-- Player Stuff
config["Walk Speed"]				= 150; -- The speed that players walk at.
config["Run Speed"]					= 275; -- The speed that players run at.
config["Incapacitated Speed"]		= 100; -- The speed arrested/tied/carrying players walk/run at.
config["Jump Power"]				= 160; -- Player's jump power. Don't mess with it unless you know what you're doing
config["Spawn Time"]				= 30; -- The time that a player has to wait before they can spawn again (seconds).
config["Bleed Time"]				= 5; -- The time that a player bleeds for when they get damaged.
config["Knock Out Time"]			= 30; -- The time that a player gets knocked out for (seconds).
config["Sleep Waiting Time"]		= 5; -- The time that a player has to stand still for before they can fall asleep (seconds).
config["Arrest Time"]				= 300; -- The time that a player is arrested for (seconds).
config["Earning Interval"]			= 300; -- The interval that players receive money from their contraband (seconds).
config["Search Warrant Expire Time"]= 60; -- The time that a player's search warrant expires (seconds) (set to 0 for never).
config["Arrest Warrant Expire Time"]= 300; -- The time that a player's arrest warrant expires (seconds) (set to 0 for never).

-- Unused entries
config["Death Penalty"]				= 2; -- The percentage of money players lose when they die.
config["Rope struggles"]			= 5 -- How many 'struggles' it takes for you to undo your rope
config["Tying Struggles"]			= 1 -- How many struggles it takes to get out of being tied up
config["Tying Struggles Timeout"]	= 30 -- How many seconds it takes for your struggle meter to fill

-- Voice
config["Local Voice"]				= true; -- Players can only hear a player's voice if they are near them.
config["Talk Radius"]				= 256; -- The radius of each player that other players have to be in to hear them talk (units).

-- Damage
config["Scale Ragdoll Damage"]		= 1; -- How much to scale ragdolled player damage by.
config["Scale Head Damage"]			= 5; -- How much to scale head damage by.
config["Scale Chest Damage"]		= 2; -- How much to scale chest damage by.
config["Scale Limb Damage"]			= 0.75; -- How much to scale limb damage by.
config["Anti propkill"]				= true -- Disables damage recieved from prop_physics', unless it's fall damage.

-- Other
config["Website URL"]				= "www.ventmob.net"; -- The website URL drawn at the bottom of the screen.
config["Cleanup Decals"]			= true; -- Whether or not to automatically cleanup decals every minute.
config["Model Choices Timeout"]		= 30 -- Number of seconds to wait before reconnecting if model choices aren't sent.
config["Autokick time"]				= 15 * 60 -- Number of seconds a player has to do something in to avoid being kicked

-- SWEP related
config["Lockpick Break Chance"]		= 0.01; -- The probaility to add to the lockpick snapping on a hit for each lock successfully picked.
config["Maximum Lockpick Hits"]		= 30; -- The maximum amount of hits a lock takes to pick
config[TYPE_LARGE]					= 1 --Number of 'big' weapons that can be carried at once. Putting this above 1 will provide strange results, so don't.
config[TYPE_SMALL]					= 2 --Number of 'small' weapons that can be carried at once

-- Plugins
config["Officials Contraband"]		= true; -- Whether city officials, i.e. City Admin, CP get contraband payments.
config["Need Warrant"]				= false; -- Whether city officials need warrants to destroy contraband.
config["Police Kill Drop"]			= true -- Whether or not weapons should drop when a player is killed by the police.

config["Hunger Minutes"]			= 30 -- The number of minutes it takes before your hunger is full.
config["Hunger Damage"]				= 5 -- The amount of damage a second you are dealt while starving
config["Hunger Death"]				= true -- Whether or not you can starve to death

config["Stamina Drain"]				= 0.35 -- The amount of stamina lost every 0.1 seconds while running
config["Stamina Restore"]			= 0.15 -- The amount of stamina restored every 0.1 seconds while not running.

config["Car Doors"]					= true -- whether or not you must be looking at a car door to gain entry

-- Props
config["Prop Limit"]				= 30 -- The amount of props donators can spawn
config["Builder Prop Limit"]		= 15 -- The amount of props builders can spawn
config["Builder Prop Cost"]			= 100 -- The price of each prop a builder spawns
config["Maximum Pickup Distance"]   = 500 -- The maximum distance a prop can be picked up from

-- Job related
config["Master Race"]				= true -- All group changes must go through one base class
config["Minimum to demote"]			= 5 -- Minimum players in a gang before the leader can demote people from it
config["Minimum to mutiny"]			= 4 -- Minimum players in a gang before the leader can be mutinied against
config["Mutiny Percentage"]			= 0.75 -- Minimum percentage of positive mutinies

-- Tying System
config["Tying Timeout"]				= 5 -- How many seconds it takes to tie someone up
config["UnTying Timeout"]			= 5 -- How many seconds it takes to untie someone

-- Tables
config["Spawnable Containers"]	={
	["models/props/de_train/lockers_long.mdl"] 					= {100,"Row of lockers"},
	["models/props_c17/furnituredrawer001a.mdl"] 				= {30,"Chest of Drawers"},
	["models/props/de_inferno/furnituredrawer001a.mdl"] 		= {30,"Chest of Drawers"},
	["models/props_lab/partsbin01.mdl"] 						= {10,"Chest of Drawers"},
	["models/props_c17/furnituredrawer003a.mdl"] 				= {20,"Chest of Drawers"},
	["models/props_lab/filecabinet02.mdl"] 						= {20,"Filing Cabinet"},
	["models/props_wasteland/controlroom_filecabinet001a.mdl"]	= {20,"Filing Cabinet"},
	["models/props_wasteland/controlroom_filecabinet002a.mdl"]	= {30,"Filing Cabinet"},
	["models/props/cs_office/file_cabinet1.mdl"] 				= {20,"Filing Cabinet"},
	["models/props/cs_office/file_cabinet1_group.mdl"] 			= {50,"Filing Cabinet"},
	["models/props/cs_office/file_cabinet2.mdl"]	 			= {20,"Filing Cabinet"},
	["models/props/cs_office/file_cabinet3.mdl"] 				= {15,"Filing Cabinet"},
	["models/props/de_nuke/file_cabinet1_group.mdl"] 			= {50,"Filing Cabinet"},
	["models/props_wasteland/controlroom_storagecloset001a.mdl"]= {60,"Storage Closet"},
	["models/props_wasteland/controlroom_storagecloset001b.mdl"]= {60,"Storage Closet"},
	["models/props_interiors/furniture_vanity01a.mdl"] 			= {5,"Dressing Table"},
	["models/props/cs_militia/footlocker01_closed.mdl"] 		= {40,"Foot Locker"},
	["models/props/de_prodigy/ammo_can_02.mdl"] 				= {20,"Foot Locker"},
	["models/props_c17/briefcase001a.mdl"] 						= {20,"Briefcase"},
	["models/props_junk/trashdumpster01a.mdl"] 					= {40,"Dumpster"},
	["models/props_c17/furnituredresser001a.mdl"] 				= {40,"Wardrobe"},
	["models/props_c17/suitcase001a.mdl"] 						= {20,"Suitcase"},
	["models/props_c17/suitcase_passenger_physics.mdl"] 		= {10,"Suitcase"},
	["models/props/de_train/lockers001a.mdl"] 					= {40,"Couple of Lockers"},
	["models/props_c17/lockers001a.mdl"]						= {40,"Couple of Lockers"},
	["models/props_interiors/furniture_cabinetdrawer01a.mdl"] 	= {20,"Cabinet"},
	["models/props_interiors/furniture_cabinetdrawer02a.mdl"] 	= {20,"Dresser"},
	["models/props_c17/furniturefridge001a.mdl"] 				= {30,"Fridge"},
	["models/props_wasteland/kitchen_fridge001a.mdl"] 			= {60,"Fridge"},
	["models/props/cs_militia/refrigerator01.mdl"] 				= {50,"Fridge"},
	["models/props_foliage/tree_stump01.mdl"] 					= {40,"Stump"},
	["models/props_c17/furnituredrawer002a.mdl"] 				= {10,"Table"},
	["models/props_junk/trashbin01a.mdl"] 						= {10,"Bin"},
} -- Models that become containers when spawned

config["Back Weapons"] = {
	[TYPE_LARGE] = true
} -- Which weapons go on your back when not deployed.
config["Weapon Timers"] = {
	["deploytime"] = {
		[TYPE_LARGE] = 2,
		[TYPE_SMALL] = 1
	},
	["redeploytime"] = {
		[TYPE_LARGE] = 30,
		[TYPE_SMALL] = 20
	},
	["reholstertime"] = {
		[TYPE_LARGE] = 10,
		[TYPE_SMALL] = 5
	},
	["deploymessage"] = { -- 1 gun type, 2 gender
		[TYPE_LARGE] = "pulls a %s off %s back",
		[TYPE_SMALL] = "pulls a %s out of %s pocket"
	},
	["equiptime"] = {
		[TYPE_LARGE] = 5,
		[TYPE_SMALL] = 2
	},
	["Equip Message"] = {
		["Start"] = "starts rummaging through %s backpack",
		["Final"] = "pulls out a %s gun and puts %s backpack back on",
		["Abort"] = "gives up and pulls %s backpack back on",
		["Plugh"] = "slides the %s gun back into %s backpack and puts it back on"
		--[[
		 -- 1 gun type, 2 gender
		[TYPE_LARGE] = "Pulls out a %s and puts %s backpack back on",
		[TYPE_SMALL] = "Pulls out a %s and puts %s backpack back on"]]
	},
	["holstermessage"] = {	 -- 1 gun type, 2 gender
		[TYPE_LARGE] = "puts the %s back on %s back",
		[TYPE_SMALL] = "puts the %s back in %s pocket"
	}
} --
config["Acceptable Datastreams"] = {
	"WhatTheFuckAreYouDoing?!",
	"cider_Laws"
}
config["sv_tags"] = {
	"applejack", -- Please always leave this in
	"rp",
	"roleplay",
	"semi-serious",
	"semi-srsrp",
	"semi-srs",
	"cider" -- Never forget your origins
} -- tags you want added to the sv_tags convar
config["Usable Commands"] = {
	"demote","blacklist","unblacklist","giveaccess","takeaccess","giveitem","save","pm","job","clan","gender","laws","ooc","looc",
	"knockout","knockoutall","wakeup","wakeupall","arrest","unarrest","spawn","awarrant","tie","untie","a","m","s"
}; -- Commands that players may use at any time
config["Default Inventory"] = {
	health_vial = 5,
	chinese_takeout = 5
}; -- The inventory that each player starts with.
config["Contraband"] = {
	cider_drug_lab = {maximum = 5, money = 50, name = "Drug Lab", health = 100, energy = 5},
	cider_money_printer = {maximum = 2, money = 150, name = "Money Printer", health = 100, energy = 5}
}; -- The different types of contraband.
config["Male Citizen Models"] = {
	"models/player/Group01/male_01.mdl",
	"models/player/Group01/male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/male_04.mdl",
	"models/player/Group01/male_05.mdl",
	"models/player/Group01/male_06.mdl",
	"models/player/Group01/male_07.mdl",
	"models/player/Group01/male_08.mdl",
	"models/player/Group01/male_09.mdl"
}; -- The male citizen models.
config["Female Citizen Models"] = {
	"models/player/Group01/female_01.mdl",
	"models/player/Group01/female_02.mdl",
	"models/player/Group01/female_03.mdl",
	"models/player/Group01/female_04.mdl",
	"models/player/Group01/female_06.mdl",
	"models/player/Group01/female_07.mdl"
}; -- The male citizen models.
config["Banned Props"] = {
	"models/props_phx/empty_barrel.mdl",
	"models/props_c17/consolebox01a.mdl",
	"models/props_combine/combine_mine01.mdl",
	"models/props_c17/gravestone_coffinpiece002a.mdl",
	"models/props_c17/gravestone_coffinpiece001a.mdl",
	"models/props_borealis/mooring_cleat01.mdl",
	"models/props_canal/canal_bridge02.mdl",
	"models/props_canal/canal_bridge01.mdl",
	"models/props_canal/canal_bridge03a.mdl",
	"models/props_canal/canal_bridge03b.mdl",
	"models/props_wasteland/cargo_container01.mdl",
	"models/props_wasteland/cargo_container01c.mdl",
	"models/props_wasteland/cargo_container01b.mdl",
	"models/props_c17/column02a.mdl",
	"models/cranes/crane_frame.mdl",
	"models/props_c17/fence04a.mdl",
	"models/props_c17/fence03a.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_combine/weaponstripper.mdl",
	"models/props_combine/combinetrain01a.mdl",
	"models/props_combine/combine_train02a.mdl",
	"models/props_combine/combine_train02b.mdl",
	"models/props_trainstation/train005.mdl",
	"models/props_trainstation/train004.mdl",
	"models/props_trainstation/train003.mdl",
	"models/props_trainstation/train001.mdl",
	"models/props_trainstation/train001.mdl",
	"models/props_wasteland/buoy01.mdl",
	"models/props/cs_militia/coveredbridge01_top.mdl",
	"models/props/cs_militia/coveredbridge01_left.mdl",
	"models/props/cs_militia/coveredbridge01_bottom.mdl",
	"models/props/cs_militia/silo_01.mdl",
	"models/props/cs_assault/money.mdl",
	"models/props/cs_assault/dollar.mdl",
	"models/props/de_nuke/ibeams_bombsitea.mdl",
	"models/props/de_nuke/fuel_cask.mdl",
	"models/props/de_nuke/ibeams_bombsitec.mdl",
	"models/props/de_nuke/ibeams_bombsite_d.mdl",
	"models/props/de_nuke/ibeams_ctspawna.mdl",
	"models/props/de_nuke/ibeams_ctspawnb.mdl",
	"models/props/de_nuke/ibeams_ctspawnc.mdl",
	"models/props/de_nuke/ibeams_tspawna.mdl",
	"models/props/de_nuke/ibeams_tspawnb.mdl",
	"models/props/de_nuke/ibeams_tunnela.mdl",
	"models/props/de_nuke/ibeams_tunnelb.mdl",
	"models/props/de_nuke/storagetank.mdl",
	"models/props/de_nuke/truck_nuke.mdl",
	"models/props/de_nuke/powerplanttank.mdl",
	"models/combine_helicopter.mdl",
	"models/props_trainstation/train002.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_explosive/explosive_butane_can.mdl",
	"models/props_explosive/explosive_butane_can02.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_phx/cannonball.mdl",
	"models/props_phx/ww2bomb.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/ball.mdl",
	"models/props_phx/misc/potato_launcher_explosive.mdl",
	"models/props_phx/misc/flakshell_big.mdl",
	"models/props_phx/playfield.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_mining/techgate01_outland03.mdl",
	"models/props_mining/techgate01.mdl",
	"models/props/cs_office/light_ceiling.mdl"

}; -- Props that are not allowed to be spawned. (make sure they are all lower case!)
config["Rules"] = [[
[General]
DO NOT EXPLOIT ANY SOURCE GLITCH, MAP GLITCH OR SCRIPT GLITCH - NO MATTER HOW SMALL - INTENTIONALLY. YOU WILL BE PERMANENTLY BANNED.
DO NOT USE ANY CLIENTSIDE MODIFICATIONS OR CHEATS TO GIVE YOU AN ADVANTAGE OVER OTHER PLAYERS - IF CAUGHT YOU WILL BE PERMANENTLY BANNED.
THERE WILL BE NO APPEAL FOR THIS KIND OF BAN.
1) Do not kill without an in-character roleplay reason (No random DM)
1.1) Someone's model being different is not a valid reason. Users have no choice over what model they are.
1.2) Yelling RAID is not a reason to kill somebody.
2) Obey the new life rule (NLR), if you die do not imediately return to where you died
2.1) You may not return to the area that you died in for 5 minutes
2.2) If you die during a raid, you may not return to the place of the raid until the raid is over. Rule 2.1 still applies.
2.3) Being called back to a place does not allow you to go there. NLR still applies.
2.4) If you are forced to go past the place you died, do it fast and do not stop there.
3) Do not flame, argue or otherwise misuse OOC (Out-Of-Character)
4) Do not use knowledge gained in OOC in-character
5) Do not suicide, change class or disconnect to avoid a roleplay situation
6) Do not dispute an admin's decision, an admin's decision is final
7) Do not revenge kill - if you are killed by someone do not go and kill them
8) Do not kill another player for their weapons or car
9) Do not grief, do not do things with the intention of annoying another player
10) Do what your job title suggests, doctors are not gangsters, gundealers are not assassins etc.
10.1) Do not 'camp' on a class. Example: If you are an Arms Dealer, you must sell weapons and ammo to people. You may not be an Arms Dealer so you can make ammo for yourself whenever you need it. This applies to every class.
11) If in a hostage situation, you must meet any reasonable demands of the hostage taker
12) If in a hostage situation, do not kill/punch-whore the hostage taker
13) Do not prop block.
13.1) Do not use props that are only see-through in one direction.
13.1) All doors must be made by the door sTool
13.2) Do not make doors out of props or 'force fields' on the map.
13.3) If you own a door that blocks off an area with doors in it, you must own every door in that area.
13.4) You may not use your own doors to block or restrict access through unownable doors. (Bathrooms/Fridges/Minor doors are exempt from this rule)
13.5) If you have more than one door, there must be room for at least 2 people to fit between each door
13.6) You may not have more than 2 doors in a row
13.7) You may only build on the ground outside. This means:
13.7.1) You may not build multi-story huts.
13.7.2) You may not build on roof tops
13.8) Do not build in the road in the Downtown area.
14) Do not advertise in OOC, use '/advert <your advert here>'
15) Only speak English in OOC, all other languages are welcome whilst in character
16) Do not have conversations in OOC, that is what /pm is for
17) If killed, do not ask who killed you or for anything you lost back in-character or in OOC chat
18) Do not ask for admin status, we will choose you
19) Do not argue in OOC, take it to '/pm <part of player name>
20) Do not question a warrant in OOC, you may not know the roleplaying behind it
21) Do not use any racist, sexist or otherwise discriminatory language in OOC chat. They are permitted in character
22) If you are released from jail by your arrest time expiring, then this counts as a New Life, and the New Life Rule applies.
23) Do not kill/knock out another player when they are typing
24) Do not scam or steal.
25) Do not prop surf. You may not use any transportation method other than walking or provided vehicles.
26) Do not prop climb (This includes ramps)
26.1) Climbing on your car to get somewhere is prop climbing
26.2) It is still prop climbing if you climb on someone else's props
26.3) It is still prop climbing if you climb on the map's stuff (traffic lights, poles...)
27) Do not prop kill.
28 Do not discriminate against players because of their class. Example: The police may not arrest rebels because they are rebels and rebels may not shoot the police just because they are Police
28.1) This rule does not apply during 'raid' type roleplays.
29) Do not trap people using props or map exploits
29.1) If you trap someone in a cage, you must RP forcing them in
29.1) All cages must have at least one breachable exit
30) When starting a raid, you must shout that you are raiding before starting, so the people you are raiding know this fact.
31) You may not have a war without the other side's consent.
31.1) You may only have wars with clans, you may not have wars with classes. (The renegades cannot wage war against the police, for example)
30.2) Yelling RAID in the street is not a reason to go on a killing spree on people in the street
32) Do not ask to be killed or deliberately kill yourself
[Police]
P1) Never kill on sight, Warning->Beating->Knock Out->Arrest
P2) Only kill if your life, of the life of another is in direct danger
P3) Do not repeatedly knock out other players
P4) If you are killed by a player, do not go straight back to where you were
P5) Do not randomly knock out other players
P6) You may not kill the mayor, but if roleplayed well you can work with others to bring him down.
P6) Do not kill other members of the police force
P7) You must enforce the permanent laws no matter what.
P8) Quartermasters may *NOT* sell weapons to anyone other than the police. If you are caught doing this, you will be perma-blacklisted from the job and banned for an hour.
P9) The police may not spawn doors in the GHQ, only the mayor can do that.
[Mayor]
M1) Do not warrant players without due reason
M2) Do not promote deathmatching
M3) Use /broadcast and set some laws for the city
M3.1) Do not create any law that goes against the permanent laws.
M4) You must respond to all warrant requests from police officers. (This does not mean you have to aprove every request, but you must acknowledge that you recieved it.)
M5) You must reside in the top floor of the GHQ. You may go outside of the GHQ to travel about and meet citizens, but you may not stay anywhere but the GHQ
M5.1) You may fortify the upper floor and place your own doors there, however you may not prop block.
M6) You may not "do your own thing" without the police
M6.1) The police commander is your trusted second in command. He should know where you are at all times. If he asks, tell him.
[Gangs]
R1) Do not kill other players on sight, just because you are in a gang does not mean you can random deathmatch
R2) Do not kill police on sight, try to avoid killing by roleplaying well
R3) Do not kill members of the opposing gang on sight, roleplay your hatred and kill only when necessary
[Cars]
C1) Do not purposefully run other players over, you will be blacklisted from using cars
C2) Do not randomly kill another player just for their car; if you are carjacking roleplay it well
C3) If you lose your car, go find it. The admin will not solve this problem for you
C4) Do not rage in OOC if you lose your car through fair roleplay means
C5) If you hit someone, get out and rp it! You wouldn't just speed off after rear-ending someone.
[New Life Rule (NLR)]
When you die, you forget everything that has happened to you in the previous life; you do not know where you died or who killed you so you cannot seek revenge or immediately return to your scene of death. When you are released from jail you also start a new life (unless you are broken out of jail) so the same ruleset must be followed.
[Out Of Character Chat (OOC)]
This is spoken in by typing // before you chat in game. Anything you see here can not be used as knowledge for your in-game character, or as a way of commumicating between characters in-game. It is only for out of character issues. Using knowledge found in OOC is metagaming, all other misuse of OOC is also not tolerated. You can speak in local OOC by using .// before you type, this is only heard by those close around you.
[Metagaming]
There has been an influx of people who use things like ventrillo or teamspeak to discuss IC information. THIS IS METAGAMING.
There is one place that it's acceptable to discuss information in IC, and that is the RP channel of our ventrillo server. All other systems, xfire, steam, teamspeak, any other ventrillo server, they are all considered OOC.
Furthermore, you may not use ventrillo as an excuse to break NLR. As soon as you die, you must stop speaking until you respawn. You are not allowed to tell people that you are dead, nor anything that happens after you die.
You must actively be called back via radio or pm. "They told me to come on vent" is not acceptable.
[Info]
All admins and moderators have logs and can tell what is going on without being there.
You will be banned if you break any of these rules

Need a rule breaker banned and no admins around?
Take screenshots, get as much evidence as you can and post here:
http://www.ventmob.com/index.php?board=6.0
]]; -- The rules for the server.
config["Laws"] = [[
[Permanent Laws]
Contraband is illegal. Anyone found with it will be arrested. Any police found with it will be demoted on the spot.
Murder is illegal.
Assault is illegal.
Racism is illegal.
Breaking into other people's property is illegal.
Stealing cars is illegal.
Explosives are illegal.
Tying people up without their explicit consent is illegal.
You must drive on the right hand side of the road.
You may not walk in the road - Always walk on the pavement or on the zebera crossings.
If you hit something while driving, you are liable for all damages.
Observe the speedlimit. The use of turbo devices is illegal.
You must obey all traffic signals.
Civilians may not enter the inner Government HQ (behind the desk) at any time, unless being escorted by two officers. They must report this to the Mayor immediately.
Civilians may not enter the main Government HQ in times of crisis.
Civilians may not unholster weapons in the Government HQ at any time.
Civilians may not build in a public area without permission.
Civilians may not block any offical thoroughfare without written consent from the mayor.
Civilians may not use silenced weapons
Any civilian seen with an illegal or police weapon will be arrested on the spot.
[Temporary Laws]
]]

GM.Config = config;
