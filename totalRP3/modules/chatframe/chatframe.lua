----------------------------------------------------------------------------------
-- Total RP 3
-- Chat management
--	---------------------------------------------------------------------------
--	Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
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

-- imports
local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local loc = TRP3_API.locale.getText;
local unitIDToInfo, unitInfoToID = Utils.str.unitIDToInfo, Utils.str.unitInfoToID;
local get = TRP3_API.profile.getData;
local getCompleteName = TRP3_API.register.getCompleteName;
local IsUnitIDKnown = TRP3_API.register.isUnitIDKnown;
local getUnitIDCurrentProfile, isIDIgnored = TRP3_API.register.getUnitIDCurrentProfile, TRP3_API.register.isIDIgnored;
local strsub, strlen, format, _G, pairs, tinsert, time, strtrim = strsub, strlen, format, _G, pairs, tinsert, time, strtrim;
local GetTime, PlaySound = GetTime, PlaySound;
local getConfigValue, registerConfigKey, registerHandler = TRP3_API.configuration.getValue, TRP3_API.configuration.registerConfigKey, TRP3_API.configuration.registerHandler;
local ChatFrame_RemoveMessageEventFilter, ChatFrame_AddMessageEventFilter = ChatFrame_RemoveMessageEventFilter, ChatFrame_AddMessageEventFilter;
local oldChatFrameOnEvent;
local handleCharacterMessage, hooking;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Config
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local POSSIBLE_CHANNELS

local CONFIG_NAME_METHOD = "chat_name";
local CONFIG_NAME_COLOR = "chat_color";
local CONFIG_NAME_EMOTE_COLOR = "chat_emote_color";
local CONFIG_NAME_ICON = "chat_name_icon";
local CONFIG_NAME_ICON_SIZE = "chat_name_icon_size";
local CONFIG_NPC_TALK = "chat_npc_talk";
local CONFIG_NPC_TALK_PREFIX = "chat_npc_talk_p";
local CONFIG_EMOTE = "chat_emote";
local CONFIG_EMOTE_PATTERN = "chat_emote_pattern";
local CONFIG_CHAT = "chat_chat";
local CONFIG_CHAT_PATTERN = "chat_chat_pattern";
local CONFIG_USAGE = "chat_use_";
local CONFIG_OOC = "chat_ooc";
local CONFIG_OOC_PATTERN = "chat_ooc_pattern";
local CONFIG_OOC_COLOR = "chat_ooc_color";
local CONFIG_YELL_NO_EMOTE = "chat_yell_no_emote";
local CONFIG_CHANNEL_PARTY = "chat_channel_party";
local CONFIG_CHANNEL_PARTY_LEADER = "chat_channel_party_leader";
local CONFIG_CHANNEL_RAID = "chat_channel_raid";
local CONFIG_CHANNEL_RAID_LEADER = "chat_channel_raid_leader";
local CONFIG_CHANNEL_GUILD = "chat_channel_guild";
local CONFIG_CHANNEL_OFFICER = "chat_channel_officer";
local CONFIG_CHANNEL_WHISPER_IN = "chat_channel_whisper_in";
local CONFIG_CHANNEL_WHISPER_OUT = "chat_channel_whisper_out";
local CONFIG_NAME_BRACKETS = "chat_name_brackets";
local CONFIG_CHANNEL_REPLACEMENT = "chat_channel_replacement";

local function configNoYelledEmote()
	return getConfigValue(CONFIG_YELL_NO_EMOTE);
end

local function configNameMethod()
	return getConfigValue(CONFIG_NAME_METHOD);
end

local function configShowNameCustomColors()
	return getConfigValue(CONFIG_NAME_COLOR);
end

local function configShowNameEmoteColors()
	return getConfigValue(CONFIG_NAME_EMOTE_COLOR);
end

local function configShowNameIcons()
	local value = getConfigValue(CONFIG_NAME_ICON);
	return value;
end

