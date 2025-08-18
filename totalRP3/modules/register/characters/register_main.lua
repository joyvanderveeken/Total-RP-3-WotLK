----------------------------------------------------------------------------------
-- Total RP 3
-- Directory : main API
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

-- Public accessor
TRP3_API.register = {
	inits = {},
	player = {},
	ui = {},
	NOTIFICATION_ID_NEW_CHARACTER = "add_character",
};

TRP3_API.register.MENU_LIST_ID = "main_30_register";
TRP3_API.register.MENU_LIST_ID_TAB = "main_31_";

-- imports
local Globals = TRP3_API.globals;
local Utils = TRP3_API.utils;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local log = Utils.log.log;
local buildZoneText = Utils.str.buildZoneText;
local getUnitID = Utils.str.getUnitID;
local UnitRace, UnitIsPlayer, UnitClass = UnitRace, UnitIsPlayer, UnitClass;
local UnitFactionGroup, UnitSex, GetGuildInfo = UnitFactionGroup, UnitSex, GetGuildInfo;
local getDefaultProfile, get = TRP3_API.profile.getDefaultProfile, TRP3_API.profile.getData;
local getPlayerCharacter = TRP3_API.profile.getPlayerCharacter;
local Config = TRP3_API.configuration;
local registerConfigKey = Config.registerConfigKey;
local getConfigValue = Config.getValue;
local Events = TRP3_API.events;
local assert, tostring, time, wipe, strconcat, pairs, tinsert = assert, tostring, time, wipe, strconcat, pairs, tinsert;
local registerMenu, selectMenu = TRP3_API.navigation.menu.registerMenu, TRP3_API.navigation.menu.selectMenu;
local registerPage, setPage = TRP3_API.navigation.page.registerPage, TRP3_API.navigation.page.setPage;
local getCurrentContext, getCurrentPageID = TRP3_API.navigation.page.getCurrentContext, TRP3_API.navigation.page.getCurrentPageID;
local showCharacteristicsTab, showAboutTab, showMiscTab, showNotesTab;
local get = TRP3_API.profile.getData;
local UnitIsPVP = UnitIsPVP;

local EMPTY = Globals.empty;
local NOTIFICATION_ID_NEW_CHARACTER = TRP3_API.register.NOTIFICATION_ID_NEW_CHARACTER;
-- Saved variables references
local profiles, characters;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- SCHEMA
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.register.registerInfoTypes = {
	CHARACTERISTICS = "characteristics",
	ABOUT = "about",
	MISC = "misc",
	CHARACTER = "character",
	NOTES = "notes",
}

local registerInfoTypes = TRP3_API.register.registerInfoTypes;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Tools
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getProfile(profileID)
	assert(profiles[profileID], "Unknown profile ID: " .. tostring(profileID));
	return profiles[profileID];
end

TRP3_API.register.getProfile = getProfile;

local function deleteProfile(profileID, dontFireEvents)
	assert(profiles[profileID], "Unknown profile ID: " .. tostring(profileID));
	-- We shouldn't keep unbounded characters.
	for character, _ in pairs(profiles[profileID].link) do
		if characters[character].profileID == profileID then
			wipe(characters[character]);
			characters[character] = nil;
		end
	end
	local mspOwners = nil;
	if profiles[profileID].msp then
		mspOwners = {};
		for ownerID, _ in pairs(profiles[profileID].link) do
			tinsert(mspOwners, ownerID);
		end
	end
	wipe(profiles[profileID]);
	profiles[profileID] = nil;
	if not dontFireEvents then
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, profileID, nil);
		Events.fireEvent(Events.REGISTER_PROFILE_DELETED, profileID, mspOwners);
	end
end

TRP3_API.register.deleteProfile = deleteProfile;

local function deleteCharacter(unitID)
	assert(characters[unitID], "Unknown unitID: " .. tostring(unitID));
	if characters[unitID].profileID and profiles[characters[unitID].profileID] and profiles[characters[unitID].profileID].link then
		profiles[characters[unitID].profileID].link[unitID] = nil;
	end
	wipe(characters[unitID]);
	characters[unitID] = nil;
