----------------------------------------------------------------------------------
-- Total RP 3
-- Character data exchange
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

-- TRP3 imports
local Globals = TRP3_API.globals;
local Utils = TRP3_API.utils;
local get = TRP3_API.profile.getData;
local Comm = TRP3_API.communication;
local loc = TRP3_API.locale.getText;
local log = Utils.log.log;
local Events = TRP3_API.events;
local getPlayerCharacter = TRP3_API.profile.getPlayerCharacter;
local getCharacterExchangeData = TRP3_API.dashboard.getCharacterExchangeData;
local registerInfoTypes = TRP3_API.register.registerInfoTypes;
local isIDIgnored, shouldUpdateInformation = TRP3_API.register.isIDIgnored, TRP3_API.register.shouldUpdateInformation;
local addCharacter = TRP3_API.register.addCharacter;
local saveCurrentProfileID, saveClientInformation, saveInformation = TRP3_API.register.saveCurrentProfileID, TRP3_API.register.saveClientInformation, TRP3_API.register.saveInformation;
local getPlayerCurrentProfileID = TRP3_API.profile.getPlayerCurrentProfileID;
local isUnitIDKnown = TRP3_API.register.isUnitIDKnown;
local playerAPI = TRP3_API.register.player;
local getCharExchangeData = playerAPI.getCharacteristicsExchangeData;
local getAboutExchangeData = playerAPI.getAboutExchangeData;
local getMiscExchangeData = playerAPI.getMiscExchangeData;
local getConfigValue = TRP3_API.configuration.getValue;
local showAlertPopup = TRP3_API.popup.showAlertPopup;

-- WoW imports
local UnitName, UnitIsPlayer, UnitFactionGroup, CheckInteractDistance = UnitName, UnitIsPlayer, UnitFactionGroup, CheckInteractDistance;
local tinsert, time, type, pairs, tonumber = tinsert, time, type, pairs, tonumber;

-- Config keys
local CONFIG_REGISTRE_AUTO_ADD = "register_auto_add";
local CONFIG_NEW_VERSION = "new_version_alert";

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local has_seen_update_alert = false;

local function configIsAutoAdd()
	return getConfigValue(CONFIG_REGISTRE_AUTO_ADD);
end

local function configShowVersionAlert()
	return getConfigValue(CONFIG_NEW_VERSION);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Vernum queries
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local LAST_QUERY = {};
local COOLDOWN_DURATION = 4; -- Should be integer
local VERNUM_QUERY_PREFIX = "VQ";
local VERNUM_R_QUERY_PREFIX = "VR";
local INFO_TYPE_QUERY_PREFIX = "GI";
local INFO_TYPE_SEND_PREFIX = "SI";
local VERNUM_QUERY_PRIORITY = "NORMAL";
local INFO_TYPE_QUERY_PRIORITY = "NORMAL";
local INFO_TYPE_SEND_PRIORITY = "BULK";

local VERNUM_QUERY_INDEX_VERSION = 1;
local VERNUM_QUERY_INDEX_VERSION_DISPLAY = 2;
local VERNUM_QUERY_INDEX_CHARACTER_PROFILE = 3;
local VERNUM_QUERY_INDEX_CHARACTER_CHARACTERISTICS_V = 4;
local VERNUM_QUERY_INDEX_CHARACTER_ABOUT_V = 5;
local VERNUM_QUERY_INDEX_CHARACTER_MISC_V = 6;
local VERNUM_QUERY_INDEX_CHARACTER_CHARACTER_V = 7;

local queryInformationType, createVernumQuery;

local function queryVernum(unitName)
	local query = createVernumQuery();
	Comm.sendObject(VERNUM_QUERY_PREFIX, query, unitName, VERNUM_QUERY_PRIORITY);
end

local function queryMarySueProtocol(unitName)

end

--- Vernum query builder
function createVernumQuery()
	local query = {};
	query[VERNUM_QUERY_INDEX_VERSION] = Globals.version; -- Your TRP3 version (number)
	query[VERNUM_QUERY_INDEX_VERSION_DISPLAY] = Globals.version_display; -- Your TRP3 version (as it should be shown on tooltip)
	-- Character
	query[VERNUM_QUERY_INDEX_CHARACTER_PROFILE] = getPlayerCurrentProfileID() or "";
	query[VERNUM_QUERY_INDEX_CHARACTER_CHARACTERISTICS_V] = get("player/characteristics").v or 0;
	query[VERNUM_QUERY_INDEX_CHARACTER_ABOUT_V] = get("player/about").v or 0;
	query[VERNUM_QUERY_INDEX_CHARACTER_MISC_V] = get("player/misc").v or 0;
	query[VERNUM_QUERY_INDEX_CHARACTER_CHARACTER_V] = get("player/character").v or 1;

	return query;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Incoming vernum queries
