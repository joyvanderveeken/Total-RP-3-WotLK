----------------------------------------------------------------------------------
-- Total RP 3
-- Character page : Characteristics
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

-- imports
local Globals, Utils, Comm, Events = TRP3_API.globals, TRP3_API.utils, TRP3_API.communication, TRP3_API.events;
local stEtN = Utils.str.emptyToNil;
local stNtE = Utils.str.nilToEmpty;
local get = TRP3_API.profile.getData;
local getProfile = TRP3_API.register.getProfile;
local tcopy, tsize = Utils.table.copy, Utils.table.size;
local numberToHexa, hexaToNumber = Utils.color.numberToHexa, Utils.color.hexaToNumber;
local loc = TRP3_API.locale.getText;
local getDefaultProfile = TRP3_API.profile.getDefaultProfile;
local showIconBrowser = TRP3_API.popup.showIconBrowser;
local assert, type, wipe, strconcat, pairs, tinsert, tremove, _G, strtrim = assert, type, wipe, strconcat, pairs, tinsert, tremove, _G, strtrim;
local strjoin, unpack, getKeys = strjoin, unpack, Utils.table.keys;
local getTiledBackground = TRP3_API.ui.frame.getTiledBackground;
local setupDropDownMenu = TRP3_API.ui.listbox.setupDropDownMenu;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local getCurrentContext = TRP3_API.navigation.page.getCurrentContext;
local setupIconButton = TRP3_API.ui.frame.setupIconButton;
local setupFieldSet = TRP3_API.ui.frame.setupFieldPanel;
local getUnitIDCharacter = TRP3_API.register.getUnitIDCharacter;
local getUnitIDProfile, getPlayerCurrentProfile = TRP3_API.register.getUnitIDProfile, TRP3_API.profile.getPlayerCurrentProfile;
local hasProfile, getRelationTexture = TRP3_API.register.hasProfile, TRP3_API.register.relation.getRelationTexture;
local RELATIONS = TRP3_API.register.relation;
local getRelationText, getRelationTooltipText, setRelation = RELATIONS.getRelationText, RELATIONS.getRelationTooltipText, RELATIONS.setRelation;
local CreateFrame = CreateFrame;
local TRP3_RegisterCharact_CharactPanel_Empty = TRP3_RegisterCharact_CharactPanel_Empty;
local displayDropDown = TRP3_API.ui.listbox.displayDropDown;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local showConfirmPopup, showTextInputPopup = TRP3_API.popup.showConfirmPopup, TRP3_API.popup.showTextInputPopup;
local deleteProfile = TRP3_API.register.deleteProfile;
local selectMenu = TRP3_API.navigation.menu.selectMenu;
local unregisterMenu = TRP3_API.navigation.menu.unregisterMenu;
local ignoreID = TRP3_API.register.ignoreID;
local buildZoneText = Utils.str.buildZoneText;
local setupEditBoxesNavigation = TRP3_API.ui.frame.setupEditBoxesNavigation;

local TRAIT_PRESETS_UNKNOWN;
local TRAIT_PRESETS;
local TRAIT_PRESETS_DROPDOWN;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- SCHEMA
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

getDefaultProfile().player.characteristics = {
	v = 1,
	RA = Globals.player_race_loc,
	CL = Globals.player_class_loc,
	FN = Globals.player,
	IC = TRP3_API.ui.misc.getUnitTexture(Globals.player_character.race, UnitSex("player")),
	CH = (function()
		local classColorTable = RAID_CLASS_COLORS[Globals.player_character.class];
		if classColorTable then
			return ("%02x%02x%02x"):format(classColorTable.r*255, classColorTable.g*255, classColorTable.b*255);
		end
		return "ffffff"; -- fallback to white
	end)(),
	MI = {},
	PS = {}
};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- COMPRESSION
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local currentCompressed;

local function compressData()
	local dataTab = get("player/characteristics");
	local serial = Utils.serial.serialize(dataTab);
	local compressed = Utils.serial.encodeCompressMessage(serial);
	if compressed:len() < serial:len() then
		currentCompressed = compressed;
		--		Utils.log.log(("Compressed data is better: %s / %s (%i%%)"):format(compressed:len(), serial:len(), compressed:len() / serial:len() * 100));
	else
		currentCompressed = nil;
	end
end

function TRP3_API.register.player.getCharacteristicsExchangeData()
	if currentCompressed ~= nil then
		return currentCompressed;
	else
		return get("player/characteristics");
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CHARACTERISTICS - CONSULT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local registerCharFrame = {};
local registerCharLocals = {
	RA = "REG_PLAYER_RACE",
	CL = "REG_PLAYER_CLASS",
	AG = "REG_PLAYER_AGE",
	EC = "REG_PLAYER_EYE",
	HE = "REG_PLAYER_HEIGHT",
	WE = "REG_PLAYER_WEIGHT",
	BP = "REG_PLAYER_BIRTHPLACE",
	RE = "REG_PLAYER_RESIDENCE"
};
local miscCharFrame = {};
local psychoCharFrame = {};

local function getCompleteName(characteristicsTab, name, hideTitle)
	if not characteristicsTab then
		return name;
	end
	local text = "";
	if not hideTitle and characteristicsTab.TI then
		text = strconcat(characteristicsTab.TI, " ");
	end
	text = strconcat(text, characteristicsTab.FN or name);
	if characteristicsTab.LN then
		text = strconcat(text, " ", characteristicsTab.LN);
	end
	return text;
end

TRP3_API.register.getCompleteName = getCompleteName;

local function getPlayerCompleteName(hideTitle)
	local profile = getPlayerCurrentProfile();
	return getCompleteName(profile.player.characteristics, Globals.player, hideTitle);
end

TRP3_API.register.getPlayerCompleteName = getPlayerCompleteName;

local function refreshPsycho(psychoLine, value, traitID)
	local normalizedValue = math.max(0, math.min(10, (value or 5)));
	
	-- Get dynamic colors for this trait
	local colors = nil;
	if traitID and traitID > 0 and traitID <= #TRAIT_PRESETS then
		colors = TRAIT_PRESETS[traitID];
	elseif traitID and traitID == 0 then
		colors = TRAIT_PRESETS_UNKNOWN;
	end
	
	-- Get the container frame (which holds the backdrop and StatusBars)
	local container = _G[psychoLine:GetName() .. "Bar"];
	if container then
		-- Get the actual StatusBars from within the container
		-- The StatusBar is named $parentStatusBar, so it becomes [ContainerName]StatusBar
		local statusBar = container.StatusBar or _G[container:GetName() .. "StatusBar"];
		local backgroundBar = container.BackgroundBar or _G[container:GetName() .. "BackgroundBar"];
		
		-- Handle the background bar (always full, use right trait color or default red)
		if backgroundBar then
			backgroundBar:SetValue(10);
			if colors then
				backgroundBar:SetStatusBarColor(colors.rightColor[1], colors.rightColor[2], colors.rightColor[3], 0.8);
			else
				backgroundBar:SetStatusBarColor(0.8, 0.2, 0.2, 0.8); -- Default red
			end
			backgroundBar:SetAlpha(1);
			backgroundBar:Show();
		end
		
		-- Handle the main status bar (use left trait color or default green, varies with value)
		if statusBar then
			statusBar:SetValue(normalizedValue);
			
			-- Set color based on trait or default green
			if colors then
				statusBar:SetStatusBarColor(colors.leftColor[1], colors.leftColor[2], colors.leftColor[3], 0.8);
			else
				statusBar:SetStatusBarColor(0.2, 0.8, 0.2, 0.8); -- Default green
			end
			
			-- Make sure everything is visible
			statusBar:SetAlpha(1);
			statusBar:Show();
		end
		
		-- Position the thumb based on value (thumb is on the container)
		if container.Thumb then
			-- Calculate position within the StatusBar area (accounting for container insets)
			local containerWidth = container:GetWidth();
			local inset = 10; -- Account for StatusBar insets (5 pixels on each side)
			local barWidth = containerWidth - inset;
			local fillPercent = normalizedValue / 10;
			local thumbPos = (fillPercent - 0.5) * barWidth;
			container.Thumb:ClearAllPoints();
			container.Thumb:SetPoint("CENTER", container, "CENTER", thumbPos, 0);
		end
		
		-- Make sure container is visible
		container:SetAlpha(1);
		container:Show();
	end
	
	psychoLine.VA = normalizedValue;
