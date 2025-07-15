----------------------------------------------------------------------------------
-- Total RP 3
-- Global variables
--	---------------------------------------------------------------------------
--	Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--	Copyright 2014 Renaud Parize (renaud@parize.me)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

-- 3.3.5 compatibility: C_Timer API doesn't exist
if not C_Timer then
	C_Timer = {
		After = function(duration, callback)
			-- Use the legacy timer system available in 3.3.5
			local frame = CreateFrame("Frame")
			frame.elapsed = 0
			frame.duration = duration
			frame.callback = callback
			frame:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = self.elapsed + elapsed
				if self.elapsed >= self.duration then
					self:SetScript("OnUpdate", nil)
					self.callback()
				end
			end)
			return frame
		end
	}
end

-- 3.3.5 compatibility: RemoveExtraSpaces function
if not RemoveExtraSpaces then
	function RemoveExtraSpaces(text)
		if not text then return text end
		-- Simple implementation to remove extra spaces and trim
		local result = text:gsub("%s+", " ")  -- Replace multiple spaces with single space
		result = result:gsub("^%s*(.-)%s*$", "%1")  -- Trim leading and trailing spaces
		return result
	end
end

-- 3.3.5 compatibility: RegisterAddonMessagePrefix doesn't exist
if not RegisterAddonMessagePrefix then
	function RegisterAddonMessagePrefix(prefix)
		-- In 3.3.5, prefixes are auto-registered when first used
		return true
	end
end

-- 3.3.5 compatibility: Ambiguate function for cross-realm support
if not Ambiguate then
	function Ambiguate(name, context)
		if name then
			-- In 3.3.5, just return the name without realm
			return name:gsub("%-.*", "")
		end
		return name
	end
end

-- 3.3.5 compatibility: Group functions
if not IsInGroup then
	function IsInGroup(category)
		if category == LE_PARTY_CATEGORY_INSTANCE then
			-- For dungeon finder groups, just check if in party
			return GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0
		else
			-- Regular groups
			return GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0
		end
	end
end

if not GetNumGroupMembers then
	function GetNumGroupMembers(category)
		local numRaid = GetNumRaidMembers()
		if numRaid > 0 then
			return numRaid
		else
			local numParty = GetNumPartyMembers()
			return numParty > 0 and (numParty + 1) or 0  -- +1 for player
		end
	end
end

-- 3.3.5 compatibility: Constants that might not exist
if not LE_PARTY_CATEGORY_HOME then
	LE_PARTY_CATEGORY_HOME = 1
end

if not LE_PARTY_CATEGORY_INSTANCE then
	LE_PARTY_CATEGORY_INSTANCE = 2  
end

-- 3.3.5 compatibility: Utility functions that might not exist
if not tContains then
	function tContains(table, item)
		if not table then return false end
		for i = 1, #table do
			if table[i] == item then
				return true
			end
		end
		return false
	end
end

if not string.trim then
	function string.trim(s)
		return s:match("^%s*(.-)%s*$")
	end
end

-- 3.3.5 compatibility: Sound functions
if not PlaySoundKitID then
	function PlaySoundKitID(soundKitID)
		-- In 3.3.5, try to play with the old PlaySound function
		if soundKitID then
			PlaySound("igMainMenuOptionCheckBoxOn")
		end
	end
end

-- 3.3.5 compatibility: Additional constants
if not CHAT_TELL_ALERT_TIME then
	CHAT_TELL_ALERT_TIME = 10
end

if not BetterDate then
	BetterDate = date
end

local race_loc, race = UnitRace("player");
local class_loc, class, class_index = UnitClass("player");
local faction, faction_loc = UnitFactionGroup("player");

-- Public accessor
TRP3_API = {
	r = {},
	globals = {
		DEBUG_MODE = TRP3_DEBUG or false,
		empty = {},

		addon_name = "Total RP 3",
		addon_name_short = "TRP3",
		addon_name_alt = "TotalRP3",
		addon_id_length = 15,

		version = 11,
		version_display = "1.0",

		player = UnitName("player"),
		player_race_loc = race_loc,
		player_class_loc = class_loc,
		player_faction_loc = faction_loc,
		player_class_index = class_index,
		player_character = {
			race = race,
			class = class,
			faction = faction
		},

		clients = {
			TRP3 = "trp3",
			MSP = "msp",
		},

		icons = {
			default = "TEMP",
			unknown = "INV_Misc_QuestionMark",
			profile_default = "INV_Misc_GroupLooking",
		},
	}
}

TRP3_API.globals.build = function()
	local name = UnitName("player");
	TRP3_API.globals.player_id = name;
	TRP3_API.globals.player_icon = TRP3_API.ui.misc.getUnitTexture(race, UnitSex("player"));

	-- Build BNet account Hash
	local bn = select(2, BNGetInfo());
	if bn then
		TRP3_API.globals.player_hash = TRP3_API.utils.serial.hashCode(bn);
	else
		-- Trial account ..etc.
		TRP3_API.globals.player_hash = TRP3_API.utils.serial.hashCode(TRP3_API.globals.player_id);
	end
end

TRP3_API.globals.addon = LibStub("AceAddon-3.0"):NewAddon(TRP3_API.globals.addon_name);