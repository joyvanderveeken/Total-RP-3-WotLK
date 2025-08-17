----------------------------------------------------------------------------------
-- Total RP 3
-- Popups API
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

-- Public accessor
TRP3_API.popup = {};

-- imports
local Utils = TRP3_API.utils;
local loc, table = TRP3_API.locale.getText, table;
local initList = TRP3_API.ui.list.initList;
local tinsert, _G, pairs, wipe, math, assert = tinsert, _G, pairs, wipe, math, assert;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForFrame, setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForFrame, TRP3_API.ui.tooltip.setTooltipForSameFrame;
local hooksecurefunc, GetItemIcon, IsControlKeyDown = hooksecurefunc, GetItemIcon, IsControlKeyDown;
local getIconList, getIconListSize, getImageList, getImageListSize, getMusicList, getMusicListSize;
local hexaToNumber, numberToHexa = TRP3_API.utils.color.hexaToNumber, TRP3_API.utils.color.numberToHexa;
local strconcat = strconcat;
local safeMatch = TRP3_API.utils.str.safeMatch;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Static popups definition
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

StaticPopupDialogs["TRP3_INFO"] = {
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
};

StaticPopupDialogs["TRP3_CONFIRM"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		if StaticPopupDialogs["TRP3_CONFIRM"].trp3onAccept then
			StaticPopupDialogs["TRP3_CONFIRM"].trp3onAccept();
		end
	end,
	OnCancel = function(arg1,arg2)
		if StaticPopupDialogs["TRP3_CONFIRM"].trp3onCancel then
			StaticPopupDialogs["TRP3_CONFIRM"].trp3onCancel();
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
};

StaticPopupDialogs["TRP3_INPUT_TEXT"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		_G[self:GetName().."EditBox"]:SetNumeric(false);
	end,
	OnAccept = function(self)
		if StaticPopupDialogs["TRP3_INPUT_TEXT"].trp3onAccept then
			StaticPopupDialogs["TRP3_INPUT_TEXT"].trp3onAccept(_G[self:GetName().."EditBox"]:GetText());
		end
	end,
	OnCancel = function(arg1,arg2)
		if StaticPopupDialogs["TRP3_INPUT_TEXT"].trp3onCancel then
			StaticPopupDialogs["TRP3_INPUT_TEXT"].trp3onCancel();
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:GetScript("OnClick")(self:GetParent().button1);
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:GetScript("OnClick")(self:GetParent().button2);
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
};

