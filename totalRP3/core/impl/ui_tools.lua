----------------------------------------------------------------------------------
-- Total RP 3
-- UI tools
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

TRP3_API.ui = {
	tooltip = {},
	listbox = {},
	list = {},
	misc = {},
	frame = {},
	text = {}
}

-- imports
local globals = TRP3_API.globals;
local loc = TRP3_API.locale.getText;
local floor, tinsert, pairs, wipe, assert, _G, tostring, table, type, strconcat = floor, tinsert, pairs, wipe, assert, _G, tostring, table, type, strconcat;
local MouseIsOver, CreateFrame, ToggleDropDownMenu = MouseIsOver, CreateFrame, ToggleDropDownMenu;
local UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton = UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton;
local TRP3_MainTooltip, TRP3_MainTooltipTextRight1, TRP3_MainTooltipTextLeft1, TRP3_MainTooltipTextLeft2 = TRP3_MainTooltip, TRP3_MainTooltipTextRight1, TRP3_MainTooltipTextLeft1, TRP3_MainTooltipTextLeft2;
local shiftDown = IsShiftKeyDown;
local UnitIsPlayer = UnitIsPlayer;
local getUnitID = TRP3_API.utils.str.getUnitID;
local numberToHexa = TRP3_API.utils.color.numberToHexa;

local CONFIG_UI_SOUNDS = "ui_sounds";
local CONFIG_UI_ANIMATIONS = "ui_animations";

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Frame utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tiledBackgrounds = {
	"Interface\\DialogFrame\\UI-DialogBox-Background",
	"Interface\\BankFrame\\Bank-Background",
	"Interface\\FrameGeneral\\UI-Background-Marble",
	"Interface\\FrameGeneral\\UI-Background-Rock",
	"Interface\\GuildBankFrame\\GuildVaultBG",
	"Interface\\HELPFRAME\\DarkSandstone-Tile",
	"Interface\\HELPFRAME\\Tileable-Parchment",
	"Interface\\QuestionFrame\\question-background",
	"Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg",
	"Interface\\Destiny\\EndscreenBG",
	"Interface\\Stationery\\AuctionStationery1",
	"Interface\\Stationery\\Stationery_ill1",
	"Interface\\Stationery\\Stationery_OG1",
	"Interface\\Stationery\\Stationery_TB1",
	"Interface\\Stationery\\Stationery_UC1",
	"Interface\\Stationery\\StationeryTest1",
	"Interface\\WorldMap\\UI-WorldMap-Middle1",
	"Interface\\WorldMap\\UI-WorldMap-Middle2",
	"Interface\\ACHIEVEMENTFRAME\\UI-Achievement-StatsBackground"
};

function TRP3_API.ui.frame.getTiledBackground(index)
	return tiledBackgrounds[index] or tiledBackgrounds[1];
end

function TRP3_API.ui.frame.getTiledBackgroundList()
	local tab = {};
	for index, texture in pairs(tiledBackgrounds) do
		tinsert(tab, {loc("UI_BKG"):format(tostring(index)), index, "|T" .. texture .. ":200:200|t"});
	end
	return tab;
end

function TRP3_API.ui.frame.showIfMouseOverFrame(frame, frameOver)
	assert(frame and frameOver, "Frames can't be nil");
	if MouseIsOver(frameOver) then
		frame:Show();
	else
		frame:Hide();
	end
end

function TRP3_API.ui.frame.createRefreshOnFrame(frame, time, callback)
	assert(frame and time and callback, "Argument must be not nil");
	frame.refreshTimer = 1000;
	frame:SetScript("OnUpdate", function(arg, elapsed)
		frame.refreshTimer = frame.refreshTimer + elapsed;
		if frame.refreshTimer > time then
			frame.refreshTimer = 0;
			callback(frame, frame.refreshTimer);
		end
	end);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Drop down
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local DROPDOWN_FRAME, DropDownList1, CloseDropDownMenus = "TRP3_UIDD", DropDownList1, CloseDropDownMenus;
local dropDownFrame, currentlyOpenedDrop;

