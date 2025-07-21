----------------------------------------------------------------------------------
-- Total RP 3
-- Character page : About
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
local Globals, Utils, Comm, Events = TRP3_API.globals, TRP3_API.utils, TRP3_API.communication, TRP3_API.events;
local stEtN = Utils.str.emptyToNil;
local get = TRP3_API.profile.getData;
local safeGet = TRP3_API.profile.getDataDefault;
local loc = TRP3_API.locale.getText;
local tcopy, tsize = Utils.table.copy, Utils.table.size;
local getDefaultProfile = TRP3_API.profile.getDefaultProfile;
local showIconBrowser = TRP3_API.popup.showIconBrowser;
local unitIDToInfo = Utils.str.unitIDToInfo;
local Log, convertTextTags = Utils.log, Utils.str.convertTextTags;
local getConfigValue = TRP3_API.configuration.getValue;
local CreateFrame = CreateFrame;
local tostring, unpack, strtrim = tostring, unpack, strtrim;
local assert, tinsert, type, wipe, _G, strconcat, tonumber, pairs, tremove, math = assert, tinsert, type, wipe, _G, strconcat, tonumber, pairs, tremove, math;
local numberToHexa, hexaToNumber = Utils.color.numberToHexa, Utils.color.hexaToNumber;
local getTiledBackground = TRP3_API.ui.frame.getTiledBackground;
local getTiledBackgroundList = TRP3_API.ui.frame.getTiledBackgroundList;
local showIfMouseOver = TRP3_API.ui.frame.showIfMouseOverFrame;
local createRefreshOnFrame = TRP3_API.ui.frame.createRefreshOnFrame;
local TRP3_RegisterAbout_AboutPanel = TRP3_RegisterAbout_AboutPanel;
local displayDropDown = TRP3_API.ui.listbox.displayDropDown;
local setupListBox = TRP3_API.ui.listbox.setupListBox;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local getCurrentContext, getCurrentPageID = TRP3_API.navigation.page.getCurrentContext, TRP3_API.navigation.page.getCurrentPageID;
local getUnitID = Utils.str.getUnitID;
local setupIconButton = TRP3_API.ui.frame.setupIconButton;
local isUnitIDKnown = TRP3_API.register.isUnitIDKnown;
local getUnitIDProfile = TRP3_API.register.getUnitIDProfile;
local hasProfile, getProfile = TRP3_API.register.hasProfile, TRP3_API.register.getProfile;
local showConfirmPopup = TRP3_API.popup.showConfirmPopup;

local saveInDraft; -- Function reference

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- SCHEMA
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

