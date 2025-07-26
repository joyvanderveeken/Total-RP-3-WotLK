----------------------------------------------------------------------------------
-- Total RP 3
-- Character page : Notes
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

local Globals, Utils, Events = TRP3_API.globals, TRP3_API.utils, TRP3_API.events;
local tcopy, tsize = Utils.table.copy, Utils.table.size;
local get = TRP3_API.profile.getData;
local getPlayerCurrentProfileID = TRP3_API.profile.getPlayerCurrentProfileID;
local saveInformation = TRP3_API.register.saveInformation;
local loc = TRP3_API.locale.getText;
local getLocaleFont = TRP3_API.locale.getLocaleFont;

local getCurrentContext = TRP3_API.navigation.page.getCurrentContext;
local getCurrentPageID = TRP3_API.navigation.page.getCurrentPageID;

local getConfigValue, registerConfigKey, registerConfigHandler, setConfigValue = TRP3_API.configuration.getValue, TRP3_API.configuration.registerConfigKey, TRP3_API.configuration.registerHandler, TRP3_API.configuration.setValue;
local CONFIG_NOTES_STYLE = "CONFIG_NOTES_STYLE";

local NOTES_DATA_FIELD = "NT";
local TRP3_RegisterNotes_Panel_ScrollText = TRP3_RegisterNotes_PanelTextScrollText;
local privateNotes;

local gameFont, gameSize = GameFontNormal:GetFont();

local WRITTEN_FONT_PATH = "fonts\\skurri.TTF";
local WRITTEN_HEADER_SIZE = 24;
local WRITTEN_TEXT_SIZE = 20;
local CLASSIC_HEADER_SIZE = 18;
local CLASSIC_TEXT_SIZE = 13;

local WRITTEN_HEADER_COLOR = {125/255, 9/255, 9/255, 0.9};
local WRITTEN_TEXT_COLOR = {0.3, 0.2, 0.1, 1.0};

local CLASSIC_HEADER_COLOR = {0.95, 0.95, 0.95, 1};
local CLASSIC_TEXT_COLOR = {1, 1, 1, 1};
local CLASSIC_SHADOW_COLOR = {0, 0, 0, 1};
local CLASSIC_SHADOW_OFFSET = {1, -1};

local function applyWrittenEditBoxStyle(editBox)
	if not editBox then return; end
	editBox:SetFont(WRITTEN_FONT_PATH, WRITTEN_TEXT_SIZE, "");
	editBox:SetTextColor(unpack(WRITTEN_TEXT_COLOR));
	editBox:SetShadowColor(0, 0, 0, 0);
	editBox:SetShadowOffset(0, 0);
end

local function applyClassicEditBoxStyle(editBox)
	if not editBox then return; end
	if gameFont then
		editBox:SetFont(gameFont, CLASSIC_TEXT_SIZE);
	end
	editBox:SetTextColor(unpack(CLASSIC_TEXT_COLOR));
	editBox:SetShadowOffset(unpack(CLASSIC_SHADOW_OFFSET));
	editBox:SetShadowColor(unpack(CLASSIC_SHADOW_COLOR));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Notes tab logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getNotesKey(context)
	if context.isPlayer then
		return "self";
	else
		return context.profileID or "unknown";
	end
end

local function saveNotes()
	local context = getCurrentContext();
	if not context then return; end
	
	local notesKey = getNotesKey(context);
	local newText = TRP3_RegisterNotes_Panel_ScrollText:GetText();

	if not privateNotes[notesKey] or privateNotes[notesKey] ~= newText then
		privateNotes[notesKey] = newText;
	end
end

