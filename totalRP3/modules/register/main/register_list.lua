----------------------------------------------------------------------------------
-- Total RP 3
-- Directory
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
local Globals, Events = TRP3_API.globals, TRP3_API.events;
local Utils = TRP3_API.utils;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local get = TRP3_API.profile.getData;
local assert, table, _G, date, pairs, error, tinsert, wipe, time = assert, table, _G, date, pairs, error, tinsert, wipe, time;
local isUnitIDKnown, getCharacterList = TRP3_API.register.isUnitIDKnown, TRP3_API.register.getCharacterList;
local unitIDToInfo, tsize = Utils.str.unitIDToInfo, Utils.table.size;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local initList = TRP3_API.ui.list.initList;
local getClassTexture = TRP3_API.ui.misc.getClassTexture;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local isMenuRegistered = TRP3_API.navigation.menu.isMenuRegistered;
local registerMenu, selectMenu, openMainFrame = TRP3_API.navigation.menu.registerMenu, TRP3_API.navigation.menu.selectMenu, TRP3_API.navigation.openMainFrame;
local registerPage, setPage = TRP3_API.navigation.page.registerPage, TRP3_API.navigation.page.setPage;
local setupFieldSet = TRP3_API.ui.frame.setupFieldPanel;
local getUnitIDCharacter = TRP3_API.register.getUnitIDCharacter;
local getUnitIDProfile = TRP3_API.register.getUnitIDProfile;
local hasProfile = TRP3_API.register.hasProfile;
local getCompleteName, getPlayerCompleteName = TRP3_API.register.getCompleteName, TRP3_API.register.getPlayerCompleteName;
local TRP3_RegisterListEmpty = TRP3_RegisterListEmpty;
local getProfile, getProfileList = TRP3_API.register.getProfile, TRP3_API.register.getProfileList;
local getIgnoredList, unignoreID, isIDIgnored = TRP3_API.register.getIgnoredList, TRP3_API.register.unignoreID, TRP3_API.register.isIDIgnored;
local getRelationText, getRelationTooltipText = TRP3_API.register.relation.getRelationText, TRP3_API.register.relation.getRelationTooltipText;
local unregisterMenu = TRP3_API.navigation.menu.unregisterMenu;
local displayDropDown, showAlertPopup, showConfirmPopup = TRP3_API.ui.listbox.displayDropDown, TRP3_API.popup.showAlertPopup, TRP3_API.popup.showConfirmPopup;
local showTextInputPopup = TRP3_API.popup.showTextInputPopup;
local deleteProfile, deleteCharacter, getProfileList = TRP3_API.register.deleteProfile, TRP3_API.register.deleteCharacter, TRP3_API.register.getProfileList;
local toast = TRP3_API.ui.tooltip.toast;
local ignoreID = TRP3_API.register.ignoreID;
local refreshList;
local NOTIFICATION_ID_NEW_CHARACTER = TRP3_API.register.NOTIFICATION_ID_NEW_CHARACTER;
local getCurrentPageID = TRP3_API.navigation.page.getCurrentPageID;
local checkGlanceActivation = TRP3_API.register.checkGlanceActivation;
local getRelationColors = TRP3_API.register.relation.getRelationColors;
local safeMatch = TRP3_API.utils.str.safeMatch;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local REGISTER_LIST_PAGEID = "register_list";
local playerMenu = "main_10_player";
local currentlyOpenedProfilePrefix = TRP3_API.register.MENU_LIST_ID_TAB;
local REGISTER_PAGE = TRP3_API.register.MENU_LIST_ID;

local function openPage(profileID)
	local profile = getProfile(profileID);
	if isMenuRegistered(currentlyOpenedProfilePrefix .. profileID) then
		-- If the character already has his "tab", simply open it
		selectMenu(currentlyOpenedProfilePrefix .. profileID);
	else
		-- Else, create a new menu entry and open it.
		local tabText = UNKNOWN;
		if profile.characteristics and profile.characteristics.FN then
			tabText = profile.characteristics.FN;
		end
		registerMenu({
			id = currentlyOpenedProfilePrefix .. profileID,
			text = tabText,
			onSelected = function() setPage("player_main", {profile = profile, profileID = profileID}) end,
			isChildOf = REGISTER_PAGE,
			closeable = true,
			icon = "Interface\\ICONS\\pet_type_humanoid",
		});
		selectMenu(currentlyOpenedProfilePrefix .. profileID);
	end