getDefaultProfile().player.about = {
	v = 1,
	TE = 1,
	T1 = {

	},
	T2 = {
		items = {}
		-- Flat structure: array of items, each with type "header" or "section"
		-- Example:
		-- {
		--     type = "header",
		--     text = "Character Background",
		--     color = {0.8, 0.2, 0.1}
		-- },
		-- {
		--     type = "section", 
		--     text = "Born in Stormwind...",
		--     icon = "inv_misc_book_07"  -- optional
		-- }
	},
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- ABOUT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local draftData = nil;

local function setBkg(frame, bkg)
	local backdrop = frame:GetBackdrop();
	backdrop.bgFile = getTiledBackground(bkg or 1);
	frame:SetBackdrop(backdrop);
end

local function setConsultBkg(bkg)
	setBkg(TRP3_RegisterAbout, bkg);
end

local function setEditBkg(bkg)
	setBkg(TRP3_RegisterAbout, bkg);
end

local function getCurrentMusicInfo()
	if draftData.MU then
		return (Utils.music.getTitle(draftData.MU))
	else
		return (loc("REG_PLAYER_ABOUT_NOMUSIC"))
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TEMPLATE 1
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function shouldShowTemplate1(dataTab)
	local templateData = dataTab.T1 or {};
	return templateData.TX and strtrim(templateData.TX):len() > 0;
end

local function showTemplate1(dataTab)
	local templateData = dataTab.T1 or {};
	if shouldShowTemplate1(dataTab) then
		local text = Utils.str.toHTML(templateData.TX or "");
		TRP3_RegisterAbout_AboutPanel_Template1:SetText(text);
	else
		TRP3_RegisterAbout_AboutPanel_Empty:Show();
		TRP3_RegisterAbout_AboutPanel_Template1:SetText("");
	end
	TRP3_RegisterAbout_AboutPanel_Template1:Show();
end

local function onLinkClicked(self, url)
	TRP3_API.popup.showTextInputPopup(loc("UI_LINK_WARNING"), nil, nil, url);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TEMPLATE 2 - FLAT STRUCTURE (HEADERS + SECTIONS)
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local template2Frames = {};
local TEMPLATE2_HEADER_HEIGHT = 55;
local TEMPLATE2_SECTION_MIN_HEIGHT = 60;

local function shouldShowTemplate2(dataTab)
	local templateData = dataTab.T2 or {};
	local items = templateData.items or {};

	for _, item in pairs(items) do
		if item.text and strtrim(item.text):len() > 0 then
			return true;
		end
	end
	return false;
end

local function showTemplate2(dataTab)
	local templateData = dataTab.T2 or {};

	for _, frame in pairs(template2Frames) do
		frame:Hide();
	end
	wipe(template2Frames);

	if not shouldShowTemplate2(dataTab) then
		TRP3_RegisterAbout_AboutPanel_Empty:Show();
		return;
	end

	TRP3_RegisterAbout_AboutPanel_Template2:Show();

	local items = templateData.items or {};
	if #items == 0 then
		TRP3_RegisterAbout_AboutPanel_Template2_PlaceholderText:SetText("Template 2: No content yet");
		return;
	end

	TRP3_RegisterAbout_AboutPanel_Template2_PlaceholderText:SetText("");

	local yOffset = 0;
	local totalHeight = 10;
	
	for i, item in ipairs(items) do
		local frameName = "TRP3_Template2_DisplayItem_" .. (item.id or i);
		local frame = _G[frameName];
		
		if not frame then
			frame = CreateFrame("Frame", frameName, TRP3_RegisterAbout_AboutPanel_Template2);
			frame:SetWidth(480);
			
			if item.type == "header" then
				frame:SetHeight(60);
				
				-- top divider
				frame.topDivider = frame:CreateTexture(frameName .. "_TopDivider", "BACKGROUND");
				frame.topDivider:SetTexture("Interface\\Addons\\totalRP3\\resources\\ui\\weather-sandstorm");
				frame.topDivider:SetSize(540, 4);
				frame.topDivider:SetPoint("TOP", frame, "TOP", 0, 6);
				
				-- header text
				frame.text = frame:CreateFontString(frameName .. "_Text", "OVERLAY", "GameFontNormalHuge");
				frame.text:SetPoint("LEFT", frame, "LEFT", 20, 0);
				frame.text:SetPoint("RIGHT", frame, "RIGHT", -20, 0);
				frame.text:SetJustifyH("CENTER");
				frame.text:SetWordWrap(true);
				
				-- bottom divider
				frame.bottomDivider = frame:CreateTexture(frameName .. "_BottomDivider", "BACKGROUND");
				frame.bottomDivider:SetTexture("Interface\\Addons\\totalRP3\\resources\\ui\\weather-sandstorm");
				frame.bottomDivider:SetSize(500, 4);
				frame.bottomDivider:SetPoint("BOTTOM", frame, "BOTTOM", 0, -6);

				-- header shadow background
				frame.headerShadow = frame:CreateTexture(frameName .. "_HeaderShadow", "ARTWORK");
				frame.headerShadow:SetTexture("Interface\\AddOns\\totalRP3\\Resources\\UI\\headershadow");
				frame.headerShadow:SetSize(500, 64);
				frame.headerShadow:SetPoint("CENTER", frame, "CENTER", 0, 0);
				frame.headerShadow:SetAlpha(0.4);
				
			else
				frame:SetHeight(60);
				
				-- section icon
				if item.icon then
					if not frame.icon then
						frame.icon = CreateFrame("Frame", frameName .. "_Icon", frame, "TRP3_SimpleIcon");
						frame.icon:SetSize(40, 40);
						frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10);
						
						frame.icon.texture = _G[frameName .. "_IconIcon"];
					end
					frame.icon:Show();
				elseif frame.icon then
					frame.icon:Hide();
				end
				
				-- section text
				if not frame.text then
					frame.text = frame:CreateFontString(frameName .. "_Text", "OVERLAY", "GameFontNormal");
					frame.text:SetJustifyH("LEFT");
					frame.text:SetWordWrap(true);
				end
				
				frame.text:ClearAllPoints();
				if item.icon and frame.icon then
					frame.text:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 10, 0);
				else
					frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10);
				end
			end
		end
		
		if item.type == "header" then
			frame.text:SetText(item.text or "Header");
			if item.color then
				local red, green, blue = item.color.red or 1, item.color.green or 1, item.color.blue or 1;
				
				local brightenFactor = 1.6;
				local brightRed = math.min(red * brightenFactor, 1); 
				local brightGreen = math.min(green * brightenFactor, 1);
				local brightBlue = math.min(blue * brightenFactor, 1);
				
				local midRed = (brightRed + red) / 2;
				local midGreen = (brightGreen + green) / 2;
				local midBlue = (brightBlue + blue) / 2;
				frame.text:SetTextColor(midRed, midGreen, midBlue);
				
				if frame.headerShadow then
					local shadowRed = red * 0.7;
					local shadowGreen = green * 0.7;
					local shadowBlue = blue * 0.7;
					frame.headerShadow:SetVertexColor(shadowRed, shadowGreen, shadowBlue);
				end
				
				if frame.topDivider then
					frame.topDivider:SetGradient("HORIZONTAL", red, green, blue, brightRed, brightGreen, brightBlue);
				end
				if frame.bottomDivider then
					frame.bottomDivider:SetGradient("HORIZONTAL", red, green, blue, brightRed, brightGreen, brightBlue);
				end
			
			else
				frame.text:SetTextColor(1, 0.82, 0);
				if frame.headerShadow then
					frame.headerShadow:SetVertexColor(0.7, 0.574, 0);
				end
				if frame.topDivider then
					frame.topDivider:SetGradient("HORIZONTAL", 1, 0.82, 0, 1, 1, 0.6);
				end
				if frame.bottomDivider then
					frame.bottomDivider:SetGradient("HORIZONTAL", 1, 0.82, 0, 1, 1, 0.6);
				end
			end

		else
			frame.text:SetText(item.text or "Section text");
			frame.text:SetTextColor(1, 1, 1);
			
			if item.icon and frame.icon and frame.icon.texture then
				frame.icon.texture:SetTexture("Interface\\ICONS\\" .. item.icon);
				frame.icon:Show();
			elseif frame.icon then
				frame.icon:Hide();
			end

			local textWidth;
			if item.icon and frame.icon then
				textWidth = 480 - 30 - 20 - 20;
			else
				textWidth = 480 - 20;
			end
			frame.text:SetWidth(textWidth);
			
			local textHeight = frame.text:GetStringHeight();
			local iconHeight = (item.icon and frame.icon) and 30 or 0;
			local calculatedHeight = math.max(textHeight + 20, iconHeight + 20, 40);
			frame:SetHeight(calculatedHeight);
		end
		
		frame:SetPoint("TOPLEFT", TRP3_RegisterAbout_AboutPanel_Template2, "TOPLEFT", 10, yOffset);
		frame:Show();
		tinsert(template2Frames, frame);
		
		yOffset = yOffset - (frame:GetHeight() + 10);
		totalHeight = totalHeight + frame:GetHeight() + 10;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TEMPLATE 2 EDIT MANAGEMENT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local template2EditFrames = {};