local function setHeaderText(context)
	if not TRP3_RegisterNotes_Header or not context then return; end
	
	local headerText = "";
	local fullTitle = "";
	local hasFullTitle = false;
	
	if context.isPlayer then
		local characterName = get("player/characteristics/FN") or Globals.player;
		local lastName = get("player/characteristics/LN");
		if lastName and lastName ~= "" then
			characterName = characterName .. " " .. lastName;
		end

		headerText = characterName .. "'s notes";
	else
		local characterName = "Unknown";
		if context.profile and context.profile.characteristics and context.profile.characteristics.FN then
			characterName = context.profile.characteristics.FN;
			if context.profile.characteristics.LN and context.profile.characteristics.LN ~= "" then
				characterName = characterName .. " " .. context.profile.characteristics.LN;
			end
		end
		if context.profile and context.profile.characteristics and context.profile.characteristics.FT then
			fullTitle = context.profile.characteristics.FT;
			hasFullTitle = (fullTitle ~= "");
		end

		headerText = "Notes on " .. characterName;
	end

	TRP3_RegisterNotes_Header:SetText(headerText);
	TRP3_RegisterNotes_FullTitle:SetText(fullTitle);

	if TRP3_RegisterNotes_PanelText then
		TRP3_RegisterNotes_PanelText:ClearAllPoints();
		if hasFullTitle then
			TRP3_RegisterNotes_PanelText:SetPoint("TOPLEFT", TRP3_RegisterNotes_FullTitle, "BOTTOMLEFT", 0, -20);
		else
			TRP3_RegisterNotes_PanelText:SetPoint("TOPLEFT", TRP3_RegisterNotes_Header, "BOTTOMLEFT", 0, -15);
		end
		TRP3_RegisterNotes_PanelText:SetPoint("BOTTOMRIGHT", 0, 0);
	end

	local isWrittenStyle = getConfigValue(CONFIG_NOTES_STYLE);
	if isWrittenStyle then
		TRP3_RegisterNotes_Header:SetTextColor(unpack(WRITTEN_HEADER_COLOR));
		TRP3_RegisterNotes_Header:SetFont(WRITTEN_FONT_PATH, WRITTEN_HEADER_SIZE, "");
		TRP3_RegisterNotes_Header:SetShadowColor(0, 0, 0, 0);
		TRP3_RegisterNotes_FullTitle:SetTextColor(unpack(WRITTEN_TEXT_COLOR));
		TRP3_RegisterNotes_FullTitle:SetFont(WRITTEN_FONT_PATH, WRITTEN_TEXT_SIZE, "");
		TRP3_RegisterNotes_FullTitle:SetShadowColor(0, 0, 0, 0);
	else
		if gameFont then
			TRP3_RegisterNotes_Header:SetFont(gameFont, CLASSIC_HEADER_SIZE);
			TRP3_RegisterNotes_FullTitle:SetFont(gameFont, CLASSIC_TEXT_SIZE);
		end
		TRP3_RegisterNotes_Header:SetTextColor(unpack(CLASSIC_HEADER_COLOR));
		TRP3_RegisterNotes_Header:SetShadowOffset(unpack(CLASSIC_SHADOW_OFFSET));
		TRP3_RegisterNotes_Header:SetShadowColor(unpack(CLASSIC_SHADOW_COLOR));
		TRP3_RegisterNotes_FullTitle:SetTextColor(unpack(CLASSIC_HEADER_COLOR));
		TRP3_RegisterNotes_FullTitle:SetShadowOffset(unpack(CLASSIC_SHADOW_OFFSET));
		TRP3_RegisterNotes_FullTitle:SetShadowColor(unpack(CLASSIC_SHADOW_COLOR));
	end
end

local function applyNotesStyle()
	local frame = TRP3_RegisterNotes_PanelText;
	if not frame then return; end
	
	local isWrittenStyle = getConfigValue(CONFIG_NOTES_STYLE);
	
	if isWrittenStyle then
		frame:SetScript("OnShow", function(self)
			local editBox = _G[self:GetName() .. "ScrollText"];
			applyWrittenEditBoxStyle(editBox);
		end);

		frame:SetBackdrop(nil);
	else
		frame:SetScript("OnShow", function(self)
			local editBox = _G[self:GetName() .. "ScrollText"];
			if editBox then
				editBox:SetWidth(self:GetWidth() - 40);
			end
			applyClassicEditBoxStyle(editBox);
		end);

		frame:SetBackdrop({
			edgeFile = "Interface\\AddOns\\totalRP3\\Resources\\UI\\ui-frame-backdrop-edge",
			bgFile = "Interface\\AddOns\\totalRP3\\Resources\\UI\\ui-frame-backdrop-fill",
			tile = true,
			edgeSize = 8,
			tileSize = 380,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		});
	end
	
	if frame:IsVisible() then
		frame:GetScript("OnShow")(frame);
	end
end

function showNotesTab()
	TRP3_RegisterNotes:Show();
	local context = getCurrentContext();
	if not context then return; end

	applyNotesStyle();
	setHeaderText(context);
	
	local notesKey = getNotesKey(context);
	local notesText = "";

	if privateNotes[notesKey] then
		notesText = privateNotes[notesKey];
	end

	TRP3_RegisterNotes_Panel_ScrollText:EnableMouse(true);
	TRP3_RegisterNotes_Panel_ScrollText:SetText(notesText);
	TRP3_RegisterNotes_Panel_ScrollText:SetCursorPosition(TRP3_RegisterNotes_Panel_ScrollText:GetNumLetters());
end
TRP3_API.register.ui.showNotesTab = showNotesTab;

local function refreshDisplay()
	if TRP3_RegisterNotes:IsVisible() then
		showNotesTab();
	end
end

local function onTextChanged()
	saveNotes();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.register.inits.notesInit()
	if not TRP3_Register then
		TRP3_Register = {};
	end
	if not TRP3_Register.character then
		TRP3_Register.character = {};
	end
	if not TRP3_Register.character.privateNotes then
		TRP3_Register.character.privateNotes = {};
	end
	
	privateNotes = TRP3_Register.character.privateNotes;
	
	if TRP3_RegisterNotes_PanelTextScrollText then
		TRP3_RegisterNotes_PanelTextScrollText:SetScript("OnTextChanged", function(self)
			onTextChanged();
		end);

		TRP3_RegisterNotes_PanelTextScrollText:SetScript("OnEditFocusLost", function(self)
			onTextChanged();
		end);

		if TRP3_RegisterNotes_PanelTextScroll then
			TRP3_RegisterNotes_PanelTextScroll:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
					TRP3_RegisterNotes_PanelTextScrollText:SetFocus();
				end
			end);
			TRP3_RegisterNotes_PanelTextScroll:EnableMouse(true);
		end
	end

	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, _, dataType)
		if getCurrentPageID() == "player_main" and TRP3_RegisterNotes:IsVisible() then
			showNotesTab();
		end
	end);
	
	registerConfigKey(CONFIG_NOTES_STYLE, false);
	registerConfigHandler(CONFIG_NOTES_STYLE, function()
		applyNotesStyle();
	end);
	
	applyNotesStyle();
end