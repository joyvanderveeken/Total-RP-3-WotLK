----------------------------------------------------------------------------------
-- Total RP 3
-- Character tooltips
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
local Globals = TRP3_API.globals;
local Utils = TRP3_API.utils;
local colorCode, getTempTable, releaseTempTable = Utils.color.colorCode, Utils.table.getTempTable, Utils.table.releaseTempTable;
local loc = TRP3_API.locale.getText;
local getUnitIDCurrentProfile, isIDIgnored = TRP3_API.register.getUnitIDCurrentProfile, TRP3_API.register.isIDIgnored;
local getIgnoreReason = TRP3_API.register.getIgnoreReason;
local ui_CharacterTT = TRP3_CharacterTooltip;
local getCharacterUnitID = Utils.str.getUnitID;
local get = TRP3_API.profile.getData;
local getConfigValue = TRP3_API.configuration.getValue;
local registerConfigKey = TRP3_API.configuration.registerConfigKey;
local registerConfigHandler = TRP3_API.configuration.registerHandler;
local strconcat = strconcat;
local getCompleteName = TRP3_API.register.getCompleteName;
local getOtherCharacter = TRP3_API.register.getUnitIDCharacter;
local getYourCharacter = TRP3_API.profile.getPlayerCharacter;
local IsUnitIDKnown = TRP3_API.register.isUnitIDKnown;
local UnitAffectingCombat = UnitAffectingCombat;
local Events = TRP3_API.events;
local GameTooltip, _G, pairs, wipe, tinsert, strtrim = GameTooltip, _G, pairs, wipe, tinsert, strtrim;
local UnitName, UnitPVPName, UnitFactionGroup, UnitIsAFK, UnitIsDND = UnitName, UnitPVPName, UnitFactionGroup, UnitIsAFK, UnitIsDND;
local UnitIsPVP, UnitRace, UnitLevel, GetGuildInfo, UnitIsPlayer, UnitClass = UnitIsPVP, UnitRace, UnitLevel, GetGuildInfo, UnitIsPlayer, UnitClass;
local hasProfile, getRelationColors = TRP3_API.register.hasProfile, TRP3_API.register.relation.getRelationColors;
local checkGlanceActivation = TRP3_API.register.checkGlanceActivation;
local IC_GUILD, OOC_GUILD;
-- Simplified type constants for character-only handling
local TYPE_CHARACTER = 1;
local EMPTY = Globals.empty;
local unitIDToInfo = Utils.str.unitIDToInfo;

-- ICONS
local AFK_ICON = "|TInterface\\FriendsFrame\\StatusIcon-Away:25:25|t";
local DND_ICON = "|TInterface\\FriendsFrame\\StatusIcon-DnD:25:25|t";
local OOC_ICON = "|TInterface\\AddOns\\TotalRP3\\Resources\\UI\\Indicator-Red:25:25|t";
local ALLIANCE_ICON = "|TInterface\\AddOns\\totalRP3\\resources\\UI\\UI-PVP-Alliance:25:25:0:0:64:64:6:36:3:37|t";
local HORDE_ICON = "|TInterface\\AddOns\\totalRP3\\resources\\UI\\UI-PVP-Horde:25:25:0:0:64:64:6:34:3:36|t";
local PVP_ICON = "|TInterface\\AddOns\\totalRP3\\resources\\UI\\UI-StateIcon:25:25:0:0:64:64:34:60:5:27|t";
local BEGINNER_ICON = "|TInterface\\AddOns\\totalRP3\\resources\\UI\\NewPlayerHelp_Newcomer:20:20:0:0:256:256:72:184:68:188|t";
local VOLUNTEER_ICON = "|TInterface\\AddOns\\totalRP3\\resources\\UI\\NewPlayerHelp_Guide:20:20:0:0:256:256:72:184:68:188|t";
local BANNED_ICON = "|TInterface\\EncounterJournal\\UI-EJ-HeroicTextIcon:25:25|t";
local GLANCE_ICON = "|TInterface\\MINIMAP\\TRACKING\\None:25:25|t";
local NEW_ABOUT_ICON = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:25:25|t";
local PEEK_ICON_SIZE = 30;

-- Config keys
local CONFIG_PROFILE_ONLY = "tooltip_profile_only";
local CONFIG_CHARACT_COMBAT = "tooltip_char_combat";
local CONFIG_CHARACT_INSTANCE = "tooltip_char_instance";
local CONFIG_CHARACT_ANCHORED_FRAME = "tooltip_char_AnchoredFrame";
local CONFIG_CHARACT_ANCHOR = "tooltip_char_Anchor";
local CONFIG_CHARACT_HIDE_ORIGINAL = "tooltip_char_HideOriginal";
local CONFIG_CHARACT_ELVUI_STYLE = "tooltip_char_elvui_style";
local CONFIG_CHARACT_MAIN_SIZE = "tooltip_char_mainSize";
local CONFIG_CHARACT_SUB_SIZE = "tooltip_char_subSize";
local CONFIG_CHARACT_TER_SIZE = "tooltip_char_terSize";
local CONFIG_CHARACT_ICONS = "tooltip_char_icons";
local CONFIG_CHARACT_FT = "tooltip_char_ft";
local CONFIG_CHARACT_RACECLASS = "tooltip_char_rc";
local CONFIG_CHARACT_GUILD = "tooltip_char_guild";
local CONFIG_CHARACT_TARGET = "tooltip_char_target";
local CONFIG_CHARACT_TITLE = "tooltip_char_title";
local CONFIG_CHARACT_NOTIF = "tooltip_char_notif";
local CONFIG_CHARACT_CURRENT = "tooltip_char_current";
local CONFIG_CHARACT_OOC = "tooltip_char_ooc";
local CONFIG_CHARACT_OOC_NAME = "tooltip_char_ooc_name";
local CONFIG_CHARACT_HEALTHBAR = "tooltip_char_healthbar";
local CONFIG_CHARACT_CURRENT_SIZE = "tooltip_char_current_size";
local CONFIG_CHARACT_RELATION = "tooltip_char_relation";
local CONFIG_CHARACT_SPACING = "tooltip_char_spacing";

local ANCHOR_TAB;

-- default tooltip style
local TOOLTIP_BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
};

local cachedElvUIEnabled = false;

local function updateElvUIEnabledCache()
	cachedElvUIEnabled = getConfigValue(CONFIG_CHARACT_ELVUI_STYLE);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Tooltip styling
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TRP3_ElvUI_StyleData = nil

