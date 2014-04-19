--[[
Name: "cl_credits.lua".
	~ Applejack ~
--]]

local PANEL = {};

-- Store the credits in a string.
PANEL.credits = [[
[Credits]
kuromeku - kuromeku@gmail.com - http://conna.org - Made the core systems of Cider, populated it with items and released it.
Lexi - mwaness@gmail.com - http://www.ventmob.com/ - Vast swathes of improvements to the script, going with the philosophy that "Light RP doesn't have to be shit."
Drewley - http://www.ventmob.com/ - Hosting the VM server that this script was born on, minor edits.
Jayhawk - www.thebluecommunity.com - Creating awesome textures
[Works included in modified form]
-[SB]- Spy - The SMod Leg SWep
NoVa - VU Mod
High6 - Door STool
Athos - The corvette and golf
Spacetech - Simple Prop Protection
Kogitsune - Various
[Thanks]
The various people of the Lua section of Facepunch - Helping me fix stuff
Drewley - For providing the server, various tools and suggestions that got Applejack to what it is today
Clown, Kizai, Vaut - Suggestions
jDog - More suggestions than I ever want to read
Deamie - Managing to out-do jDog
Stephanov - Finding map exploits, being awsum, tester
Hawkace - Some food based suggestions
Snake Logan - Finding me models when I'm too lazy do it myself
Cuttlefish - Spent $1,000,000 on an alien ballsack
||VM|| Server population - Being my labrats and helping me isolate bugs
kuromeku - For being my inspiration, doing things that started me doing srs lua coding, for writing scripts that I admire and give me something to live up to, for releasing Cider into the public and for being such a retarded asshole and banning me, thus allowing me to start work on this project.
[Testers]
(If you have done beta testing on the test server and are not on here, pm me)
Thorium
iShot
TJjokerR
Crillz
Brother Correcticus
Stephanov
Chronic
MartinP
Frosty
deathstar
]]

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetText(self.credits);
end

-- Register the panel.
vgui.Register("cider_Credits", PANEL, "MSTextPanel");
