--
-- ~ Note Entity ~ Clientside ~
-- ~ Applejack ~
--
include("shared.lua")

-- Add a language text for when we undo the note.
language.Add("Undone_Note", "Undone Note");

function ENT:ESPPaint(lines, pos, dist, centre)
	lines:Add("Name", "Note", color_lightblue, 1);
	if (not centre) then
		return;
	end
	local line;
	for i = 1, 5 do
		line = self:GetNWString("text_" .. i);
		if (line == "") then
			break
		end
		lines:Add("Line " .. i, line, color_white, 1 + i);
	end
end