end

TRP3_API.register.deleteCharacter = deleteCharacter;

local function isUnitIDKnown(unitID)
	assert(unitID, "Nil unitID");
	return characters[unitID] ~= nil;
end

TRP3_API.register.isUnitIDKnown = isUnitIDKnown;

local function hasProfile(unitID)
	assert(isUnitIDKnown(unitID), "Unknown character: " .. tostring(unitID));
	return characters[unitID].profileID;
end

TRP3_API.register.hasProfile = hasProfile;

local function profileExists(unitID)
	return isUnitIDKnown(unitID) and hasProfile(unitID) and profiles[characters[unitID].profileID];
end

TRP3_API.register.profileExists = profileExists;

local function createUnitIDProfile(unitID)
	assert(characters[unitID].profileID, "UnitID don't have a profileID: " .. unitID);
	assert(not profiles[characters[unitID].profileID], "Profile already exist: " .. characters[unitID].profileID);
	profiles[characters[unitID].profileID] = {};
	profiles[characters[unitID].profileID].link = {};
	return profiles[characters[unitID].profileID];
end

TRP3_API.register.createUnitIDProfile = createUnitIDProfile;

local function getUnitIDProfile(unitID)
	assert(profileExists(unitID), "No profile for character: " .. tostring(unitID));
	return profiles[characters[unitID].profileID];
end

TRP3_API.register.getUnitIDProfile = getUnitIDProfile;

local function getUnitIDCharacter(unitID)
	assert(isUnitIDKnown(unitID), "Unknown character: " .. tostring(unitID));
	return characters[unitID];
end

TRP3_API.register.getUnitIDCharacter = getUnitIDCharacter;

function TRP3_API.register.isUnitKnown(targetType)
	return isUnitIDKnown(getUnitID(targetType));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Main data management
-- For decoupling reasons, the saved variable TRP3_Register shouln'd be used outside this file !
-- Please use all these public method instead.
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- SETTERS

--- Raises error if unknown unitName
-- Link a unitID to a profileID. This link is bidirectional.
function TRP3_API.register.saveCurrentProfileID(unitID, currentProfileID, isMSP)
	local character = getUnitIDCharacter(unitID);
	local oldProfileID = character.profileID;
	character.profileID = currentProfileID;
	-- Search if this character was bounded to another profile
	for profileID, profile in pairs(profiles) do
		if profile.link and profile.link[unitID] then
			profile.link[unitID] = nil; -- unbound
		end
	end
	if not profileExists(unitID) then
		createUnitIDProfile(unitID);
	end
	local profile = getProfile(currentProfileID);
	profile.link[unitID] = 1; -- bound
	profile.msp = isMSP;

	if oldProfileID ~= currentProfileID then
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, unitID, currentProfileID, nil);
	end
end

--- Raises error if unknown unitName
function TRP3_API.register.saveClientInformation(unitID, client, clientVersion, msp)
	local character = getUnitIDCharacter(unitID);
	character.client = client;
	character.clientVersion = clientVersion;
	character.msp = msp;
end

--- Raises error if unknown unitName
local function saveCharacterInformation(unitID, race, class, gender, faction, time, zone, guild)
	local character = getUnitIDCharacter(unitID);
	character.class = class;
	character.race = race;
	character.gender = gender;
	character.faction = faction;
	character.guild = guild;
	if hasProfile(unitID) then
		local profile = getProfile(character.profileID);
		profile.time = time;
		profile.zone = zone;
	end
end

TRP3_API.register.saveCharacterInformation = saveCharacterInformation;

--- Raises error if unknown unitID or unit hasn't profile ID
function TRP3_API.register.saveInformation(unitID, informationType, data)
	local profile = getUnitIDProfile(unitID);
	if profile[informationType] then
		wipe(profile[informationType]);
	end
	profile[informationType] = data;
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, unitID, hasProfile(unitID), informationType);
end