local addTemplate2Item, removeTemplate2Item, moveTemplate2Item;

local function refreshTemplate2EditDisplay()
	for _, frame in pairs(template2EditFrames) do
		frame:Hide();
	end
	wipe(template2EditFrames);
	
	if not draftData.T2 or not draftData.T2.items then
		return;
	end
	
	local content = TRP3_RegisterAbout_Edit_Template2_Content;
	local yOffset = 0;
	local totalHeight = 10;
	
	for i, item in ipairs(draftData.T2.items) do
		local frameName = "TRP3_Template2_EditItem_" .. (item.id or i);
		local frame;
		
		frame = _G[frameName];
		if not frame then
			if item.type == "header" then
				frame = CreateFrame("Frame", frameName, content, "TRP3_Template2_HeaderFrame");
			else
				frame = CreateFrame("Frame", frameName, content, "TRP3_Template2_SectionFrame");
			end
		end
		
		local textBox, iconButton, colorButton, textScroll;
		if item.type == "header" then
			textBox = _G[frameName .. "_Text"];
			colorButton = _G[frameName .. "_ColorButton"];
		else
			iconButton = _G[frameName .. "_IconButton"];
			textScroll = _G[frameName .. "_TextScroll"];
			textBox = _G[frameName .. "_TextScrollScrollText"];
		end
		
		local upButton = _G[frameName .. "_UpButton"];
		local downButton = _G[frameName .. "_DownButton"];
		local deleteButton = _G[frameName .. "_DeleteButton"];
		
		if textBox then
			textBox:SetText(item.text or (item.type == "header" and "Title" or "Some text.."));
			textBox:SetScript("OnTextChanged", function()
				item.text = textBox:GetText();
			end);
		end
		
		if item.type == "header" and colorButton then
			colorButton.onSelection = function(red, green, blue)
				if red and green and blue then
					local hexa = strconcat(numberToHexa(red), numberToHexa(green), numberToHexa(blue));
					item.color = { red = red/255, green = green/255, blue = blue/255 };
				else
					item.color = nil;
				end
			end;
			
			if item.color then
				local red = math.floor((item.color.red or 1) * 255);
				local green = math.floor((item.color.green or 1) * 255);
				local blue = math.floor((item.color.blue or 1) * 255);
				colorButton.setColor(red, green, blue);
			else
				item.color = { red = 1, green = 1, blue = 1 };
				colorButton.setColor(255, 255, 255);
			end
		end
		
		if item.type == "section" and iconButton then
			setupIconButton(iconButton, item.icon or TRP3_API.globals.icons.default);
			
			-- no icon state
			local iconTexture = _G[iconButton:GetName() .. "Icon"];
			if not item.icon and iconTexture then
				iconTexture:SetDesaturated(true);
				iconTexture:SetAlpha(0.5);
			elseif iconTexture then
				iconTexture:SetDesaturated(false);
				iconTexture:SetAlpha(1.0);
			end
			
			-- click handler
			iconButton:SetScript("OnClick", function()
				showIconBrowser(function(icon)
					item.icon = icon;
					setupIconButton(iconButton, icon or TRP3_API.globals.icons.default);
					
					local iconTexture = _G[iconButton:GetName() .. "Icon"];
					if not icon and iconTexture then
						iconTexture:SetDesaturated(true);
						iconTexture:SetAlpha(0.5);
					elseif iconTexture then
						iconTexture:SetDesaturated(false);
						iconTexture:SetAlpha(1.0);
					end
				end);
			end);
		end
		
		frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset);

		local itemId = item.id;
		local upBtn = _G[frameName .. "_UpButton"];
		local downBtn = _G[frameName .. "_DownButton"];
		local deleteBtn = _G[frameName .. "_DeleteButton"];

		local isFirstItem = (i == 1);
		local isLastItem = (i == #draftData.T2.items);
		
		if upBtn then
			upBtn:SetScript("OnClick", function()
				moveTemplate2Item(itemId, -1);
			end);
			if isFirstItem then
				upBtn:Hide();
			else
				upBtn:Show();
			end
		end
		if downBtn then
			downBtn:SetScript("OnClick", function()
				moveTemplate2Item(itemId, 1);
			end);
			if isLastItem then
				downBtn:Hide();
			else
				downBtn:Show();
			end
		end
		if deleteBtn then
			deleteBtn:SetScript("OnClick", function()
				removeTemplate2Item(itemId);
			end);
		end
		
		frame:Show();
		tinsert(template2EditFrames, frame);
		
		yOffset = yOffset - (frame:GetHeight() + 5);
		totalHeight = totalHeight + frame:GetHeight() + 5;
	end

	content:SetHeight(totalHeight);
end

function addTemplate2Item(itemType)
	if not draftData.T2 then
		draftData.T2 = {};
	end
	if not draftData.T2.items then
		draftData.T2.items = {};
	end

	-- unique id gen
	local timestamp = GetTime() * 1000;
	local uniqueId = itemType .. "_" .. math.floor(timestamp);
	
	local newItem = {
		id = uniqueId,
		type = itemType,
		text = itemType == "header" and "Title" or "Some text..",
	};
	
	if itemType == "header" then
		newItem.color = {r = 1, g = 0.75, b = 0};
	else
		newItem.icon = nil;
	end
	
	tinsert(draftData.T2.items, newItem);
	refreshTemplate2EditDisplay();
end

function removeTemplate2Item(id)
	if not draftData.T2 or not draftData.T2.items then return end
	
	for i, item in ipairs(draftData.T2.items) do
		if item.id == id then
			tremove(draftData.T2.items, i);
			refreshTemplate2EditDisplay();
			return;
		end
	end
end

function moveTemplate2Item(id, direction)
	if not draftData.T2 or not draftData.T2.items then return end
	
	local items = draftData.T2.items;
	local currentIndex = nil;
	
	for i, item in ipairs(items) do
		if item.id == id then
			currentIndex = i;
			break;
		end
	end
	
	if not currentIndex then return end
	
	local newIndex = currentIndex + direction;
	
	if newIndex >= 1 and newIndex <= #items then
		local temp = items[currentIndex];
		items[currentIndex] = items[newIndex];
		items[newIndex] = temp;
		refreshTemplate2EditDisplay();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- VOTE
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local sendVote;
local VOTE_MESSAGE_PREFIX = "ABVT";
local VOTE_MESSAGE_PRIORITY = "ALERT";
local VOTE_MESSAGE_R_PREFIX = "ABVR";
local VOTE_MESSAGE_R_PRIORITY = "ALERT";

local function refreshVoteDisplay(aboutTab)
	if aboutTab.vote == 1 then
		TRP3_RegisterAbout_AboutPanel_LikeButton:LockHighlight();
		TRP3_RegisterAbout_AboutPanel_LikeButton:GetHighlightTexture():SetVertexColor(0, 1, 0);
		TRP3_RegisterAbout_AboutPanel_DislikeButton:UnlockHighlight();
		TRP3_RegisterAbout_AboutPanel_DislikeButton:GetHighlightTexture():SetVertexColor(1, 1, 1);
	elseif aboutTab.vote == -1 then
		TRP3_RegisterAbout_AboutPanel_DislikeButton:LockHighlight();
		TRP3_RegisterAbout_AboutPanel_DislikeButton:GetHighlightTexture():SetVertexColor(0, 1, 0);
		TRP3_RegisterAbout_AboutPanel_LikeButton:UnlockHighlight();
		TRP3_RegisterAbout_AboutPanel_LikeButton:GetHighlightTexture():SetVertexColor(1, 1, 1);
	else
		TRP3_RegisterAbout_AboutPanel_LikeButton:UnlockHighlight();
		TRP3_RegisterAbout_AboutPanel_LikeButton:GetHighlightTexture():SetVertexColor(1, 1, 1);
		TRP3_RegisterAbout_AboutPanel_DislikeButton:UnlockHighlight();
		TRP3_RegisterAbout_AboutPanel_DislikeButton:GetHighlightTexture():SetVertexColor(1, 1, 1);
	end
end

local function showVotingOption(voteValue)
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	assert(context.profile, "No profile in context !");
	assert(not context.isPlayer, "Trying to vote for yourself ...");

	local profile = context.profile;
	if profile.link then
		local sent = false;
		for unitID, _ in pairs(profile.link) do
			local isOnline = true;
			if isOnline then
				-- TODO: check if is online
				sendVote(voteValue, unitID, profile);
				sent = true;
				break;
			end
		end
		if not sent then
			Utils.message.displayMessage(loc("REG_PLAYER_ABOUT_VOTE_NO"));
		end
	end
end

function sendVote(voteValue, target, profile)
	if target ~= Globals.player_id and profile and profile.about then
		if voteValue == profile.about.vote then
			voteValue = 0; -- Unvoting
		end
		Comm.sendObject(VOTE_MESSAGE_PREFIX, {voteValue, Globals.player_hash}, target, VOTE_MESSAGE_PRIORITY);
		local playerName = unitIDToInfo(target);
		Utils.message.displayMessage(loc("REG_PLAYER_ABOUT_VOTE_SENDING"):format(playerName));
	end
end

local function aggregateVotes(voteData)
	local voteUp = 0;
	local voteDown = 0;
	for voter, vote in pairs(voteData or {}) do
		if vote == 1 then
			voteUp = voteUp + 1;
		elseif vote == -1 then
			voteDown = voteDown + 1;
		end
	end
	return voteUp, voteDown;
end

local function refreshPlayerVoteDisplay()
	if getCurrentPageID() == "player_main" then
		local context = getCurrentContext();
		if context and context.isPlayer and context.profile and context.profile.about then
			local voteUp, voteDown = aggregateVotes(context.profile.about.vote);

			voteUp = voteUp or 0;
			voteDown = voteDown or 0;
			
			if not TRP3_RegisterAbout_AboutPanel_LikeButton:GetFontString() then
				TRP3_RegisterAbout_AboutPanel_LikeButton:SetText("");
			end
			TRP3_RegisterAbout_AboutPanel_LikeButton:SetText(tostring(voteUp));
			if TRP3_RegisterAbout_AboutPanel_LikeButton:GetFontString() then
				TRP3_RegisterAbout_AboutPanel_LikeButton:GetFontString():SetTextColor(1, 1, 1); 
			end

			if not TRP3_RegisterAbout_AboutPanel_DislikeButton:GetFontString() then
				TRP3_RegisterAbout_AboutPanel_DislikeButton:SetText("");
			end
			TRP3_RegisterAbout_AboutPanel_DislikeButton:SetText(tostring(voteDown));
			if TRP3_RegisterAbout_AboutPanel_DislikeButton:GetFontString() then
				TRP3_RegisterAbout_AboutPanel_DislikeButton:GetFontString():SetTextColor(1, 1, 1); 
			end
		end
	end
end

-- Someone vote for your description
local function vote(values, sender)
	local value, fromHash = unpack(values);
	Log.log(("Receive vote from %s: %s (%s)"):format(sender, value, fromHash));
	local about = get("player/about");
	if not about.vote then
		about.vote = {};
	end
	about.vote[fromHash] = value;
	Comm.sendObject(VOTE_MESSAGE_R_PREFIX, value, sender, VOTE_MESSAGE_R_PRIORITY);
	refreshPlayerVoteDisplay();
end

-- Your vote has been registered
local function voteResponse(value, sender)
	local value = tonumber(value);
	if isUnitIDKnown(sender) and hasProfile(sender) and getUnitIDProfile(sender).about then
		getUnitIDProfile(sender).about.vote = value;
		local playerName = unitIDToInfo(sender);
		Utils.message.displayMessage(loc("REG_PLAYER_ABOUT_VOTE_SENDING_OK"):format(playerName));
		if getCurrentPageID() == "player_main" then
			local context = getCurrentContext();
			assert(context, "No context for page player_main !");
			if context.profile == getUnitIDProfile(sender) then
				refreshVoteDisplay(getUnitIDProfile(sender).about);
			end
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- COMPRESSION
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local currentCompressed;

local function getOptimizedData()
	local dataTab = get("player/about");
	-- Optimize : only send the selected template
	local dataToSend = {};
	tcopy(dataToSend, dataTab);
	dataToSend.vote = nil; -- Don't send your votes ...
	-- Don't send data about templates you don't use ...
	local template = dataToSend.TE or 1;
	if template ~= 1 then
		dataToSend.T1 = nil;
	end
	if template ~= 2 then
		dataToSend.T2 = nil;
	end
	return dataToSend;
end

local function compressData()
	local dataTab = getOptimizedData();
	local serial = Utils.serial.serialize(dataTab);
	local compressed = Utils.serial.encodeCompressMessage(serial);

	--	log(("Compressed data : %s / %s (%i%%)"):format(compressed:len(), serial:len(), compressed:len() / serial:len() * 100));
	if compressed:len() < serial:len() then
		currentCompressed = compressed;
	else
		currentCompressed = nil;
	end
end

function TRP3_API.register.player.getAboutExchangeData()
	if currentCompressed ~= nil then
		return currentCompressed;
	else
		return getOptimizedData();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LOGIC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local templatesFunction = {
	showTemplate1,
	showTemplate2
}

local function refreshConsultDisplay(context)
	local dataTab = context.profile.about or Globals.empty;
	local template = dataTab.TE or 1;
	TRP3_RegisterAbout_AboutPanel.isMine = context.isPlayer;
	
	if TRP3_RegisterAbout_AboutPanel_LikeButton then
		TRP3_RegisterAbout_AboutPanel_LikeButton:Hide();
	end
	if TRP3_RegisterAbout_AboutPanel_DislikeButton then
		TRP3_RegisterAbout_AboutPanel_DislikeButton:Hide();
	end

	if context.isPlayer then
		TRP3_RegisterAbout_AboutPanel_DislikeButton:ClearAllPoints();
		if TRP3_RegisterAbout_AboutPanel_LikeButton then
			TRP3_RegisterAbout_AboutPanel_LikeButton:Show();
			TRP3_RegisterAbout_AboutPanel_LikeButton:Disable();
		end
		if TRP3_RegisterAbout_AboutPanel_DislikeButton then
			TRP3_RegisterAbout_AboutPanel_DislikeButton:Show();
			TRP3_RegisterAbout_AboutPanel_DislikeButton:Disable();
			TRP3_RegisterAbout_AboutPanel_DislikeButton:SetPoint("RIGHT", TRP3_RegisterAbout_AboutPanel_LikeButton, "LEFT", -10, 0);
		end
		refreshPlayerVoteDisplay();
	else
		if dataTab ~= Globals.empty then
			dataTab.read = true;
		end
		Events.fireEvent(Events.REGISTER_ABOUT_READ);
		if TRP3_RegisterAbout_AboutPanel_LikeButton then
			TRP3_RegisterAbout_AboutPanel_LikeButton:Show();
			TRP3_RegisterAbout_AboutPanel_LikeButton:Enable();
			TRP3_RegisterAbout_AboutPanel_LikeButton:SetText("");
		end
		if TRP3_RegisterAbout_AboutPanel_DislikeButton then
			TRP3_RegisterAbout_AboutPanel_DislikeButton:Show();
			TRP3_RegisterAbout_AboutPanel_DislikeButton:Enable();
			TRP3_RegisterAbout_AboutPanel_DislikeButton:SetText("");
		end
		refreshVoteDisplay(dataTab);
	end

	assert(type(dataTab) == "table", "Error: Nil about data or not a table.");
	assert(template, "Error: No about template ID.");
	assert(type(templatesFunction[template]) == "function", "Error: no function for about template: " .. tostring(template));

	TRP3_RegisterAbout_AboutPanel.musicURL = dataTab.MU;
	
	local shouldShowMusicButton = dataTab.MU or not context.isPlayer;
	if shouldShowMusicButton then
		TRP3_RegisterAbout_AboutPanel_MusicButton:Show();
		TRP3_RegisterAbout_AboutPanel_MusicButton:ClearAllPoints();
		if context.isPlayer then
			TRP3_RegisterAbout_AboutPanel_MusicButton:SetPoint("RIGHT", TRP3_RegisterAbout_AboutPanel_EditButton, "LEFT", -6, 0);
		else
			TRP3_RegisterAbout_AboutPanel_MusicButton:SetPoint("TOPRIGHT", 15, 37);
		end

		if not dataTab.MU then
			TRP3_RegisterAbout_AboutPanel_MusicButton:SetAlpha(0);
		else
			TRP3_RegisterAbout_AboutPanel_MusicButton:SetAlpha(1);
		end
	else
		TRP3_RegisterAbout_AboutPanel_MusicButton:Hide();
	end

	TRP3_RegisterAbout_AboutPanel_EditButton:Hide();
	TRP3_RegisterAbout_AboutPanel:Show();
	-- Putting the right templates
	templatesFunction[template](dataTab);
	-- Putting the righ background
	setConsultBkg(dataTab.BK);
end

function saveInDraft()
	assert(type(draftData) == "table", "Error: Nil draftData or not a table.");
	draftData.BK = TRP3_RegisterAbout_Edit_BckField:GetSelectedValue();
	draftData.TE = TRP3_RegisterAbout_Edit_TemplateField:GetSelectedValue();
	draftData.T1.TX = TRP3_RegisterAbout_Edit_Template1ScrollText:GetText();
end

local function setEditTemplate(value)
	TRP3_RegisterAbout_Edit_Template1:Hide();
	TRP3_RegisterAbout_Edit_Template2:Hide();

	for _, frame in pairs(template2EditFrames) do
		frame:Hide();
	end
	
	_G["TRP3_RegisterAbout_Edit_Template"..value]:Show();
	draftData.TE = value;

	if value == 2 then
		refreshTemplate2EditDisplay();
	end
end

local function save()
	saveInDraft();

	local dataTab = get("player/about");
	assert(type(dataTab) == "table", "Error: Nil about data or not a table.");
	wipe(dataTab);

	tcopy(dataTab, draftData);

	if dataTab.vote then
		wipe(dataTab.vote);
	end
	dataTab.vote = nil;

	assert(type(dataTab.v) == "number", "Error: No version in draftData or not a number.");
	dataTab.v = Utils.math.incrementNumber(dataTab.v, 2);

	compressData();
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getCurrentContext().profileID, "about");
end

