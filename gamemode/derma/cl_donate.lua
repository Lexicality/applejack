--[[
Name: "cl_donate.lua".
	~ Applejack ~
--]]

local PANEL = {};

PANEL.services = [[
[Donations]
Official Forum Thread: http://www.ventmob.com/index.php?topic=101.0

[Donator Advantages]
---$50,000 -In-Game Cash-
---Physics Gun/Tool Gun
---Ability to Spawn Props without the limits imposed by the builder class
---2 Pockets -In-Game Item-
---Respected Donator Status on Forums
---A symbol next to your name when you talk in OOC
---Double salary In Game

[Super Donator Advantages]
---$120,000 -In-Game Cash-
---Physics Gun/Tool Gun
---Ability to Spawn props without the limits imposed by the builder class
---6 Pockets -In-Game Item-
---5 Breaches -In-Game Item-
---Respected Super Donator Status on Forums
---A symbol next to your name when you talk in OOC
---Double salary In Game

[Costs]
Donator = $7.50 Lasts 1 and a half Months (45 days)
Super Donator = $15 Lasts 3 Months

[How to Pay]
Made your mind up you want to be a Donator?
Go to: http://www.ventmob.com/donate/
]];

function PANEL:Init()
	self:SetText(self.services)
end

vgui.Register("cider_Donate", PANEL, "MSTextPanel");