--- Raises error if KNOWN unitID
function TRP3_API.register.addCharacter(unitID)
	assert(unitID and unitID ~= "", "Malformed unitID");
	assert(not isUnitIDKnown(unitID), "Already known character: " .. tostring(unitID));
	characters[unitID] = {};
	log("Added to the register: " .. unitID);
end

-- GETTERS

--- Raises error if unknown unitName
local function getUnitIDCurrentProfile(unitID)
	assert(isUnitIDKnown(unitID), "Unknown character: " .. tostring(unitID));
	if hasProfile(unitID) then
		return getUnitIDProfile(unitID);
	end
end

TRP3_API.register.getUnitIDCurrentProfile = getUnitIDCurrentProfile;

--- Raises error if unknown unitID
function TRP3_API.register.shouldUpdateInformation(unitID, infoType, version)
	--- Raises error if unit hasn't profile ID or no profile exists
	local profile = getUnitIDProfile(unitID);
	return not profile[infoType] or not profile[infoType].v or profile[infoType].v ~= version;
end

function TRP3_API.register.getCharacterList()
	return characters;
end

--- Raises error if unknown unitID
function TRP3_API.register.getUnitIDCharacter(unitID)
	if unitID == Globals.player_id then
		return Globals.player_character;
	end
	assert(characters[unitID], "Unknown character ID: " .. tostring(unitID));
	return characters[unitID];
end

function TRP3_API.register.getProfileList()
	return profiles;
end

function TRP3_API.register.getUnitRPName(targetType)
	local unitName = UnitName(targetType);
	local unitID = getUnitID(targetType);
	if unitID then
		if unitID == Globals.player_id then
			unitName = TRP3_API.register.getPlayerCompleteName(true);
		elseif isUnitIDKnown(unitID) and profileExists(unitID) then
			local profile = getUnitIDProfile(unitID);
			if profile.characteristics then
				unitName = TRP3_API.register.getCompleteName(profile.characteristics, unitName, true);
			end
		end
	end
	return unitName or UNKNOWN;
end

TRP3_API.r.name = TRP3_API.register.getUnitRPName;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Tools
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tabGroup; -- Reference to the tab panel tabs group

local function onMouseOver(...)
	local unitID = getUnitID("mouseover");
	if unitID and isUnitIDKnown(unitID) then
		local _, race = UnitRace("mouseover");
		local _, class, _ = UnitClass("mouseover");
		local englishFaction = UnitFactionGroup("mouseover");
		saveCharacterInformation(unitID, race, class, UnitSex("mouseover"), englishFaction, time(), buildZoneText(), GetGuildInfo("mouseover"));
	end
end

local function onInformationUpdated(profileID, infoType)
	if getCurrentPageID() == "player_main" then
		local context = getCurrentContext();
		assert(context, "No context for page player_main !");
		if not context.isPlayer and profileID == context.profileID then
			if infoType == registerInfoTypes.ABOUT and tabGroup.current == 2 then
				showAboutTab();
			elseif (infoType == registerInfoTypes.CHARACTERISTICS or infoType == registerInfoTypes.CHARACTER) and tabGroup.current == 1 then
				showCharacteristicsTab();
			elseif infoType == registerInfoTypes.MISC and tabGroup.current == 3 then
				showMiscTab();
			elseif infoType == registerInfoTypes.NOTES and tabGroup.current == 4 then
				showNotesTab();
			end
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI: TAB MANAGEMENT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_RegisterMainTabBar", TRP3_RegisterMain);
	frame:SetSize(400, 30);
	frame:SetPoint("TOPLEFT", 17, -5);
	frame:SetFrameLevel(1);
	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc("REG_PLAYER_CARACT"), 1, 70 },
			{ loc("REG_PLAYER_ABOUT"), 2, 110 },
			{ loc("REG_PLAYER_PEEK"), 3, 130 },
			{ loc("REG_PLAYER_NOTES"), 4, 110 }
		},
		function(tabWidget, value)
		-- Clear all
			TRP3_RegisterCharact:Hide();
			TRP3_RegisterAbout:Hide();
			TRP3_RegisterMisc:Hide();
			TRP3_RegisterNotes:Hide()
			if value == 1 then
				showCharacteristicsTab();
			elseif value == 2 then
				showAboutTab();
			elseif value == 3 then
				showMiscTab();
			elseif value == 4 then
				showNotesTab();
			end
		end,
		-- Confirmation callback
		function(callback)
			if getCurrentContext() and getCurrentContext().isEditMode then
				TRP3_API.popup.showConfirmPopup(loc("REG_PLAYER_CHANGE_CONFIRM"),
					function()
						callback();
					end);
			else
				callback();
			end
		end);
	TRP3_API.register.player.tabGroup = tabGroup;