local function applyTooltipStyling()
	local E = _G.ElvUI and _G.ElvUI[1]

	if cachedElvUIEnabled and E then
		TRP3_ElvUI_StyleData = {
			enabled = true,
			E = E
		}
	else
		TRP3_ElvUI_StyleData = {
			enabled = false,
			E = nil
		}
	end

	local trp3Tooltips = {
		ui_CharacterTT,
		_G.TRP3_MainTooltip
	}
	
	if cachedElvUIEnabled and E then
		for _, tooltip in ipairs(trp3Tooltips) do
			if tooltip and tooltip.SetTemplate then
				local success = false
				local templates = {"Transparent", "Default", nil}
				
				for i, template in ipairs(templates) do
					success = pcall(function()
						if template then
							tooltip:SetTemplate(template)
						else
							tooltip:SetTemplate()
						end
					end)
					
					if success then
						break
					end
				end
				
				if success then
					if E.frames then
						E.frames[tooltip] = true
					elseif E.createdFrames then
						E.createdFrames[tooltip] = true
					end
				else
					tooltip:SetBackdrop(TOOLTIP_BACKDROP);
					-- default tooltip
					tooltip:SetBackdropColor(0.1, 0.1, 0.2, 1.0);
					tooltip:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0);
				end
			end
		end

		if E.UpdateBackdropColors then
			E:UpdateBackdropColors()
		end
		
		if E.UpdateFrameTemplates then
			E:UpdateFrameTemplates()
		end
		
		if E.UpdateFontTemplates then
			E:UpdateFontTemplates()
		end
	else
		if E and E.frames then
			for _, tooltip in ipairs(trp3Tooltips) do
				if tooltip then
					E.frames[tooltip] = nil
				end
			end
		end

		for _, tooltip in ipairs(trp3Tooltips) do
			if tooltip then
				tooltip:SetBackdrop(TOOLTIP_BACKDROP);
				-- default tooltip
				tooltip:SetBackdropColor(0.1, 0.1, 0.2, 1.0);
				tooltip:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0);
			end
		end
	end
end

local function applyElvUIStyleToTooltip(tooltip)
	if not tooltip or not TRP3_ElvUI_StyleData or not TRP3_ElvUI_StyleData.enabled then
		return false
	end
	
	local E = TRP3_ElvUI_StyleData.E
	if not E or not tooltip.SetTemplate then
		return false
	end
	
	local success = false
	local templates = {"Transparent", "Default", nil}
	
	for i, template in ipairs(templates) do
		success = pcall(function()
			if template then
				tooltip:SetTemplate(template)
			else
				tooltip:SetTemplate()
			end
		end)
		
		if success then
			break
		end
	end
	
	if success then
		if E.frames then
			E.frames[tooltip] = true
		elseif E.createdFrames then
			E.createdFrames[tooltip] = true
		end
		return true
	end
	
	return false
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Config getters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getAnchoredFrame()
	if getConfigValue(CONFIG_CHARACT_ANCHORED_FRAME) == "" then return nil end;
	return _G[getConfigValue(CONFIG_CHARACT_ANCHORED_FRAME)] or GameTooltip;
end

local function showRelationColor()
	return getConfigValue(CONFIG_CHARACT_RELATION);
end

local function getAnchoredPosition()
	return getConfigValue(CONFIG_CHARACT_ANCHOR);
end

local function shouldHideGameTooltip()
	return getConfigValue(CONFIG_CHARACT_HIDE_ORIGINAL);
end

local function getMainLineFontSize()
	return getConfigValue(CONFIG_CHARACT_MAIN_SIZE);
end

local function getSubLineFontSize()
	return getConfigValue(CONFIG_CHARACT_SUB_SIZE);
end

local function getSmallLineFontSize()
	return getConfigValue(CONFIG_CHARACT_TER_SIZE);
end

local function showIcons()
	return getConfigValue(CONFIG_CHARACT_ICONS);
end

local function showFullTitle()
	return getConfigValue(CONFIG_CHARACT_FT);
end

local function showRaceClass()
	return getConfigValue(CONFIG_CHARACT_RACECLASS);
end

local function showGuild()
	return getConfigValue(CONFIG_CHARACT_GUILD);
end

local function showTarget()
	return getConfigValue(CONFIG_CHARACT_TARGET);
end

local function showTitle()
	return getConfigValue(CONFIG_CHARACT_TITLE);
end

local function showNotifications()
	return getConfigValue(CONFIG_CHARACT_NOTIF);
end

local function showCurrently()
	return getConfigValue(CONFIG_CHARACT_CURRENT);
end

local function showMoreInformation()
	return getConfigValue(CONFIG_CHARACT_OOC);
end

local function showOOCName()
	return getConfigValue(CONFIG_CHARACT_OOC_NAME);
end

local function getCurrentMaxSize()
	return getConfigValue(CONFIG_CHARACT_CURRENT_SIZE);
end

local function showSpacing()
	return getConfigValue(CONFIG_CHARACT_SPACING);
end

local function showHealthBar()
	return getConfigValue(CONFIG_CHARACT_HEALTHBAR);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UTIL METHOD
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function isElvUITooltipStylingActive()
	local E = _G.ElvUI and _G.ElvUI[1]
	return cachedElvUIEnabled and E and ui_CharacterTT.SetTemplate
end

local function getGameTooltipTexts()
	local tab = {};
	for j = 1, GameTooltip:NumLines() do
		tab[j] = _G["GameTooltipTextLeft" ..  j]:GetText();
	end
	return tab;
end

-- util to get ElvUI font(size)
-- fontType: "header", "text", "small" - determines which ElvUI font size to use
local function getElvUIFontSettings(fallbackFont, fallbackSize, fontType)
	if not cachedElvUIEnabled then
		return fallbackFont, fallbackSize
	end
	
	local E = _G.ElvUI and _G.ElvUI[1]
	if not (E and E.media) then
		return fallbackFont, fallbackSize
	end
	
	local currentFont = E.media.normFont or fallbackFont
	local currentFontSize = fallbackSize
	
	if E.db and E.db.tooltip then
		if fontType == "header" and E.db.tooltip.headerFontSize then
			currentFontSize = E.db.tooltip.headerFontSize
		elseif fontType == "small" and E.db.tooltip.smallTextFontSize then
			currentFontSize = E.db.tooltip.smallTextFontSize
		elseif fontType == "text" and E.db.tooltip.fontSize then
		currentFontSize = E.db.tooltip.fontSize
		elseif E.db.tooltip.fontSize then
			currentFontSize = E.db.tooltip.fontSize
		end
	elseif E.media.normFontSize then
		currentFontSize = E.media.normFontSize
	end
	
	return currentFont, currentFontSize