local function openDropDown(anchoredFrame, values, callback, space, addCancel)
	if not dropDownFrame then
		dropDownFrame = CreateFrame("Frame", DROPDOWN_FRAME, UIParent, "UIDropDownMenuTemplate");
	end

	if DropDownList1:IsVisible() then
		CloseDropDownMenus();
		return;
	end
	
	UIDropDownMenu_Initialize(dropDownFrame,
		function(uiFrame, level, menuList)
			local levelValues = menuList or values;
			level = level or 1;
			for index, tab in pairs(levelValues) do
				assert(type(tab) == "table", "Level value is not a table !");
				local text = tab[1];
				local value = tab[2];
				local tooltipText = tab[3];
				local info = UIDropDownMenu_CreateInfo();
				info.notCheckable = "true";
				info.text = text;
				info.isTitle = false;
				info.tooltipOnButton = tooltipText ~= nil;
				info.tooltipTitle = text;
				info.tooltipText = tooltipText;
				if tab[3] then
					info.tooltipTitle = tab[1];
					info.tooltipText = tab[3];
					info.tooltipOnButton = true;
				end
				if type(value) == "table" then
					info.hasArrow = true;
					info.keepShownOnClick = true;
					info.menuList = value;
				elseif value then
					info.func = function()
						if callback then
							callback(value, anchoredFrame);
						end
						anchoredFrame:GetParent().selectedValue = value;
						if level > 1 then
							ToggleDropDownMenu(nil, nil, dropDownFrame);
						end
						currentlyOpenedDrop = nil;
					end;
				else
					info.func = function() end;
					info.isTitle = true;
				end
				UIDropDownMenu_AddButton(info, level);
			end
			if menuList == nil and addCancel then
				local info = UIDropDownMenu_CreateInfo();
				info.notCheckable = "true";
				info.text = CANCEL;
				UIDropDownMenu_AddButton(info, level);
			end

		end,
		"MENU"
	);
	dropDownFrame:SetParent(anchoredFrame);
	ToggleDropDownMenu(1, nil, dropDownFrame, anchoredFrame:GetName(), -((space or -10)), 0);
	TRP3_API.ui.misc.playUISound("igMainMenuOptionCheckBoxOn");
	currentlyOpenedDrop = anchoredFrame;
end
TRP3_API.ui.listbox.displayDropDown = openDropDown;

--- Setup a drop down menu for a clickable (Button ...)
local function setupDropDownMenu(hasClickFrame, values, callback, space, addCancel, rightClick)
	hasClickFrame:SetScript("OnClick", function(self, button)
		if (rightClick and button ~= "RightButton") or (not rightClick and button ~= "LeftButton") then return; end
		openDropDown(hasClickFrame, values, callback, space, addCancel);
	end);
end
TRP3_API.ui.listbox.setupDropDownMenu = setupDropDownMenu;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- ListBox tools
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function listBoxSetSelected(self, index)
	assert(self and self.values, "Badly initialized listbox");
	assert(self.values[index], "Array index out of bound");
	_G[self:GetName().."Text"]:SetText(self.values[index][1]);
	self.selectedValue = self.values[index][2];
	if self.callback then
		self.callback(self.values[index][2], self);
	end
end

local function listBoxSetSelectedValue(self, value)
	assert(self and self.values, "Badly initialized listbox");
	for index, tab in pairs(self.values) do
		local val = tab[2];
		if val == value then
			listBoxSetSelected(self, index);
			break;
		end
	end
end

local function listBoxGetValue(self)
	return self.selectedValue;
end

-- Setup a ListBox. When the player choose a value, it triggers the function passing the value of the selected element
local function setupListBox(listBox, values, callback, defaultText, boxWidth, addCancel)
	assert(listBox and values, "Invalid arguments");
	assert(_G[listBox:GetName().."Button"], "Invalid arguments: listbox doesn't have a button");
	boxWidth = boxWidth or 115;
	listBox.values = values;
	listBox.callback = callback;
	local listCallback = function(value)
		for index, tab in pairs(values) do
			local text = tab[1];
			local val = tab[2];
			if val == value then
				_G[listBox:GetName().."Text"]:SetText(text);
			end
		end
		if callback then
			callback(value, listBox);
		end
	end;

	setupDropDownMenu(_G[listBox:GetName().."Button"], values, listCallback, boxWidth, addCancel, false);

	listBox.SetSelectedIndex = listBoxSetSelected;
	listBox.GetSelectedValue = listBoxGetValue;
	listBox.SetSelectedValue = listBoxSetSelectedValue;

	if defaultText then
		_G[listBox:GetName().."Text"]:SetText(defaultText);
	end
	_G[listBox:GetName().."Middle"]:SetWidth(boxWidth);
	_G[listBox:GetName().."Text"]:SetWidth(boxWidth-20);
end
TRP3_API.ui.listbox.setupListBox = setupListBox;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List tools
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Handle the mouse wheel for the frame in order to slide the slider
TRP3_API.ui.list.handleMouseWheel = function(frame,slider)
	frame:SetScript("OnMouseWheel",function(self,delta)
		local mini,maxi = slider:GetMinMaxValues();
		if delta == 1 and slider:GetValue() > mini then
			slider:SetValue(slider:GetValue()-1);
		elseif delta == -1 and slider:GetValue() < maxi then
			slider:SetValue(slider:GetValue()+1);
		end
	end);
	frame:EnableMouseWheel(1);