end

local function openPageByUnitID(unitID)
	if unitID == Globals.player_id then
		selectMenu(playerMenu);
	elseif isUnitIDKnown(unitID) and hasProfile(unitID) then
		openPage(hasProfile(unitID));
	end
end
TRP3_API.register.openPageByUnitID = openPageByUnitID;


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local sortingType = 1;

local function switchNameSorting()
	sortingType = sortingType == 2 and 1 or 2;
	refreshList();
end

local function switchInfoSorting()
	sortingType = sortingType == 4 and 3 or 4;
	refreshList();
end

local function nameComparator(elem1, elem2)
	return elem1[2]:lower() < elem2[2]:lower();
end

local function nameComparatorInverted(elem1, elem2)
	return elem1[2]:lower() > elem2[2]:lower();
end

local function infoComparator(elem1, elem2)
	return elem1[3]:lower() < elem2[3]:lower();
end

local function infoComparatorInverted(elem1, elem2)
	return elem1[3]:lower() > elem2[3]:lower();
end

local comparators = {
	nameComparator, nameComparatorInverted, infoComparator, infoComparatorInverted
}

local function getCurrentComparator()
	return comparators[sortingType];
end

local ARROW_DOWN = "Interface\\Buttons\\Arrow-Down-Up";
local ARROW_UP = "Interface\\Buttons\\Arrow-Up-Up";
local ARROW_SIZE = 15;

local function getComparatorArrows()
	local nameArrow, relationArrow = "", "";
	if sortingType == 1 then
		nameArrow = " |T" .. ARROW_DOWN .. ":" .. ARROW_SIZE .. "|t";
	elseif sortingType == 2 then
		nameArrow = " |T" .. ARROW_UP .. ":" .. ARROW_SIZE .. "|t";
	elseif sortingType == 3 then
		relationArrow = " |T" .. ARROW_DOWN .. ":" .. ARROW_SIZE .. "|t";
	elseif sortingType == 4 then
		relationArrow = " |T" .. ARROW_UP .. ":" .. ARROW_SIZE .. "|t";
	end
	return nameArrow, relationArrow;
end

local MODE_CHARACTER, MODE_PETS, MODE_IGNORE = 1, 2, 3;
local selectedIDs = {};
local ICON_SIZE = 30;
local currentMode = 1;
local DATE_FORMAT = "%d/%m/%y %H:%M";
local IGNORED_ICON = Utils.str.texture("Interface\\Buttons\\UI-GroupLoot-Pass-Down", 15);
local GLANCE_ICON = Utils.str.texture("Interface\\MINIMAP\\TRACKING\\None", 15);
local NEW_ABOUT_ICON = Utils.str.texture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up", 15);

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI : CHARACTERS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local characterLines = {};