end

local function setBkg(backgroundIndex)
	local backdrop = TRP3_RegisterCharact_CharactPanel:GetBackdrop();
	backdrop.bgFile = getTiledBackground(backgroundIndex);
	TRP3_RegisterCharact_CharactPanel:SetBackdrop(backdrop);
end

local function setConsultDisplay(context)
	local dataTab = context.profile.characteristics or Globals.empty;
	local hasCharac, hasPsycho, hasMisc, margin;
	assert(type(dataTab) == "table", "Error: Nil characteristics data or not a table.");
	-- Icon, complete name and titles
	local completeName = getCompleteName(dataTab, UNKNOWN);
	TRP3_RegisterCharact_NamePanel_Name:SetText("|cff" .. (dataTab.CH or "ffffff") .. completeName);
	TRP3_RegisterCharact_NamePanel_Title:SetText(dataTab.FT or "");
	setupIconButton(TRP3_RegisterCharact_NamePanel_Icon, dataTab.IC or Globals.icons.profile_default);

	setBkg(dataTab.bkg or 1);

	-- hide all
	for _, regCharFrame in pairs(registerCharFrame) do
		regCharFrame:Hide();
	end
	TRP3_RegisterCharact_CharactPanel_PsychoTitle:Hide();
	TRP3_RegisterCharact_CharactPanel_MiscTitle:Hide();

	-- Previous var helps for layout building
	local previous = TRP3_RegisterCharact_CharactPanel_RegisterTitle;
	TRP3_RegisterCharact_CharactPanel_RegisterTitle:Hide();

	-- Which directory chars must be shown ?
	local shownCharacteristics = {};
	local shownValues = {};
	for _, attribute in pairs({ "RA", "CL", "AG", "EC", "HE", "WE", "BP", "RE" }) do
		if strtrim(dataTab[attribute] or ""):len() > 0 then
			tinsert(shownCharacteristics, attribute);
			shownValues[attribute] = dataTab[attribute];
		end
	end
	if #shownCharacteristics > 0 then
		hasCharac = true;
		TRP3_RegisterCharact_CharactPanel_RegisterTitle:Show();
		margin = 0;
	else
		margin = 50;
	end

	-- Show directory chars values
	for frameIndex, charName in pairs(shownCharacteristics) do
		local frame = registerCharFrame[frameIndex];
		if frame == nil then
			frame = CreateFrame("Frame", "TRP3_RegisterCharact_RegisterInfoLine" .. frameIndex, TRP3_RegisterCharact_CharactPanel_Container, "TRP3_RegisterCharact_RegisterInfoLine");
			tinsert(registerCharFrame, frame);
		end
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 10);
		frame:SetPoint("RIGHT", 0, 0);
		_G[frame:GetName() .. "FieldName"]:SetText(loc(registerCharLocals[charName]));
		if charName == "EC" then
			local hexa = dataTab.EH or "ffffff"
			_G[frame:GetName() .. "FieldValue"]:SetText("|cff" .. hexa .. shownValues[charName] .. "|r");
		elseif charName == "CL" then
			local hexa = dataTab.CH or "ffffff";
			_G[frame:GetName() .. "FieldValue"]:SetText("|cff" .. hexa .. shownValues[charName] .. "|r");
		else
			_G[frame:GetName() .. "FieldValue"]:SetText(shownValues[charName]);
		end
		frame:Show();
		previous = frame;
	end

	-- extended character info
	if type(dataTab.MI) == "table" and #dataTab.MI > 0 then
		hasMisc = true;
		TRP3_RegisterCharact_CharactPanel_MiscTitle:Show();
		TRP3_RegisterCharact_CharactPanel_MiscTitle:ClearAllPoints();
		TRP3_RegisterCharact_CharactPanel_MiscTitle:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, margin);
		previous = TRP3_RegisterCharact_CharactPanel_MiscTitle;

		for frameIndex, miscStructure in pairs(dataTab.MI) do
			local frame = miscCharFrame[frameIndex];
			if frame == nil then
				frame = CreateFrame("Frame", "TRP3_RegisterCharact_MiscInfoLine" .. frameIndex, TRP3_RegisterCharact_CharactPanel_Container, "TRP3_RegisterCharact_RegisterInfoLine");
				tinsert(miscCharFrame, frame);
			end
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -5);
			frame:SetPoint("RIGHT", 0, 0);
			
			-- Create SimpleIcon frame if it doesn't exist
			if not frame.miscIcon then
				frame.miscIcon = CreateFrame("Frame", frame:GetName() .. "MiscIcon", frame, "TRP3_SimpleIcon");
				frame.miscIcon:SetSize(32, 32);
				frame.miscIcon:SetPoint("LEFT", frame, "LEFT", 0, 0);
			end
			
			-- Update the icon texture
			local iconTexture = _G[frame.miscIcon:GetName() .. "Icon"];
			if iconTexture then
				iconTexture:SetTexture("Interface\\ICONS\\" .. (miscStructure.IC or Globals.icons.default));
			end
			frame.miscIcon:Show();
			
			-- Update text labels with proper spacing for the icon
			_G[frame:GetName() .. "FieldName"]:SetText(miscStructure.NA or "");
			_G[frame:GetName() .. "FieldName"]:SetPoint("LEFT", frame.miscIcon, "RIGHT", 5, 0);
			_G[frame:GetName() .. "FieldValue"]:SetText(miscStructure.VA or "");
			frame:Show();
			previous = frame;
		end
	end

	-- traits
	if type(dataTab.PS) == "table" and #dataTab.PS > 0 then
		hasPsycho = true;
		TRP3_RegisterCharact_CharactPanel_PsychoTitle:Show();
		TRP3_RegisterCharact_CharactPanel_PsychoTitle:ClearAllPoints();
		TRP3_RegisterCharact_CharactPanel_PsychoTitle:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, margin);
		margin = 0;
		previous = TRP3_RegisterCharact_CharactPanel_PsychoTitle;

		for frameIndex, psychoStructure in pairs(dataTab.PS) do
			local frame = psychoCharFrame[frameIndex];
			local value = psychoStructure.VA;
			if frame == nil then
				frame = CreateFrame("Frame", "TRP3_RegisterCharact_PsychoInfoLine" .. frameIndex, TRP3_RegisterCharact_CharactPanel_Container, "TRP3_RegisterCharact_PsychoInfoDisplayLine");
				tinsert(psychoCharFrame, frame);
			end

			-- Preset pointer
			local originalID = psychoStructure.ID;
			if psychoStructure.ID then
				psychoStructure = TRAIT_PRESETS[psychoStructure.ID] or TRAIT_PRESETS_UNKNOWN;
			end

			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0);
			frame:SetPoint("RIGHT", 0, 0);
			
			-- Update text labels with dynamic colors
			local leftText = _G[frame:GetName() .. "LeftText"];
			local rightText = _G[frame:GetName() .. "RightText"];
			
			leftText:SetText(psychoStructure.LT or "");
			rightText:SetText(psychoStructure.RT or "");
			
			-- Apply dynamic colors based on trait ID
			local colors = nil;
			if originalID and originalID > 0 and originalID <= #TRAIT_PRESETS then
				colors = TRAIT_PRESETS[originalID];
			elseif originalID and originalID == 0 then
				colors = TRAIT_PRESETS_UNKNOWN;
			end
			
			if colors then
				leftText:SetTextColor(colors.leftColor[1], colors.leftColor[2], colors.leftColor[3]);
				rightText:SetTextColor(colors.rightColor[1], colors.rightColor[2], colors.rightColor[3]);
			else
				-- Fallback colors if no trait ID or colors defined
				leftText:SetTextColor(1.0, 0.9, 0.0); -- Yellow
				rightText:SetTextColor(0.6, 0.8, 1.0); -- Light blue
			end
			
			-- Update icons using TRP3_SimpleIcon template
			local leftIcon = _G[frame:GetName() .. "LeftIcon"];
			local rightIcon = _G[frame:GetName() .. "RightIcon"];
			
			-- Handle TRP3_SimpleIcon template icons
			if leftIcon then
				local iconTexture = _G[leftIcon:GetName() .. "Icon"];
				if iconTexture then
					iconTexture:SetTexture("Interface\\ICONS\\" .. (psychoStructure.LI or Globals.icons.default));
				end
			end
			
			if rightIcon then
				local iconTexture = _G[rightIcon:GetName() .. "Icon"];
				if iconTexture then
					iconTexture:SetTexture("Interface\\ICONS\\" .. (psychoStructure.RI or Globals.icons.default));
				end
			end
			
			refreshPsycho(frame, value or 5, originalID);
			frame:Show();
			previous = frame;
		end
	end

	if not hasCharac and not hasPsycho and not hasMisc then
		TRP3_RegisterCharact_CharactPanel_Empty:Show();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CHARACTERISTICS - EDIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setEditDisplay;