local function refreshEditDisplay()
	if not draftData then
		local dataTab = get("player/about");
		assert(type(dataTab) == "table", "Error: Nil about data or not a table.");
		draftData = {};
		tcopy(draftData, dataTab);
	end

	TRP3_RegisterAbout_Edit_BckField:SetSelectedIndex(draftData.BK or 1);
	TRP3_RegisterAbout_Edit_TemplateField:SetSelectedIndex(draftData.TE or 1);
	-- Template 1
	local template1Data = draftData.T1;
	assert(type(template1Data) == "table", "Error: Nil template1 data or not a table.");
	TRP3_RegisterAbout_Edit_Template1ScrollText:SetText(template1Data.TX or "");

	if not draftData.T2 then
		draftData.T2 = {};
	end
	if not draftData.T2.items then
		draftData.T2.items = {};
	end
	for i, item in ipairs(draftData.T2.items) do
		if not item.id then
			local timestamp = GetTime() * 1000 + i;
			item.id = item.type .. "_" .. math.floor(timestamp);
		end
	end

	if #draftData.T2.items == 0 then
		local timestamp = GetTime() * 1000;
		draftData.T2.items = {
			{id = "header_" .. math.floor(timestamp), type = "header", text = "About Me", color = {r = 1, g = 0.75, b = 0}},
			{id = "section_" .. math.floor(timestamp + 1), type = "section", text = "Write your character description here.", icon = nil}
		};
	end
	local template2Data = draftData.T2;

	TRP3_RegisterAbout_AboutPanel_Edit:Show();
	setEditTemplate(draftData.TE or 1);