end

-- util to determine ElvUI font type based on TRP3 font size
local function getFontTypeFromSize(fontSize)
	local mainSize = getMainLineFontSize() or 16
	local subSize = getSubLineFontSize() or 12  
	local smallSize = getSmallLineFontSize() or 10
	
	if fontSize >= mainSize then
		return "header"
	elseif fontSize <= smallSize then
		return "small"
	else
		return "text"
	end
end

-- util to apply font to a specific text element
local function applyFontToElement(element, fontSize)
	if element and element.SetFont then
	local baseFont = TRP3_API.locale.getLocaleFont()
		local fontType = getFontTypeFromSize(fontSize)
		local currentFont, currentFontSize = getElvUIFontSettings(baseFont, fontSize, fontType)
		element:SetFont(currentFont, currentFontSize)
	end
end

local function setLineFont(tooltip, lineIndex, fontSize)
	local leftText = _G[strconcat(tooltip:GetName(), "TextLeft", lineIndex)]
	applyFontToElement(leftText, fontSize)
end

local function setDoubleLineFont(tooltip, lineIndex, fontSize)
	local leftText = _G[strconcat(tooltip:GetName(), "TextLeft", lineIndex)]
	local rightText = _G[strconcat(tooltip:GetName(), "TextRight", lineIndex)]
	applyFontToElement(leftText, fontSize)
	applyFontToElement(rightText, fontSize)
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TOOLTIP BUILDER
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local BUILDER_TYPE_LINE = 1;
local BUILDER_TYPE_DOUBLELINE = 2;
local BUILDER_TYPE_SPACE = 3;

local function AddLine(self, text, red, green, blue, lineSize, lineWrap)
	local lineStructure = getTempTable();
	lineStructure.type = BUILDER_TYPE_LINE;
	lineStructure.text = text;
	lineStructure.red = red;
	lineStructure.green = green;
	lineStructure.blue = blue;
	lineStructure.lineSize = lineSize;
	lineStructure.lineWrap = lineWrap;
	tinsert(self._content, lineStructure);
end

local function AddDoubleLine(self, textL, textR, redL, greenL, blueL, redR, greenR, blueR, lineSize)
	local lineStructure = getTempTable();
	lineStructure.type = BUILDER_TYPE_DOUBLELINE;
	lineStructure.textL = textL;
	lineStructure.redL = redL;
	lineStructure.greenL = greenL;
	lineStructure.blueL = blueL;
	lineStructure.textR = textR;
	lineStructure.redR = redR;
	lineStructure.greenR = greenR;
	lineStructure.blueR = blueR;
	lineStructure.lineSize = lineSize;
	tinsert(self._content, lineStructure);
end

local function AddSpace(self)
	if #self._content > 0 and self._content[#self._content].type == BUILDER_TYPE_SPACE then
		return; -- Don't add two spaces in a row.
	end
	local lineStructure = getTempTable();
	lineStructure.type = BUILDER_TYPE_SPACE;
	tinsert(self._content, lineStructure);
end

local function Build(self)
	local size = #self._content;
	local tooltipLineIndex = 1;
	for lineIndex, line in pairs(self._content) do
		if line.type == BUILDER_TYPE_LINE then
			self.tooltip:AddLine(line.text, line.red, line.green, line.blue, line.lineSize, line.lineWrap);
			setLineFont(self.tooltip, tooltipLineIndex, line.lineSize);
			tooltipLineIndex = tooltipLineIndex + 1;
		elseif line.type == BUILDER_TYPE_DOUBLELINE then
			self.tooltip:AddDoubleLine(line.textL, line.textR, line.redL, line.greenL, line.blueL, line.redR, line.greenR, line.blueR);
			setDoubleLineFont(self.tooltip, tooltipLineIndex, line.lineSize);
			tooltipLineIndex = tooltipLineIndex + 1;
		elseif line.type == BUILDER_TYPE_SPACE and showSpacing() and lineIndex ~= size then
			self.tooltip:AddLine(" ", 1, 0.50, 0, getSubLineFontSize());
			setLineFont(self.tooltip, tooltipLineIndex, getSubLineFontSize());
			tooltipLineIndex = tooltipLineIndex + 1;
		end
	end
	self.tooltip:Show();
	for index, tempTable in pairs(self._content) do
		self._content[index] = nil;
		releaseTempTable(tempTable);
	end
end

local function createTooltipBuilder(tooltip)
	local builder = {
		_content = {},
		tooltip = tooltip,
	};
	builder.AddLine = AddLine;
	builder.AddDoubleLine = AddDoubleLine;
	builder.AddSpace = AddSpace;
	builder.Build = Build;
	return builder;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CHARACTER TOOLTIP
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tooltipBuilder = createTooltipBuilder(ui_CharacterTT);

local function getUnitID(targetType)
	-- Simplified for character-only handling
	if UnitIsPlayer(targetType) then
		return getCharacterUnitID(targetType), TYPE_CHARACTER;
	end
	-- Return nil if not a player character
	return nil;
end

TRP3_API.register.getUnitID = getUnitID;

--- Returns a not nil table containing the character information.
-- The returned table is not nil, but could be empty.
local function getCharacterInfoTab(unitID)
	if unitID == Globals.player_id then
		return get("player");
	elseif IsUnitIDKnown(unitID) then
		return getUnitIDCurrentProfile(unitID) or {};
	end
	return {};
end

local function getCharacter(unitID)
	if unitID == Globals.player_id then
		return getYourCharacter();
	elseif IsUnitIDKnown(unitID) then
		return getOtherCharacter(unitID);
	end
	return {};
end

local function getFactionIcon(targetType)
	if UnitFactionGroup(targetType) == "Alliance" then
		return ALLIANCE_ICON;
	elseif UnitFactionGroup(targetType) == "Horde" then
		return HORDE_ICON;
	end
	return "";
end

local function getLevelIconOrText(targetType)
	if UnitLevel(targetType) ~= -1 then
		return UnitLevel(targetType);
	else
		return "|TInterface\\TARGETINGFRAME\\UI-TargetingFrame-Skull:16:16|t";
	end
end