local draftData = nil;
local psychoEditCharFrame = {};
local miscEditCharFrame = {};

local function saveInDraft()
	assert(type(draftData) == "table", "Error: Nil draftData or not a table.");
	draftData.TI = stEtN(strtrim(TRP3_RegisterCharact_Edit_TitleField:GetText()));
	draftData.FN = stEtN(strtrim(TRP3_RegisterCharact_Edit_FirstField:GetText())) or Globals.player;
	draftData.LN = stEtN(strtrim(TRP3_RegisterCharact_Edit_LastField:GetText()));
	draftData.FT = stEtN(strtrim(TRP3_RegisterCharact_Edit_FullTitleField:GetText()));
	draftData.RA = stEtN(TRP3_RegisterCharact_Edit_RaceField:GetText());
	draftData.CL = stEtN(TRP3_RegisterCharact_Edit_ClassField:GetText());
	draftData.AG = stEtN(strtrim(TRP3_RegisterCharact_Edit_AgeField:GetText()));
	draftData.EC = stEtN(strtrim(TRP3_RegisterCharact_Edit_EyeField:GetText()));
	draftData.HE = stEtN(strtrim(TRP3_RegisterCharact_Edit_HeightField:GetText()));
	draftData.WE = stEtN(strtrim(TRP3_RegisterCharact_Edit_WeightField:GetText()));
	draftData.RE = stEtN(strtrim(TRP3_RegisterCharact_Edit_ResidenceField:GetText()));
	draftData.BP = stEtN(strtrim(TRP3_RegisterCharact_Edit_BirthplaceField:GetText()));
	for index, psychoStructure in pairs(draftData.PS) do
		if psychoEditCharFrame[index] then
			psychoStructure.VA = psychoEditCharFrame[index].VA;
			if not psychoStructure.ID then
				psychoStructure.LT = stEtN(_G[psychoEditCharFrame[index]:GetName() .. "LeftField"]:GetText()) or loc("REG_PLAYER_LEFTTRAIT");
				psychoStructure.RT = stEtN(_G[psychoEditCharFrame[index]:GetName() .. "RightField"]:GetText()) or loc("REG_PLAYER_RIGHTTRAIT");
				local leftIcon = _G[psychoEditCharFrame[index]:GetName() .. "LeftIcon"];
				local rightIcon = _G[psychoEditCharFrame[index]:GetName() .. "RightIcon"];
				if leftIcon and leftIcon.IC then
					psychoStructure.LI = leftIcon.IC;
				end
				if rightIcon and rightIcon.IC then
					psychoStructure.RI = rightIcon.IC;
				end
			else
				-- Don't save preset data !
				psychoStructure.LT = nil;
				psychoStructure.RT = nil;
				psychoStructure.LI = nil;
				psychoStructure.RI = nil;
			end
		end
	end
	-- Save Misc
	for index, miscStructure in pairs(draftData.MI) do
		miscStructure.VA = stEtN(_G[miscEditCharFrame[index]:GetName() .. "ValueField"]:GetText()) or loc("CM_VALUE");
		miscStructure.NA = stEtN(_G[miscEditCharFrame[index]:GetName() .. "NameField"]:GetText()) or loc("CM_NAME");
	end
end

local function onPlayerIconSelected(icon)
	draftData.IC = icon;
	setupIconButton(TRP3_RegisterCharact_Edit_NamePanel_Icon, draftData.IC or Globals.icons.profile_default);
end

local function onEyeColorSelected(red, green, blue)
	if red and green and blue then
		local hexa = strconcat(numberToHexa(red), numberToHexa(green), numberToHexa(blue))
		draftData.EH = hexa;
	else
		draftData.EH = nil;
	end
end

local function onClassColorSelected(red, green, blue)
	if red and green and blue then
		local hexa = strconcat(numberToHexa(red), numberToHexa(green), numberToHexa(blue))
		draftData.CH = hexa;
	else
		draftData.CH = nil;
	end
end

local function onPsychoClick(frame, value, modif)
	local currentValue = value or 10;
	local newValue = currentValue + modif;

	if newValue >= 0 and newValue <= 10 then
		refreshPsycho(frame, newValue);
	end
end

local function onLeftClick(button)
	onPsychoClick(button:GetParent(), button:GetParent().VA or 10, -1);
end

local function onRightClick(button)
	onPsychoClick(button:GetParent(), button:GetParent().VA or 10, 1);
end

local function refreshEditIcon(frame)
	setupIconButton(frame, frame.IC or Globals.icons.profile_default);
end