local function configNameIconSize()
	return getConfigValue(CONFIG_NAME_ICON_SIZE);
end

local function configIsChannelUsed(channel)
	return getConfigValue(CONFIG_USAGE .. channel);
end

local function configDoHandleNPCTalk()
	return getConfigValue(CONFIG_NPC_TALK);
end

local function configNPCTalkPrefix()
	return getConfigValue(CONFIG_NPC_TALK_PREFIX);
end

local function configDoEmoteDetection()
	return getConfigValue(CONFIG_EMOTE);
end

local function configEmoteDetectionPattern()
	return getConfigValue(CONFIG_EMOTE_PATTERN);
end

local function configChatDetectionPattern()
	return getConfigValue(CONFIG_CHAT_PATTERN);
end

local function configDoChatDetection()
	return getConfigValue(CONFIG_CHAT);
end

local function configDoOOCDetection()
	return getConfigValue(CONFIG_OOC);
end

local function configOOCDetectionPattern()
	return getConfigValue(CONFIG_OOC_PATTERN);
end

local function configOOCDetectionColor()
	return getConfigValue(CONFIG_OOC_COLOR);
end

local function configPartyChannelName()
	return getConfigValue(CONFIG_CHANNEL_PARTY);
end

local function configPartyLeaderChannelName()
	return getConfigValue(CONFIG_CHANNEL_PARTY_LEADER);
end

local function configRaidChannelName()
	return getConfigValue(CONFIG_CHANNEL_RAID);
end

local function configRaidLeaderChannelName()
	return getConfigValue(CONFIG_CHANNEL_RAID_LEADER);
end

local function configGuildChannelName()
	return getConfigValue(CONFIG_CHANNEL_GUILD);
end

local function configOfficerChannelName()
	return getConfigValue(CONFIG_CHANNEL_OFFICER);
end

local function configWhisperInChannelName()
	return getConfigValue(CONFIG_CHANNEL_WHISPER_IN);
end

local function configWhisperOutChannelName()
	return getConfigValue(CONFIG_CHANNEL_WHISPER_OUT);
end

local function configNameBrackets()
	return getConfigValue(CONFIG_NAME_BRACKETS);
end

local function getNameBrackets()
	local bracketStyle = configNameBrackets();
	if bracketStyle == 1 then
		return "[", "]"; 
	elseif bracketStyle == 2 then
		return "(", ")";
	elseif bracketStyle == 3 then
		return "<", ">";
	else
		return "", ""; 
	end
end

local function configChannelReplacement()
	return getConfigValue(CONFIG_CHANNEL_REPLACEMENT);
end