--- The complete character's tooltip writing sequence.
local function writeTooltipForCharacter(targetID, originalTexts, targetType)
	local info = getCharacterInfoTab(targetID);
	local character = getCharacter(targetID);
	local targetName = UnitName(targetType);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- BLOCKED
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if isIDIgnored(targetID) then
		tooltipBuilder:AddLine(loc("REG_TT_IGNORED"), 1, 0, 0, getSubLineFontSize());
		tooltipBuilder:AddLine("\"" .. getIgnoreReason(targetID) .. "\"", 1, 0.75, 0, getSmallLineFontSize());
		tooltipBuilder:Build();
		return;
	end

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- icon, complete name, RP/AFK/PVP/Volunteer status
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local localizedClass, englishClass = UnitClass(targetType);
	local classColor = RAID_CLASS_COLORS[englishClass];
	local rightIcons = "";
	local leftIcons = "";
	local characterColorCode = colorCode(classColor.r * 255, classColor.g * 255, classColor.b * 255);
	if info.characteristics and info.characteristics.CH then
		characterColorCode = "|cff" .. info.characteristics.CH;
	end
	local completeName = characterColorCode .. getCompleteName(info.characteristics or {}, targetName, not showTitle());
	
	-- Add [OOC] prefix if the option is enabled and character is OOC
	if showOOCName() and info.character and info.character.RP ~= 1 then
		completeName = "|cffff9999[OOC]|r " .. completeName;
	end

	if showIcons() then
		-- Player icon
		if info.characteristics and info.characteristics.IC then
			leftIcons = strconcat(Utils.str.icon(info.characteristics.IC, 25), leftIcons, " ");
		end
		-- OOC
		if info.character and info.character.RP ~= 1 then
			rightIcons = strconcat(rightIcons, OOC_ICON);
		end
		-- AFK / DND status
		if UnitIsAFK(targetType) then
			rightIcons = strconcat(rightIcons, AFK_ICON);
		elseif UnitIsDND(targetType) then
			rightIcons = strconcat(rightIcons, DND_ICON);
		end
		-- PVP icon (faction)
		if UnitIsPVP(targetType) then
			rightIcons = strconcat(rightIcons, getFactionIcon(targetType));
		end
		-- Beginner icon / volunteer icon
		if info.character and info.character.XP == 1 then
			rightIcons = strconcat(rightIcons, BEGINNER_ICON);
		elseif info.character and info.character.XP == 3 then
			rightIcons = strconcat(rightIcons, VOLUNTEER_ICON);
		end
	end

	tooltipBuilder:AddDoubleLine(leftIcons .. completeName, rightIcons, 1, 1, 1, 1, 1, 1, getMainLineFontSize());

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- full title
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showFullTitle() then
		local fullTitle = "";
		if info.characteristics and info.characteristics.FT and info.characteristics.FT:len() > 0 then
			fullTitle = info.characteristics.FT;
		elseif UnitPVPName(targetType) ~= targetName then
			fullTitle = UnitPVPName(targetType);
		end
		if fullTitle:len() > 0 then
			tooltipBuilder:AddLine(strconcat("< ", fullTitle, " |r>"), 1, 0.50, 0, getSubLineFontSize(), true);
		end
	end

	tooltipBuilder:AddSpace();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- race, class, level and faction
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showRaceClass() then
		local lineLeft = "";
		local lineRight;
		local race = UnitRace(targetType);
		local class = localizedClass;
		if info.characteristics and info.characteristics.RA and info.characteristics.RA:len() > 0 then
			race = info.characteristics.RA;
		end
		if info.characteristics and info.characteristics.CL and info.characteristics.CL:len() > 0 then
			class = info.characteristics.CL;
		end
		lineLeft = strconcat("|cffffffff", race, " ", characterColorCode, class);
		lineRight = strconcat("|cffffffff", "Level ", getLevelIconOrText(targetType));

		tooltipBuilder:AddDoubleLine(lineLeft, lineRight, 1, 1, 1, 1, 1, 1, getSubLineFontSize());
	end

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Guild
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local guild, grade = GetGuildInfo(targetType);
	if showGuild() and guild then
		local text = loc("REG_TT_GUILD"):format(grade, guild);
		local membership;
		if info.misc and info.misc.ST then
			if info.misc.ST["6"] == 1 then -- IC guild membership
				membership = IC_GUILD;
			elseif info.misc.ST["6"] == 2 then -- OOC guild membership
				membership = OOC_GUILD;
			end
		end
		tooltipBuilder:AddDoubleLine(text, membership, 1, 1, 1, 1, 1, 1, getSubLineFontSize());
	end

	tooltipBuilder:AddSpace();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- CURRENTLY
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showCurrently() and info.character and (info.character.CU or ""):len() > 0 then
		tooltipBuilder:AddLine(loc("REG_PLAYER_CURRENT"), 1, 1, 1, getSubLineFontSize());

		local text = strtrim(info.character.CU);
		if text:len() > getCurrentMaxSize() then
			text = text:sub(1, getCurrentMaxSize()) .. "…";
		end
		tooltipBuilder:AddLine(text , 1, 0.75, 0, getSmallLineFontSize(), true);
	end

	tooltipBuilder:AddSpace();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- OOC More information
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showMoreInformation() and info.character and (info.character.CO or ""):len() > 0 then
		tooltipBuilder:AddLine(loc("DB_STATUS_CURRENTLY_OOC"), 1, 1, 1, getSubLineFontSize());

		local text = strtrim(info.character.CO);
		if text:len() > getCurrentMaxSize() then
			text = text:sub(1, getCurrentMaxSize()) .. "…";
		end
		tooltipBuilder:AddLine(text, 1, 0.75, 0, getSmallLineFontSize(), true);
	end

	tooltipBuilder:AddSpace();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Target
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showTarget() and UnitName(targetType .. "target") then
		local name = UnitName(targetType .. "target");
		local targetTargetID = getUnitID(targetType .. "target");
		if targetTargetID then
			local targetInfo = getCharacterInfoTab(targetTargetID);
			local characterColorCode = "";
			if targetInfo.characteristics and targetInfo.characteristics.CH then
				characterColorCode = "|cff" .. targetInfo.characteristics.CH;
			end
			name = characterColorCode .. getCompleteName(targetInfo.characteristics or {}, targetName, true);
		end
		tooltipBuilder:AddLine(loc("REG_TT_TARGET"):format(name), 1, 1, 1, getSubLineFontSize());
	end

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Quick peek & new description notifications & Client
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showNotifications() then
		local notifText = "";
		if info.misc and info.misc.PE and checkGlanceActivation(info.misc.PE) then
			notifText = GLANCE_ICON;
		end
		if targetID ~= Globals.player_id and info.about and not info.about.read then
			notifText = notifText .. " " ..NEW_ABOUT_ICON;
		end
		local clientText = "";
		if targetID == Globals.player_id then
			clientText = strconcat("|cffffffff", Globals.addon_name_alt, " v", Globals.version_display);
		elseif IsUnitIDKnown(targetID) then
			if character.client then
				clientText = strconcat("|cffffffff", character.client, " v", character.clientVersion);
			end
		end
		if notifText:len() > 0 or clientText:len() > 0 then
			if notifText:len() == 0 then
				notifText = " "; -- Prevent bad right line height
			end
			tooltipBuilder:AddDoubleLine(notifText, clientText, 1, 1, 1, 0, 1, 0, getSmallLineFontSize());
		end
	end

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Build tooltip
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	tooltipBuilder:Build();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Healthbar
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	if showHealthBar() and UnitExists(targetType) and UnitHealth(targetType) then
		local currentHP = UnitHealth(targetType);
		local maxHP = UnitHealthMax(targetType);
		
		if currentHP and maxHP and maxHP > 0 then
			if not ui_CharacterTT.healthBar then
				-- foreground
				ui_CharacterTT.healthBar = CreateFrame("StatusBar", nil, ui_CharacterTT);
				ui_CharacterTT.healthBar:SetFrameLevel(ui_CharacterTT:GetFrameLevel() + 1);
				ui_CharacterTT.healthBar:SetOrientation("HORIZONTAL");
				
				-- background
				ui_CharacterTT.healthBar.bg = ui_CharacterTT.healthBar:CreateTexture(nil, "BACKGROUND");
				ui_CharacterTT.healthBar.bg:SetAllPoints();
				ui_CharacterTT.healthBar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar"); -- Default WoW background
				ui_CharacterTT.healthBar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8);
				
				-- borderframe
				if cachedElvUIEnabled then 
					ui_CharacterTT.healthBar.border = CreateFrame("Frame", nil, ui_CharacterTT.healthBar);
					ui_CharacterTT.healthBar.border:SetAllPoints();
					ui_CharacterTT.healthBar.border:SetFrameLevel(ui_CharacterTT.healthBar:GetFrameLevel() + 1);
					local borderSize = 1;
					
					-- top
					ui_CharacterTT.healthBar.border.top = ui_CharacterTT.healthBar.border:CreateTexture(nil, "OVERLAY");
					ui_CharacterTT.healthBar.border.top:SetTexture(0, 0, 0, 1); 
					ui_CharacterTT.healthBar.border.top:SetPoint("TOPLEFT", ui_CharacterTT.healthBar.border, "TOPLEFT", 0, 0);
					ui_CharacterTT.healthBar.border.top:SetPoint("TOPRIGHT", ui_CharacterTT.healthBar.border, "TOPRIGHT", 0, 0);
					ui_CharacterTT.healthBar.border.top:SetHeight(borderSize);
					
					-- bottom
					ui_CharacterTT.healthBar.border.bottom = ui_CharacterTT.healthBar.border:CreateTexture(nil, "OVERLAY");
					ui_CharacterTT.healthBar.border.bottom:SetTexture(0, 0, 0, 1); 
					ui_CharacterTT.healthBar.border.bottom:SetPoint("BOTTOMLEFT", ui_CharacterTT.healthBar.border, "BOTTOMLEFT", 0, 0);
					ui_CharacterTT.healthBar.border.bottom:SetPoint("BOTTOMRIGHT", ui_CharacterTT.healthBar.border, "BOTTOMRIGHT", 0, 0);
					ui_CharacterTT.healthBar.border.bottom:SetHeight(borderSize);
					
					-- left
					ui_CharacterTT.healthBar.border.left = ui_CharacterTT.healthBar.border:CreateTexture(nil, "OVERLAY");
					ui_CharacterTT.healthBar.border.left:SetTexture(0, 0, 0, 1); 
					ui_CharacterTT.healthBar.border.left:SetPoint("TOPLEFT", ui_CharacterTT.healthBar.border, "TOPLEFT", 0, 0);
					ui_CharacterTT.healthBar.border.left:SetPoint("BOTTOMLEFT", ui_CharacterTT.healthBar.border, "BOTTOMLEFT", 0, 0);
					ui_CharacterTT.healthBar.border.left:SetWidth(borderSize);
					
					-- right
					ui_CharacterTT.healthBar.border.right = ui_CharacterTT.healthBar.border:CreateTexture(nil, "OVERLAY");
					ui_CharacterTT.healthBar.border.right:SetTexture(0, 0, 0, 1); 
					ui_CharacterTT.healthBar.border.right:SetPoint("TOPRIGHT", ui_CharacterTT.healthBar.border, "TOPRIGHT", 0, 0);
					ui_CharacterTT.healthBar.border.right:SetPoint("BOTTOMRIGHT", ui_CharacterTT.healthBar.border, "BOTTOMRIGHT", 0, 0);
					ui_CharacterTT.healthBar.border.right:SetWidth(borderSize);
				end
			end
			
			-- fetch elvui config
			local E = _G.ElvUI and _G.ElvUI[1];
			local healthBarHeight = 8;
			local statusBarTexture = nil; -- No default texture initially
			
			-- set elvui styling, otherwise default
			if E and cachedElvUIEnabled then 
				if E.media and E.media.normTex then
					statusBarTexture = E.media.normTex;
				end
				if E.db and E.db.tooltip and E.db.tooltip.healthBar and E.db.tooltip.healthBar.height then
					healthBarHeight = E.db.tooltip.healthBar.height + 2;
				end
			else
				statusBarTexture = "Interface\\TargetingFrame\\UI-StatusBar";
			end
			
			local hpPercent = currentHP / maxHP;
			local r, g, b = 1, 1, 1; 
			
			-- trp3 class colour
			local usedTRP3Color = false;
			if targetID then
				local characterInfo = getCharacterInfoTab(targetID);
				if characterInfo.characteristics and characterInfo.characteristics.CH then
					local hexColor = characterInfo.characteristics.CH;
					-- hex to rgb
					if hexColor and hexColor:len() == 6 then
						local rHex = hexColor:sub(1, 2);
						local gHex = hexColor:sub(3, 4);
						local bHex = hexColor:sub(5, 6);
						r = tonumber(rHex, 16) / 255;
						g = tonumber(gHex, 16) / 255;
						b = tonumber(bHex, 16) / 255;
						usedTRP3Color = true;
					end
				end
			end
			
			-- elvui colours as fallback
			if not usedTRP3Color and E and cachedElvUIEnabled then
				-- class colours
				if UnitIsPlayer(targetType) then
					local _, englishClass = UnitClass(targetType);
					if englishClass and RAID_CLASS_COLORS[englishClass] then
						local classColor = RAID_CLASS_COLORS[englishClass];
						r, g, b = classColor.r, classColor.g, classColor.b;
					end
				else
					-- npc reaction colours
					local reaction = UnitReaction(targetType, "player");
					if reaction then
						if reaction >= 5 then 
							r, g, b = 0, 1, 0;
						elseif reaction == 4 then 
							r, g, b = 1, 1, 0;
						else 
							r, g, b = 1, 0, 0; 
						end
					end
				end
				
				-- elvui custom colours
				if E.db and E.db.tooltip and E.db.tooltip.healthBar then
					if E.db.tooltip.healthBar.statusBarColor then
						local color = E.db.tooltip.healthBar.statusBarColor;
						if color.r and color.g and color.b then
							r, g, b = color.r, color.g, color.b;
						end
					end
				end
			elseif not usedTRP3Color then
				-- fallback
				if hpPercent > 0.5 then
					r = (1 - hpPercent) * 2;
					g = 1;
					b = 0;
				else
					r = 1;
					g = hpPercent * 2;
					b = 0;
				end
			end
			
			ui_CharacterTT.healthBar:ClearAllPoints();
			if cachedElvUIEnabled then
				ui_CharacterTT.healthBar:SetPoint("BOTTOMLEFT", ui_CharacterTT, "TOPLEFT", 0, -1);
				ui_CharacterTT.healthBar:SetPoint("BOTTOMRIGHT", ui_CharacterTT, "TOPRIGHT", 0, -1);
			else
				ui_CharacterTT.healthBar:SetPoint("BOTTOMLEFT", ui_CharacterTT, "BOTTOMLEFT", 5, -10);
				ui_CharacterTT.healthBar:SetPoint("BOTTOMRIGHT", ui_CharacterTT, "BOTTOMRIGHT", -5, -10);
			end
			ui_CharacterTT.healthBar:SetHeight(healthBarHeight);
			ui_CharacterTT.healthBar:Show();
			
			-- frame width
			local barWidth = ui_CharacterTT.healthBar:GetWidth();
			if barWidth == 0 then
				local tooltipWidth = ui_CharacterTT:GetWidth();
				if tooltipWidth > 20 then
					ui_CharacterTT.healthBar:ClearAllPoints();
					ui_CharacterTT.healthBar:SetPoint("BOTTOM", ui_CharacterTT, "TOP", 0, -1);
					ui_CharacterTT.healthBar:SetWidth(tooltipWidth);
				end
			end
			
			-- update healthbar
			if statusBarTexture then
				ui_CharacterTT.healthBar:SetStatusBarTexture(statusBarTexture);
			end
			ui_CharacterTT.healthBar:SetMinMaxValues(0, maxHP);
			ui_CharacterTT.healthBar:SetValue(currentHP);
			ui_CharacterTT.healthBar:SetStatusBarColor(r, g, b, 1);
		end
	elseif ui_CharacterTT.healthBar and (not showHealthBar() or not UnitExists(targetType) or not UnitHealth(targetType)) then
		ui_CharacterTT.healthBar:Hide();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- MAIN
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local GameTooltip_SetDefaultAnchor, UIParent = GameTooltip_SetDefaultAnchor, UIParent;