local function onMiscDelete(self)
	assert(self and self:GetParent(), "Badly initialiazed remove button, reference");
	local frame = self:GetParent();
	assert(frame.miscIndex and draftData.MI[frame.miscIndex], "Badly initialiazed remove button, index");
	saveInDraft();
	wipe(draftData.MI[frame.miscIndex]);
	tremove(draftData.MI, frame.miscIndex);
	setEditDisplay();
end

local function miscAdd(NA, VA, IC)
	saveInDraft();
	tinsert(draftData.MI, {
		NA = NA,
		VA = VA,
		IC = IC,
	});
	setEditDisplay();
end

local MISC_PRESET = {
	{
		NA = loc("REG_PLAYER_MSP_HOUSE"),
		VA = "",
		IC = "inv_misc_kingsring1"
	},
	{
		NA = loc("REG_PLAYER_MSP_NICK"),
		VA = "",
		IC = "Ability_Hunter_BeastCall"
	},
	{
		NA = loc("REG_PLAYER_MSP_MOTTO"),
		VA = "",
		IC = "INV_Inscription_ScrollOfWisdom_01"
	},
	{
		NA = loc("REG_PLAYER_TRP2_TRAITS"),
		VA = "",
		IC = "spell_shadow_mindsteal"
	},
	{
		NA = loc("REG_PLAYER_TRP2_PIERCING"),
		VA = "",
		IC = "inv_jewelry_ring_14"
	},
	{
		NA = loc("REG_PLAYER_TRP2_TATTOO"),
		VA = "",
		IC = "INV_Inscription_inkblack01"
	},
	{
		list = "|cff00ff00" .. loc("REG_PLAYER_ADD_NEW"),
		NA = loc("CM_NAME"),
		VA = loc("CM_VALUE"),
		IC = "TEMP"
	},
}

local function miscAddDropDownSelection(index)
	local preset = MISC_PRESET[index];
	miscAdd(preset.NA, preset.VA, preset.IC);
end

local function miscAddDropDown()
	local values = {};
	tinsert(values, { loc("REG_PLAYER_MISC_ADD") });
	for index, preset in pairs(MISC_PRESET) do
		tinsert(values, { preset.list or preset.NA, index });
	end
	displayDropDown(TRP3_RegisterCharact_Edit_MiscAdd, values, miscAddDropDownSelection, 0, true);
end

local function psychoAdd(presetID)
	saveInDraft();
	if presetID == "new" then
		tinsert(draftData.PS, {
			LT = loc("REG_PLAYER_LEFTTRAIT"),
			LI = Globals.icons.default,
			RT = loc("REG_PLAYER_RIGHTTRAIT"),
			RI = Globals.icons.default,
			VA = 5,
		});
	else
		tinsert(draftData.PS, { ID = presetID, VA = 5 });
	end
	setEditDisplay();
end

local function onPsychoDelete(self)
	assert(self and self:GetParent(), "Badly initialiazed remove button, reference");
	local frame = self:GetParent();
	assert(frame.psychoIndex and draftData.PS[frame.psychoIndex], "Badly initialiazed remove button, index");
	saveInDraft();
	wipe(draftData.PS[frame.psychoIndex]);
	tremove(draftData.PS, frame.psychoIndex);
	setEditDisplay();
end