end

local function showTabs(context)
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	
	-- Notes tab is now always visible - allows private notes about any character
	tabGroup:SetTabVisible(4, true);
	
	tabGroup:SelectTab(1);
end

function TRP3_API.register.ui.getSelectedTabIndex()
	return tabGroup.current;
end

function TRP3_API.register.ui.isTabSelected(infoType)
	return (infoType == registerInfoTypes.CHARACTERISTICS and tabGroup.current == 1)
			or (infoType == registerInfoTypes.ABOUT and tabGroup.current == 2)
			or (infoType == registerInfoTypes.MISC and tabGroup.current == 3)
			or (infoType == registerInfoTypes.NOTES and tabGroup.current == 4);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CLEANUP
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function cleanupCharacters()
	for unitID, character in pairs(characters) do
		if character.profileID and (not profiles[character.profileID] or not profiles[character.profileID].link[unitID]) then
			character.profileID = nil;
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.register.init()
	showCharacteristicsTab = TRP3_API.register.ui.showCharacteristicsTab;
	showAboutTab = TRP3_API.register.ui.showAboutTab;
	showMiscTab = TRP3_API.register.ui.showMiscTab;
	showNotesTab = TRP3_API.register.ui.showNotesTab;

	if not TRP3_Register then
		TRP3_Register = {};
	end
	if not TRP3_Register.character then
		TRP3_Register.character = {};
	end
	if not TRP3_Register.profiles then
		TRP3_Register.profiles = {};
	end
	profiles = TRP3_Register.profiles;
	characters = TRP3_Register.character;

	cleanupCharacters();

	-- Listen to the mouse over event
	Utils.event.registerHandler("UPDATE_MOUSEOVER_UNIT", onMouseOver);

	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, profileID, dataType)
		onInformationUpdated(profileID, dataType);
	end);


	registerMenu({
		id = "main_10_player",
		text = loc("REG_PLAYER"),
		onSelected = function() selectMenu("main_12_player_character") end,
	});

	registerMenu({
		id = "main_11_profiles",
		text = loc("PR_PROFILES"),
		onSelected = function() setPage("player_profiles"); end,
		isChildOf = "main_10_player",
	});

	local currentPlayerMenu = {
		id = "main_12_player_character",
		text = get("player/characteristics/FN") or Globals.player,
		onSelected = function()
			setPage("player_main", {
				profile = get("player"),
				isPlayer = true,
			});
		end,
		isChildOf = "main_10_player",
	};
	registerMenu(currentPlayerMenu);
	local refreshMenu = TRP3_API.navigation.menu.rebuildMenu;
	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, profileID, dataType)
		if unitID == Globals.player_id and (not dataType or dataType == "characteristics") then
			currentPlayerMenu.text = get("player/characteristics/FN") or Globals.player;
			refreshMenu();
		end
	end);

	registerPage({
		id = "player_main",
		templateName = "TRP3_RegisterMain",
		frameName = "TRP3_RegisterMain",
		frame = TRP3_RegisterMain,
		onPagePostShow = function(context)
			showTabs(context);
		end,
	});

	registerConfigKey("register_about_use_vote", true);
	registerConfigKey("register_auto_add", true);

	local CONFIG_ENABLE_MAP_LOCATION = "register_map_location";
	local CONFIG_DISABLE_MAP_LOCATION_ON_OOC = "register_map_location_ooc";
	local CONFIG_DISABLE_MAP_LOCATION_ON_PVP = "register_map_location_pvp";
	local CONFIG_DISABLE_MAP_LOCATION_ON_CROSSFACTION = "register_map_location_crossfaction";
	local CONFIG_ENABLE_WARBORN_MODE = "register_warborn_mode";
	local CONFIG_MAP_MARKERS_HIGH_STRATA = "register_map_markers_high_strata";
	local CONFIG_MAP_AUTO_SCAN = "register_map_auto_scan";
	local CONFIG_MAP_MARKER_ICON_TYPE = "register_map_marker_icon_type";

	registerConfigKey(CONFIG_ENABLE_MAP_LOCATION, true);
	registerConfigKey(CONFIG_DISABLE_MAP_LOCATION_ON_OOC, false);
	registerConfigKey(CONFIG_DISABLE_MAP_LOCATION_ON_PVP, false);
	registerConfigKey(CONFIG_DISABLE_MAP_LOCATION_ON_CROSSFACTION, false);
	registerConfigKey(CONFIG_ENABLE_WARBORN_MODE, false);
	registerConfigKey(CONFIG_MAP_MARKERS_HIGH_STRATA, false);
	registerConfigKey(CONFIG_MAP_AUTO_SCAN, true);
	registerConfigKey(CONFIG_MAP_MARKER_ICON_TYPE, 1); -- 1=race, 2=faction, 3=default

	-- Build configuration page
	TRP3_API.register.CONFIG_STRUCTURE = {
		id = "main_config_register",
		menuText = loc("CO_REGISTER"),
		pageText = loc("CO_REGISTER"),
		elements = {
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_REGISTER_ABOUT_VOTE"),
				configKey = "register_about_use_vote",
				help = loc("CO_REGISTER_ABOUT_VOTE_TT")
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_REGISTER_AUTO_ADD"),
				configKey = "register_auto_add",
				help = loc("CO_REGISTER_AUTO_ADD_TT")
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_LOCATION"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_ACTIVATE"),
				help = loc("CO_LOCATION_ACTIVATE_TT"),
				configKey = CONFIG_ENABLE_MAP_LOCATION,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_DISABLE_OOC"),
				help = loc("CO_LOCATION_DISABLE_OOC_TT"),
				configKey = CONFIG_DISABLE_MAP_LOCATION_ON_OOC,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_DISABLE_PVP"),
				help = loc("CO_LOCATION_DISABLE_PVP_TT"),
				configKey = CONFIG_DISABLE_MAP_LOCATION_ON_PVP,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_DISABLE_CROSSFACTION"),
				help = loc("CO_LOCATION_DISABLE_CROSSFACTION_TT"),
				configKey = CONFIG_DISABLE_MAP_LOCATION_ON_CROSSFACTION,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_WARBORN"),
				help = loc("CO_LOCATION_WARBORN_TT"),
				configKey = CONFIG_ENABLE_WARBORN_MODE,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_HIGH_STRATA"),
				help = loc("CO_LOCATION_HIGH_STRATA_TT"),
				configKey = CONFIG_MAP_MARKERS_HIGH_STRATA,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_LOCATION_AUTO_SCAN"),
				help = loc("CO_LOCATION_AUTO_SCAN_TT"),
				configKey = CONFIG_MAP_AUTO_SCAN,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationTooltip_MapMarkerIconType",
				title = loc("CO_LOCATION_MARKER_ICON_TYPE"),
				help = loc("CO_LOCATION_MARKER_ICON_TYPE_TT"),
				listContent = {
					{ loc("CO_LOCATION_MARKER_ICON_RACE"), 1 },
					{ loc("CO_LOCATION_MARKER_ICON_FACTION"), 2 },
					{ loc("CO_LOCATION_MARKER_ICON_DEFAULT"), 3 }
				},
				configKey = CONFIG_MAP_MARKER_ICON_TYPE,
			}
		}
	};
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_FINISH, function()
		Config.registerConfigurationPage(TRP3_API.register.CONFIG_STRUCTURE);
	end);

	local function locationEnabled()
		if getConfigValue(CONFIG_ENABLE_WARBORN_MODE) then
			return getConfigValue(CONFIG_ENABLE_MAP_LOCATION);
		end
		
		-- Normal logic: check OOC and PVP restrictions
		return getConfigValue(CONFIG_ENABLE_MAP_LOCATION)
			and (not getConfigValue(CONFIG_DISABLE_MAP_LOCATION_ON_OOC) or get("player/character/RP") ~= 2)
			and (not getConfigValue(CONFIG_DISABLE_MAP_LOCATION_ON_PVP) or not UnitIsPVP("player"));
	end

	-- Initialization
	TRP3_API.register.inits.characteristicsInit();
	TRP3_API.register.inits.aboutInit();
	TRP3_API.register.inits.glanceInit();
	TRP3_API.register.inits.miscInit();
	TRP3_API.register.inits.dataExchangeInit();
	if TRP3_API.register.inits.notesInit then
		TRP3_API.register.inits.notesInit();
	end
	wipe(TRP3_API.register.inits);
	TRP3_API.register.inits = nil; -- Prevent init function to be called again, and free them from memory

	createTabBar();

	local CHARACTER_SCAN_COMMAND = "CSCAN";
	local GetCurrentMapAreaID, SetMapToCurrentZone, GetPlayerMapPosition = GetCurrentMapAreaID, SetMapToCurrentZone, GetPlayerMapPosition;
	local SetMapByID, tonumber, broadcast = SetMapByID, tonumber, TRP3_API.communication.broadcast;
	local UnitInParty = UnitInParty;
	local Ambiguate, tContains = Ambiguate, tContains;
	local phasedZones = {
		971, -- Alliance garrison
		976  -- Horde garrison
	};

	local function playersCanSeeEachOthers(sender)
		local currentMapID = GetCurrentMapAreaID();
		if tContains(phasedZones, currentMapID) then
			return UnitInParty(sender);
		else
			return true;
		end
	end

	TRP3_API.map.registerScan({
		id = "playerScan",
		buttonText = "Scan for characters",
		scan = function()
			local zoneID = GetCurrentMapAreaID();
			broadcast.broadcast(CHARACTER_SCAN_COMMAND, zoneID);
		end,
		scanTitle = "Characters",
		scanCommand = CHARACTER_SCAN_COMMAND,
		scanResponder = function(sender, zoneID)
			if locationEnabled() and playersCanSeeEachOthers(sender) then
				local currentMapID = GetCurrentMapAreaID();
				TRP3_WorldMapButton.doNotHide = true;
				local newMapID = currentMapID;
				if newMapID == tonumber(zoneID) then
					local x, y = GetPlayerMapPosition("player");
					if x and y and x ~= 0 and y ~= 0 then
					local isPVP = UnitIsPVP("player");
					local faction = UnitFactionGroup("player");
					local _, race = UnitRace("player");
					local gender = UnitSex("player");
					
					isPVP = isPVP and true or false;
					
					-- check cross-faction in trp3 directory
					if getConfigValue(CONFIG_DISABLE_MAP_LOCATION_ON_CROSSFACTION) then
						local senderFaction = nil;
						if isUnitIDKnown(sender) then
							local senderCharacter = getUnitIDCharacter(sender);
							senderFaction = senderCharacter.faction;
						end
						if senderFaction and senderFaction ~= faction then
							return;
						end
					end
					
					local factionToSend, raceToSend, genderToSend;
					
					-- determine scanner's faction
					local scannerFaction = nil;
					if isUnitIDKnown(sender) then
						local senderCharacter = getUnitIDCharacter(sender);
						scannerFaction = senderCharacter.faction;
					else
						if getConfigValue(CONFIG_DISABLE_MAP_LOCATION_ON_CROSSFACTION) then
							scannerFaction = faction; -- Same as our faction
						end
					end
					
					local shouldSendData = false;
					
					if getConfigValue(CONFIG_ENABLE_WARBORN_MODE) then
						-- warborn, send everything
						factionToSend = faction;
						raceToSend = race;
						genderToSend = gender;
						shouldSendData = true;
					elseif not isPVP then
						-- pvp disabled, send everything
						factionToSend = faction;
						raceToSend = race;
						genderToSend = gender;
						shouldSendData = true;
					elseif scannerFaction and scannerFaction == faction then
						-- pvp flagged && same faction, send data 
						factionToSend = faction;
						raceToSend = race;
						genderToSend = gender;
						shouldSendData = true;
					else
						-- pvp flagged && different/unknown faction: don't send data at all
						shouldSendData = false;
					end
					
					if shouldSendData then
						-- combine flags to dodge arg limit
						local characterData = (raceToSend or "") .. "|" .. (genderToSend or "") .. "|" .. (factionToSend or "");
						
						broadcast.sendP2PMessage(sender, CHARACTER_SCAN_COMMAND, x, y, zoneID, Globals.addon_name_short, isPVP, characterData);
					end
					end
				end

				-- restores the original map, issue popped up on Teldrassil (triggering a scan moved it to Darkshore, resulting in no characters found)
				if not getConfigValue(CONFIG_MAP_AUTO_SCAN) then
					if currentMapID ~= newMapID then
						SetMapByID(currentMapID);
					end
				end
				TRP3_WorldMapButton.doNotHide = false;
			end;
		end,
		canScan = function()
			return locationEnabled();
		end,
		scanAssembler = function(saveStructure, sender, x, y, mapId, addon, isPVP, characterData)
			if playersCanSeeEachOthers(sender) then
				if isPVP ~= nil then
					isPVP = (isPVP == "true");
				else
					isPVP = false;
				end

				-- parse characterdata (707)
				local race, gender, faction = nil, nil, nil;
				if characterData then
					local parts = {};
					local current = "";
					for i = 1, #characterData do
						local char = characterData:sub(i, i);
						if char == "|" then
							table.insert(parts, current);
							current = "";
						else
							current = current .. char;
						end
					end
					table.insert(parts, current);
					
					race = (parts[1] and parts[1] ~= "") and parts[1] or nil;
					gender = (parts[2] and parts[2] ~= "") and tonumber(parts[2]) or nil;
					faction = (parts[3] and parts[3] ~= "") and parts[3] or nil;
				end

				saveStructure[sender] = { 
					x = x, 
					y = y, 
					mapId = mapId, 
					addon = addon,
					isPVP = isPVP,
					race = race,
					gender = gender,
					faction = faction
				};
			end
		end,
		scanComplete = function(saveStructure)
		end,
		scanMarkerDecorator = function(characterID, entry, marker)
			local line = characterID;
			
			-- player char
			if characterID == Globals.player_id then
				local playerData = get("player/characteristics");
				if playerData then
					line = TRP3_API.register.getCompleteName(playerData, characterID, true);
					if playerData.CH then
						line = "|cff" .. playerData.CH .. line;
					end
				end
			-- other known chars
			elseif isUnitIDKnown(characterID) and getUnitIDCurrentProfile(characterID) then
				local profile = getUnitIDCurrentProfile(characterID);
				line = TRP3_API.register.getCompleteName(profile.characteristics, characterID, true);
				if profile.characteristics and profile.characteristics.CH then
					line = "|cff" .. profile.characteristics.CH .. line;
				end
			end
			
			marker.scanLine = line;
		end,
		scanDuration = 2.5;
	});
end