-- Check version numbers and perform information queries
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local infoTypeTab = {
	registerInfoTypes.CHARACTERISTICS,
	registerInfoTypes.ABOUT,
	registerInfoTypes.MISC,
	registerInfoTypes.CHARACTER
};

--- Incoming vernum query
-- This is received when another player has "mouseovered" you.
-- His main query is to receive your vernum tab. But you can already read his tab to query information.
local function incomingVernumQuery(structure, senderID, bResponse)
	-- First: Integrity check
	if type(structure) ~= "table"
	or #structure <= 0
	or type(structure[VERNUM_QUERY_INDEX_VERSION]) ~= "number"
	or type(structure[VERNUM_QUERY_INDEX_VERSION_DISPLAY]) ~= "string"
	or type(structure[VERNUM_QUERY_INDEX_CHARACTER_PROFILE]) ~= "string"
	then
		log("Incoming vernum integrity check fails. Sender: " .. senderID);
		return;
	end

	-- First send back or own vernum
	if not bResponse and (not LAST_QUERY[senderID] or time() - LAST_QUERY[senderID] > COOLDOWN_DURATION) then
		local query = createVernumQuery();
		Comm.sendObject(VERNUM_R_QUERY_PREFIX, query, senderID, VERNUM_QUERY_PRIORITY);
	end

	-- Data processing
	local senderVersion = structure[VERNUM_QUERY_INDEX_VERSION];
	local senderVersionText = structure[VERNUM_QUERY_INDEX_VERSION_DISPLAY];
	local senderProfileID = structure[VERNUM_QUERY_INDEX_CHARACTER_PROFILE];

	if configShowVersionAlert() and senderVersion > Globals.version and not has_seen_update_alert then
		showAlertPopup(loc("GEN_NEW_VERSION_AVAILABLE"):format(Globals.version_display, senderVersionText));
		has_seen_update_alert = true;
	end

	if isUnitIDKnown(senderID) or configIsAutoAdd() then
		if not isUnitIDKnown(senderID) then
			addCharacter(senderID);
		end
		saveClientInformation(senderID, Globals.addon_name, senderVersionText, false);
		saveCurrentProfileID(senderID, senderProfileID);

		-- Query specific data, depending on version number.
		local index = VERNUM_QUERY_INDEX_CHARACTER_CHARACTERISTICS_V;
		for _, infoType in pairs(infoTypeTab) do
			if shouldUpdateInformation(senderID, infoType, structure[index]) then
				log(("Should update: %s's %s"):format(senderID, infoType));
				queryInformationType(senderID, infoType);
			end
			index = index + 1;
		end

	end
end