function setEditDisplay()
	-- Copy character's data into draft structure : We never work directly on saved_variable structures !
	if not draftData then
		local dataTab = get("player/characteristics");
		assert(type(dataTab) == "table", "Error: Nil characteristics data or not a table.");
		draftData = {};
		tcopy(draftData, dataTab);
	end

	setupIconButton(TRP3_RegisterCharact_Edit_NamePanel_Icon, draftData.IC or Globals.icons.profile_default);
	TRP3_RegisterCharact_Edit_TitleField:SetText(draftData.TI or "");
	TRP3_RegisterCharact_Edit_FirstField:SetText(draftData.FN or Globals.player);
	TRP3_RegisterCharact_Edit_LastField:SetText(draftData.LN or "");
	TRP3_RegisterCharact_Edit_FullTitleField:SetText(draftData.FT or "");

	TRP3_RegisterCharact_Edit_RaceField:SetText(draftData.RA or "");
	TRP3_RegisterCharact_Edit_ClassField:SetText(draftData.CL or "");
	TRP3_RegisterCharact_Edit_AgeField:SetText(draftData.AG or "");
	TRP3_RegisterCharact_Edit_EyeField:SetText(draftData.EC or "");

	TRP3_RegisterCharact_Edit_EyeButton.setColor(hexaToNumber(draftData.EH))
	TRP3_RegisterCharact_Edit_ClassButton.setColor(hexaToNumber(draftData.CH));

	TRP3_RegisterCharact_Edit_HeightField:SetText(draftData.HE or "");
	TRP3_RegisterCharact_Edit_WeightField:SetText(draftData.WE or "");
	TRP3_RegisterCharact_Edit_ResidenceField:SetText(draftData.RE or "");
	TRP3_RegisterCharact_Edit_BirthplaceField:SetText(draftData.BP or "");

	-- Misc
	local previous = TRP3_RegisterCharact_CharactPanel_Edit_MiscTitle;
	for _, frame in pairs(miscEditCharFrame) do frame:Hide(); end
	for frameIndex, miscStructure in pairs(draftData.MI) do
		local frame = miscEditCharFrame[frameIndex];
		if frame == nil then
			frame = CreateFrame("Frame", "TRP3_RegisterCharact_MiscEditLine" .. frameIndex, TRP3_RegisterCharact_Edit_CharactPanel_Container, "TRP3_RegisterCharact_MiscEditLine");
			_G[frame:GetName() .. "NameFieldText"]:SetText(loc("CM_NAME"));
			_G[frame:GetName() .. "ValueFieldText"]:SetText(loc("CM_VALUE"));
			_G[frame:GetName() .. "Delete"]:SetScript("OnClick", onMiscDelete);
			setTooltipForSameFrame(_G[frame:GetName() .. "Delete"], "TOP", 0, 5, loc("CM_REMOVE"));
			tinsert(miscEditCharFrame, frame);
		end
		_G[frame:GetName() .. "Icon"]:SetScript("OnClick", function()
			showIconBrowser(function(icon)
				miscStructure.IC = icon;
				setupIconButton(_G[frame:GetName() .. "Icon"], icon or Globals.icons.default);
			end);
		end);

		frame.miscIndex = frameIndex;
		_G[frame:GetName() .. "Icon"].IC = miscStructure.IC or Globals.icons.default;
		_G[frame:GetName() .. "NameField"]:SetText(miscStructure.NA or loc("CM_NAME"));
		_G[frame:GetName() .. "ValueField"]:SetText(miscStructure.VA or loc("CM_VALUE"));
		refreshEditIcon(_G[frame:GetName() .. "Icon"]);
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -6);
		frame:SetPoint("RIGHT", 0, 0);
		frame:Show();
		previous = frame;
	end
	-- MiscAdd button uses XML anchors relative to MiscTitle, just ensure it's shown
	-- TRP3_RegisterCharact_Edit_MiscAdd:Show();

	-- traits
	TRP3_RegisterCharact_CharactPanel_Edit_PsychoTitle:ClearAllPoints();
	TRP3_RegisterCharact_CharactPanel_Edit_PsychoTitle:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0);
	previous = TRP3_RegisterCharact_CharactPanel_Edit_PsychoTitle;
	for _, frame in pairs(psychoEditCharFrame) do frame:Hide(); end
	for frameIndex, psychoStructure in pairs(draftData.PS) do
		local frame = psychoEditCharFrame[frameIndex];
		if frame == nil then
			frame = CreateFrame("Frame", "TRP3_RegisterCharact_PsychoEditLine" .. frameIndex, TRP3_RegisterCharact_Edit_CharactPanel_Container, "TRP3_RegisterCharact_PsychoInfoEditLine");
			_G[frame:GetName() .. "Delete"]:SetScript("OnClick", onPsychoDelete);
			setTooltipForSameFrame(_G[frame:GetName() .. "LeftIcon"], "TOP", 0, 5, loc("UI_ICON_SELECT"), loc("REG_PLAYER_PSYCHO_LEFTICON_TT"));
			setTooltipForSameFrame(_G[frame:GetName() .. "RightIcon"], "TOP", 0, 5, loc("UI_ICON_SELECT"), loc("REG_PLAYER_PSYCHO_RIGHTICON_TT"));
			setTooltipForSameFrame(_G[frame:GetName() .. "Delete"], "TOP", 0, 5, loc("CM_REMOVE"));
			tinsert(psychoEditCharFrame, frame);
		end

		if psychoStructure.ID then
			local preset = TRAIT_PRESETS[psychoStructure.ID] or TRAIT_PRESETS_UNKNOWN;

			_G[frame:GetName() .. "LeftIcon"]:Hide();
			_G[frame:GetName() .. "RightIcon"]:Hide();

			local leftText = _G[frame:GetName() .. "LeftText"];
			local rightText = _G[frame:GetName() .. "RightText"];
			leftText:Show();
			rightText:Show();
			leftText:SetText(preset.LT or "");
			rightText:SetText(preset.RT or "");
			
			-- Apply dynamic colors in edit mode too
			local colors = nil;
			if psychoStructure.ID and psychoStructure.ID > 0 and psychoStructure.ID <= #TRAIT_PRESETS then
				colors = TRAIT_PRESETS[psychoStructure.ID];
			elseif psychoStructure.ID and psychoStructure.ID == 0 then
				colors = TRAIT_PRESETS_UNKNOWN;
			end
			
			if colors then
				leftText:SetTextColor(colors.leftColor[1], colors.leftColor[2], colors.leftColor[3]);
				rightText:SetTextColor(colors.rightColor[1], colors.rightColor[2], colors.rightColor[3]);
			else
				-- Fallback colors
				leftText:SetTextColor(1.0, 0.9, 0.0); -- Yellow
				rightText:SetTextColor(0.6, 0.8, 1.0); -- Light blue
			end

			_G[frame:GetName() .. "LeftField"]:Hide();
			_G[frame:GetName() .. "RightField"]:Hide();
			
			if not frame.simpleLeftIcon then
				frame.simpleLeftIcon = CreateFrame("Frame", frame:GetName() .. "SimpleLeftIcon", frame, "TRP3_SimpleIcon");
				frame.simpleLeftIcon:SetSize(32, 32);
				frame.simpleLeftIcon:SetPoint("RIGHT", _G[frame:GetName() .. "Bar"], "LEFT", -7, 2);
			end
			if not frame.simpleRightIcon then
				frame.simpleRightIcon = CreateFrame("Frame", frame:GetName() .. "SimpleRightIcon", frame, "TRP3_SimpleIcon");
				frame.simpleRightIcon:SetSize(32, 32);
				frame.simpleRightIcon:SetPoint("LEFT", _G[frame:GetName() .. "Bar"], "RIGHT", 7, 2);
			end

			frame.simpleLeftIcon:Show();
			frame.simpleRightIcon:Show();

			local leftIconTexture = _G[frame.simpleLeftIcon:GetName() .. "Icon"];
			local rightIconTexture = _G[frame.simpleRightIcon:GetName() .. "Icon"];
			
			if leftIconTexture then
				leftIconTexture:SetTexture("Interface\\ICONS\\" .. (preset.LI or Globals.icons.default));
			end
			if rightIconTexture then
				rightIconTexture:SetTexture("Interface\\ICONS\\" .. (preset.RI or Globals.icons.default));
			end
		else
			local leftIcon = _G[frame:GetName() .. "LeftIcon"];
			local rightIcon = _G[frame:GetName() .. "RightIcon"];

			leftIcon:Show();
			rightIcon:Show();

			_G[frame:GetName() .. "LeftText"]:Hide();
			_G[frame:GetName() .. "RightText"]:Hide();

			_G[frame:GetName() .. "LeftField"]:Show();
			_G[frame:GetName() .. "RightField"]:Show();
			_G[frame:GetName() .. "LeftField"]:SetText(psychoStructure.LT or "");
			_G[frame:GetName() .. "RightField"]:SetText(psychoStructure.RT or "");

			if frame.simpleLeftIcon then frame.simpleLeftIcon:Hide(); end
			if frame.simpleRightIcon then frame.simpleRightIcon:Hide(); end

			leftIcon:SetScript("OnClick", function(self)
				showIconBrowser(function(icon)
					psychoStructure.LI = icon;
					self.IC = icon;
					setupIconButton(self, icon or Globals.icons.default);
				end);
			end);
			rightIcon:SetScript("OnClick", function(self)
				showIconBrowser(function(icon)
					psychoStructure.RI = icon;
					self.IC = icon;
					setupIconButton(self, icon or Globals.icons.default);
				end);
			end);
			
			-- Set icons from saved data
			leftIcon.IC = psychoStructure.LI or Globals.icons.default;
			rightIcon.IC = psychoStructure.RI or Globals.icons.default;
			
			refreshEditIcon(leftIcon);
			refreshEditIcon(rightIcon);
		end

		-- store trait index for reference
		frame.psychoIndex = frameIndex;
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0);
		frame:SetPoint("RIGHT", 0, 0);

		local slider = _G[frame:GetName() .. "Slider"];
		if slider then
			slider:SetValue(psychoStructure.VA or 5);
			slider:SetScript("OnValueChanged", function(self, value)
				local parentFrame = self:GetParent();
				refreshPsycho(parentFrame, value, psychoStructure.ID);
			end);
		end
		
		refreshPsycho(frame, psychoStructure.VA or 5, psychoStructure.ID);
		frame:Show();
		previous = frame;
	end
	-- PsychoAdd button uses XML anchors relative to PsychoTitle, just ensure it's shown
	TRP3_RegisterCharact_Edit_PsychoAdd:Show();
end

local function setupRelationButton(profileID, profile)
	setupIconButton(TRP3_RegisterCharact_ActionButton, getRelationTexture(profileID));
	setTooltipAll(TRP3_RegisterCharact_ActionButton, "LEFT", 0, 0, loc("CM_ACTIONS"), loc("REG_RELATION_BUTTON_TT"):format(getRelationText(profileID), getRelationTooltipText(profileID, profile)));
end

