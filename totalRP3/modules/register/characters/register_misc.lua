----------------------------------------------------------------------------------
-- Total RP 3
-- Character page : Miscellaneous
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
local Utils, Events, Globals = TRP3_API.utils, TRP3_API.events, TRP3_API.globals;
local stEtN = Utils.str.emptyToNil;
local color, getIcon, tableRemove = Utils.str.color, Utils.str.icon, Utils.table.remove;
local loc = TRP3_API.locale.getText;
local get = TRP3_API.profile.getData;
local tcopy, tsize = Utils.table.copy, Utils.table.size;
local assert, table, wipe, _G = assert, table, wipe, _G;
local getDefaultProfile = TRP3_API.profile.getDefaultProfile;
local showIconBrowser = TRP3_API.popup.showIconBrowser;
local tinsert, pairs, type, tostring = tinsert, pairs, type, tostring;
local setupListBox = TRP3_API.ui.listbox.setupListBox;
local setTooltipForSameFrame, toast = TRP3_API.ui.tooltip.setTooltipForSameFrame, TRP3_API.ui.tooltip.toast;
local getCurrentContext, getCurrentPageID = TRP3_API.navigation.page.getCurrentContext, TRP3_API.navigation.page.getCurrentPageID;
local setupIconButton, getPlayerCurrentProfileID = TRP3_API.ui.frame.setupIconButton, TRP3_API.profile.getPlayerCurrentProfileID;
local setupFieldSet = TRP3_API.ui.frame.setupFieldPanel;
local showPopup = TRP3_API.popup.showPopup;
local hasProfile = TRP3_API.register.hasProfile;
local refreshTooltip = TRP3_API.ui.tooltip.refresh;
local compressData;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- SCHEMA
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

getDefaultProfile().player.misc = {
	v = 1,
	PE = {},
	ST = {},
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- RP Style
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local STYLE_FIELDS;
local function buildStyleStructure()
	STYLE_FIELDS = {
		{
			id = "1",
			name = loc("REG_PLAYER_STYLE_FREQ"),
			values = {
				{loc("REG_PLAYER_STYLE_FREQ_1"), 1},
				{loc("REG_PLAYER_STYLE_FREQ_2"), 2},
				{loc("REG_PLAYER_STYLE_FREQ_3"), 3},
				{loc("REG_PLAYER_STYLE_FREQ_4"), 4},
				{loc("REG_PLAYER_STYLE_FREQ_5"), 5},
				{loc("REG_PLAYER_STYLE_HIDE"), 0},
			}
		},
		{
			id = "2",
			name = loc("REG_PLAYER_STYLE_INJURY"),
			values = {
				{YES, 1},
				{NO, 2},
				{loc("REG_PLAYER_STYLE_PERMI"), 3},
				{loc("REG_PLAYER_STYLE_HIDE"), 0},
			}
		},
		{
			id = "3",
			name = loc("REG_PLAYER_STYLE_DEATH"),
			values = {
				{YES, 1},
				{NO, 2},
				{loc("REG_PLAYER_STYLE_PERMI"), 3},
				{loc("REG_PLAYER_STYLE_HIDE"), 0},
			}
		},
		{
			id = "4",
			name = loc("REG_PLAYER_STYLE_ROMANCE"),
			values = {
				{YES, 1},
				{NO, 2},
				{loc("REG_PLAYER_STYLE_PERMI"), 3},
				{loc("REG_PLAYER_STYLE_HIDE"), 0},
			}
		},
		{
			id = "5",
			name = loc("REG_PLAYER_STYLE_BATTLE"),
			values = {
				{loc("REG_PLAYER_STYLE_BATTLE_1"), 1},
				{loc("REG_PLAYER_STYLE_BATTLE_3"), 3},
				{loc("REG_PLAYER_STYLE_BATTLE_4"), 4},
				{loc("REG_PLAYER_STYLE_HIDE"), 0},
			}
		},
		{
			id = "6",
			name = loc("REG_PLAYER_STYLE_GUILD"),
			values = {
				{loc("REG_PLAYER_STYLE_GUILD_IC"), 1},
				{loc("REG_PLAYER_STYLE_GUILD_OOC"), 2},
				{loc("REG_PLAYER_STYLE_HIDE"), 0},
			}
		},
	};
end

local styleLines = {};

local function onEditStyle(choice, frame)
	frame = frame:GetParent();
	assert(frame.fieldData, "No data in frame !");
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	if context.isPlayer then
		local dataTab = get("player/misc");
		local old = dataTab.ST[frame.fieldData.id];
		dataTab.ST[frame.fieldData.id] = choice;
		if old ~= choice then
			-- version increment
			assert(type(dataTab.v) == "number", "Error: No version in draftData or not a number.");
			dataTab.v = Utils.math.incrementNumber(dataTab.v, 2);
			compressData();
		end
	end
end

local function displayRPStyle(context)
	local dataTab = context.profile.misc or Globals.empty;
	local styleData = dataTab.ST or {};

	-- Hide all
	for _, frame in pairs(styleLines) do
		frame:Hide();
	end

	local previous;
	local count = 0;
	for index, fieldData in pairs(STYLE_FIELDS) do
		local frame = styleLines[index];
		if frame == nil then
			frame = CreateFrame("Frame", "TRP3_RegisterMiscViewRPStyle_line"..index, TRP3_RegisterMiscViewRPStyle, "TRP3_RegisterRPStyleMain_Edit_Line");
			setupListBox(_G[frame:GetName().."Values"], fieldData.values, onEditStyle, nil, 180, true);
			frame.fieldData = fieldData;
			tinsert(styleLines, frame);
		end

		local selectedValue = styleData[fieldData.id] or 0;

		if context.isPlayer or selectedValue ~= 0 then
			-- Position
			frame:ClearAllPoints();
			if previous == nil then
				frame:SetPoint("TOPLEFT", TRP3_RegisterMiscViewRPStyle, "TOPLEFT", 25, -12);
			else
				frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0);
			end
			frame:SetPoint("LEFT", 0, 0);
			frame:SetPoint("RIGHT", 0, 0);

			-- Value
			_G[frame:GetName().."FieldName"]:SetText(fieldData.name);
			local dropDown = _G[frame:GetName().."Values"];
			local readOnlyValue = _G[frame:GetName().."FieldValue"];
			if context.isPlayer then
				dropDown:SetSelectedValue(selectedValue);
				dropDown:Show();
				readOnlyValue:Hide();
			else
				dropDown:Hide();
				readOnlyValue:Show();
				local valueText = nil;
				for _, data in pairs(fieldData.values) do
					if data[2] == selectedValue then
						valueText = data[1];
						break;
					end
				end
				readOnlyValue:SetText(valueText);
			end

			frame:Show();
			previous = frame;
			count = count + 1;
		end
	end

	TRP3_RegisterMiscViewRPStyleEmpty:Hide();
	if not context.isPlayer and count == 0 then
		TRP3_RegisterMiscViewRPStyleEmpty:Show();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- PEEK
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local GLANCE_NOT_USED_ICON = "INV_Misc_QuestionMark";