end

local function refreshDisplay()
	local context = getCurrentContext();
	assert(context, "No context for page player_main !");
	assert(context.profile, "No profile in context");

	TRP3_RegisterAbout_AboutPanel_Template1:Hide();
	TRP3_RegisterAbout_AboutPanel_Template2:Hide();
	TRP3_RegisterAbout_AboutPanel_Empty:Hide();
	TRP3_RegisterAbout_AboutPanel:Hide();
	TRP3_RegisterAbout_AboutPanel_Edit:Hide();

	if context.isEditMode then
		assert(context.isPlayer, "Trying to show About edition for another than mine ...");
		refreshEditDisplay();
	else
		refreshConsultDisplay(context);
	end
end

local function showAboutTab()
	TRP3_RegisterAbout:Show();
	getCurrentContext().isEditMode = false;
	refreshDisplay();
end
TRP3_API.register.ui.showAboutTab = showAboutTab;

local function onEdit()
	if draftData then
		wipe(draftData);
		draftData = nil;
	end
	getCurrentContext().isEditMode = true;
	refreshDisplay();
end

function TRP3_API.register.ui.shouldShowAboutTab(profile)
	if profile and profile.about then
		local dataTab = profile.about;
		return (dataTab.TE == 1 and shouldShowTemplate1(dataTab))
		or (dataTab.TE == 2 and shouldShowTemplate2(dataTab));
	end
	return false;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- MUSIC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onMusicSelected(music)
	draftData.MU = music;