local function saveCharacteristics()
	saveInDraft();

	local dataTab = get("player/characteristics");
	assert(type(dataTab) == "table", "Error: Nil characteristics data or not a table.");
	wipe(dataTab);
	-- By simply copy the draftData we get everything we need about ordering and structures.
	tcopy(dataTab, draftData);
	-- version increment
	assert(type(dataTab.v) == "number", "Error: No version in draftData or not a number.");
	dataTab.v = Utils.math.incrementNumber(dataTab.v, 2);

	compressData();
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getCurrentContext().profileID, "characteristics");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CHARACTERISTICS - LOGIC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function refreshDisplay()
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	assert(context.profile, "No profile in context");

	-- Hide all
	TRP3_RegisterCharact_NamePanel:Hide();
	TRP3_RegisterCharact_CharactPanel:Hide();
	TRP3_RegisterCharact_ActionButton:Hide();
	TRP3_RegisterCharact_CharactPanel_Empty:Hide();
	TRP3_RegisterCharact_Edit_NamePanel:Hide();
	TRP3_RegisterCharact_Edit_CharactPanel:Hide();
	for _, frame in pairs(registerCharFrame) do frame:Hide(); end
	for _, frame in pairs(psychoCharFrame) do frame:Hide(); end
	for _, frame in pairs(miscCharFrame) do frame:Hide(); end

	-- IsSelf ?
	TRP3_RegisterCharact_NamePanel_EditButton:Hide();
	if context.isPlayer then
		TRP3_RegisterCharact_NamePanel_EditButton:Show();
	else
		assert(context.profileID, "No profileID in context");
		TRP3_RegisterCharact_ActionButton:Show();
		setupRelationButton(context.profileID, context.profile);
	end

	if context.isEditMode then
		assert(context.isPlayer, "Trying to show Characteristics edition but is not mine ...");
		TRP3_RegisterCharact_Edit_NamePanel:Show();
		TRP3_RegisterCharact_Edit_CharactPanel:Show();
		setEditDisplay();
	else
		TRP3_RegisterCharact_NamePanel:Show();
		TRP3_RegisterCharact_CharactPanel:Show();
		setConsultDisplay(context);
	end
end

local toast = TRP3_API.ui.tooltip.toast;

local function onActionSelected(value, button)
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	assert(context.profile, "No profile in context");
	assert(context.profileID, "No profileID in context");

	if value == 1 then
		local profil = getProfile(context.profileID);
		showConfirmPopup(loc("REG_DELETE_WARNING"):format(Utils.str.color("g") .. getCompleteName(profil.characteristics or {}, UNKNOWN, true) .. "|r"),
			function()
				deleteProfile(context.profileID);
			end);
	elseif value == 2 then
		showTextInputPopup(loc("REG_PLAYER_IGNORE_WARNING"):format(strjoin("\n", unpack(getKeys(context.profile.link)))), function(text)
			for unitID, _ in pairs(context.profile.link) do
				ignoreID(unitID, text);
			end
			toast(loc("REG_IGNORE_TOAST"), 2);
		end);
	elseif type(value) == "string" then
		setRelation(context.profileID, value);
		setupRelationButton(context.profileID, context.profile);
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, context.profileID, "characteristics");
	end
end

local function onActionClicked(button)
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	assert(context.profile, "No profile in context");

	local values = {};
	tinsert(values, { loc("PR_DELETE_PROFILE"), 1 });
	if context.profile.link and tsize(context.profile.link) > 0 then
		tinsert(values, { loc("REG_PLAYER_IGNORE"):format(tsize(context.profile.link)), 2 });
	end
	tinsert(values, {
		loc("REG_RELATION"),
		{
			{ loc("REG_RELATION_NONE"), RELATIONS.NONE },
			{ loc("REG_RELATION_UNFRIENDLY"), RELATIONS.UNFRIENDLY },
			{ loc("REG_RELATION_NEUTRAL"), RELATIONS.NEUTRAL },
			{ loc("REG_RELATION_BUSINESS"), RELATIONS.BUSINESS },
			{ loc("REG_RELATION_FRIEND"), RELATIONS.FRIEND },
			{ loc("REG_RELATION_LOVE"), RELATIONS.LOVE },
			{ loc("REG_RELATION_FAMILY"), RELATIONS.FAMILY },
		},
	});
	displayDropDown(button, values, onActionSelected, 0, true);
end



local function showCharacteristicsTab()
	TRP3_RegisterCharact:Show();
	getCurrentContext().isEditMode = false;
	refreshDisplay();
end

TRP3_API.register.ui.showCharacteristicsTab = showCharacteristicsTab;

local function onEdit()
	if draftData then
		wipe(draftData);
		draftData = nil;
	end
	getCurrentContext().isEditMode = true;
	refreshDisplay();
end