local function setupGlanceButton(button, active, icon, title, text, isMine)
	button:Enable();
	button.isCurrentMine = isMine;
	button:SetNormalTexture("Interface\\ICONS\\" .. (icon or GLANCE_NOT_USED_ICON));
	if active then
		button:SetAlpha(1);
		if not isMine then
			setTooltipForSameFrame(button, "RIGHT", 0, 5, title or "...", text);
		else
			setTooltipForSameFrame(button, "RIGHT", 0, 5, title or "...", (text or "..."));
		end
	else
		button:SetAlpha(0.1);
		if not isMine then
			button:Disable();
		else
			setTooltipForSameFrame(button, "RIGHT", 0, 5, loc("REG_PLAYER_GLANCE_UNUSED"));
		end
	end
end
TRP3_API.register.setupGlanceButton = setupGlanceButton;

local function displayPeek(context)
	TRP3_AtFirstGlanceEditor:Hide();
	local dataTab = context.profile.misc or Globals.empty;
	for i=1,5 do
		local glanceData = (dataTab.PE or {})[tostring(i)] or {};
		local button = _G["TRP3_RegisterMiscViewGlanceSlot" .. i];
		button.data = glanceData;
		setupGlanceButton(button, glanceData.AC, glanceData.IC, glanceData.TI, glanceData.TX, context.isPlayer);
	end
	if context.isPlayer then
		TRP3_RegisterMiscViewGlanceHelp:Show();
	else
		TRP3_RegisterMiscViewGlanceHelp:Hide();
	end
end


function TRP3_API.register.checkGlanceActivation(dataTab)
	for i=1, 5, 1 do
		if dataTab[tostring(i)] and dataTab[tostring(i)].AC then
			return true
		end
	end
	return false;
end

function TRP3_API.register.getGlanceIconTextures(dataTab, size)
	local text = "";
	for i=1, 5, 1 do
		local index = tostring(i);
		if dataTab[index] and dataTab[index].AC then
			text = text .. "|TInterface\\ICONS\\".. (dataTab[index].IC or Globals.icons.default) .. ":" .. size .. "|t "
		end
	end
	return text;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Peek editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local draftData = {};