local function createConfigPage(useWIM)
	-- Config default value
	registerConfigKey(CONFIG_NAME_METHOD, 3);
	registerConfigKey(CONFIG_NAME_COLOR, true);
	registerConfigKey(CONFIG_NAME_EMOTE_COLOR, true);
	registerConfigKey(CONFIG_NAME_ICON, false); -- Changed default to false to avoid persistence issues
	registerConfigKey(CONFIG_NAME_ICON_SIZE, 16);
	registerConfigKey(CONFIG_NPC_TALK, true);
	registerConfigKey(CONFIG_NPC_TALK_PREFIX, "|| ");
	registerConfigKey(CONFIG_EMOTE, true);
	registerConfigKey(CONFIG_EMOTE_PATTERN, "(%*.-%*)");
	registerConfigKey(CONFIG_CHAT, true);
	registerConfigKey(CONFIG_CHAT_PATTERN, "(%\".-%\")");
	registerConfigKey(CONFIG_OOC, true);
	registerConfigKey(CONFIG_OOC_PATTERN, "(%(.-%))");
	registerConfigKey(CONFIG_OOC_COLOR, "aaaaaa");
	registerConfigKey(CONFIG_YELL_NO_EMOTE, false);
	registerConfigKey(CONFIG_CHANNEL_PARTY, "[Party]");
	registerConfigKey(CONFIG_CHANNEL_PARTY_LEADER, "[Party Leader]");
	registerConfigKey(CONFIG_CHANNEL_RAID, "[Raid]");
	registerConfigKey(CONFIG_CHANNEL_RAID_LEADER, "[Raid Leader]");
	registerConfigKey(CONFIG_CHANNEL_GUILD, "[Guild]");
	registerConfigKey(CONFIG_CHANNEL_OFFICER, "[Officer]");
	registerConfigKey(CONFIG_CHANNEL_WHISPER_IN, "whispers");
	registerConfigKey(CONFIG_CHANNEL_WHISPER_OUT, "To");
	registerConfigKey(CONFIG_NAME_BRACKETS, 1);
	registerConfigKey(CONFIG_CHANNEL_REPLACEMENT, false);

	local NAMING_METHOD_TAB = {
		{loc("CO_CHAT_MAIN_NAMING_1"), 1},
		{loc("CO_CHAT_MAIN_NAMING_2"), 2},
		{loc("CO_CHAT_MAIN_NAMING_3"), 3},
		{loc("CO_CHAT_MAIN_NAMING_4"), 4},
	}
	
	local EMOTE_PATTERNS = {
		{"* Emote *", "(%*.-%*)"},
		{"** Emote **", "(%*%*.-%*%*)"},
		{"< Emote >", "(%<.-%>)"},
		{"* Emote * + < Emote >", "([%*%<].-[%*%>])"},
	}
	
	local OOC_PATTERNS = {
		{"( OOC )", "(%(.-%))"},
		{"(( OOC ))", "(%(%(.-%)%))"},
	}
	
	local NAME_BRACKET_PATTERNS = {
		{"[Name]", 1},
		{"(Name)", 2},
		{"<Name>", 3},
		{"Name", 4},
	}

	-- Build configuration page
	local CONFIG_STRUCTURE = {
		id = "main_config_chatframe",
		menuText = loc("CO_CHAT"),
		pageText = loc("CO_CHAT"),
		elements = {
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_CHAT_MAIN"),
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationTooltip_Chat_NamingMethod",
				title = loc("CO_CHAT_MAIN_NAMING"),
				listContent = NAMING_METHOD_TAB,
				configKey = CONFIG_NAME_METHOD,
				listCancel = true,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_COLOR"),
				configKey = CONFIG_NAME_COLOR,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_EMOTE_COLOR"),
				configKey = CONFIG_NAME_EMOTE_COLOR,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_ICON"),
				configKey = CONFIG_NAME_ICON,
			},
			{
				inherit = "TRP3_ConfigSlider",
				title = loc("CO_CHAT_MAIN_ICON_SIZE"),
				configKey = CONFIG_NAME_ICON_SIZE,
				min = 8,
				max = 32,
				step = 2,
				integer = true,
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_CHAT_MAIN_NPC"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_NPC_USE"),
				configKey = CONFIG_NPC_TALK,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = loc("CO_CHAT_MAIN_NPC_PREFIX"),
				configKey = CONFIG_NPC_TALK_PREFIX,
				help = loc("CO_CHAT_MAIN_NPC_PREFIX_TT")
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_CHAT_MAIN_EMOTE"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_EMOTE_YELL"),
				help = loc("CO_CHAT_MAIN_EMOTE_YELL_TT"),
				configKey = CONFIG_YELL_NO_EMOTE,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_EMOTE_USE"),
				configKey = CONFIG_EMOTE,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationTooltip_Chat_EmotePattern",
				title = loc("CO_CHAT_MAIN_EMOTE_PATTERN"),
				listContent = EMOTE_PATTERNS,
				configKey = CONFIG_EMOTE_PATTERN,
				listCancel = true,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_CHAT_USE"),
				configKey = CONFIG_CHAT,
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_CHAT_MAIN_OOC"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_CHAT_MAIN_OOC_USE"),
				configKey = CONFIG_OOC,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationTooltip_Chat_OOCPattern",
				title = loc("CO_CHAT_MAIN_OOC_PATTERN"),
				listContent = OOC_PATTERNS,
				configKey = CONFIG_OOC_PATTERN,
				listCancel = true,
			},
			{
				inherit = "TRP3_ConfigColorPicker",
				title = loc("CO_CHAT_MAIN_OOC_COLOR"),
				configKey = CONFIG_OOC_COLOR,
			},
			-- we don't reuse POSSIBLE_CHANNELS because of unnecessary complexity
			{
				inherit = "TRP3_ConfigH1",
				title = "Channel Names",
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = "Enable Channel Name Replacement",
				help = "Enable custom channel names for party, guild, raid, whispers, etc.",
				configKey = CONFIG_CHANNEL_REPLACEMENT,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationTooltip_Chat_NameBrackets",
				title = "Name Bracket Style",
				help = "Choose the style of brackets around player names",
				listContent = NAME_BRACKET_PATTERNS,
				configKey = CONFIG_NAME_BRACKETS,
				listCancel = true,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Party Channel Name",
				configKey = CONFIG_CHANNEL_PARTY,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Party Leader Channel Name",
				configKey = CONFIG_CHANNEL_PARTY_LEADER,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Raid Channel Name",
				configKey = CONFIG_CHANNEL_RAID,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Raid Leader Channel Name",
				configKey = CONFIG_CHANNEL_RAID_LEADER,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Guild Channel Name",
				configKey = CONFIG_CHANNEL_GUILD,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Officer Channel Name",
				configKey = CONFIG_CHANNEL_OFFICER,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Incoming Whisper Name",
				configKey = CONFIG_CHANNEL_WHISPER_IN,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = "Outgoing Whisper Name",
				configKey = CONFIG_CHANNEL_WHISPER_OUT,
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_CHAT_USE"),
			},
		}
	};
	if useWIM then
		tinsert(CONFIG_STRUCTURE.elements, {
			inherit = "TRP3_ConfigNote",
			help = loc("CO_WIM_TT"),
			title = loc("CO_WIM"),
		});
	end

	for _, channel in pairs(POSSIBLE_CHANNELS) do
		registerConfigKey(CONFIG_USAGE .. channel, true);
		registerHandler(CONFIG_USAGE .. channel, hooking);
		tinsert(CONFIG_STRUCTURE.elements, {
			inherit = "TRP3_ConfigCheck",
			title = _G[channel],
			configKey = CONFIG_USAGE .. channel,
		});
	end

	TRP3_API.configuration.registerConfigurationPage(CONFIG_STRUCTURE);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getCharacterInfoTab(unitID)
	if unitID == Globals.player_id then
		return get("player");
	elseif IsUnitIDKnown(unitID) then
		return getUnitIDCurrentProfile(unitID) or {};
	end
	return {};