local function onSave()
	saveCharacteristics();
	showCharacteristicsTab();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CHARACTERISTICS - INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function initStructures()
	TRAIT_PRESETS_UNKNOWN = {
		LT = loc("CM_UNKNOWN"),
		RT = loc("CM_UNKNOWN"),
		LI = "INV_Misc_QuestionMark",
		RI = "INV_Misc_QuestionMark",
		leftColor = {1.0, 1.0, 0.4}, -- Yellow for both text and bar
		rightColor = {0.55, 0.55, 0.95} -- Light blue for both text and bar
	};

	TRAIT_PRESETS = {
		{
			LT = loc("REG_PLAYER_TRAIT_CHAOTIC"),
			RT = loc("REG_PLAYER_TRAIT_LOYAL"),
			LI = "Ability_Rogue_WrongfullyAccused",
			RI = "Ability_Paladin_SanctifiedWrath",
			leftColor = {0.6, 0.2, 0.8}, -- Purple
			rightColor = {0.2, 0.6, 1.0} -- Blue
		},
		{
			LT = loc("REG_PLAYER_TRAIT_CHASTE"),
			RT = loc("REG_PLAYER_TRAIT_LUSTFUL"),
			LI = "INV_Belt_27",
			RI = "Spell_Shadow_SummonSuccubus",
			leftColor = {1.0, 1.0, 1.0}, -- White
			rightColor = {1.0, 0.2, 0.2} -- Red
		},
		{
			LT = loc("REG_PLAYER_TRAIT_FORGIVING"),
			RT = loc("REG_PLAYER_TRAIT_VENGEFUL"),
			LI = "INV_RoseBouquet01",
			RI = "Ability_Hunter_SniperShot",
			leftColor = {0.4, 0.8, 0.4}, -- Green
			rightColor = {1.0, 0.6, 0.2} -- Orange
		},
		{
			LT = loc("REG_PLAYER_TRAIT_GENEROUS"),
			RT = loc("REG_PLAYER_TRAIT_SELFISH"),
			LI = "INV_Misc_Gift_02",
			RI = "INV_Misc_Coin_02",
			leftColor = {1.0, 0.8, 0.2}, -- Gold
			rightColor = {0.8, 0.2, 0.2} -- Dark Red
		},
		{
			LT = loc("REG_PLAYER_TRAIT_SINCERE"),
			RT = loc("REG_PLAYER_TRAIT_DECEPTIVE"),
			LI = "INV_Misc_Toy_07",
			RI = "Ability_Rogue_Disguise",
			leftColor = {0.5, 0.8, 1.0}, -- Light Blue
			rightColor = {0.5, 0.2, 0.6} -- Dark Purple
		},
		{
			LT = loc("REG_PLAYER_TRAIT_MERCIFUL"),
			RT = loc("REG_PLAYER_TRAIT_CRUEL"),
			LI = "INV_ValentinesCandySack",
			RI = "Ability_Warrior_Trauma",
			leftColor = {1.0, 0.6, 0.8}, -- Pink
			rightColor = {0.7, 0.1, 0.1} -- Dark Red
		},
		{
			LT = loc("REG_PLAYER_TRAIT_SPIRITUAL"),
			RT = loc("REG_PLAYER_TRAIT_RATIONAL"),
			LI = "Spell_Holy_HolyGuidance",
			RI = "INV_Gizmo_02",
			leftColor = {1.0, 0.9, 0.3}, -- Yellow
			rightColor = {0.3, 0.8, 0.8} -- Cyan
		},
		{
			LT = loc("REG_PLAYER_TRAIT_PRAGMATIC"),
			RT = loc("REG_PLAYER_TRAIT_DIPLOMATIC"),
			LI = "Ability_Rogue_HonorAmongstThieves",
			RI = "INV_Misc_GroupNeedMore",
			leftColor = {0.7, 0.5, 0.3}, -- Brown
			rightColor = {0.6, 0.9, 0.6} -- Light Green
		},
		{
			LT = loc("REG_PLAYER_TRAIT_THOUGHTFUL"),
			RT = loc("REG_PLAYER_TRAIT_IMPULSIVE"),
			LI = "Spell_Shadow_Brainwash",
			RI = "Achievement_BG_CaptureFlag_EOS",
			leftColor = {0.3, 0.5, 0.8}, -- Dark Blue
			rightColor = {1.0, 0.5, 0.1} -- Bright Orange
		},
		{
			LT = loc("REG_PLAYER_TRAIT_ASCETIC"),
			RT = loc("REG_PLAYER_TRAIT_HEDONISTIC"),
			LI = "INV_Misc_Food_PineNut",
			RI = "INV_Misc_Food_99",
			leftColor = {0.7, 0.7, 0.7}, -- Gray
			rightColor = {0.9, 0.3, 0.7} -- Magenta
		},
		{
			LT = loc("REG_PLAYER_TRAIT_VALOROUS"),
			RT = loc("REG_PLAYER_TRAIT_COWARDLY"),
			LI = "Ability_Paladin_BeaconofLight",
			RI = "Ability_Druid_Cower",
			leftColor = {1.0, 0.9, 0.1}, -- Bright Gold
			rightColor = {0.5, 0.5, 0.5} -- Dark Gray
		},
		-- Warcraft Chronicles Cosmology traits
		{
			LT = loc("REG_PLAYER_TRAIT_LIGHT"),
			RT = loc("REG_PLAYER_TRAIT_SHADOW"),
			LI = "Spell_Holy_DivineIllumination",
			RI = "Spell_Shadow_ShadowWordPain",
			leftColor = {1.0, 0.9, 0.2}, -- Yellow/Gold (Holy)
			rightColor = {0.5, 0.2, 0.8} -- Purple-ish (Void)
		},
		{
			LT = loc("REG_PLAYER_TRAIT_LIFE"),
			RT = loc("REG_PLAYER_TRAIT_DEATH"),
			LI = "Spell_Nature_HealingTouch",
			RI = "Spell_Shadow_RaiseDead",
			leftColor = {0.2, 0.8, 0.6}, -- Green/Teal (Nature)
			rightColor = {0.5, 0.5, 0.5} -- Gray (Necromancy)
		},
		{
			LT = loc("REG_PLAYER_TRAIT_ORDER"),
			RT = loc("REG_PLAYER_TRAIT_DISORDER"),
			LI = "Spell_Arcane_MassDispel",
			RI = "Spell_Fire_FelImmolation",
			leftColor = {0.2, 0.5, 1.0}, -- Blue (Arcane)
			rightColor = {0.5, 0.8, 0.2} -- Green (Fel)
		},
	};

	TRAIT_PRESETS_DROPDOWN = {
		{ loc("REG_PLAYER_TRAIT_SOCIAL") },
		{ loc("REG_PLAYER_TRAIT_CHAOTIC") .. " - " .. loc("REG_PLAYER_TRAIT_LOYAL"), 1 },
		{ loc("REG_PLAYER_TRAIT_CHASTE") .. " - " .. loc("REG_PLAYER_TRAIT_LUSTFUL"), 2 },
		{ loc("REG_PLAYER_TRAIT_FORGIVING") .. " - " .. loc("REG_PLAYER_TRAIT_VENGEFUL"), 3 },
		{ loc("REG_PLAYER_TRAIT_GENEROUS") .. " - " .. loc("REG_PLAYER_TRAIT_SELFISH"), 4 },
		{ loc("REG_PLAYER_TRAIT_SINCERE") .. " - " .. loc("REG_PLAYER_TRAIT_DECEPTIVE"), 5 },
		{ loc("REG_PLAYER_TRAIT_MERCIFUL") .. " - " .. loc("REG_PLAYER_TRAIT_CRUEL"), 6 },
		{ loc("REG_PLAYER_TRAIT_SPIRITUAL") .. " - " .. loc("REG_PLAYER_TRAIT_RATIONAL"), 7 },
		{ loc("REG_PLAYER_TRAIT_PERSONAL") },
		{ loc("REG_PLAYER_TRAIT_PRAGMATIC") .. " - " .. loc("REG_PLAYER_TRAIT_DIPLOMATIC"), 8 },
		{ loc("REG_PLAYER_TRAIT_THOUGHTFUL") .. " - " .. loc("REG_PLAYER_TRAIT_IMPULSIVE"), 9 },
		{ loc("REG_PLAYER_TRAIT_ASCETIC") .. " - " .. loc("REG_PLAYER_TRAIT_HEDONISTIC"), 10 },
		{ loc("REG_PLAYER_TRAIT_VALOROUS") .. " - " .. loc("REG_PLAYER_TRAIT_COWARDLY"), 11 },
		{ loc("REG_PLAYER_TRAIT_COSMIC") },
		{ loc("REG_PLAYER_TRAIT_LIGHT") .. " - " .. loc("REG_PLAYER_TRAIT_SHADOW"), 12 },
		{ loc("REG_PLAYER_TRAIT_LIFE") .. " - " .. loc("REG_PLAYER_TRAIT_DEATH"), 13 },
		{ loc("REG_PLAYER_TRAIT_ORDER") .. " - " .. loc("REG_PLAYER_TRAIT_DISORDER"), 14 },
		{ loc("REG_PLAYER_TRAIT_CUSTOM") },
		{ loc("REG_PLAYER_TRAIT_CREATENEW"), "new" },
	};
end