StaticPopupDialogs["TRP3_INPUT_NUMBER"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		_G[self:GetName().."EditBox"]:SetNumeric(true);
	end,
	OnAccept = function(self)
		if StaticPopupDialogs["TRP3_INPUT_NUMBER"].trp3onAccept then
			StaticPopupDialogs["TRP3_INPUT_NUMBER"].trp3onAccept(_G[self:GetName().."EditBox"]:GetNumber());
		end
	end,
	OnHide = function(self)
		_G[self:GetName().."EditBox"]:SetNumeric(false);
	end,
	OnCancel = function(arg1,arg2)
		if StaticPopupDialogs["TRP3_INPUT_NUMBER"].trp3onCancel then
			StaticPopupDialogs["TRP3_INPUT_NUMBER"].trp3onCancel();
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:GetScript("OnClick")(self:GetParent().button1);
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:GetScript("OnClick")(self:GetParent().button2);
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Static popups methods
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local POPUP_HEAD = "|TInterface\\AddOns\\totalRP3\\resources\\trp3logo:113:263|t\n \n";

-- Show a simple alert with a OK button.
function TRP3_API.popup.showAlertPopup(text)
	StaticPopupDialogs["TRP3_INFO"].text = POPUP_HEAD..text;
	local dialog = StaticPopup_Show("TRP3_INFO");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end

function TRP3_API.popup.showConfirmPopup(text, onAccept, onCancel)
	StaticPopupDialogs["TRP3_CONFIRM"].text = POPUP_HEAD..text.."\n\n";
	StaticPopupDialogs["TRP3_CONFIRM"].trp3onAccept = onAccept;
	StaticPopupDialogs["TRP3_CONFIRM"].trp3onCancel = onCancel;
	local dialog = StaticPopup_Show("TRP3_CONFIRM");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end

function TRP3_API.popup.showTextInputPopup(text, onAccept, onCancel, default)
	StaticPopupDialogs["TRP3_INPUT_TEXT"].text = POPUP_HEAD..text.."\n\n";
	StaticPopupDialogs["TRP3_INPUT_TEXT"].trp3onAccept = onAccept;
	StaticPopupDialogs["TRP3_INPUT_TEXT"].trp3onCancel = onCancel;
	local dialog = StaticPopup_Show("TRP3_INPUT_TEXT");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
		_G[dialog:GetName().."EditBox"]:SetText(default or "");
		_G[dialog:GetName().."EditBox"]:HighlightText();
	end
end

function TRP3_API.popup.showNumberInputPopup(text, onAccept, onCancel, default)
	StaticPopupDialogs["TRP3_INPUT_NUMBER"].text = POPUP_HEAD..text.."\n\n";
	StaticPopupDialogs["TRP3_INPUT_NUMBER"].trp3onAccept = onAccept;
	StaticPopupDialogs["TRP3_INPUT_NUMBER"].trp3onCancel = onCancel;
	local dialog = StaticPopup_Show("TRP3_INPUT_NUMBER");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
		_G[dialog:GetName().."EditBox"]:SetNumber(default or false);
		_G[dialog:GetName().."EditBox"]:HighlightText();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Dynamic popup
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TRP3_PopupsFrame = TRP3_PopupsFrame;

local function showPopup(popup)
	for _, frame in pairs({TRP3_PopupsFrame:GetChildren()}) do
		frame:Hide();
	end
	TRP3_PopupsFrame:Show();
	popup:Show();
end
TRP3_API.popup.showPopup = showPopup;

local function hidePopups()
	TRP3_PopupsFrame:Hide();
end
TRP3_API.popup.hidePopups = hidePopups;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Music browser
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local musicWidgetTab = {};
local filteredMusicList;

local function decorateMusic(lineFrame, musicURL)
	musicURL = filteredMusicList[musicURL];
	local musicName = musicURL:reverse();
	musicName = (musicName:sub(1, musicName:find("%\\")-1)):reverse();

	setTooltipForFrame(lineFrame, lineFrame, "RIGHT", 0, -30, musicName,
	("|cff00ff00%s\n\n|cffff9900%s: |cffffffff%s\n|cffff9900%s: |cffffffff%s"):format(musicURL, loc("CM_L_CLICK"), loc("REG_PLAYER_ABOUT_MUSIC_SELECT2"), loc("CM_R_CLICK"), loc("REG_PLAYER_ABOUT_MUSIC_LISTEN")));
	_G[lineFrame:GetName().."Text"]:SetText(musicName);
	lineFrame.musicURL = musicURL;
end

local function onMusicClick(lineFrame, mousebutton)
	if mousebutton == "LeftButton" then
		hidePopups();
		if TRP3_MusicBrowserContent.callback then
			TRP3_MusicBrowserContent.callback(lineFrame.musicURL);
		end
	elseif lineFrame.musicURL then
		Utils.music.play(lineFrame.musicURL);
	end

end

local function filteredMusicBrowser()
	local filter = TRP3_MusicBrowserFilterBox:GetText();
	if filteredMusicList and filteredMusicList ~= getMusicList() then  -- Remove previous filtering if is not full list
		wipe(filteredMusicList);
		filteredMusicList = nil;
	end
	filteredMusicList = getMusicList(filter); -- Music tab is unfiltered

	TRP3_MusicBrowserTotal:SetText( (#filteredMusicList) .. " / " .. getMusicListSize() );
	initList(
		{
			widgetTab = musicWidgetTab,
			decorate = decorateMusic
		},
		filteredMusicList,
		TRP3_MusicBrowserContentSlider
	);
end

local function initMusicBrowser()
	handleMouseWheel(TRP3_MusicBrowserContent, TRP3_MusicBrowserContentSlider);
	TRP3_MusicBrowserContentSlider:SetValue(0);
	-- Create lines
	for line = 0, 8 do
		local lineFrame = CreateFrame("Button", "TRP3_MusicBrowserButton_"..line, TRP3_MusicBrowserContent, "TRP3_MusicBrowserLine");
		lineFrame:SetPoint("TOP", TRP3_MusicBrowserContent, "TOP", 0, -10 + (line * (-31)));
		lineFrame:SetScript("OnClick", onMusicClick);
		tinsert(musicWidgetTab, lineFrame);
	end

	TRP3_MusicBrowserFilterBox:SetScript("OnTextChanged", filteredMusicBrowser);

	TRP3_MusicBrowserTitle:SetText(loc("UI_MUSIC_BROWSER"));
	TRP3_MusicBrowserFilterBoxText:SetText(loc("UI_FILTER"));
	TRP3_MusicBrowserFilterStop:SetText(loc("REG_PLAYER_ABOUT_MUSIC_STOP"));
	filteredMusicBrowser();
end

function TRP3_API.popup.showMusicBrowser(callback)
	TRP3_MusicBrowserContent.callback = callback;
	TRP3_MusicBrowserFilterBox:SetText("");
	showPopup(TRP3_MusicBrowser);
	TRP3_MusicBrowserFilterBox:SetFocus();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Icon browser
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TRP3_IconBrowser = TRP3_IconBrowser;
local iconWidgetTab = {};
local filteredIconList;
local ui_IconBrowserContent = TRP3_IconBrowserContent;

local function decorateIcon(icon, index)
	icon:SetNormalTexture("Interface\\ICONS\\"..filteredIconList[index]);
	icon:SetPushedTexture("Interface\\ICONS\\"..filteredIconList[index]);
	setTooltipForFrame(icon, TRP3_IconBrowser, "RIGHT", 0, -100, Utils.str.icon(filteredIconList[index], 75), filteredIconList[index]);
	icon.index = index;
end

local function onIconClick(icon)
	TRP3_API.popup.hideIconBrowser();
	if ui_IconBrowserContent.onSelectCallback then
		ui_IconBrowserContent.onSelectCallback(filteredIconList[icon.index], icon);
	end
end

local function onIconClose()
	TRP3_API.popup.hideIconBrowser();
	if ui_IconBrowserContent.onCancelCallback then
		ui_IconBrowserContent.onCancelCallback();
	end
end

local function filteredIconBrowser()
	local filter = TRP3_IconBrowserFilterBox:GetText();
	if filteredIconList and filteredIconList ~= getIconList() then -- Remove previous filtering if is not full list
		wipe(filteredIconList);
		filteredIconList = nil;
	end
	filteredIconList = getIconList(filter);
	TRP3_IconBrowserTotal:SetText( (#filteredIconList) .. " / " .. getIconListSize() );
	initList(
		{
			widgetTab = iconWidgetTab,
			decorate = decorateIcon
		},
		filteredIconList,
		TRP3_IconBrowserContentSlider
	);
end

local function initIconBrowser()
	handleMouseWheel(ui_IconBrowserContent, TRP3_IconBrowserContentSlider);
	TRP3_IconBrowserContentSlider:SetValue(0);
	-- Create icons
	local row, column;

	for row = 0, 5 do
		for column = 0, 7 do
			local button = CreateFrame("Button", "TRP3_IconBrowserButton_"..row.."_"..column, ui_IconBrowserContent, "TRP3_IconBrowserButton");
			button:ClearAllPoints();
			button:SetPoint("TOPLEFT", ui_IconBrowserContent, "TOPLEFT", 15 + (column * 45), -15 + (row * (-45)));
			button:SetScript("OnClick", onIconClick);
			tinsert(iconWidgetTab, button);
		end
	end

	TRP3_IconBrowserFilterBox:SetScript("OnTextChanged", filteredIconBrowser);
	TRP3_IconBrowserClose:SetScript("OnClick", onIconClose);
	TRP3_IconBrowserClearIcon:SetScript("OnClick", function()
		TRP3_API.popup.hideIconBrowser();
		if ui_IconBrowserContent.onSelectCallback then
			ui_IconBrowserContent.onSelectCallback(nil);
		end
	end);
	TRP3_IconBrowserTitle:SetText(loc("UI_ICON_BROWSER"));
	TRP3_IconBrowserFilterBoxText:SetText(loc("UI_FILTER"));
	filteredIconBrowser();

	-- Icon from item
	hooksecurefunc("HandleModifiedItemClick", function(link)
		if TRP3_IconBrowser:IsVisible() and IsControlKeyDown() and link and GetItemIcon(link) then
			local icon = GetItemIcon(link):match("([^\\]+)$");
			icon = icon:gsub("%.blp", ""):gsub("%.BLP", "");
			TRP3_IconBrowserFilterBox:SetText(icon);
			TRP3_IconBrowserFilterBox:HighlightText();
		end
	end);
	-- Icon from spellbook
	local GetSpellBookItemTexture, SpellBook_GetSpellBookSlot, SpellBookFrame = GetSpellBookItemTexture, SpellBook_GetSpellBookSlot, SpellBookFrame;
	hooksecurefunc("SpellButton_OnModifiedClick", function(self)
		if TRP3_IconBrowser:IsVisible() and IsControlKeyDown() then
			local icon = GetSpellBookItemTexture(SpellBook_GetSpellBookSlot(self), SpellBookFrame.bookType):match("([^\\]+)$");
			TRP3_IconBrowserFilterBox:SetText(icon);
			TRP3_IconBrowserFilterBox:HighlightText();
		end
	end);
end

function TRP3_API.popup.showIconBrowser(onSelectCallback, onCancelCallback, isExternal)
	TRP3_IconBrowser.isExternal = isExternal;
	ui_IconBrowserContent.onSelectCallback = onSelectCallback;
	ui_IconBrowserContent.onCancelCallback = onCancelCallback;
	TRP3_IconBrowserFilterBox:SetText("");

	TRP3_IconBrowser:ClearAllPoints();
	if isExternal then
		TRP3_IconBrowser:SetScale(0.75);
		TRP3_IconBrowser:SetParent(TRP3_AtFirstGlanceEditor);
		TRP3_IconBrowser:SetPoint("RIGHT", TRP3_AtFirstGlanceEditor, "LEFT", -5, 0);
		TRP3_IconBrowser:Show();
	else
		TRP3_IconBrowser:SetScale(1);
		TRP3_IconBrowser:SetParent(TRP3_PopupsFrame);
		TRP3_IconBrowser:SetPoint("CENTER", 0, 0);
		showPopup(TRP3_IconBrowser);
	end

	TRP3_IconBrowserFilterBox:SetFocus();
end

function TRP3_API.popup.hideIconBrowser()
	hidePopups();
	TRP3_IconBrowser:Hide();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Color browser
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TRP3_ColorBrowser, TRP3_ColorBrowserColor = TRP3_ColorBrowser, TRP3_ColorBrowserColor;
local toast = TRP3_API.ui.tooltip.toast;

local function initColorBrowser()
	TRP3_ColorBrowserSelect:SetText(loc("UI_COLOR_BROWSER_SELECT"));
	TRP3_ColorBrowserTitle:SetText(loc("UI_COLOR_BROWSER"));

	TRP3_ColorBrowserEditBoxText:SetText("Code");
	setTooltipForSameFrame(TRP3_ColorBrowserEditBoxHelp, "RIGHT", 0, 5, loc("BW_COLOR_CODE"), loc("BW_COLOR_CODE_TT"));
	
	-- class color button
	if not TRP3_ColorBrowser.classColorButton then
		local button = CreateFrame("Button", "TRP3_ColorBrowserClassColor", TRP3_ColorBrowser, "TRP3_CommonButton");
		button:SetSize(120, 25);
		button:SetPoint("RIGHT", TRP3_ColorBrowserSelect, "LEFT", -15, 0);
		button:SetText("Class Color");
		
		local _, englishClass = UnitClass("player");
		if englishClass and RAID_CLASS_COLORS[englishClass] then
			local classColor = RAID_CLASS_COLORS[englishClass];
			button:SetScript("OnClick", function()
				local r, g, b = classColor.r, classColor.g, classColor.b;
				TRP3_ColorBrowserColor:SetColorRGB(r, g, b);
				TRP3_ColorBrowserColor:GetScript("OnColorSelect")(TRP3_ColorBrowserColor, r, g, b);
			end);
			setTooltipForSameFrame(button, "RIGHT", 0, 5, "Class Color", "Click to select your class color");
		else
			button:Disable();
		end
		
		TRP3_ColorBrowser.classColorButton = button;
	end
	
	TRP3_ColorBrowserEditBox:SetScript("OnEnterPressed", function(self)
		if self:GetText():match("^%x%x%x%x%x%x$") then -- Checks that it is a 6 figures hexadecimal number
			local r, g, b = hexaToNumber(self:GetText());
			TRP3_ColorBrowserColor:SetColorRGB(r / 255, g / 255, b / 255);
			self:ClearFocus();
		else
			toast(loc("BW_COLOR_CODE_ALERT"), 1);
		end
	end);
	
	TRP3_ColorBrowserColor:SetScript("OnColorSelect", function(self, r, g, b)
		TRP3_ColorBrowserSwatch:SetTexture(r, g, b);
		TRP3_ColorBrowser.red = r;
		TRP3_ColorBrowser.green = g;
		TRP3_ColorBrowser.blue = b;
		TRP3_ColorBrowserEditBox:SetText(("%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255));
	end);

	TRP3_ColorBrowserSelect:SetScript("OnClick", function()
		hidePopups();
		if TRP3_ColorBrowser.callback ~= nil then
			TRP3_ColorBrowser.callback(TRP3_ColorBrowser.red * 255, TRP3_ColorBrowser.green * 255, TRP3_ColorBrowser.blue * 255);
		end
	end);
end

function TRP3_API.popup.showColorBrowser(callback, red, green, blue)
	TRP3_ColorBrowserColor:SetColorRGB((red or 255) / 255, (green or 255) / 255, (blue or 255) / 255);
	TRP3_ColorBrowser.callback = callback;
	showPopup(TRP3_ColorBrowser);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Image browser
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local imageWidgetTab = {};
local filteredImageList = {};

local function onImageSelect()
	assert(TRP3_ImageBrowserContent.currentImage, "No current image ...");
	hidePopups();
	if TRP3_ImageBrowser.callback then
		TRP3_ImageBrowser.callback(filteredImageList[TRP3_ImageBrowserContent.currentImage]);
	end
end

local function decorateImage(texture, index)
	local image = filteredImageList[index];
	local ratio = image.height / image.width;
	texture:SetHeight(texture:GetWidth() * ratio);
	texture:SetTexture(image.url);
	TRP3_ImageBrowserContentURL:SetText(image.url:sub(11));
	TRP3_ImageBrowserContent.currentImage = index;
end

local function filteredImageBrowser()
	local filter = TRP3_ImageBrowserFilterBox:GetText();
	filteredImageList = getImageList(filter);
	local size = #filteredImageList;
	TRP3_ImageBrowserTotal:SetText( size .. " / " .. getImageListSize() );
	if size > 0 then
		TRP3_ImageBrowserSelect:Enable();
	else
		TRP3_ImageBrowserSelect:Disable();
	end
	initList(
		{
			widgetTab = imageWidgetTab,
			decorate = decorateImage
		},
		filteredImageList,
		TRP3_ImageBrowserContentSlider
	);
end

local function initImageBrowser()
	handleMouseWheel(TRP3_ImageBrowserContent, TRP3_ImageBrowserContentSlider);
	TRP3_ImageBrowserContentSlider:SetValue(0);
	TRP3_ImageBrowserFilterBox:SetScript("OnTextChanged", filteredImageBrowser);
	TRP3_ImageBrowserSelect:SetScript("OnClick", onImageSelect);

	tinsert(imageWidgetTab, TRP3_ImageBrowserContentTexture);

	TRP3_ImageBrowserTitle:SetText(loc("UI_IMAGE_BROWSER"));
	TRP3_ImageBrowserFilterBoxText:SetText(loc("UI_FILTER"));
	TRP3_ImageBrowserSelect:SetText(loc("UI_IMAGE_SELECT"));
	filteredImageBrowser();
end

function TRP3_API.popup.showImageBrowser(callback)
	TRP3_ImageBrowser.callback = callback;
	showPopup(TRP3_ImageBrowser);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.popup.init()
	getIconList, getIconListSize = TRP3_API.utils.resources.getIconList, TRP3_API.utils.resources.getIconListSize;
	getImageList, getImageListSize = TRP3_API.utils.resources.getImageList, TRP3_API.utils.resources.getImageListSize;
	getMusicList, getMusicListSize = TRP3_API.utils.resources.getMusicList, TRP3_API.utils.resources.getMusicListSize;

	initIconBrowser();
	initMusicBrowser();
	initColorBrowser();
	initImageBrowser();
end