local function decorateCharacterLine(line, characterIndex)
	local profileID = characterLines[characterIndex][1];
	local profile = getProfile(profileID);
	line.id = profileID;

	local name = getCompleteName(profile.characteristics or {}, UNKNOWN, true);
	local leftTooltipTitle, leftTooltipText = name, "";

	_G[line:GetName().."Name"]:SetText(name);
	if profile.characteristics and profile.characteristics.IC then
		leftTooltipTitle = Utils.str.icon(profile.characteristics.IC, ICON_SIZE) .. " " .. name;
	end

	local hasGlance = profile.misc and profile.misc.PE and checkGlanceActivation(profile.misc.PE);
	local hasNewAbout = profile.about and not profile.about.read;

	local atLeastOneIgnored = false;
	_G[line:GetName().."Info2"]:SetText("");
	if profile.link and tsize(profile.link) > 0 then
		leftTooltipText = leftTooltipText .. loc("REG_LIST_CHAR_TT_CHAR");
		for unitID, _ in pairs(profile.link) do
			local unitName = unitIDToInfo(unitID);
			if isIDIgnored(unitID) then
				leftTooltipText = leftTooltipText .. "\n|cffff0000 - " .. unitName .. IGNORED_ICON .. " " .. loc("REG_LIST_CHAR_IGNORED");
				atLeastOneIgnored = true;
			else
				leftTooltipText = leftTooltipText .. "\n|cff00ff00 - " .. unitName;
			end
		end
	else
		leftTooltipText = leftTooltipText .. "|cffffff00" .. loc("REG_LIST_CHAR_TT_CHAR_NO");
	end

	if profile.time and profile.zone then
		local formatDate = date(DATE_FORMAT, profile.time);
		leftTooltipText = leftTooltipText .. "\n|r" .. loc("REG_LIST_CHAR_TT_DATE"):format(formatDate, profile.zone);
	end

	-- Middle column : relation
	local relation, relationRed, relationGreen, relationBlue = getRelationText(profileID), getRelationColors(profileID);
	local color = Utils.color.colorCode(relationRed * 255, relationGreen * 255, relationBlue * 255);
	if relation:len() > 0 then
		local middleTooltipTitle, middleTooltipText = relation, getRelationTooltipText(profileID, profile);
		setTooltipForSameFrame(_G[line:GetName().."ClickMiddle"], "TOPLEFT", 0, 5, middleTooltipTitle, color .. middleTooltipText);
	else
		setTooltipForSameFrame(_G[line:GetName().."ClickMiddle"]);
	end
	_G[line:GetName().."Info"]:SetText(color .. relation);

	-- Third column : flags
	local rightTooltipTitle, rightTooltipText, flags;
	if atLeastOneIgnored then
		if not rightTooltipText then rightTooltipText = "" else rightTooltipText = rightTooltipText .. "\n" end
		if not flags then flags = "" else flags = flags .. " " end
		flags = flags .. IGNORED_ICON;
		rightTooltipText = rightTooltipText .. IGNORED_ICON .. " " .. loc("REG_LIST_CHAR_TT_IGNORE");
	end
	if hasGlance then
		if not rightTooltipText then rightTooltipText = "" else rightTooltipText = rightTooltipText .. "\n" end
		if not flags then flags = "" else flags = flags .. " " end
		flags = flags .. GLANCE_ICON;
		rightTooltipText = rightTooltipText .. GLANCE_ICON .. " " .. loc("REG_LIST_CHAR_TT_GLANCE");
	end
	if hasNewAbout then
		if not rightTooltipText then rightTooltipText = "" else rightTooltipText = rightTooltipText .. "\n" end
		if not flags then flags = "" else flags = flags .. " " end
		flags = flags .. NEW_ABOUT_ICON;
		rightTooltipText = rightTooltipText .. NEW_ABOUT_ICON .. " " .. loc("REG_LIST_CHAR_TT_NEW_ABOUT");
	end
	if rightTooltipText then
		setTooltipForSameFrame(_G[line:GetName().."ClickRight"], "TOPLEFT", 0, 5, loc("REG_LIST_FLAGS"), rightTooltipText);
	else
		setTooltipForSameFrame(_G[line:GetName().."ClickRight"]);
	end
	_G[line:GetName().."Info2"]:SetText(flags);

	_G[line:GetName().."Select"]:SetChecked(selectedIDs[profileID]);
	_G[line:GetName().."Select"]:Show();

	setTooltipForSameFrame(_G[line:GetName().."Click"], "TOPLEFT", 0, 5, leftTooltipTitle, leftTooltipText .. "\n\n|cffffff00" .. loc("REG_LIST_CHAR_TT"));
end