end

local function onMusicEditSelected(value, button)
	if value == 1 then
		TRP3_API.popup.showMusicBrowser(onMusicSelected);
	elseif value == 2 and draftData.MU then
		draftData.MU = nil;
	elseif value == 3 and draftData.MU then
		Utils.music.play(draftData.MU);
	elseif value == 4 and draftData.MU then
		Utils.music.stop();
	end
end

local function onMusicEditClicked(button)
	local profileID = button:GetParent().profileID;
	local values = {};
	
	-- current track is in dropdown instead
	tinsert(values, {getCurrentMusicInfo()});
	tinsert(values, {loc("REG_PLAYER_ABOUT_MUSIC_SELECT"), 1});
	if draftData.MU then
		tinsert(values, {loc("REG_PLAYER_ABOUT_MUSIC_REMOVE"), 2});
		tinsert(values, {loc("REG_PLAYER_ABOUT_MUSIC_LISTEN"), 3});
		tinsert(values, {loc("REG_PLAYER_ABOUT_MUSIC_STOP"), 4});
	end
	displayDropDown(button, values, onMusicEditSelected, 0, true);
end

local function getUnitIDTheme(unitID)
	if unitID == Globals.player_id then
		return get("player/about/MU");
	elseif isUnitIDKnown(unitID) and hasProfile(unitID) and getUnitIDProfile(unitID).about then
		return getUnitIDProfile(unitID).about.MU;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI MISC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TRP3_RegisterAbout_AboutPanel_EditButton = TRP3_RegisterAbout_AboutPanel_EditButton;