local function show(targetType, targetID, targetMode)
	ui_CharacterTT:Hide();

	-- checks if gametooltip needs to be hidden, raven compatibility
	if targetType == "mouseover" and targetID then
		local mouseOverFrame = GetMouseFocus()
		if mouseOverFrame then
			local frameName = mouseOverFrame:GetName() or ""
			if frameName:find("Raven") or frameName:find("ElvUI") or frameName:find("WeakAuras") or
			   (mouseOverFrame.GetParent and mouseOverFrame:GetParent() and 
			    (mouseOverFrame:GetParent():GetName() or ""):find("Raven")) then
				return
			end
		end
	end

	-- If using TRP TT
	if not UnitAffectingCombat("player") or not getConfigValue(CONFIG_CHARACT_COMBAT) then
		local inInstance = false;
		if IsInInstance then
			inInstance = IsInInstance();
		end
		
		if inInstance and getConfigValue(CONFIG_CHARACT_INSTANCE) then
			-- default tooltip if IsInInstance resolves as true (1)
			return;
		end
		
		-- If we have a target
		if targetID then
			ui_CharacterTT.target = targetID;
			ui_CharacterTT.targetType = targetType;
			ui_CharacterTT.targetMode = targetMode;

			-- Check if has a profile
			if getConfigValue(CONFIG_PROFILE_ONLY) then
				if targetMode == TYPE_CHARACTER and targetID ~= Globals.player_id and (not IsUnitIDKnown(targetID) or not hasProfile(targetID)) then
					-- Don't hide GameTooltip if we're not showing TRP tooltip due to profile filtering
					return;
				end
			end

			-- We have a target
			if targetMode then
				-- Stock all the current text from the GameTooltip
				local originalTexts = getGameTooltipTexts();

				if (targetMode == TYPE_CHARACTER and isIDIgnored(targetID)) then
					ui_CharacterTT:SetOwner(GameTooltip, "ANCHOR_TOPRIGHT");
				else
					local anchorFrame = getAnchoredFrame();
					local anchorPosition = getAnchoredPosition();
					if anchorPosition == "ANCHOR_CURSOR" then
						ui_CharacterTT:SetOwner(UIParent, "ANCHOR_CURSOR");
					elseif anchorFrame and anchorFrame:IsShown() then
						ui_CharacterTT:SetOwner(anchorFrame, anchorPosition);
					else
						ui_CharacterTT:SetOwner(UIParent, "ANCHOR_CURSOR");
					end
				end

				if not isElvUITooltipStylingActive() then
					ui_CharacterTT:SetBackdropBorderColor(1, 1, 1, 1);
				else
					local E = _G.ElvUI and _G.ElvUI[1]
					if E and E.media and E.media.bordercolor then
						ui_CharacterTT:SetBackdropBorderColor(unpack(E.media.bordercolor, 1, 3))
					end
				end
				
				if targetMode == TYPE_CHARACTER then
					writeTooltipForCharacter(targetID, originalTexts, targetType);
					if showRelationColor() and targetID ~= Globals.player_id and not isIDIgnored(targetID) and IsUnitIDKnown(targetID) and hasProfile(targetID) then
						local r, g, b = getRelationColors(hasProfile(targetID));
						ui_CharacterTT:SetBackdropBorderColor(r, g, b, 1);
					elseif not isElvUITooltipStylingActive() then
						ui_CharacterTT:SetBackdropBorderColor(1, 1, 1, 1);
					else
						local E = _G.ElvUI and _G.ElvUI[1]
						if E and E.media and E.media.bordercolor then
							ui_CharacterTT:SetBackdropBorderColor(unpack(E.media.bordercolor, 1, 3))
						end
					end
					-- Only hide GameTooltip if TRP tooltip is actually showing and not ignored
					if shouldHideGameTooltip() and not isIDIgnored(targetID) and ui_CharacterTT:IsShown() then
						GameTooltip:SetAlpha(0);
					end
				end
			end

			-- ui_CharacterTT:ClearAllPoints(); -- Prevent to break parent frame fade out if parent is a tooltip.
		end
	end