end

local function listShowPage(infoTab, pageNum)
	assert(infoTab.uiTab, "Error : no uiTab in infoTab.");

	-- Hide all widgets
	for k=1,infoTab.maxPerPage do
		infoTab.widgetTab[k]:Hide();
	end

	-- Show list
	for widgetIndex=1, infoTab.maxPerPage do
		local dataIndex = pageNum*infoTab.maxPerPage + widgetIndex;
		if dataIndex <= #infoTab.uiTab then
			infoTab.widgetTab[widgetIndex]:Show();
			infoTab.decorate(infoTab.widgetTab[widgetIndex], infoTab.uiTab[dataIndex]);
		else
			break;
		end
	end
end

-- Init a list.
-- Arguments :
-- 		infoTab, a structure containing :
-- 			- A widgetTab (the list of all widget used in a full page)
-- 			- A decorate function, which will receive 3 arguments : a widget and an ID. Decorate will be called on every couple "widget from widgetTab" and "id from dataTab".
--		dataTab, all the possible values
--		slider, the slider :3
TRP3_API.ui.list.initList = function(infoTab, dataTab, slider)
	assert(infoTab and dataTab and slider, "Error : no argument can be nil.");
	assert(infoTab.widgetTab, "Error : no widget tab in infoTab.");
	assert(infoTab.decorate, "Error : no decorate function in infoTab.");

	local count = 0;
	local maxPerPage = #infoTab.widgetTab;
	infoTab.maxPerPage = maxPerPage;

	if not infoTab.uiTab then
		infoTab.uiTab = {};
	end

	slider:Hide();
	slider:SetValueStep(1);
	-- 3.3.5 compatibility: SetObeyStepOnDrag doesn't exist
	if slider.SetObeyStepOnDrag then
		slider:SetObeyStepOnDrag(true);
	end
	wipe(infoTab.uiTab);

	if type(dataTab) == "table" then
		for key,_ in pairs(dataTab) do
			tinsert(infoTab.uiTab, key);
		end
	else
		for i=1, dataTab, 1 do
			tinsert(infoTab.uiTab, i);
		end
	end
	count = #infoTab.uiTab;

	table.sort(infoTab.uiTab);

	slider:SetScript("OnValueChanged", nil);
	if count > maxPerPage then
		slider:Show();
		local total = floor((count-1)/maxPerPage);
		slider:SetMinMaxValues(0, total);
	else
		slider:SetValue(0);
	end
	slider:SetScript("OnValueChanged",function(self)
		if self:IsVisible() then
			listShowPage(infoTab, floor(self:GetValue()));
		end
	end);
	listShowPage(infoTab, slider:GetValue());
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Tooltip tools
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.ui.tooltip.CONFIG_TOOLTIP_SIZE = "CONFIG_TOOLTIP_SIZE";
local CONFIG_TOOLTIP_SIZE = TRP3_API.ui.tooltip.CONFIG_TOOLTIP_SIZE;
local getConfigValue;

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
	TRP3_API.configuration.registerConfigKey(TRP3_API.ui.tooltip.CONFIG_TOOLTIP_SIZE, 11);
	getConfigValue = TRP3_API.configuration.getValue;
end);

local function getTooltipSize()
	return getConfigValue(CONFIG_TOOLTIP_SIZE) or 11;
end

-- Show the tooltip for this Frame (the frame must have been set up with setTooltipForFrame).
-- If already shown, the tooltip text will be refreshed.
local function refreshTooltip(Frame)
	local localeFont = TRP3_API.locale.getLocaleFont();
	if Frame.titleText and Frame.GenFrame and Frame.GenFrameX and Frame.GenFrameY and Frame.GenFrameAnch then
		TRP3_MainTooltip:Hide();
		TRP3_MainTooltip:SetOwner(Frame.GenFrame, Frame.GenFrameAnch,Frame.GenFrameX,Frame.GenFrameY);
		if not Frame.rightText then
			TRP3_MainTooltip:AddLine(Frame.titleText, 1, 1, 1, true);
		else
			TRP3_MainTooltip:AddDoubleLine(Frame.titleText, Frame.rightText);
			TRP3_MainTooltipTextRight1:SetFont(localeFont, getTooltipSize() + 4);
			TRP3_MainTooltipTextRight1:SetNonSpaceWrap(true);
			TRP3_MainTooltipTextRight1:SetTextColor(1, 1, 1);
		end
		TRP3_MainTooltipTextLeft1:SetFont(localeFont, getTooltipSize() + 4);
		TRP3_MainTooltipTextLeft1:SetNonSpaceWrap(true);
		TRP3_MainTooltipTextLeft1:SetTextColor(1, 1, 1);
		if Frame.bodyText then
			TRP3_MainTooltip:AddLine(Frame.bodyText, 1, 0.6666, 0, true);
			TRP3_MainTooltipTextLeft2:SetFont(localeFont, getTooltipSize());
			TRP3_MainTooltipTextLeft2:SetNonSpaceWrap(true);
			TRP3_MainTooltipTextLeft2:SetTextColor(1, 0.75, 0);
		end
		TRP3_MainTooltip:Show();
	end
