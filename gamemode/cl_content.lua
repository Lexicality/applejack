--[[ 
	Content Replacement Service
	Applejack
--]]
--[[
local chand		= Material	"models/weapons/v_hand/v_hand_sheet"
local nhand		= Material	"hand_replacement"
chand:SetTexture(	"$basetexture",	nhand:GetTexture"$basetexture"	)
chand:SetTexture(	"$bumpmap",		nhand:GetTexture"$bumpmap"		)	
--]]
--[[ Jayhawk's Epic Hands ]]--
local mat = Material("models/weapons/v_hand/v_hand_sheet");
local mot = Material("models/weapons/v_models/hands/v_hands");
local met = Material("hand_replacement_jayhawk_v2");
local mut = Material("css_hand_replacement_jayhawk");
mat:SetTexture("$basetexture", met:GetTexture("$basetexture"));
mot:SetTexture("$basetexture", mut:GetTexture("$basetexture"));
if (game.GetMap():lower() ~= "rp_evocity_v2d") then return end
local cursign = Material	"maps/rp_evocity_v2pdless/sgtsicktextures/bankofamericasign_-6363_-7696_137"
local newsign = Material	"evocityextrude"
cursign:SetTexture(	"$basetexture",	newsign:GetTexture"$basetexture")
cursign:SetTexture(	"$bumpmap",		newsign:GetTexture"$bumpmap"	)
local cursign2	= Material	"SGTSICKTEXTURES/BANKOAMERICA2"
newsign			= Material	"evocityintrude"
cursign2:SetTexture("$basetexture", newsign:GetTexture"$basetexture")
cursign2:SetTexture("$bumpmap",     newsign:GetTexture"$bumpmap"    )
cursign2:SetInt(	"$normalmapalphaenvmapmask", 1			        )
cursign2:SetTexture("$envmap",      cursign:GetTexture"$envmap"     )
cursign2:SetString(	"$envmaptint",	"[ .3 .3 .45 ]")
