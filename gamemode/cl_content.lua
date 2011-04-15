--[[ 
	Content Replacement Service
	Applejack
--]]
--[[
local chand		= Material	"models/weapons/v_hand/v_hand_sheet"
local nhand		= Material	"hand_replacement"
chand:SetMaterialTexture(	"$basetexture",	nhand:GetMaterialTexture"$basetexture"	)
chand:SetMaterialTexture(	"$bumpmap",		nhand:GetMaterialTexture"$bumpmap"		)	
--]]
--[[ Jayhawk's Epic Hands ]]--
local mat = Material("models/weapons/v_hand/v_hand_sheet");
local mot = Material("models/weapons/v_models/hands/v_hands");
local met = Material("hand_replacement_jayhawk_v2");
local mut = Material("css_hand_replacement_jayhawk");
mat:SetMaterialTexture("$basetexture", met:GetMaterialTexture("$basetexture"));
mot:SetMaterialTexture("$basetexture", mut:GetMaterialTexture("$basetexture"));
if (game.GetMap():lower() ~= "rp_evocity_v2d") then return end
local cursign = Material	"maps/rp_evocity_v2pdless/sgtsicktextures/bankofamericasign_-6363_-7696_137"
local newsign = Material	"evocityextrude"
cursign:SetMaterialTexture(	"$basetexture",	newsign:GetMaterialTexture"$basetexture")
cursign:SetMaterialTexture(	"$bumpmap",		newsign:GetMaterialTexture"$bumpmap"	)
local cursign2	= Material	"SGTSICKTEXTURES/BANKOAMERICA2"
newsign			= Material	"evocityintrude"
cursign2:SetMaterialTexture("$basetexture", newsign:GetMaterialTexture"$basetexture")
cursign2:SetMaterialTexture("$bumpmap",     newsign:GetMaterialTexture"$bumpmap"    )
cursign2:SetMaterialInt(	"$normalmapalphaenvmapmask", 1					        )
cursign2:SetMaterialTexture("$envmap",      cursign:GetMaterialTexture"$envmap"     )
cursign2:SetMaterialString(	"$envmaptint",	"[ .3 .3 .45 ]")