local TRP3_RegisterAbout_AboutPanel_MusicButton = TRP3_RegisterAbout_AboutPanel_MusicButton;

local function onPlayerAboutRefresh()
	local profile = getCurrentContext().profile;
	if TRP3_RegisterAbout_AboutPanel.isMine then
		TRP3_RegisterAbout_AboutPanel_EditButton:Show();
	else
		TRP3_RegisterAbout_AboutPanel_EditButton:Hide();
	end
end

local function onSave()
	save();
	showAboutTab();
end

local function onAboutReceived(profileID)
	local aboutData = getProfile(profileID);
	-- Check that there is a description. If not => set read to true !
	local noDescr = (aboutData.TE == 1 and not shouldShowTemplate1(aboutData)) or
	                (aboutData.TE == 2 and not shouldShowTemplate2(aboutData))
	if noDescr then
		aboutData.read = true;
		Events.fireEvent(Events.REGISTER_ABOUT_READ);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
	if TRP3_API.target then
		TRP3_API.target.registerButton({
			id = "aa_player_b_music",
			onlyForType = TRP3_API.ui.misc.TYPE_CHARACTER,
			configText = loc("TF_PLAY_THEME"),
			condition = function(targetType, unitID)
				return getUnitIDTheme(unitID) ~= nil;
			end,
			onClick = function(unitID, _, button)
				if button == "LeftButton" then
					Utils.music.play(getUnitIDTheme(unitID));
				else
					Utils.music.stop();
				end
			end,
			adapter = function(buttonStructure, unitID)
				local theme = getUnitIDTheme(unitID);
				if theme then
					buttonStructure.tooltipSub = loc("TF_PLAY_THEME_TT"):format(Utils.music.getTitle(theme));
				end
			end,
			tooltip = loc("TF_PLAY_THEME"),
			icon = "inv_misc_drum_06"
		});
	end
end);