end

local function getCharacterClassColor(chatInfo, event, text, characterID, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, messageID, GUID)
	local color;
	local shouldUseClassColor = false;
	
	if event == "CHAT_MSG_EMOTE" or event == "CHAT_MSG_TEXT_EMOTE" then
		shouldUseClassColor = configShowNameEmoteColors();
	elseif configDoEmoteDetection() and text and text:find(configEmoteDetectionPattern()) then
		shouldUseClassColor = configShowNameEmoteColors();
	else
		shouldUseClassColor = chatInfo and chatInfo.colorNameByClass;
	end
	
	if ( shouldUseClassColor and GUID ) then
		local localizedClass, englishClass = GetPlayerInfoByGUID(GUID);
		-- 3.3.5 compatibility: GetPlayerInfoByGUID might not work, fallback to other methods
		if not englishClass and characterID then
			-- Try to get class info from our own data if available
			local profile = getCharacterInfoTab(characterID);
			if profile and profile.characteristics and profile.characteristics.CL then
				englishClass = profile.characteristics.CL;
			end
		end
		if englishClass and RAID_CLASS_COLORS[englishClass] then
			local classColorTable = RAID_CLASS_COLORS[englishClass];
			return ("|cff%.2x%.2x%.2x"):format(classColorTable.r*255, classColorTable.g*255, classColorTable.b*255);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Name replacement in emotes and chat
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function replaceNameInEmote(message, characterID, type)
	local characters = TRP3_API.register.getCharacterList();
	local replacedNames = {};
	
	-- no name replacement when in ""
	local function isInsideQuotes(text, position)
		local quoteCount = 0;
		for i = 1, position - 1 do
			if text:sub(i, i) == '"' then
				quoteCount = quoteCount + 1;
			end
		end
		return (quoteCount % 2) == 1;
	end
	
	local skipSpeakerName = nil;
	if type == "TEXT_EMOTE" and characterID and characterID ~= Globals.player_id then
		local speakerName = unitIDToInfo(characterID);
		if speakerName and message:sub(1, speakerName:len()) == speakerName then
			skipSpeakerName = speakerName;
			replacedNames[speakerName] = true;
		end
	end
	
	-- replace player target
	if UnitExists("target") then
		local targetName = UnitName("target");
		if targetName and not replacedNames[targetName] then
			local targetRPName;
			
			-- if targeting self
			if UnitIsUnit("target", "player") then
				targetRPName = TRP3_API.register.getPlayerCompleteName(true);

				local playerData = TRP3_API.profile.getData("player/characteristics");
				if configShowNameEmoteColors() and playerData and playerData.CH then
					targetRPName = "|cff" .. playerData.CH .. targetRPName .. "|r";
				end
			else
				-- target
				local targetID = Utils.str.getUnitID("target");
				if targetID and TRP3_API.register.profileExists(targetID) then
					local profile = TRP3_API.register.getUnitIDProfile(targetID);
					if profile.characteristics then
						targetRPName = TRP3_API.register.getCompleteName(profile.characteristics, targetName, true);
						if configShowNameEmoteColors() and profile.characteristics.CH then
							targetRPName = "|cff" .. profile.characteristics.CH .. targetRPName .. "|r";
						end
					end
				end
			end
			
			if targetRPName and targetRPName ~= targetName then
				local escapedName = targetName:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1");
				local pattern = "%f[%w]" .. escapedName .. "%f[%W]";
				
				local startPos = 1;
				while true do
					local matchStart, matchEnd = message:find(pattern, startPos);
					if not matchStart then break; end
					
					if not isInsideQuotes(message, matchStart) then
						message = message:sub(1, matchStart - 1) .. targetRPName .. message:sub(matchEnd + 1);
						startPos = matchStart + targetRPName:len();
						break;
					else
						startPos = matchEnd + 1;
					end
				end
				replacedNames[targetName] = true;
			end
		end
	end
	
	-- other characters
	for unitID, character in pairs(characters) do
		if unitID ~= Globals.player_id and TRP3_API.register.profileExists(unitID) then
			local characterName = unitID;
			
			if characterName and not replacedNames[characterName] and message:find(characterName, 1, true) then
				local profile = TRP3_API.register.getUnitIDProfile(unitID);
				if profile.characteristics then
					local rpName = TRP3_API.register.getCompleteName(profile.characteristics, characterName, true);
					if rpName and rpName ~= characterName then
						if configShowNameEmoteColors() and profile.characteristics.CH then
							rpName = "|cff" .. profile.characteristics.CH .. rpName .. "|r";
						end
						local escapedName = characterName:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1");
						local pattern = "%f[%w]" .. escapedName .. "%f[%W]";
						
						local startPos = 1;
						while true do
							local matchStart, matchEnd = message:find(pattern, startPos);
							if not matchStart then break; end
							
							if not isInsideQuotes(message, matchStart) then
								message = message:sub(1, matchStart - 1) .. rpName .. message:sub(matchEnd + 1);
								startPos = matchStart + rpName:len();
								break; 
							else
								startPos = matchEnd + 1;
							end
						end
						replacedNames[characterName] = true;
					end
				end
			end
		end
	end
	
	-- player
	local playerName = Globals.player;
	if playerName and not replacedNames[playerName] and message:find(playerName, 1, true) then
		local playerRPName = TRP3_API.register.getPlayerCompleteName(true);
		if playerRPName and playerRPName ~= playerName then
			local playerData = TRP3_API.profile.getData("player/characteristics");
			if configShowNameEmoteColors() and playerData and playerData.CH then
				playerRPName = "|cff" .. playerData.CH .. playerRPName .. "|r";
			end
			local escapedName = playerName:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1");
			local pattern = "%f[%w]" .. escapedName .. "%f[%W]";
			
			-- replace matches
			local startPos = 1;
			while true do
				local matchStart, matchEnd = message:find(pattern, startPos);
				if not matchStart then break; end
				
				if not isInsideQuotes(message, matchStart) then
					message = message:sub(1, matchStart - 1) .. playerRPName .. message:sub(matchEnd + 1);
					break;
				else
					startPos = matchEnd + 1;
				end
			end
		end
	end
	
	return message;