end
TRP3_API.ui.tooltip.refresh = refreshTooltip;
TRP3_RefreshTooltipForFrame = refreshTooltip; -- For XML integration without too much perf' issue

local function tooltipSimpleOnEnter(self)
	refreshTooltip(self);
end

local function tooltipSimpleOnLeave(self)
	TRP3_MainTooltip:Hide();
end

-- Setup the frame tooltip (position and text)
-- The tooltip can be shown by using refreshTooltip(Frame)
local function setTooltipForFrame(Frame, GenFrame, GenFrameAnch, GenFrameX, GenFrameY, titleText, bodyText, rightText)
	assert(Frame and GenFrame, "Frame and GenFrame cannot be nil.");
	if Frame and GenFrame then
		Frame.GenFrame = GenFrame;
		Frame.GenFrameX = GenFrameX;
		Frame.GenFrameY = GenFrameY;
		Frame.titleText = titleText;
		Frame.bodyText = bodyText;
		Frame.rightText = rightText;
		if GenFrameAnch then
			Frame.GenFrameAnch = "ANCHOR_"..GenFrameAnch;
		else
			Frame.GenFrameAnch = "ANCHOR_TOPRIGHT";
		end
	end
end
TRP3_API.ui.tooltip.setTooltipForFrame = setTooltipForFrame;

-- Setup the frame tooltip (position and text)
-- The tooltip can be shown by using refreshTooltip(Frame)
TRP3_API.ui.tooltip.setTooltipForSameFrame = function(Frame, GenFrameAnch, GenFrameX, GenFrameY, titleText, bodyText, rightText)
	setTooltipForFrame(Frame, Frame, GenFrameAnch, GenFrameX, GenFrameY, titleText, bodyText, rightText);
end

-- Setup the frame tooltip and add the Enter and Leave scripts
TRP3_API.ui.tooltip.setTooltipAll = function(Frame, GenFrameAnch, GenFrameX, GenFrameY, titleText, bodyText, rightText)
	Frame:SetScript("OnEnter", tooltipSimpleOnEnter);
	Frame:SetScript("OnLeave", tooltipSimpleOnLeave);
	setTooltipForFrame(Frame, Frame, GenFrameAnch, GenFrameX, GenFrameY, titleText, bodyText, rightText);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Character ID
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.ui.misc.TYPE_CHARACTER = "CHARACTER";
local TYPE_CHARACTER = TRP3_API.ui.misc.TYPE_CHARACTER;

-- Returns target type as first return value and boolean isMine as second.
function TRP3_API.ui.misc.getTargetType(unitType)
	if not unitType then
		return nil, false;
	end
	
	if UnitIsPlayer(unitType) then
		local unitID = getUnitID(unitType);
		local isMine = (unitID and globals.player_id and unitID == globals.player_id) or false;
		return TYPE_CHARACTER, isMine;
	-- In 3.3.5, battle pets don't exist, so we only handle regular pets
	elseif UnitIsUnit(unitType, "pet") or (UnitIsOtherPlayersPet and UnitIsOtherPlayersPet(unitType)) then
		return TYPE_PET, UnitIsUnit(unitType, "pet");
	end
	
	-- Return nil if we can't determine the type
	return nil, false;
end

local function getDummyGameTooltipTexts()
	local tab = {};
	for j = 1, DUMMY_TOOLTIP:NumLines() do
		tab[j] = _G["TRP3_DUMMY_TOOLTIPTextLeft" ..  j]:GetText();
	end
	return tab;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Toast
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local TRP3_Toast, TRP3_ToastTextLeft1 = TRP3_Toast, TRP3_ToastTextLeft1;

local function toastUpdate(self, elapsed)
	self.delay = self.delay - elapsed;
	if self.delay <= 0 and not self.isFading then
		self.isFading = true;
		self:FadeOut();
	end
end

TRP3_Toast.delay = 0;
TRP3_Toast:SetScript("OnUpdate", toastUpdate);

