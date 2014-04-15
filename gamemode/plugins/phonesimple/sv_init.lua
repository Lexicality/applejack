--[[
	~ Phone Plugin / SV ~
	~ Applejack ~
--]]

-- Plugin Disabled
do return; end

local charge = 2;

-- Rated artistic?
local function UniqueIDToPhoneNumber(uniqueID)
	local length = string.len(uniqueID);

	return string.sub(uniqueID, 1, math.floor(length / 2)) .. "-" .. string.sub(uniqueID, math.floor(length / 2 + 1));
end;

local function PhoneNumberToUniqueID(phonenumber)
	return string.gsub(phonenumber, "-","")
end;

function PLUGIN:PlayerCanSayIC(ply, text)
	local target = ply.phoneCalling;

	if( target )then
		-- Check if the target too is calling
		if( target.phoneCalling )then
			local canAfford, need = ply:CanAfford(charge);

			-- Check if we have money for the phone call and take it!
			if(canAfford)then
				cider.chatBox.add(target, ply, "phone", text);
				text = "@" .. UniqueIDToPhoneNumber(target:UniqueID()) .. " " .. text;
				cider.chatBox.add(ply,    ply, "phone", text);

				-- Don't let them talk IC, send it over the phone
				return false;
			else
				ply:Notify("You need another $".. need.." to continue this call!", 1);
				ply:Notify("(Phone) Stopped calling with " .. UniqueIDToPhoneNumber(target:UniqueID()));
				target:Notify("(Phone) Stopped calling with " .. UniqueIDToPhoneNumber(ply:UniqueID()));

				target.phoneCalling = nil;
				ply.phoneCalling = nil;
			end;
		end;
	end;
end

-- Register the phone handling command
cider.command.add("phone","b",1,function(ply, action, targetnumber)
	if( !ply._Phone )then ply:Notify("You don't have a phone!", 1); return; end;

	local phoneNumber = UniqueIDToPhoneNumber(ply:UniqueID());

	if(action == "call")then
		local canAfford, need = ply:CanAfford(charge);

		if( canAfford )then
			if( !ply.phoneCalling and !ply.phoneAnswer )then
				if( targetnumber and string.find(targetnumber, "-") )then
					ply:Notify("(Phone) Now calling " .. targetnumber .. " (Wait for them to answer)");

					local target = player.GetByUniqueID(PhoneNumberToUniqueID(targetnumber));

					if(IsValid(target))then
						if(!target.phoneCalling and !target.phoneAnswer and ply ~= target)then
							ply.phoneCalling = target;

							target:Notify("(Phone) Incomming call from " .. phoneNumber .. " ('/phone answer|deny' to answer or deny)");
							target.phoneAnswer = ply;
						else
							ply:Notify("(Phone) This person is already calling someone...");
						end;
					else
						ply:Notify("(Phone) The person you are trying to call isn't available right now. Their phone might be turned off.");
					end;
				else
					ply:Notify("(Phone) Invalid phone number!");
				end;
			else
				ply:Notify("(Phone) You're already calling or being called.");
			end;
		else
			ply:Notify("You need another $".. need.." to start this call!", 1);
		end;
	elseif(action == "answer")then
		if( IsValid(ply.phoneAnswer) )then
			ply:Notify("(Phone) Answered to phone call " .. UniqueIDToPhoneNumber(ply.phoneAnswer:UniqueID()) .. " (local cost is $2 per message sent)");
			ply.phoneAnswer:Notify("(Phone) Phone call was answered (local cost is $2 per message sent)");

			ply.phoneCalling = ply.phoneAnswer;
			ply.phoneAnswer = nil;
		else
			ply:Notify("(Phone) Nobody is calling you!");
		end;
	elseif(action == "deny")then
		if( IsValid(ply.phoneAnswer) )then
			ply:Notify("(Phone) Denied phone call from " .. UniqueIDToPhoneNumber(ply.phoneAnswer:UniqueID()));
			ply.phoneAnswer:Notify("(Phone) Phone call from ".. phoneNumber .." denied..");

			ply.phoneAnswer.phoneCalling = nil;
			ply.phoneAnswer = nil;
		else
			ply:Notify("(Phone) Nobody is calling you!");
		end;
	elseif(action == "endcall")then
		if( IsValid(ply.phoneCalling) )then
			ply:Notify("(Phone) Stopped calling with " .. UniqueIDToPhoneNumber(ply.phoneCalling:UniqueID()));
			ply.phoneCalling:Notify("(Phone) Phone call with ".. phoneNumber .." ended..");

			ply.phoneCalling.phoneCalling = nil;
			ply.phoneCalling = nil;
		else
			ply:Notify("(Phone) Nobody is calling you!");
		end;
	elseif(action == "getnumber")then
		ply:Notify("(Phone) Your phone number is: " .. phoneNumber);
	else
		ply:Notify("(Phone) Invalid action, you can only use call, endcall or getnumber!");
	end;
end,"Commands", "<call|answer|endcall|getnumber> [phone number]", "Use call to start calling, anything you say will be heard through the phone.", true);