local displayDropDown, setGlanceSlotPreset = TRP3_API.ui.listbox.displayDropDown;

local function applyPeekSlot(slot, ic, ac, ti, tx, swap)
	TRP3_AtFirstGlanceEditor:Hide();
	assert(slot, "No selection ...");
	local dataTab = get("player/misc");
	if not dataTab.PE then
		dataTab.PE = {};
	end
	if not dataTab.PE[slot] then
		dataTab.PE[slot] = {};
	end
	local peekTab = dataTab.PE[slot];
	if swap then
		peekTab.AC = not peekTab.AC;
	else
		peekTab.IC = ic;
		peekTab.AC = ac;
		peekTab.TI = ti;
		peekTab.TX = tx;
	end
	-- version increment
	assert(type(dataTab.v) == "number", "Error: No version in draftData or not a number.");
	dataTab.v = Utils.math.incrementNumber(dataTab.v, 2);
	compressData();
	-- Refresh display & target frame
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getPlayerCurrentProfileID(), "misc");
end
TRP3_API.register.applyPeekSlot = applyPeekSlot;

local function swapGlanceSlot(from, to)
	TRP3_AtFirstGlanceEditor:Hide();
	local dataTab = get("player/misc");
	TRP3_API.register.glance.swapDataFromSlots(dataTab, from, to);
	-- Refresh display & target frame
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getPlayerCurrentProfileID(), "misc");
	compressData();
end
TRP3_API.register.swapGlanceSlot = swapGlanceSlot;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Currently
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TRP3_RegisterMiscViewCurrentlyIC, TRP3_RegisterMiscViewCurrentlyOOC = TRP3_RegisterMiscViewCurrentlyICScrollText, TRP3_RegisterMiscViewCurrentlyOOCScrollText;

local function displayCurrently(context)
	-- workaround as Enable/Disable methods don't work on scroll text elements 
	if context.isPlayer then
		TRP3_RegisterMiscViewCurrentlyIC:EnableMouse(true);
		TRP3_RegisterMiscViewCurrentlyOOC:EnableMouse(true);
		TRP3_RegisterMiscViewCurrentlyICHelp:Show();
		TRP3_RegisterMiscViewCurrentlyOOCHelp:Show();
	else
		TRP3_RegisterMiscViewCurrentlyIC:EnableMouse(false);
		TRP3_RegisterMiscViewCurrentlyIC:ClearFocus();
		TRP3_RegisterMiscViewCurrentlyOOC:EnableMouse(false);
		TRP3_RegisterMiscViewCurrentlyOOC:ClearFocus();
		TRP3_RegisterMiscViewCurrentlyICHelp:Hide();
		TRP3_RegisterMiscViewCurrentlyOOCHelp:Hide();
	end

	local dataTab = context.profile.character or Globals.empty;
	TRP3_RegisterMiscViewCurrentlyIC:SetText(dataTab.CU or "");
	TRP3_RegisterMiscViewCurrentlyOOC:SetText(dataTab.CO or "");
	if not context.isPlayer and dataTab.CU and dataTab.CU:len() > 0 then
		setTooltipForSameFrame(TRP3_RegisterMiscViewCurrentlyIC, "TOP", 0, 5, loc("DB_STATUS_CURRENTLY"), dataTab.CU);
	else
		setTooltipForSameFrame(TRP3_RegisterMiscViewCurrentlyIC);
	end
	if not context.isPlayer and dataTab.CO and dataTab.CO:len() > 0 then
		setTooltipForSameFrame(TRP3_RegisterMiscViewCurrentlyOOC, "TOP", 0, 5, loc("DB_STATUS_CURRENTLY_OOC"), dataTab.CO);
	else
		setTooltipForSameFrame(TRP3_RegisterMiscViewCurrentlyOOC);
	end
end

local function onCurrentlyChanged()
	if getCurrentContext().isPlayer then
		local character = get("player/character");
		local old = character.CU;
		character.CU = TRP3_RegisterMiscViewCurrentlyIC:GetText();
		if old ~= character.CU then
			character.v = Utils.math.incrementNumber(character.v or 1, 2);
			Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getPlayerCurrentProfileID(), "character");
		end
	end
end

local function onOOCInfoChanged()
	if getCurrentContext().isPlayer then
		local character = get("player/character");
		local old = character.CO;
		character.CO = TRP3_RegisterMiscViewCurrentlyOOC:GetText();
		if old ~= character.CO then
			character.v = Utils.math.incrementNumber(character.v or 1, 2);
			Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getPlayerCurrentProfileID(), "character");
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Misc logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function showMiscTab()
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	assert(context.profile, "No profile in context");
	TRP3_RegisterMisc:Show();
	displayPeek(context);
	displayRPStyle(context);
	displayCurrently(context);