end

local function onUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if getAnchoredPosition() == "ANCHOR_CURSOR" then
		local effScale, x, y = self:GetEffectiveScale(), GetCursorPosition();
		self:ClearAllPoints();
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (x / effScale) + 10, (y / effScale) + 10);
	end

	-- prevents original tooltip from showing when modifier is pressed (ctrl, shift, alt)
	if self:IsShown() and self.target and shouldHideGameTooltip() and not isIDIgnored(self.target) then
		if GameTooltip:GetAlpha() > 0 then
			GameTooltip:SetAlpha(0);
		end
	end

	if (self.TimeSinceLastUpdate > 0) then
		self.TimeSinceLastUpdate = 0;
		if self.target and self.targetType and not self.isFading then
			if self.target ~= getUnitID(self.targetType) then
				self.isFading = true;
				self.target = nil;
				self:Hide();
				self.isFading = nil;
			end
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOAD, function()
	-- Listen to the mouse over event
	Utils.event.registerHandler("UPDATE_MOUSEOVER_UNIT", function()
		local targetID, targetMode = getUnitID("mouseover");
		Events.fireEvent(Events.MOUSE_OVER_CHANGED, targetID, targetMode);
	end);
end);

local function onModuleInit()
	Events.listenToEvent(Events.MOUSE_OVER_CHANGED, function(targetID, targetMode)
		show("mouseover", targetID, targetMode);
	end);
	
	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, profileID, dataType)
		if not unitID or (ui_CharacterTT.target == unitID) then
			local targetID, targetMode = getUnitID("mouseover");
			show("mouseover", targetID, targetMode);
		end
	end);

	ui_CharacterTT.TimeSinceLastUpdate = 0;
	ui_CharacterTT:SetScript("OnUpdate", onUpdate);

	ui_CharacterTT:SetScript("OnHide", function()
		if shouldHideGameTooltip() and GameTooltip:GetAlpha() == 0 then
			GameTooltip:SetAlpha(1);
		end
		-- Hide health bar when tooltip hides
		if ui_CharacterTT.healthBar then
			ui_CharacterTT.healthBar:Hide();
		end
	end);

	IC_GUILD = " |cff00ff00(" .. loc("REG_TT_GUILD_IC") .. ")";
	OOC_GUILD = " |cffff0000(" .. loc("REG_TT_GUILD_OOC") .. ")";

	-- Config default value
	local E = _G.ElvUI and _G.ElvUI[1]
	registerConfigKey(CONFIG_PROFILE_ONLY, false);
	registerConfigKey(CONFIG_CHARACT_COMBAT, false);
	registerConfigKey(CONFIG_CHARACT_INSTANCE, false);
	registerConfigKey(CONFIG_CHARACT_ANCHORED_FRAME, "GameTooltip");
	registerConfigKey(CONFIG_CHARACT_ANCHOR, "ANCHOR_CURSOR");
	registerConfigKey(CONFIG_CHARACT_HIDE_ORIGINAL, true);
	registerConfigKey(CONFIG_CHARACT_ELVUI_STYLE, false);
	registerConfigKey(CONFIG_CHARACT_MAIN_SIZE, 16);
	registerConfigKey(CONFIG_CHARACT_SUB_SIZE, 12);
	registerConfigKey(CONFIG_CHARACT_TER_SIZE, 10);
	registerConfigKey(CONFIG_CHARACT_ICONS, true);
	registerConfigKey(CONFIG_CHARACT_FT, true);
	registerConfigKey(CONFIG_CHARACT_RACECLASS, true);
	registerConfigKey(CONFIG_CHARACT_GUILD, true);
	registerConfigKey(CONFIG_CHARACT_TARGET, true);
	registerConfigKey(CONFIG_CHARACT_TITLE, true);
	registerConfigKey(CONFIG_CHARACT_NOTIF, false);
	registerConfigKey(CONFIG_CHARACT_CURRENT, true);
	registerConfigKey(CONFIG_CHARACT_OOC, true);
	registerConfigKey(CONFIG_CHARACT_OOC_NAME, false);
	registerConfigKey(CONFIG_CHARACT_HEALTHBAR, true);
	registerConfigKey(CONFIG_CHARACT_CURRENT_SIZE, 140);
	registerConfigKey(CONFIG_CHARACT_RELATION, true);
	registerConfigKey(CONFIG_CHARACT_SPACING, true);

	updateElvUIEnabledCache();
	applyTooltipStyling();

	registerConfigHandler(CONFIG_CHARACT_ELVUI_STYLE, function()
		updateElvUIEnabledCache();
		if ui_CharacterTT then
			applyTooltipStyling();
		end
	end);

	-- hook into tooltip creation to apply elvui styling
	local function ensureMainTooltipStyling()
		if _G.TRP3_MainTooltip then
			if TRP3_ElvUI_StyleData and TRP3_ElvUI_StyleData.enabled then
				if not applyElvUIStyleToTooltip(_G.TRP3_MainTooltip) then
					_G.TRP3_MainTooltip:SetBackdrop(TOOLTIP_BACKDROP);
					_G.TRP3_MainTooltip:SetBackdropColor(0, 0, 0, 1); 
					_G.TRP3_MainTooltip:SetBackdropBorderColor(1, 1, 1, 1);
				end
				
				local defaultFontSize = 12
				
				for i = 1, 30 do
					local leftText = _G[_G.TRP3_MainTooltip:GetName() .. "TextLeft" .. i]
					local rightText = _G[_G.TRP3_MainTooltip:GetName() .. "TextRight" .. i]
					
					applyFontToElement(leftText, defaultFontSize)
					applyFontToElement(rightText, defaultFontSize)
				end
			else
				-- Apply TRP3 styling
				_G.TRP3_MainTooltip:SetBackdrop(TOOLTIP_BACKDROP);
				_G.TRP3_MainTooltip:SetBackdropColor(0, 0, 0, 1); 
				_G.TRP3_MainTooltip:SetBackdropBorderColor(1, 1, 1, 1);
			end
		end
	end

	local tooltipCheckFrame = CreateFrame("Frame")
	local timeSinceLastCheck = 0
	tooltipCheckFrame:SetScript("OnUpdate", function(self, elapsed)
		timeSinceLastCheck = timeSinceLastCheck + elapsed
		if timeSinceLastCheck >= 1 then  -- Check every second
			timeSinceLastCheck = 0
			ensureMainTooltipStyling()
		end
	end)

	-- Also hook the OnShow event if the tooltip exists
	if _G.TRP3_MainTooltip then
		_G.TRP3_MainTooltip:HookScript("OnShow", ensureMainTooltipStyling)
	end

	ANCHOR_TAB = {
		{loc("CO_ANCHOR_TOP_LEFT"), "ANCHOR_TOPLEFT"},
		{loc("CO_ANCHOR_TOP"), "ANCHOR_TOP"},
		{loc("CO_ANCHOR_TOP_RIGHT"), "ANCHOR_TOPRIGHT"},
		{loc("CO_ANCHOR_RIGHT"), "ANCHOR_RIGHT"},
		{loc("CO_ANCHOR_BOTTOM_RIGHT"), "ANCHOR_BOTTOMRIGHT"},
		{loc("CO_ANCHOR_BOTTOM"), "ANCHOR_BOTTOM"},
		{loc("CO_ANCHOR_BOTTOM_LEFT"), "ANCHOR_BOTTOMLEFT"},
		{loc("CO_ANCHOR_LEFT"), "ANCHOR_LEFT"},
		{loc("CO_ANCHOR_CURSOR"), "ANCHOR_CURSOR"},
	};

	-- Build configuration page
	local CONFIG_STRUCTURE = {
		id = "main_config_tooltip",
		menuText = loc("CO_TOOLTIP"),
		pageText = loc("CO_TOOLTIP"),
		elements = {
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_TOOLTIP_COMMON"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_PROFILE_ONLY"),
				configKey = CONFIG_PROFILE_ONLY,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_COMBAT"),
				configKey = CONFIG_CHARACT_COMBAT,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = "Hide in instances",
				help = "Hide TotalRP3 tooltips when in dungeons, raids, battlegrounds, or arenas",
				configKey = CONFIG_CHARACT_INSTANCE,
			},
			{
				inherit = "TRP3_ConfigEditBox",
				title = loc("CO_TOOLTIP_ANCHORED"),
				configKey = CONFIG_CHARACT_ANCHORED_FRAME,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationTooltip_Charact_Anchor",
				title = loc("CO_TOOLTIP_ANCHOR"),
				listContent = ANCHOR_TAB,
				configKey = CONFIG_CHARACT_ANCHOR,
				listWidth = nil,
				listCancel = true,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_HIDE_ORIGINAL"),
				configKey = CONFIG_CHARACT_HIDE_ORIGINAL,
			},
			{
				inherit = "TRP3_ConfigSlider",
				title = loc("CO_TOOLTIP_MAINSIZE"),
				configKey = CONFIG_CHARACT_MAIN_SIZE,
				min = 6,
				max = 20,
				step = 1,
				integer = true,
			},
			{
				inherit = "TRP3_ConfigSlider",
				title = loc("CO_TOOLTIP_SUBSIZE"),
				configKey = CONFIG_CHARACT_SUB_SIZE,
				min = 6,
				max = 20,
				step = 1,
				integer = true,
			},
			{
				inherit = "TRP3_ConfigSlider",
				title = loc("CO_TOOLTIP_TERSIZE"),
				configKey = CONFIG_CHARACT_TER_SIZE,
				min = 6,
				max = 20,
				step = 1,
				integer = true,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_SPACING"),
				help = loc("CO_TOOLTIP_SPACING_TT"),
				configKey = CONFIG_CHARACT_SPACING,
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc("CO_TOOLTIP_CHARACTER"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_ICONS"),
				configKey = CONFIG_CHARACT_ICONS,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_TITLE"),
				configKey = CONFIG_CHARACT_TITLE,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_FT"),
				configKey = CONFIG_CHARACT_FT,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_RACE"),
				configKey = CONFIG_CHARACT_RACECLASS,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_GUILD"),
				configKey = CONFIG_CHARACT_GUILD,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_TARGET"),
				configKey = CONFIG_CHARACT_TARGET,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_CURRENT"),
				configKey = CONFIG_CHARACT_CURRENT,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("DB_STATUS_CURRENTLY_OOC"),
				configKey = CONFIG_CHARACT_OOC,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_OOC_NAME"),
				help = loc("CO_TOOLTIP_OOC_NAME_TT"),
				configKey = CONFIG_CHARACT_OOC_NAME,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_NOTIF"),
				configKey = CONFIG_CHARACT_NOTIF,
				help = loc("CO_TOOLTIP_NOTIF_TT"),
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc("CO_TOOLTIP_RELATION"),
				help = loc("CO_TOOLTIP_RELATION_TT"),
				configKey = CONFIG_CHARACT_RELATION,
			},
			{
				inherit = "TRP3_ConfigSlider",
				title = loc("CO_TOOLTIP_CURRENT_SIZE"),
				configKey = CONFIG_CHARACT_CURRENT_SIZE,
				min = 40,
				max = 200,
				step = 10,
				integer = true,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = "Show Healthbar",
				help = "Show a health bar in character tooltips",
				configKey = CONFIG_CHARACT_HEALTHBAR,
			},
		}
	}
	TRP3_API.configuration.registerConfigurationPage(CONFIG_STRUCTURE);
end

local MODULE_STRUCTURE = {
	["name"] = "Characters tooltip",
	["description"] = "Use TRP3 custom tooltip for characters",
	["version"] = 1.000,
	["id"] = "trp3_tooltips",
	["onStart"] = onModuleInit,
	["minVersion"] = 3,
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);