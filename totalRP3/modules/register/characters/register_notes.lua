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

local getCurrentContext = TRP3_API.navigation.page.getCurrentContext;
local getCurrentPageID = TRP3_API.navigation.page.getCurrentPageID;

local getConfigValue, registerConfigKey, registerConfigHandler, setConfigValue = TRP3_API.configuration.getValue, TRP3_API.configuration.registerConfigKey, TRP3_API.configuration.registerHandler, TRP3_API.configuration.setValue;
local CONFIG_NOTES_STYLE = "CONFIG_NOTES_STYLE";

local NOTES_DATA_FIELD = "NT";
local TRP3_RegisterNotes_Panel_ScrollText = TRP3_RegisterNotes_PanelTextScrollText;
local privateNotes;

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

function showNotesTab()
	TRP3_RegisterNotes:Show();
	local context = getCurrentContext();
	if not context then return; end
	
	local notesKey = getNotesKey(context);
	local notesText = "";

	local headerText = "";
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
		headerText = "Notes on " .. characterName;
	end
	TRP3_RegisterNotes_Header:SetText(headerText);

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
end