end


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Emote and OOC detection
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function detectEmoteAndOOC(type, message)
	local function stripColorCodes(text)
		return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
	end
	
	if configDoEmoteDetection() and message:find(configEmoteDetectionPattern()) then
		local chatInfo = ChatTypeInfo["EMOTE"];
		local color = ("|cff%.2x%.2x%.2x"):format(chatInfo.r*255, chatInfo.g*255, chatInfo.b*255);
		message = message:gsub(configEmoteDetectionPattern(), function(content)
			local cleanContent = stripColorCodes(content);
			return color .. cleanContent .. "|r";
		end);
	end
	if configDoChatDetection() and message:find(configChatDetectionPattern()) then
		message = message:gsub(configChatDetectionPattern(), function(content)
			local cleanContent = stripColorCodes(content);
			return "|cffffffff" .. cleanContent .. "|r";  -- White color
		end);
	end
	if configDoOOCDetection() and message:find(configOOCDetectionPattern()) then
		message = message:gsub(configOOCDetectionPattern(), function(content)
			local cleanContent = stripColorCodes(content);
			return "|cff" .. configOOCDetectionColor() .. cleanContent .. "|r";
		end);
	end
	return message;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- NPC talk detection
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local NPC_TALK_CHANNELS = {
	CHAT_MSG_SAY = 1, CHAT_MSG_EMOTE = 1, CHAT_MSG_PARTY = 1, CHAT_MSG_RAID = 1, CHAT_MSG_PARTY_LEADER = 1, CHAT_MSG_RAID_LEADER = 1
};
local NPC_TALK_PATTERNS;