local function getCharacterLines()
	local nameSearch = TRP3_RegisterListFilterCharactName:GetText():lower();
	local guildSearch = TRP3_RegisterListFilterCharactGuild:GetText():lower();
	local profileList = getProfileList();
	local fullSize = tsize(profileList);
	wipe(characterLines);

	for profileID, profile in pairs(profileList) do
		local nameIsConform, guildIsConform = false, false;

		-- Defines if at least one character is conform to the search criteria
		for unitID, _ in pairs(profile.link) do
			local unitName = unitIDToInfo(unitID);
			if safeMatch(unitName:lower(), nameSearch) then
				nameIsConform = true;
			end
			local character = getUnitIDCharacter(unitID);
			if character.guild and safeMatch(character.guild:lower(), guildSearch) then
				guildIsConform = true;
			end
		end
		local completeName = getCompleteName(profile.characteristics or {}, "", true);
		if not nameIsConform and safeMatch(completeName:lower(), nameSearch) then
			nameIsConform = true;
		end

		nameIsConform = nameIsConform or nameSearch:len() == 0;
		guildIsConform = guildIsConform or guildSearch:len() == 0;

		if nameIsConform and guildIsConform then
			tinsert(characterLines, {profileID, completeName, getRelationText(profileID)});
		end
	end

	table.sort(characterLines, getCurrentComparator());

	local lineSize = #characterLines;
	if lineSize == 0 then
		if fullSize == 0 then
			TRP3_RegisterListEmpty:SetText(loc("REG_LIST_CHAR_EMPTY"));
		else
			TRP3_RegisterListEmpty:SetText(loc("REG_LIST_CHAR_EMPTY2"));
		end
	end
	setupFieldSet(TRP3_RegisterListCharactFilter, loc("REG_LIST_CHAR_FILTER"):format(lineSize, fullSize), 200);

	local nameArrow, relationArrow = getComparatorArrows();
	TRP3_RegisterListHeaderName:SetText(loc("REG_PLAYER") .. nameArrow);
	TRP3_RegisterListHeaderInfo:SetText(loc("REG_RELATION") .. relationArrow);
	TRP3_RegisterListHeaderInfoTT:Enable();
	TRP3_RegisterListHeaderNameTT:Enable();
	TRP3_RegisterListHeaderInfo2:SetText(loc("REG_LIST_FLAGS"));
	TRP3_RegisterListHeaderActions:Show();

	return characterLines;
end

local MONTH_IN_SECONDS = 2592000;

