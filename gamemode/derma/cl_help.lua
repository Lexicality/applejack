--
-- "cl_help.lua"
-- ~ Applejack ~
--
local PANEL = {};

function PANEL:Init()
	-- We need to load the current help into our items list.
	self:Reload();
end

local function isModerator(text)
	return text:sub(1,  9) == "Moderator";
end

local function isAuthed(text)
	return text:sub(1, 10) == "Superadmin"
		or text:sub(1,  5) == "Admin"
		or isModerator(text);
end

local function isAbuse(text)
	return text:find("Abuse") and true or false;
end

local function bullshitSort(a, b)
	a,b = a.title, b.title;
	-- General always floats to the top
	if (a == "General") then
		return true;
	elseif (b == "General") then
		return false;
	end
	local aa, ab = isAuthed(a), isAuthed(b);
	-- Authed commands go below normal ones.
	if (aa ~= ab) then
		-- If ab is true, aa is false and thus a is lighter than b. Inverse also applies
		return ab;
	elseif (not aa) then
		-- aa and bb are both false. Normal sorting applies
		return a < b;
	end
	aa, ab = isAbuse(a), isAbuse(b);
	if (aa ~= ab) then
		return ab;
	end
	aa, ab = isModerator(a), isModerator(b);
	if (aa ~= ab) then
		-- Moderator commands go upwards
		return aa;
	end
	return a < b;
end

-- Reload the help text.
function PANEL:Reload()
	self:Empty();
	local sections = {};

	for title, text in pairs(GM.HelpItems) do
		local text2 = {};
		for _, line in ipairs(text) do
			table.insert(text2, line);
		end
		table.insert(sections, {
			title = title;
			text  = text2;
		} );
	end

	table.sort(sections, bullshitSort);

	self:CreateChildren(sections);
	self:InvalidateLayout(true);
end

-- Register the panel.
vgui.Register("cider_Help", PANEL, "MSTextPanel");