local function handleNPCTalk(chatFrame, message, characterID, messageID)
	local playerLink = "|Hplayer:".. characterID .. ":" .. messageID .. "|h";
	for TALK_TYPE, TALK_CHANNEL in pairs(NPC_TALK_PATTERNS) do
		if message:find(TALK_TYPE) then
			local chatInfo = ChatTypeInfo[TALK_CHANNEL];
			local name = message:sub(4, message:find(TALK_TYPE) - 2); -- Isolate the name
			local content = message:sub(name:len() + 4);
			playerLink = playerLink .. name;
			chatFrame:AddMessage("|cffff9900" .. playerLink .. "|h|r" .. content, chatInfo.r, chatInfo.g, chatInfo.b, chatInfo.id);
			return;
		end
	end
	local chatInfo = ChatTypeInfo["MONSTER_EMOTE"];
	chatFrame:AddMessage(playerLink .. message:sub(4) .. "|h", chatInfo.r, chatInfo.g, chatInfo.b, chatInfo.id);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Chatframe management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Ideas:
-- Ignored to another chatframe (config)
-- Limit name length (config)

function handleCharacterMessage(chatFrame, event, ...)
	local characterName, characterColor;
	local message, characterID, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, messageID, arg12, arg13, arg14, arg15, arg16 = ...;
	local languageHeader = "";
	local character = unitIDToInfo(characterID);
	-- if not realm then -- Thanks Blizzard to not always send a full character ID
	-- 	realm = nil;
	-- 	characterID = unitInfoToID(character, realm);
	-- end
	local info = getCharacterInfoTab(characterID);
	
	if not character or character == "" then
		character = characterID or "Unknown";
	end
	
	-- Get chat type and configuration
	local type = strsub(event, 10);
	local chatInfo = ChatTypeInfo[type];
	
	-- Detect NPC talk pattern on authorized channels
	if message:sub(1, 3) == configNPCTalkPrefix() and configDoHandleNPCTalk() and NPC_TALK_CHANNELS[event] then
		handleNPCTalk(chatFrame, message, characterID, messageID);
		return true;
	end

	-- WHISPER and WHISPER_INFORM have the same chat info
	if ( strsub(type, 1, 7) == "WHISPER" ) then
		chatInfo = ChatTypeInfo["WHISPER"];
	end

	-- WHISPER respond
	if type == "WHISPER" then
		ChatEdit_SetLastTellTarget(characterID, type);
		if ( chatFrame.tellTimer and (GetTime() > chatFrame.tellTimer) ) then
			PlaySound("TellMessage");
		end
		chatFrame.tellTimer = GetTime() + CHAT_TELL_ALERT_TIME;
	end

	-- Character name
	characterName = character;

	local nameMethod = configNameMethod();
	if nameMethod == 2 or nameMethod == 3 or nameMethod == 4 then -- TRP3 names
		if info.characteristics and info.characteristics.FN then
			characterName = info.characteristics.FN;
		end
		if nameMethod == 3 and info.characteristics and info.characteristics.LN then -- With last name
			characterName = characterName .. " " .. info.characteristics.LN;
		end
		if nameMethod == 4 then -- With title + first name + last name
			characterName = getCompleteName(info.characteristics);
		end
	end

	-- Ensure characterName is never nil
	characterName = characterName or character or "Unknown";

	-- add characters icon if enabled
	if configShowNameIcons() and info.characteristics and info.characteristics.IC then
		local characterIcon = Utils.str.icon(info.characteristics.IC, configNameIconSize());
		characterName = characterIcon .. " " .. characterName;
	end

	-- class colour (custom through trp3)
	if configShowNameCustomColors() and info.characteristics and info.characteristics.CH then
		characterColor = "|cff" .. info.characteristics.CH;
	else
		characterColor = getCharacterClassColor(chatInfo, event, message, characterID, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, messageID, arg12);
	end
	if characterColor then
		characterName = characterColor .. characterName .. "|r";
	end

	-- Language
	if ( (strlen(language) > 0) and (language ~= chatFrame.defaultLanguage) ) then
		languageHeader = "[" .. language .. "] ";
	end

	-- Show
	message = RemoveExtraSpaces(message);
	
	-- No yelled emote ?
	if event == "CHAT_MSG_YELL" and configNoYelledEmote() then
		message = message:gsub("%*.-%*", "");
		message = message:gsub("%<.-%>", "");
	end
	
	-- Colorize emote and OOC
	message = detectEmoteAndOOC(type, message);
	
	-- replace character name with trp3 names (only for emotes and messages containing emote patterns)
	if type == "EMOTE" or type == "TEXT_EMOTE" or (configDoEmoteDetection() and message:find(configEmoteDetectionPattern())) then
		message = replaceNameInEmote(message, characterID, type);
		message = detectEmoteAndOOC(type, message);
	end
	
	-- Is there still something to show ?
	if strtrim(message):len() == 0 then
		return true;
	end
	
	local playerLink = "|Hplayer:".. characterID .. ":" .. messageID .. "|h";
	local body;
	if type == "EMOTE" then
		body = format(_G["CHAT_"..type.."_GET"], playerLink .. characterName .. "|h") .. message;
	elseif type == "TEXT_EMOTE" then
		body = message;
		if characterID ~= Globals.player_id and body:sub(1, character:len()) == character then
			body = body:gsub("^([^%s]+)", playerLink .. characterName .. "|h");
		end
	else
		local characterIcon = "";
		local nameWithoutIcon = characterName;
		if configShowNameIcons() and characterName and characterName:find("|T.*|t") then
			characterIcon = characterName:match("(|T.-|t)") .. " ";
			nameWithoutIcon = characterName:gsub("|T.-|t ", "") or characterName;
		end
		nameWithoutIcon = nameWithoutIcon or characterName or "Unknown";
		
		local leftBracket, rightBracket;
		if configChannelReplacement() then
			leftBracket, rightBracket = getNameBrackets();
		else
			leftBracket, rightBracket = "[", "]";
		end
		
		-- custom channel names (only if channel replacement is enabled)
		if configChannelReplacement() then
			if type == "PARTY" then
				body = characterIcon .. configPartyChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			elseif type == "PARTY_LEADER" then
				body = characterIcon .. configPartyLeaderChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			elseif type == "RAID" then
				body = characterIcon .. configRaidChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			elseif type == "RAID_LEADER" then
				body = characterIcon .. configRaidLeaderChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			elseif type == "GUILD" then
				body = characterIcon .. configGuildChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			elseif type == "OFFICER" then
				body = characterIcon .. configOfficerChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			elseif type == "WHISPER" then
				body = characterIcon .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h " .. configWhisperInChannelName() .. ": " .. languageHeader .. message;
			elseif type == "WHISPER_INFORM" then
				body = characterIcon .. configWhisperOutChannelName() .. " " .. playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h: " .. languageHeader .. message;
			else
				body = characterIcon .. format(_G["CHAT_"..type.."_GET"], playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h") .. languageHeader .. message;
			end
		else
			body = characterIcon .. format(_G["CHAT_"..type.."_GET"], playerLink .. leftBracket .. nameWithoutIcon .. rightBracket .. "|h") .. languageHeader .. message;
		end
	end

	--Add Timestamps
	if ( CHAT_TIMESTAMP_FORMAT ) then
		body = BetterDate(CHAT_TIMESTAMP_FORMAT, time()) .. body;
	end

	chatFrame:AddMessage(body, chatInfo.r, chatInfo.g, chatInfo.b, chatInfo.id, false);

	return true;
end

function hooking()
	for _, channel in pairs(POSSIBLE_CHANNELS) do
		ChatFrame_RemoveMessageEventFilter(channel, handleCharacterMessage);
		if configIsChannelUsed(channel) then
			ChatFrame_AddMessageEventFilter(channel, handleCharacterMessage);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onStart()
	local useWIM = WIM ~= nil;

	if useWIM then
		POSSIBLE_CHANNELS = {
			"CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
			"CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
			"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER"
		};
	else
		POSSIBLE_CHANNELS = {
			"CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
			"CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
			"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM"
		};
	end


	NPC_TALK_PATTERNS = {
		[loc("NPC_TALK_SAY_PATTERN")] = "MONSTER_SAY",
		[loc("NPC_TALK_YELL_PATTERN")] = "MONSTER_YELL",
		[loc("NPC_TALK_WHISPER_PATTERN")] = "MONSTER_WHISPER",
	};
	createConfigPage(useWIM);
	hooking();
end

local MODULE_STRUCTURE = {
	["name"] = "Chat frames",
	["description"] = "Global enhancement for chat frames. Use roleplay information, detect emotes and OOC sentences and use colors.",
	["version"] = 1.000,
	["id"] = "trp3_chatframes",
	["onStart"] = onStart,
	["minVersion"] = 3,
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);