----------------------------------------------------------------------------------
-- Total RP 3
-- ---------------------------------------------------------------------------
-- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

local IMAGES = {
	{
		url = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Bling",
		width = 128,
		height = 128
	},
	{
		url = "Interface\\BarberShop\\UI-Barbershop-Banner",
		width = 512,
		height = 256
	},
	{
		url = "Interface\\BattlefieldFrame\\UI-Battlefield-Icon",
		width = 64,
		height = 64
	},
	{
		url = "Interface\\Calendar\\MeetingIcon",
		width = 128,
		height = 128
	},
	{
		url = "Interface\\Calendar\\UI-Calendar-Event-PVP",
		width = 128,
		height = 128
	},
	{
		url = "Interface\\Calendar\\UI-Calendar-Event-PVP01",
		width = 128,
		height = 128
	},
	{
		url = "Interface\\Calendar\\UI-Calendar-Event-PVP02",
		width = 128,
		height = 128
	}, {
		url = "Interface\\FlavorImages\\BloodElfLogo-small",
		width = 256,
		height = 256
	}, {
		url = "Interface\\FlavorImages\\ScarletCrusadeLogo",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-BLACKFATHOMDEEPS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-BLACKROCKDEPTHS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-BLACKROCKSPIRE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-BLACKTEMPLE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-BLACKWINGLAIR",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-BLADESEDGEARENA",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-CAVERNSOFTIME",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-COILFANG",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-DALARANSEWERS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-DEADMINES",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-DIREMAUL",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-DUNGEON",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-EASTERNKINGDOMS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-GNOMEREGAN",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-GRUULSLAIR",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-HALLSOFLIGHTNING",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-HELLFIRECITADEL",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-HELLFIRECITADEL5MAN",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-HELLFIRECITADELRAID",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-HYJALPAST",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-KALIMDOR",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-KARAZHAN",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-MAGISTERSTERRACE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-MARAUDON",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-MOLTENCORE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-NAGRANDARENA",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-NAXXRAMAS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-OUTLAND",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-QUEST",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-RAGEFIRECHASM",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-RAID",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-RAZORFENDOWNS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-RAZORFENKRAUL",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-RINGOFVALOR",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-RUINSOFLORDAERON",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-SCARLETMONASTERY",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-SCHOLOMANCE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-SERPENTSHRINECAVERN",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-SHADOWFANGKEEP",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-STORMWINDSTOCKADES",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-STRANDOFTHEANCIENTS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-STRATHOLME",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-SUNKENTEMPLE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-SUNWELL",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-TEMPESTKEEP",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-ULDAMAN",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-WAILINGCAVERNS",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-WARSONGGULCH",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-ZONE",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-ZULAMAN",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-ZULFARAK",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGICON-ZULGURUB",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Ahnkalet",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-ArgentDungeon",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-ArgentRaid",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-AzjolNerub",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-DrakTharon",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Gundrak",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Halloween",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-HallsofLighting",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-HallsofReflection",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-HallsofStone",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-IcecrownCitadel",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-IsleOfConquest",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Love",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Malygos",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-OldStratholme",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-OnyxiaEncounter",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-PitofSaron",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-RubySanctum",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Summer",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-TheForgeofSouls",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-TheNexus",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-TheOculus",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-TheVioletHold",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Ulduar",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-UlduarRaid",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-UlduarRaidHeroic",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-Utgarde",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-UtgardePinnacle",
		width = 256,
		height = 256
	}, {
		url = "Interface\\LFGFRAME\\LFGIcon-VaultOfArchavon",
		width = 256,
		height = 256
	}, {
		url = "Interface\\Pictures\\11482_crystals_east",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11482_crystals_mini_east",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11482_crystals_mini_north",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11482_crystals_mini_west",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11482_crystals_north",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11482_crystals_west",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_blackrock_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_blasted_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_bldbank_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_nightdragon_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_ungoro_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_whipper_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\11733_windblossom_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\14679_Tirion_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\21037_crudemap_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\24475_gordawg_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\9330_gammerita_color_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\9330_gammerita_sepia_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\Linken__color_256px",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\Linken_sepia_256px",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\Winterspring_Memento_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\Pictures\\obj_nesingwary_256",
		width = 256,
		height = 256
	},
	{
		url = "Interface\\QuestionFrame\\answer-alliance",
		width = 512,
		height = 256
	},
	{
		url = "Interface\\QuestionFrame\\answer-horde",
		width = 512,
		height = 256
	},
	{
		url = "Interface\\QuestionFrame\\answer-kirintor",
		width = 512,
		height = 256
	},
	{
		url = "Interface\\QuestionFrame\\answer-sunreaver",
		width = 512,
		height = 256
	},
	{
		url = "Interface\\QuestionFrame\\answer-troll",
		width = 512,
		height = 256
	},

};

local pairs, tinsert = pairs, tinsert;
local safeMatch = TRP3_API.utils.str.safeMatch;
local size = #IMAGES;

function TRP3_API.utils.resources.getImageListSize()
	return size;
end

function TRP3_API.utils.resources.getImageList(filter)
	if filter == nil or filter:len() == 0 then
		return IMAGES;
	end
	filter = filter:lower();
	local newList = {};
	for _, image in pairs(IMAGES) do
		if safeMatch(image.url:lower(), filter) then
			tinsert(newList, image);
		end
	end
	return newList;
end