function TRP3_API.register.inits.aboutInit()
	Comm.registerProtocolPrefix(VOTE_MESSAGE_PREFIX, vote);
	Comm.registerProtocolPrefix(VOTE_MESSAGE_R_PREFIX, voteResponse);

	createRefreshOnFrame(TRP3_RegisterAbout_AboutPanel, 0.2, onPlayerAboutRefresh);
	local bkgTab = getTiledBackgroundList();
	setupListBox(TRP3_RegisterAbout_Edit_BckField, bkgTab, setEditBkg, nil, 120, true);
	setupListBox(TRP3_RegisterAbout_Edit_TemplateField, {{"Template 1", 1}, {"Template 2", 2}}, setEditTemplate, nil, 120, true);
	TRP3_RegisterAbout_Edit_Music_Action:SetScript("OnClick", onMusicEditClicked);
	TRP3_RegisterAbout_AboutPanel_EditButton:SetScript("OnClick", onEdit);
	TRP3_RegisterAbout_Edit_SaveButton:SetScript("OnClick", onSave);
	TRP3_RegisterAbout_Edit_CancelButton:SetScript("OnClick", showAboutTab);

	TRP3_RegisterAbout_AboutPanel_Empty:SetText(loc("REG_PLAYER_ABOUT_EMPTY"));
	TRP3_API.ui.text.setupToolbar("TRP3_RegisterAbout_Edit_Template1_Toolbar", TRP3_RegisterAbout_Edit_Template1ScrollText);

	TRP3_RegisterAbout_Edit_Template2:Hide();
	
	TRP3_RegisterAbout_Edit_Template2_AddHeader:SetScript("OnClick", function()
		addTemplate2Item("header");
	end);
	TRP3_RegisterAbout_Edit_Template2_AddSection:SetScript("OnClick", function()
		addTemplate2Item("section");
	end);

	TRP3_RegisterAbout_AboutPanel_Template1:SetScript("OnHyperlinkClick", onLinkClicked);
	TRP3_RegisterAbout_AboutPanel_Template1:SetScript("OnHyperlinkEnter", function(self, link, text)
		TRP3_MainTooltip:Hide();
		TRP3_MainTooltip:SetOwner(TRP3_RegisterAbout_AboutPanel, "ANCHOR_CURSOR");
		TRP3_MainTooltip:AddLine(text, 1, 1, 1, true);
		TRP3_MainTooltip:AddLine(link, 1, 1, 1, true);
		TRP3_MainTooltip:Show();
	end);
	TRP3_RegisterAbout_AboutPanel_Template1:SetScript("OnHyperlinkLeave", function() TRP3_MainTooltip:Hide(); end);

	TRP3_RegisterAbout_AboutPanel_EditButton:SetText(loc("CM_EDIT"));
	TRP3_RegisterAbout_Edit_SaveButton:SetText(loc("CM_SAVE"));
	TRP3_RegisterAbout_Edit_CancelButton:SetText(loc("CM_CANCEL"));

	TRP3_RegisterAbout_AboutPanel_Template1:SetFontObject("p", GameFontNormal);
	TRP3_RegisterAbout_AboutPanel_Template1:SetFontObject("h1", GameFontNormalHuge3);
	TRP3_RegisterAbout_AboutPanel_Template1:SetFontObject("h2", GameFontNormalHuge);
	TRP3_RegisterAbout_AboutPanel_Template1:SetFontObject("h3", GameFontNormalLarge);
	TRP3_RegisterAbout_AboutPanel_Template1:SetTextColor("h1", 1, 1, 1);
	TRP3_RegisterAbout_AboutPanel_Template1:SetTextColor("h2", 1, 1, 1);
	TRP3_RegisterAbout_AboutPanel_Template1:SetTextColor("h3", 1, 1, 1);

	if TRP3_RegisterAbout_AboutPanel_LikeButton then
		if TRP3_RegisterAbout_AboutPanel_LikeButton:GetName() then
			setTooltipForSameFrame(TRP3_RegisterAbout_AboutPanel_LikeButton, "LEFT", 0, 5, loc("REG_PLAYER_ABOUT_VOTE_UP"), loc("REG_PLAYER_ABOUT_VOTE_TT") .. "\n\n" .. Utils.str.color("y") .. loc("REG_PLAYER_ABOUT_VOTE_TT2"));
		end

		if not TRP3_RegisterAbout_AboutPanel_LikeButton:GetFontString() then
			local fontString = TRP3_RegisterAbout_AboutPanel_LikeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
			fontString:SetPoint("LEFT", TRP3_RegisterAbout_AboutPanel_LikeButton, "LEFT", -7, 1);
			TRP3_RegisterAbout_AboutPanel_LikeButton:SetFontString(fontString);
		end
		
		TRP3_RegisterAbout_AboutPanel_LikeButton:SetScript("OnClick", function() 
			local context = getCurrentContext();
			if context and not context.isPlayer then
				showVotingOption(1);
			end
		end);
	end
	
	if TRP3_RegisterAbout_AboutPanel_DislikeButton then
		if TRP3_RegisterAbout_AboutPanel_DislikeButton:GetName() then
			setTooltipForSameFrame(TRP3_RegisterAbout_AboutPanel_DislikeButton, "LEFT", 0, 5, loc("REG_PLAYER_ABOUT_VOTE_DOWN"), loc("REG_PLAYER_ABOUT_VOTE_TT") .. "\n\n" .. Utils.str.color("y") .. loc("REG_PLAYER_ABOUT_VOTE_TT2"));
		end

		if not TRP3_RegisterAbout_AboutPanel_DislikeButton:GetFontString() then
			local fontString = TRP3_RegisterAbout_AboutPanel_DislikeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
			fontString:SetPoint("LEFT", TRP3_RegisterAbout_AboutPanel_DislikeButton, "LEFT", -7, 1);
			TRP3_RegisterAbout_AboutPanel_DislikeButton:SetFontString(fontString);
		end
		
		TRP3_RegisterAbout_AboutPanel_DislikeButton:SetScript("OnClick", function() 
			local context = getCurrentContext();
			if context and not context.isPlayer then
				showVotingOption(-1);
			end
		end);
	end

	if TRP3_RegisterAbout_AboutPanel_MusicButton then
		TRP3_RegisterAbout_AboutPanel_MusicButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		TRP3_RegisterAbout_AboutPanel_MusicButton:SetScript("OnClick", function(self, button)
			if TRP3_RegisterAbout_AboutPanel.musicURL then
				if button == "LeftButton" then
					Utils.music.play(TRP3_RegisterAbout_AboutPanel.musicURL);
				elseif button == "RightButton" then
					Utils.music.stop();
				end
			end
		end);

		if TRP3_RegisterAbout_AboutPanel_MusicButton:GetName() then
			setTooltipForSameFrame(TRP3_RegisterAbout_AboutPanel_MusicButton, "LEFT", 0, 5, 
				loc("REG_PLAYER_ABOUT_MUSIC"), 
				loc("CM_L_CLICK") .. ": " .. loc("CM_PLAY") .. "\n" .. loc("CM_R_CLICK") .. ": " .. loc("CM_STOP"));
		end
	end

	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, compressData); -- On profile change, compress the new data
	compressData();

	Events.listenToEvent(Events.REGISTER_DATA_UPDATED, function(unitID, profileID, dataType)
		if dataType == "about" and unitID and unitID ~= Globals.player_id then
			onAboutReceived(profileID);
		end
	end);
	
	local function createSampleTemplate2Data()
		if not draftData then
			onEdit();
		end
		
		if not draftData.T2 then
			draftData.T2 = { items = {} };
		end
		
		wipe(draftData.T2.items);
		
		tinsert(draftData.T2.items, {
			id = "sample_header_1",
			type = "header",
			text = "Character Background",
			color = { red = 1, green = 0.8, blue = 0.2 }
		});
		
		tinsert(draftData.T2.items, {
			id = "sample_section_1",
			type = "section",
			text = "Born in the misty mountains of Dun Morogh, this dwarf has seen many adventures across Azeroth. From the frozen peaks of Northrend to the burning sands of Tanaris, countless tales could be told of valor and friendship.",
			icon = "Achievement_Character_Dwarf_Male"
		});

		tinsert(draftData.T2.items, {
			id = "sample_header_2",
			type = "header",
			text = "Recent Adventures",
			color = { red = 0.2, green = 1, blue = 0.4 }
		});

		tinsert(draftData.T2.items, {
			id = "sample_section_2",
			type = "section",
			text = "Recently returned from a expedition to the Dragon Isles, bringing back ancient artifacts and stories of magnificent dragons. Currently seeking new allies for future adventures.",
			icon = "Achievement_Dungeon_DragonSoulRaid_KillDeathwing"
		});

		draftData.TE = 2;
		TRP3_RegisterAbout_Edit_TemplateField:SetSelectedValue(2);
		setEditTemplate(2);

		refreshTemplate2EditDisplay();
		
		Utils.message.displayMessage("Sample Template 2 data created! You can now test the display and edit features.");
	end

	TRP3_API.CreateSampleTemplate2Data = createSampleTemplate2Data;
end