--- Incoming vernum response
-- This is received when you asked a player for his vernum tab and he responses.
-- In that case we shouldn't query him anymore as it would bring an infinite loop.
local function incomingVernumResponseQuery(structure, senderID)
	incomingVernumQuery(structure, senderID, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Query for information
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local CURRENT_QUERY_EXCHANGES = {};

function queryInformationType(unitName, informationType)
	if CURRENT_QUERY_EXCHANGES[unitName] and CURRENT_QUERY_EXCHANGES[unitName][informationType] then
		return; -- Don't ask again for information that are incoming !
	end
	if not CURRENT_QUERY_EXCHANGES[unitName] then
		CURRENT_QUERY_EXCHANGES[unitName] = {};
	end
	CURRENT_QUERY_EXCHANGES[unitName][informationType] = time();
	Comm.sendObject(INFO_TYPE_QUERY_PREFIX, informationType, unitName, INFO_TYPE_QUERY_PRIORITY);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Incoming query for information, and send information
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function incomingInformationType(informationType, senderID)
	local data = nil;
	if informationType == registerInfoTypes.CHARACTERISTICS then
		data = getCharExchangeData();
	elseif informationType == registerInfoTypes.ABOUT then
		data = getAboutExchangeData();
	elseif informationType == registerInfoTypes.MISC then
		data = getMiscExchangeData();
	elseif informationType == registerInfoTypes.CHARACTER then
		data = getCharacterExchangeData();
	end
	if data then
		log(("Send %s info to %s"):format(informationType, senderID));
		Comm.sendObject(INFO_TYPE_SEND_PREFIX, {informationType, data}, senderID, INFO_TYPE_SEND_PRIORITY);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Received information
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function incomingInformationTypeSent(structure, senderID)
	local informationType = structure[1];
	local data = structure[2];

	if not CURRENT_QUERY_EXCHANGES[senderID] or not CURRENT_QUERY_EXCHANGES[senderID][informationType] then
		return; -- We didn't ask for theses information ...
	end

	log(("Received %s's %s info !"):format(senderID, informationType));
	CURRENT_QUERY_EXCHANGES[senderID][informationType] = nil;

	local decodedData = data;
	-- If the data is a string, we assume that it was compressed.
	if type(data) == "string" then
		decodedData = Utils.serial.decompressCodedStructure(decodedData);
	end

	if informationType == registerInfoTypes.CHARACTERISTICS or informationType == registerInfoTypes.ABOUT
	or informationType == registerInfoTypes.MISC or informationType == registerInfoTypes.CHARACTER then
		saveInformation(senderID, informationType, decodedData);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TRIGGERS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

--- Send vernum request to the player
local function sendQuery(unitID)
	if unitID and unitID ~= Globals.player_id and not isIDIgnored(unitID) and (not LAST_QUERY[unitID] or time() - LAST_QUERY[unitID] > COOLDOWN_DURATION) then
		LAST_QUERY[unitID] = time();
		queryVernum(unitID);
		queryMarySueProtocol(unitID);
	end
end
TRP3_API.r.sendQuery = sendQuery;

-- disabling 264 and 271 checks allows for crossfaction
local function onMouseOverCharacter(unitID)
	-- if UnitFactionGroup("player") == UnitFactionGroup("mouseover") then
		sendQuery(unitID);
	-- end
end

local function onTargetChanged()
	local unitID = Utils.str.getUnitID("target");
	if UnitIsPlayer("target") then -- and UnitFactionGroup("player") == UnitFactionGroup("target") then
		sendQuery(unitID);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Check size
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ALERT_FOR_SIZE = 20;

local function checkPlayerDataWeight()
	local totalData = {getCharExchangeData(), getAboutExchangeData(), getMiscExchangeData(), getCharacterExchangeData()};
	local computedSize = Comm.estimateStructureLoad(totalData);
	if computedSize > ALERT_FOR_SIZE then
		log(("Profile too heavy ! It would take %s messages to send."):format(computedSize));
		if getConfigValue("heavy_profile_alert") then
			TRP3_API.ui.tooltip.toast(loc("REG_PLAYER_ALERT_HEAVY_SMALL"), 5);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TYPE_CHARACTER = TRP3_API.ui.misc.TYPE_CHARACTER;

function TRP3_API.register.inits.dataExchangeInit()
	if not TRP3_Register then
		TRP3_Register = {};
	end

	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, profileID)
		if unitID == Globals.player_id then
			checkPlayerDataWeight();
		end
	end);

	-- Listen to the mouse over event
	TRP3_API.events.listenToEvent(TRP3_API.events.MOUSE_OVER_CHANGED, function(targetID, targetMode)
		if targetMode == TYPE_CHARACTER and targetID then
			onMouseOverCharacter(targetID);
		end
	end);
	Utils.event.registerHandler("PLAYER_TARGET_CHANGED", onTargetChanged);

	-- Register prefix for data exchange
	Comm.registerProtocolPrefix(VERNUM_QUERY_PREFIX, incomingVernumQuery);
	Comm.registerProtocolPrefix(VERNUM_R_QUERY_PREFIX, incomingVernumResponseQuery);
	Comm.registerProtocolPrefix(INFO_TYPE_QUERY_PREFIX, incomingInformationType);
	Comm.registerProtocolPrefix(INFO_TYPE_SEND_PREFIX, incomingInformationTypeSent);

	Comm.broadcast.registerCommand(Comm.broadcast.HELLO_CMD, function(sender, version, versionDisplay)
		version = tonumber(version);
		if sender ~= Globals.player_id then
			if configShowVersionAlert() and version > Globals.version and not has_seen_update_alert then
				showAlertPopup(loc("GEN_NEW_VERSION_AVAILABLE"):format(Globals.version_display, versionDisplay));
				has_seen_update_alert = true;
			end
		end
	end);
end