local function onCharactersActionSelected(value, button)
	-- PURGES
	if value == "purge_time" then
		local profiles = getProfileList();
		local profilesToPurge = {};
		for profileID, profile in pairs(profiles) do
			if profile.time and time() - profile.time > MONTH_IN_SECONDS then
				tinsert(profilesToPurge, profileID);
			end
		end
		if #profilesToPurge == 0 then
			showAlertPopup(loc("REG_LIST_ACTIONS_PURGE_TIME_C"):format(loc("REG_LIST_ACTIONS_PURGE_EMPTY")));
		else
			showConfirmPopup(loc("REG_LIST_ACTIONS_PURGE_TIME_C"):format(loc("REG_LIST_ACTIONS_PURGE_COUNT"):format(#profilesToPurge)), function()
				for _, profileID in pairs(profilesToPurge) do
					deleteProfile(profileID, true);
				end
				Events.fireEvent(Events.REGISTER_DATA_UPDATED);
				Events.fireEvent(Events.REGISTER_PROFILE_DELETED);
				refreshList();
			end);
		end
	elseif value == "purge_unlinked" then
		local profiles = getProfileList();
		local profilesToPurge = {};
		for profileID, profile in pairs(profiles) do
			if not profile.link or tsize(profile.link) == 0 then
				tinsert(profilesToPurge, profileID);
			end
		end
		if #profilesToPurge == 0 then
			showAlertPopup(loc("REG_LIST_ACTIONS_PURGE_UNLINKED_C"):format(loc("REG_LIST_ACTIONS_PURGE_EMPTY")));
		else
			showConfirmPopup(loc("REG_LIST_ACTIONS_PURGE_UNLINKED_C"):format(loc("REG_LIST_ACTIONS_PURGE_COUNT"):format(#profilesToPurge)), function()
				for _, profileID in pairs(profilesToPurge) do
					deleteProfile(profileID, true);
				end
				Events.fireEvent(Events.REGISTER_DATA_UPDATED);
				Events.fireEvent(Events.REGISTER_PROFILE_DELETED);
				refreshList();
			end);
		end
	elseif value == "purge_ignore" then
		local profilesToPurge, characterToPurge = TRP3_API.register.getIDsToPurge();
		if #profilesToPurge + #characterToPurge == 0 then
			showAlertPopup(loc("REG_LIST_ACTIONS_PURGE_IGNORE_C"):format(loc("REG_LIST_ACTIONS_PURGE_EMPTY")));
		else
			showConfirmPopup(loc("REG_LIST_ACTIONS_PURGE_IGNORE_C"):format(loc("REG_LIST_ACTIONS_PURGE_COUNT"):format(#profilesToPurge + #characterToPurge)), function()
				for _, profileID in pairs(profilesToPurge) do
					deleteProfile(profileID);
				end
				for _, unitID in pairs(characterToPurge) do
					deleteCharacter(unitID);
				end
				refreshList();
			end);
		end
	elseif value == "purge_all" then
		local list = getProfileList();
		showConfirmPopup(loc("REG_LIST_ACTIONS_PURGE_ALL_C"):format(tsize(list)), function()
			for profileID, _ in pairs(list) do
				deleteProfile(profileID, true);
			end
			Events.fireEvent(Events.REGISTER_DATA_UPDATED);
			Events.fireEvent(Events.REGISTER_PROFILE_DELETED);
		end);
	-- Mass actions
	elseif value == "actions_delete" then
		showConfirmPopup(loc("REG_LIST_ACTIONS_MASS_REMOVE_C"):format(tsize(selectedIDs)), function()
			for profileID, _ in pairs(selectedIDs) do
				deleteProfile(profileID, true);
			end
			Events.fireEvent(Events.REGISTER_DATA_UPDATED);
			Events.fireEvent(Events.REGISTER_PROFILE_DELETED);
			refreshList();
		end);
	elseif value == "actions_ignore" then
		local charactToIgnore = {};
		for profileID, _ in pairs(selectedIDs) do
			for unitID, _ in pairs(getProfile(profileID).link or Globals.empty) do
				charactToIgnore[unitID] = true;
			end
		end
		showTextInputPopup(loc("REG_LIST_ACTIONS_MASS_IGNORE_C"):format(tsize(charactToIgnore)), function(text)
			for unitID, _ in pairs(charactToIgnore) do
				ignoreID(unitID, text);
			end
			refreshList();
		end);
	end
end

local function onCharactersActions(self)
	local values = {};
	tinsert(values, {loc("REG_LIST_ACTIONS_PURGE"), {
			{loc("REG_LIST_ACTIONS_PURGE_TIME"), "purge_time"},
			{loc("REG_LIST_ACTIONS_PURGE_UNLINKED"), "purge_unlinked"},
			{loc("REG_LIST_ACTIONS_PURGE_IGNORE"), "purge_ignore"},
			{loc("REG_LIST_ACTIONS_PURGE_ALL"), "purge_all"},
		}});
	if tsize(selectedIDs) > 0 then
		tinsert(values, {loc("REG_LIST_ACTIONS_MASS"):format(tsize(selectedIDs)), {
				{loc("REG_LIST_ACTIONS_MASS_REMOVE"), "actions_delete"},
				{loc("REG_LIST_ACTIONS_MASS_IGNORE"), "actions_ignore"},
			}});
	end
	displayDropDown(self, values, onCharactersActionSelected, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI : IGNORED
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function decorateIgnoredLine(line, unitID)
	line.id = unitID;
	_G[line:GetName().."Name"]:SetText(unitID);
	_G[line:GetName().."Info"]:SetText("");
	_G[line:GetName().."Info2"]:SetText("");
	_G[line:GetName().."Select"]:Hide();
	setTooltipForSameFrame(_G[line:GetName().."Click"], "TOPLEFT", 0, 5, unitID, loc("REG_LIST_IGNORE_TT"):format(getIgnoredList()[unitID]));
	setTooltipForSameFrame(_G[line:GetName().."ClickMiddle"]);
	setTooltipForSameFrame(_G[line:GetName().."ClickRight"]);
end

local function getIgnoredLines()
	if tsize(getIgnoredList()) == 0 then
		TRP3_RegisterListEmpty:SetText(loc("REG_LIST_IGNORE_EMPTY"));
	end
	TRP3_RegisterListHeaderName:SetText(loc("REG_PLAYER"));
	TRP3_RegisterListHeaderInfo:SetText("");
	TRP3_RegisterListHeaderInfoTT:Disable();
	TRP3_RegisterListHeaderNameTT:Disable();
	TRP3_RegisterListHeaderInfo2:SetText("");

	return getIgnoredList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI : LIST
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function refreshList()
	local lines;
	TRP3_RegisterListEmpty:Hide();
	TRP3_RegisterListHeaderActions:Hide();

	if currentMode == MODE_CHARACTER then
		lines = getCharacterLines();
		TRP3_RegisterList.decorate = decorateCharacterLine;
	elseif currentMode == MODE_IGNORE then
		lines = getIgnoredLines();
		TRP3_RegisterList.decorate = decorateIgnoredLine;
	end

	-- Ensure lines is not nil to prevent errors
	if not lines then
		lines = {};
	end

	if tsize(lines) == 0 then
		TRP3_RegisterListEmpty:Show();
	end
	initList(TRP3_RegisterList, lines, TRP3_RegisterListSlider);
end

local function onLineClicked(self, button)
	if currentMode == MODE_CHARACTER then
		assert(self:GetParent().id, "No profileID on line.");
		openPage(self:GetParent().id);
	elseif currentMode == MODE_IGNORE then
		assert(self:GetParent().id, "No unitID on line.");
		unignoreID(self:GetParent().id);
		refreshList();
	end
end

local function onLineSelected(self, button)
	assert(self:GetParent().id, "No id on line.");
	local rawValue = self:GetChecked();
	-- 3.3.5 compatibility
	selectedIDs[self:GetParent().id] = rawValue == 1 or rawValue == true;
end

local function changeMode(tabWidget, value)
	currentMode = value;
	wipe(selectedIDs);
	TRP3_RegisterListCharactFilter:Hide();
	if currentMode == MODE_CHARACTER then
		TRP3_RegisterListCharactFilter:Show();
	end
	refreshList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tabGroup;

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_RegisterMainTabBar", TRP3_RegisterList);
	frame:SetSize(400, 30);
	frame:SetPoint("TOPLEFT", 17, -5);
	frame:SetFrameLevel(1);
	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
	{
		{loc("REG_LIST_CHAR_TITLE"), 1, 150},
		{loc("REG_LIST_IGNORE_TITLE"), 3, 150},
	},
	changeMode
	);
	tabGroup:SelectTab(1);
end

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOAD, function()
	-- To try, but I'm afraid for performances ...
	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, profileID, dataType)
		if getCurrentPageID() == REGISTER_LIST_PAGEID and unitID ~= Globals.player_id and (not dataType or dataType == "characteristics") then
			refreshList();
		end
	end);
	
	Events.listenToEvent(Events.REGISTER_PROFILE_DELETED, function(profileID)
		if profileID then
			selectedIDs[profileID] = nil;
			if isMenuRegistered(currentlyOpenedProfilePrefix .. profileID) then
				unregisterMenu(currentlyOpenedProfilePrefix .. profileID);
			end
		end
		if getCurrentPageID() == REGISTER_LIST_PAGEID then
			refreshList();
		end
	end);

	registerMenu({
		id = REGISTER_PAGE,
		closeable = true,
		text = loc("REG_REGISTER"),
		onSelected = function() setPage(REGISTER_LIST_PAGEID); end,
	});

	registerPage({
		id = REGISTER_LIST_PAGEID,
		templateName = "TRP3_RegisterList",
		frameName = "TRP3_RegisterList",
		frame = TRP3_RegisterList,
		onPagePostShow = function() tabGroup:SelectTab(1); end,
	});

	TRP3_RegisterListSlider:SetValue(0);
	handleMouseWheel(TRP3_RegisterListContainer, TRP3_RegisterListSlider);
	local widgetTab = {};
	for i=1,14 do
		local widget = _G["TRP3_RegisterListLine"..i];
		local widgetClick = _G["TRP3_RegisterListLine"..i.."Click"];
		local widgetSelect = _G["TRP3_RegisterListLine"..i.."Select"];
		widgetSelect:SetScript("OnClick", onLineSelected);
		widgetClick:SetScript("OnClick", onLineClicked);
		widgetClick:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue");
		widgetClick:SetAlpha(0.75);
		table.insert(widgetTab, widget);
	end
	TRP3_RegisterList.widgetTab = widgetTab;
	TRP3_RegisterListFilterCharactName:SetScript("OnEnterPressed", refreshList);
	TRP3_RegisterListFilterCharactGuild:SetScript("OnEnterPressed", refreshList);
	TRP3_RegisterListCharactFilterButton:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			TRP3_RegisterListFilterCharactName:SetText("");
			TRP3_RegisterListFilterCharactGuild:SetText("");
		end
		refreshList();
	end)
	setTooltipForSameFrame(TRP3_RegisterListCharactFilterButton, "LEFT", 0, 5, loc("REG_LIST_FILTERS"), loc("REG_LIST_FILTERS_TT"));
	TRP3_RegisterListFilterCharactNameText:SetText(loc("REG_LIST_NAME"));
	TRP3_RegisterListFilterCharactGuildText:SetText(loc("REG_LIST_GUILD"));
	TRP3_API.ui.frame.setupEditBoxesNavigation({TRP3_RegisterListFilterCharactName, TRP3_RegisterListFilterCharactGuild});

	TRP3_RegisterListHeaderNameTT:SetScript("OnClick", switchNameSorting);
	TRP3_RegisterListHeaderInfoTT:SetScript("OnClick", switchInfoSorting);

	setTooltipForSameFrame(TRP3_RegisterListHeaderActions, "TOP", 0, 0, loc("CM_ACTIONS"));
	TRP3_RegisterListHeaderActions:SetScript("OnClick", function(self)
		if currentMode == MODE_CHARACTER then
			onCharactersActions(self);
		elseif currentMode == MODE_PETS then
			onPetsActions(self);
		end
	end);

	createTabBar();

end);

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
	if TRP3_API.target then
		TRP3_API.target.registerButton({
			id = "aa_player_a_page",
			configText = loc("TF_OPEN_CHARACTER"),
			onlyForType = TRP3_API.ui.misc.TYPE_CHARACTER,
			condition = function(targetType, unitID)
				return unitID == Globals.player_id or (isUnitIDKnown(unitID) and hasProfile(unitID));
			end,
			onClick = function(unitID)
				openMainFrame();
				openPageByUnitID(unitID);
			end,
			adapter = function(buttonStructure, unitID, currentTargetType)
				buttonStructure.tooltip = loc("REG_PLAYER");
				buttonStructure.tooltipSub =  "|cffffff00" .. loc("CM_CLICK") .. ": |r" .. loc("TF_OPEN_CHARACTER");
				buttonStructure.alert = nil;
				if unitID ~= Globals.player_id and hasProfile(unitID) then
					local profile = getUnitIDProfile(unitID);
					if profile.about and not profile.about.read then
						buttonStructure.tooltipSub =  "|cff00ff00" .. loc("REG_TT_NOTIF") .. "\n" .. buttonStructure.tooltipSub;
						buttonStructure.alert = true;
					end
				end
			end,
			alertIcon = "Interface\\GossipFrame\\AvailableQuestIcon",
			icon = "inv_inscription_scroll"
		});
	end
end);