end
TRP3_API.register.ui.showMiscTab = showMiscTab;

local currentCompressed;

function compressData()
	local data = get("player/misc");
	local dataToSend = {
		v = data.v,
		ST = data.ST,
		PE = {},
	};
	-- Only send used slot !
	for slotIndex, slot in pairs(data.PE) do
		if slot.AC then
			dataToSend.PE[slotIndex] = slot;
		end
	end

	local serial = Utils.serial.serialize(dataToSend);
	local compressed = Utils.serial.encodeCompressMessage(serial);

	--	print(("Compressed data : %s / %s (%i%%)"):format(compressed:len(), serial:len(), compressed:len() / serial:len() * 100));
	if compressed:len() < serial:len() then
		currentCompressed = compressed;
	else
		currentCompressed = dataToSend;
	end
end

function TRP3_API.register.player.getMiscExchangeData()
	return currentCompressed;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.register.inits.miscInit()
	buildStyleStructure();

	setupFieldSet(TRP3_RegisterMiscViewGlance, loc("REG_PLAYER_GLANCE"), 150);
	setupFieldSet(TRP3_RegisterMiscViewCurrently, loc("REG_PLAYER_CURRENT"), 150);
	TRP3_AtFirstGlanceEditorApply:SetText(loc("CM_APPLY"));
	TRP3_AtFirstGlanceEditorNameText:SetText(loc("REG_PLAYER_GLANCE_TITLE"));
	TRP3_RegisterMiscViewRPStyleEmpty:SetText(loc("REG_PLAYER_STYLE_EMPTY"));

	TRP3_API.ui.tooltip.setTooltipAll(TRP3_AtFirstGlanceEditorActive, "TOP", 0, 0, loc("REG_PLAYER_GLANCE_USE"));

	TRP3_RegisterMiscViewCurrentlyICTitle:SetText(loc("DB_STATUS_CURRENTLY"));
	setTooltipForSameFrame(TRP3_RegisterMiscViewCurrentlyICHelp, "LEFT", 0, 10, loc("DB_STATUS_CURRENTLY"), loc("DB_STATUS_CURRENTLY_TT"));
	TRP3_RegisterMiscViewCurrentlyIC:SetScript("OnTextChanged", onCurrentlyChanged);

	TRP3_RegisterMiscViewCurrentlyOOCTitle:SetText(loc("DB_STATUS_CURRENTLY_OOC"));
	setTooltipForSameFrame(TRP3_RegisterMiscViewCurrentlyOOCHelp, "LEFT", 0, 10, loc("DB_STATUS_CURRENTLY_OOC"), loc("DB_STATUS_CURRENTLY_OOC_TT"));
	TRP3_RegisterMiscViewCurrentlyOOC:SetScript("OnTextChanged", onOOCInfoChanged);

	setTooltipForSameFrame(TRP3_RegisterMiscViewGlanceHelp, "LEFT", 0, 10, loc("REG_PLAYER_GLANCE"), loc("REG_PLAYER_GLANCE_CONFIG"));

	for index=1,5,1 do
		-- DISPLAY
		local button = _G["TRP3_RegisterMiscViewGlanceSlot" .. index];
		button:SetDisabledTexture("Interface\\ICONS\\" .. GLANCE_NOT_USED_ICON);
		button:GetDisabledTexture():SetDesaturated(1);
		button:SetScript("OnClick", TRP3_API.register.glance.onGlanceSlotClick);
		button:SetScript("OnDoubleClick", TRP3_API.register.glance.onGlanceDoubleClick);
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		button:RegisterForDrag("LeftButton");
		button:SetScript("OnDragStart", TRP3_API.register.glance.onGlanceDragStart);
		button:SetScript("OnDragStop", TRP3_API.register.glance.onGlanceDragStop);
		button.slot = tostring(index);
		button.targetType = TRP3_API.ui.misc.TYPE_CHARACTER;
	end

	-- RP style
	setupFieldSet(TRP3_RegisterMiscViewRPStyle, loc("REG_PLAYER_STYLE_RPSTYLE"), 150);

	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, _, dataType)
		if getCurrentPageID() == "player_main" and unitID == Globals.player_id and (not dataType or dataType == "misc") then
			TRP3_API.popup.hidePopups();
			local context = getCurrentContext();
			assert(context, "No context for page player_main !");
			displayPeek(context);
		end
	end);

	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, compressData); -- On profile change, compress the new data
	compressData();
end