function TRP3_API.ui.tooltip.toast(text, duration)
	TRP3_Toast:Hide();
	TRP3_Toast:SetOwner(TRP3_MainFramePageContainer, "ANCHOR_BOTTOM", 0, 60);
	TRP3_Toast:AddLine(text, 1, 1, 1, true);
	TRP3_ToastTextLeft1:SetFont("Fonts\\FRIZQT__.TTF", getTooltipSize());
	TRP3_ToastTextLeft1:SetNonSpaceWrap(true);
	TRP3_ToastTextLeft1:SetTextColor(1, 1, 1);
	TRP3_Toast:Show();
	TRP3_Toast.delay = duration or 3;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Icon utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.ui.frame.setupIconButton(self, icon)
	assert(self, "Frame is nil");
	assert(_G[self:GetName().."Icon"], "Frame must have a Icon");
	_G[self:GetName().."Icon"]:SetTexture("Interface\\ICONS\\"..icon);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Fieldsets
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local FIELDSET_DEFAULT_CAPTION_WIDTH = 100;

function TRP3_API.ui.frame.setupFieldPanel(fieldset, text, size)
	if fieldset and _G[fieldset:GetName().."CaptionPanelCaption"] then
		_G[fieldset:GetName().."CaptionPanelCaption"]:SetText(text);
		if _G[fieldset:GetName().."CaptionPanel"] then
			_G[fieldset:GetName().."CaptionPanel"]:SetWidth(size or FIELDSET_DEFAULT_CAPTION_WIDTH);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Editboxes
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.ui.frame.setupEditBoxesNavigation(tabEditBoxes)
	local maxBound = # tabEditBoxes;
	local minBound = 1;
	for index, editbox in pairs(tabEditBoxes) do
		editbox:SetScript("OnTabPressed", function(self, button)
			local cursor = index
			if shiftDown() then
				if cursor == minBound then
					cursor = maxBound
				else
					cursor = cursor -1
				end
			else
				if cursor == maxBound then
					cursor = minBound
				else
					cursor = cursor + 1
				end
			end			
			tabEditBoxes[cursor]:SetFocus();		
		end)
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Tab bar
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tabBar_index = 0;
local tabBar_HEIGHT_SELECTED = 34;
local tabBar_HEIGHT_NORMAL = 32;