function TRP3_API.register.inits.characteristicsInit()
	initStructures();

	-- UI
	TRP3_RegisterCharact_Edit_MiscAdd:SetScript("OnClick", miscAddDropDown);
	TRP3_RegisterCharact_Edit_NamePanel_Icon:SetScript("OnClick", function() showIconBrowser(onPlayerIconSelected) end);
	TRP3_RegisterCharact_NamePanel_Edit_CancelButton:SetScript("OnClick", showCharacteristicsTab);
	TRP3_RegisterCharact_NamePanel_Edit_SaveButton:SetScript("OnClick", onSave);
	TRP3_RegisterCharact_NamePanel_EditButton:SetScript("OnClick", onEdit);
	TRP3_RegisterCharact_ActionButton:SetScript("OnClick", onActionClicked);
	TRP3_RegisterCharact_Edit_ResidenceButton:SetScript("OnClick", function()
		TRP3_RegisterCharact_Edit_ResidenceField:SetText(buildZoneText());
	end);
	TRP3_RegisterCharact_Edit_BirthplaceButton:SetScript("OnClick", function()
		TRP3_RegisterCharact_Edit_BirthplaceField:SetText(buildZoneText());
	end);
	TRP3_RegisterCharact_Edit_ClassButton.onSelection = onClassColorSelected;
	TRP3_RegisterCharact_Edit_EyeButton.onSelection = onEyeColorSelected;

	setupDropDownMenu(TRP3_RegisterCharact_Edit_PsychoAdd, TRAIT_PRESETS_DROPDOWN, psychoAdd, 0, true, false);

	-- Localz
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_NamePanel_Icon, "RIGHT", 0, 5, loc("REG_PLAYER_ICON"), loc("REG_PLAYER_ICON_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_TitleFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_TITLE"), loc("REG_PLAYER_TITLE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_FirstFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_FIRSTNAME"), loc("REG_PLAYER_FIRSTNAME_TT"):format(Globals.player));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_LastFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_LASTNAME"), loc("REG_PLAYER_LASTNAME_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_FullTitleFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_FULLTITLE"), loc("REG_PLAYER_FULLTITLE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_RaceFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_RACE"), loc("REG_PLAYER_RACE_TT"):format(Globals.player_race_loc));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_ClassFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_CLASS"), loc("REG_PLAYER_CLASS_TT"):format(Globals.player_class_loc));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_AgeFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_AGE"), loc("REG_PLAYER_AGE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_BirthplaceFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_BIRTHPLACE"), loc("REG_PLAYER_BIRTHPLACE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_ResidenceFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_RESIDENCE"), loc("REG_PLAYER_RESIDENCE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_EyeFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_EYE"), loc("REG_PLAYER_EYE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_HeightFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_HEIGHT"), loc("REG_PLAYER_HEIGHT_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_WeightFieldHelp, "RIGHT", 0, 5, loc("REG_PLAYER_WEIGHT"), loc("REG_PLAYER_WEIGHT_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_ResidenceButton, "RIGHT", 0, 5, loc("REG_PLAYER_HERE"), loc("REG_PLAYER_HERE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_BirthplaceButton, "RIGHT", 0, 5, loc("REG_PLAYER_HERE"), loc("REG_PLAYER_HERE_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_EyeButton, "RIGHT", 0, 5, loc("REG_PLAYER_EYE"), loc("REG_PLAYER_COLOR_TT"));
	setTooltipForSameFrame(TRP3_RegisterCharact_Edit_ClassButton, "RIGHT", 0, 5, loc("REG_PLAYER_COLOR_CLASS"), loc("REG_PLAYER_COLOR_CLASS_TT") .. loc("REG_PLAYER_COLOR_TT"));

	setupFieldSet(TRP3_RegisterCharact_NamePanel, loc("REG_PLAYER_NAMESTITLES"), 150);
	setupFieldSet(TRP3_RegisterCharact_Edit_NamePanel, loc("REG_PLAYER_NAMESTITLES"), 150);
	setupFieldSet(TRP3_RegisterCharact_CharactPanel, loc("REG_PLAYER_CHARACTERISTICS"), 150);
	setupFieldSet(TRP3_RegisterCharact_Edit_CharactPanel, loc("REG_PLAYER_CHARACTERISTICS"), 150);

	setupEditBoxesNavigation({
		TRP3_RegisterCharact_Edit_RaceField,
		TRP3_RegisterCharact_Edit_ClassField,
		TRP3_RegisterCharact_Edit_AgeField,
		TRP3_RegisterCharact_Edit_ResidenceField,
		TRP3_RegisterCharact_Edit_EyeField,
		TRP3_RegisterCharact_Edit_BirthplaceField,
		TRP3_RegisterCharact_Edit_HeightField,
		TRP3_RegisterCharact_Edit_WeightField
	})

	setupEditBoxesNavigation({
		TRP3_RegisterCharact_Edit_TitleField,
		TRP3_RegisterCharact_Edit_FirstField,
		TRP3_RegisterCharact_Edit_LastField,
		TRP3_RegisterCharact_Edit_FullTitleField
	});

	TRP3_RegisterCharact_CharactPanel_Empty:SetText(loc("REG_PLAYER_NO_CHAR"));
	TRP3_RegisterCharact_Edit_MiscAdd:SetText(loc("REG_PLAYER_MISC_ADD"));
	TRP3_RegisterCharact_Edit_PsychoAdd:SetText(loc("REG_PLAYER_PSYCHO_ADD"));
	TRP3_RegisterCharact_NamePanel_Edit_CancelButton:SetText(loc("CM_CANCEL"));
	TRP3_RegisterCharact_NamePanel_Edit_SaveButton:SetText(loc("CM_SAVE"));
	TRP3_RegisterCharact_NamePanel_EditButton:SetText(loc("CM_EDIT"));
	TRP3_RegisterCharact_Edit_TitleFieldText:SetText(loc("REG_PLAYER_TITLE"));
	TRP3_RegisterCharact_Edit_FirstFieldText:SetText(loc("REG_PLAYER_FIRSTNAME"));
	TRP3_RegisterCharact_Edit_LastFieldText:SetText(loc("REG_PLAYER_LASTNAME"));
	TRP3_RegisterCharact_Edit_FullTitleFieldText:SetText(loc("REG_PLAYER_FULLTITLE"));
	TRP3_RegisterCharact_CharactPanel_RegisterTitle:SetText(loc("REG_PLAYER_REGISTER"));
	TRP3_RegisterCharact_CharactPanel_Edit_RegisterTitle:SetText(loc("REG_PLAYER_REGISTER"));
	TRP3_RegisterCharact_CharactPanel_PsychoTitle:SetText(loc("REG_PLAYER_OTHER"));
	TRP3_RegisterCharact_CharactPanel_Edit_PsychoTitle:SetText(loc("REG_PLAYER_OTHER"));
	TRP3_RegisterCharact_CharactPanel_MiscTitle:SetText(loc("REG_PLAYER_MORE_INFO"));
	TRP3_RegisterCharact_CharactPanel_Edit_MiscTitle:SetText(loc("REG_PLAYER_MORE_INFO"));
	TRP3_RegisterCharact_Edit_RaceFieldText:SetText(loc("REG_PLAYER_RACE"));
	TRP3_RegisterCharact_Edit_ClassFieldText:SetText(loc("REG_PLAYER_CLASS"));
	TRP3_RegisterCharact_Edit_AgeFieldText:SetText(loc("REG_PLAYER_AGE"));
	TRP3_RegisterCharact_Edit_EyeFieldText:SetText(loc("REG_PLAYER_EYE"));
	TRP3_RegisterCharact_Edit_HeightFieldText:SetText(loc("REG_PLAYER_HEIGHT"));
	TRP3_RegisterCharact_Edit_WeightFieldText:SetText(loc("REG_PLAYER_WEIGHT"));
	TRP3_RegisterCharact_Edit_ResidenceFieldText:SetText(loc("REG_PLAYER_RESIDENCE"));
	TRP3_RegisterCharact_Edit_BirthplaceFieldText:SetText(loc("REG_PLAYER_BIRTHPLACE"));

	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, compressData); -- On profile change, compress the new data
	compressData();
end