local function tabBar_onSelect(tabGroup, index)
	assert(#tabGroup.tabs >= index, "Index out of bound.");
	local i;
	for i=1, #tabGroup.tabs do
		local widget = tabGroup.tabs[i];
		if i == index then
			widget:SetAlpha(1);
			widget:Disable();
			widget:LockHighlight();
			_G[widget:GetName().."Left"]:SetHeight(tabBar_HEIGHT_SELECTED);
			_G[widget:GetName().."Middle"]:SetHeight(tabBar_HEIGHT_SELECTED);
			_G[widget:GetName().."Right"]:SetHeight(tabBar_HEIGHT_SELECTED);
			widget:GetHighlightTexture():SetAlpha(0.7);
			widget:GetHighlightTexture():SetDesaturated(1);
			tabGroup.current = index;
		else
			widget:SetAlpha(0.85);
			widget:Enable();
			widget:UnlockHighlight();
			_G[widget:GetName().."Left"]:SetHeight(tabBar_HEIGHT_NORMAL);
			_G[widget:GetName().."Middle"]:SetHeight(tabBar_HEIGHT_NORMAL);
			_G[widget:GetName().."Right"]:SetHeight(tabBar_HEIGHT_NORMAL);
			widget:GetHighlightTexture():SetAlpha(0.5);
			widget:GetHighlightTexture():SetDesaturated(0);
		end
	end
end

local function tabBar_redraw(tabGroup)
	local lastWidget;
	for _, tabWidget in pairs(tabGroup.tabs) do
		if tabWidget:IsShown() then
			tabWidget:ClearAllPoints();
			if lastWidget == nil then
				tabWidget:SetPoint("LEFT", 0, 0);
			else
				tabWidget:SetPoint("LEFT", lastWidget, "RIGHT", 2, 0);
			end
			lastWidget = tabWidget;
		end
	end
end

local function tabBar_size(tabGroup)
	return #tabGroup.tabs;
end

local function tabBar_setTabVisible(tabGroup, index, isVisible)
	assert(tabGroup.tabs[index], "Tab index out of bound.");
	if isVisible then
		tabGroup.tabs[index]:Show();
	else
		tabGroup.tabs[index]:Hide();
	end
	tabGroup:Redraw();
end

local function tabBar_selectTab(tabGroup, index)
	assert(tabGroup.tabs[index], "Tab index out of bound.");
	assert(tabGroup.tabs[index]:IsShown(), "Try to select a hidden tab.");
	tabGroup.tabs[index]:GetScript("OnClick")(tabGroup.tabs[index]);
end

function TRP3_API.ui.frame.createTabPanel(tabBar, data, callback, confirmCallback)
	assert(tabBar, "The tabBar can't be nil");

	local tabGroup = {};
	tabGroup.tabs = {};
	for index, tabData in pairs(data) do
		local text = tabData[1];
		local value = tabData[2];
		local width = tabData[3];
		local tabWidget = CreateFrame("Button", "TRP3_TabBar_Tab_" .. tabBar_index, tabBar, "TRP3_TabBar_Tab");
		tabWidget:SetText(text);
		tabWidget:SetWidth(width or (text:len() * 11));
		local clickFunction = function()
			tabBar_onSelect(tabGroup, index);
				if callback then
					callback(tabWidget, value);
				end
		end
		tabWidget:SetScript("OnClick", function(self)
			if not confirmCallback then
				clickFunction();
			else
				confirmCallback(function() clickFunction() end);
			end
		end);
		tinsert(tabGroup.tabs, tabWidget);
		tabBar_index = tabBar_index + 1;
	end

	tabGroup.Redraw = tabBar_redraw;
	tabGroup.Size = tabBar_size;
	tabGroup.SetTabVisible = tabBar_setTabVisible;
	tabGroup.SelectTab = tabBar_selectTab;
	tabGroup:Redraw();

	return tabGroup;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Textures tools
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local unitTexture = {
	Human = {
		"Achievement_Character_Human_Male",
		"Achievement_Character_Human_Female",
	},
	Gnome = {
		"Achievement_Character_Gnome_Male",
		"Achievement_Character_Gnome_Female",
	},
	Scourge = {
		"Achievement_Character_Undead_Male",
		"Achievement_Character_Undead_Female",
	},
	NightElf = {
		"Achievement_Character_Nightelf_Male",
		"Achievement_Character_Nightelf_Female",
	},
	Dwarf = {
		"Achievement_Character_Dwarf_Male",
		"Achievement_Character_Dwarf_Female",
	},
	Draenei = {
		"Achievement_Character_Draenei_Male",
		"Achievement_Character_Draenei_Female",
	},
	Orc = {
		"Achievement_Character_Orc_Male",
		"Achievement_Character_Orc_Female",
	},
	BloodElf = {
		"Achievement_Character_Bloodelf_Male",
		"Achievement_Character_Bloodelf_Female",
	},
	Troll = {
		"Achievement_Character_Troll_Male",
		"Achievement_Character_Troll_Female",
	},
	Tauren = {
		"Achievement_Character_Tauren_Male",
		"Achievement_Character_Tauren_Female",
	},
	Worgen = {
		"achievement_worganhead",
		"Ability_Racial_Viciousness",
	},
	Goblin = {
		"Ability_Racial_RocketJump",
		"Ability_Racial_RocketJump",
	},
	Pandaren = {
		"Achievement_Guild_ClassyPanda",
		"Achievement_Character_Pandaren_Female",
	},
};

local classTexture = {
	ROGUE = "Ability_Rogue_DualWeild",
	WARLOCK = "Ability_Warlock_Eradication",
	PALADIN = "Spell_Paladin_Clarityofpurpose",
	MONK = "Monk_Ability_Transcendence",
	MAGE = "spell_Mage_NetherTempest",
	HUNTER = "Ability_Hunter_MasterMarksman",
	WARRIOR = "Ability_Warrior_OffensiveStance",
	DEATHKNIGHT = "Spell_Deathknight_FrostPresence",
	DRUID = "Spell_druid_tirelesspursuit",
	SHAMAN = "Ability_Shaman_WindwalkTotem",
	PRIEST = "Priest_icon_Chakra",
}

TRP3_API.ui.misc.getUnitTexture = function(race, gender)
	if unitTexture[race] and unitTexture[race][gender - 1] then
		return unitTexture[race][gender - 1];
	end
	return globals.icons.default;
end

TRP3_API.ui.misc.getClassTexture = function (class)
	return classTexture[class] or globals.icons.default;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Text toolbar
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TAGS_INFO = {
	{
		openTags = {"{h1}", "{h1:c}", "{h1:r}"},
		closeTag = "{/h1}",
	},
	{
		openTags = {"{h2}", "{h2:c}", "{h2:r}"},
		closeTag = "{/h2}",
	},
	{
		openTags = {"{h3}", "{h3:c}", "{h3:r}"},
		closeTag = "{/h3}",
	},
	{
		openTags = {"{p:c}", "{p:r}"},
		closeTag = "{/p}",
	}
}

local function insertTag(tag, index, frame)
	local text = frame:GetText();
	local pre = text:sub(1, index);
	local post = text:sub(index + 1);
	text = strconcat(pre, tag, post);
	frame:SetText(text);
end

local function postInsertHighlight(index, tagSize, textSize, frame)
	frame:SetCursorPosition(index + tagSize + textSize);
	frame:HighlightText(index + tagSize, index + tagSize + textSize);
end

local function insertContainerTag(alignIndex, button, frame)
	assert(button.tagIndex and TAGS_INFO[button.tagIndex], "Button is not properly init with a tag index");
	local tagInfo = TAGS_INFO[button.tagIndex];
	local cursorIndex = frame:GetCursorPosition();
	insertTag(strconcat(tagInfo.openTags[alignIndex], loc("REG_PLAYER_ABOUT_T1_YOURTEXT"), tagInfo.closeTag), cursorIndex, frame);
	postInsertHighlight(cursorIndex, tagInfo.openTags[alignIndex]:len(), loc("REG_PLAYER_ABOUT_T1_YOURTEXT"):len(), frame);
end

local function onColorTagSelected(red, green, blue, frame)
	local cursorIndex = frame:GetCursorPosition();
	local tag = ("{col:%s}"):format(strconcat(numberToHexa(red), numberToHexa(green), numberToHexa(blue)));
	insertTag(tag .. "{/col}", cursorIndex, frame);
	frame:SetCursorPosition(cursorIndex + tag:len());
end

local function onIconTagSelected(icon, frame)
	local cursorIndex = frame:GetCursorPosition();
	local tag = ("{icon:%s:25}"):format(icon);
	insertTag(tag, cursorIndex, frame);
	frame:SetCursorPosition(cursorIndex + tag:len());
end

local function onImageTagSelected(image, frame)
	local cursorIndex = frame:GetCursorPosition();
	local tag = ("{img:%s:%s:%s}"):format(image.url, math.min(image.width, 512), math.min(image.height, 512));
	insertTag(tag, cursorIndex, frame);
	frame:SetCursorPosition(cursorIndex + tag:len());
end

local function onLinkTagClicked(frame)
	local cursorIndex = frame:GetCursorPosition();
	local tag = ("{link*%s*%s}"):format(loc("UI_LINK_URL"), loc("UI_LINK_TEXT"));
	insertTag(tag, cursorIndex, frame);
	frame:SetCursorPosition(cursorIndex + 6);
	frame:HighlightText(cursorIndex + 6, cursorIndex + 6 + loc("UI_LINK_URL"):len());
end

-- Drop down
local function onContainerTagClicked(button, frame, isP)
	local values = {};
	if not isP then
		tinsert(values, {loc("REG_PLAYER_ABOUT_P")});
		tinsert(values, {loc("CM_LEFT"), 1});
		tinsert(values, {loc("CM_CENTER"), 2});
		tinsert(values, {loc("CM_RIGHT"), 3});
	else
		tinsert(values, {loc("REG_PLAYER_ABOUT_HEADER")});
		tinsert(values, {loc("CM_CENTER"), 1});
		tinsert(values, {loc("CM_RIGHT"), 2});
	end
	openDropDown(button, values, function(alignIndex, button) insertContainerTag(alignIndex, button, frame) end, 0, true);
end

function TRP3_API.ui.text.setupToolbar(toolbar, textFrame)
	_G[toolbar .. "_Title"]:SetText(loc("REG_PLAYER_ABOUT_TAGS"));
	_G[toolbar .. "_Image"]:SetText(loc("CM_IMAGE"));
	_G[toolbar .. "_Icon"]:SetText(loc("CM_ICON"));
	_G[toolbar .. "_Color"]:SetText(loc("CM_COLOR"));
	_G[toolbar .. "_Link"]:SetText(loc("CM_LINK"));
	_G[toolbar .. "_H1"].tagIndex = 1;
	_G[toolbar .. "_H2"].tagIndex = 2;
	_G[toolbar .. "_H3"].tagIndex = 3;
	_G[toolbar .. "_P"].tagIndex = 4;
	_G[toolbar .. "_H1"]:SetScript("OnClick", function(button) onContainerTagClicked(button, textFrame) end);
	_G[toolbar .. "_H2"]:SetScript("OnClick", function(button) onContainerTagClicked(button, textFrame) end);
	_G[toolbar .. "_H3"]:SetScript("OnClick", function(button) onContainerTagClicked(button, textFrame) end);
	_G[toolbar .. "_P"]:SetScript("OnClick", function(button) onContainerTagClicked(button, textFrame, true) end);
	_G[toolbar .. "_Icon"]:SetScript("OnClick", function() TRP3_API.popup.showIconBrowser(function(icon) onIconTagSelected(icon, textFrame) end) end);
	_G[toolbar .. "_Color"]:SetScript("OnClick", function() TRP3_API.popup.showColorBrowser(function(red, green, blue) onColorTagSelected(red, green, blue, textFrame) end) end);
	_G[toolbar .. "_Image"]:SetScript("OnClick", function() TRP3_API.popup.showImageBrowser(function(image) onImageTagSelected(image, textFrame) end) end);
	_G[toolbar .. "_Link"]:SetScript("OnClick", function() onLinkTagClicked(textFrame) end);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Sounds
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.ui.misc.playUISound(pathToSound, url)
	if getConfigValue and getConfigValue(CONFIG_UI_SOUNDS) then
		if url then
			PlaySoundFile(pathToSound, "SFX");
		else
			PlaySound(pathToSound,"SFX");
		end
	end
end

function TRP3_API.ui.misc.playSoundKit(soundID)
	if getConfigValue and getConfigValue(CONFIG_UI_SOUNDS) then
		PlaySoundKitID(soundID)
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Animation
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.ui.misc.playAnimation(animationGroup)
	if getConfigValue and getConfigValue(CONFIG_UI_ANIMATIONS) and animationGroup then
		animationGroup:Stop();
		animationGroup:Play();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Hovered frames
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.ui.frame.configureHoverFrame(frame, hoveredFrame, arrowPosition, x, y)
	x = x or 0;
	y = y or 0;
	frame:ClearAllPoints();
	frame:SetParent(hoveredFrame:GetParent());
	frame:SetFrameStrata("HIGH");
	frame.ArrowRIGHT:Hide();
	frame.ArrowGlowRIGHT:Hide();
	frame.ArrowUP:Hide();
	frame.ArrowGlowUP:Hide();
	frame.ArrowDOWN:Hide();
	frame.ArrowGlowDOWN:Hide();
	frame.ArrowLEFT:Hide();
	frame.ArrowGlowLEFT:Hide();

	if arrowPosition == "RIGHT" then
		frame:SetPoint("RIGHT", hoveredFrame, "LEFT", -10 + x, 0 + y);
		frame.ArrowLEFT:Show();
		frame.ArrowGlowLEFT:Show();
	elseif arrowPosition == "LEFT" then
		frame:SetPoint("LEFT", hoveredFrame, "RIGHT", 10 + x, 0 + y);
		frame.ArrowRIGHT:Show();
		frame.ArrowGlowRIGHT:Show();
	elseif arrowPosition == "TOP" then
		frame:SetPoint("TOP", hoveredFrame, "BOTTOM", 0 + x, -20 + y);
		frame.ArrowDOWN:Show();
		frame.ArrowGlowDOWN:Show();
	else
		frame:SetPoint("BOTTOM", hoveredFrame, "TOP", 0 + x, 20 + y);
		frame.ArrowUP:Show();
		frame.ArrowGlowUP:Show();
	end

	frame:Show();
end

-- 3.3.5 compatibility: UI-related functions and methods

-- SetClampedTextureRotation doesn't exist in 3.3.5
if not SetClampedTextureRotation then
	function SetClampedTextureRotation(texture, rotation)
		-- SetClampedTextureRotation doesn't exist in 3.3.5
		-- We'll use the older SetTexCoord method as a fallback
		if texture and texture.SetTexCoord then
			-- Simple rotation approximation using texture coordinates
			if rotation == 90 then
				texture:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
			elseif rotation == 180 then
				texture:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
			elseif rotation == 270 then
				texture:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
			else
				-- Default (0 degrees)
				texture:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
			end
		end
	end
end

-- Enhance frame methods for 3.3.5 compatibility
local function enhanceFrameMethods()
	local frameMetatable = getmetatable(CreateFrame("Frame")).__index
	
	-- GetSize method
	if not frameMetatable.GetSize then
		frameMetatable.GetSize = function(self)
			return self:GetWidth(), self:GetHeight()
		end
	end
	
	-- SetSize method  
	if not frameMetatable.SetSize then
		frameMetatable.SetSize = function(self, width, height)
			self:SetWidth(width)
			self:SetHeight(height)
		end
	end
end

-- Enhance slider methods for 3.3.5 compatibility
local function enhanceSliderMethods()
	local sliderPrototype = getmetatable(CreateFrame("Slider")).__index
	
	-- SetObeyStepOnDrag method doesn't exist in 3.3.5
	if sliderPrototype and not sliderPrototype.SetObeyStepOnDrag then
		sliderPrototype.SetObeyStepOnDrag = function(self, obey)
			-- In 3.3.5, this method doesn't exist but sliders already behave this way by default
			-- So we can just make this a no-op function
		end
	end
end

-- Enhance texture methods for 3.3.5 compatibility
local function enhanceTextureMethods()
	local texturePrototype = getmetatable(CreateFrame("Frame"):CreateTexture()).__index
	if texturePrototype and not texturePrototype.SetClampedTextureRotation then
		texturePrototype.SetClampedTextureRotation = function(self, rotation)
			SetClampedTextureRotation(self, rotation)
		end
	end
end

-- Apply method enhancements
enhanceFrameMethods()
enhanceSliderMethods()
enhanceTextureMethods()