----------------------------------------------------------------------------------
-- Total RP 3
-- Map marker and coordinates system
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

TRP3_API.map = {};

local Utils, Events, Globals = TRP3_API.utils, TRP3_API.events, TRP3_API.globals;
local Comm = TRP3_API.communication;
local setupIconButton = TRP3_API.ui.frame.setupIconButton;
local displayDropDown = TRP3_API.ui.listbox.displayDropDown;
local loc = TRP3_API.locale.getText;
local tinsert, assert, tonumber, pairs, _G, wipe = tinsert, assert, tonumber, pairs, _G, wipe;
local CreateFrame = CreateFrame;

local after = C_Timer.After;
local playAnimation = TRP3_API.ui.misc.playAnimation;
local tsize = Utils.table.size;
local getConfigValue = TRP3_API.configuration.getValue;

local CONFIG_UI_ANIMATIONS = "ui_animations";
local CONFIG_MAP_MARKERS_HIGH_STRATA = "register_map_markers_high_strata";
local CONFIG_MAP_AUTO_SCAN = "register_map_auto_scan";
local CONFIG_MAP_MARKER_ICON_TYPE = "register_map_marker_icon_type";

local TRP3_ScanLoaderFramePercent, TRP3_ScanLoaderFrame = TRP3_ScanLoaderFramePercent, TRP3_ScanLoaderFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local SCAN_STRUCTURES = {};

local function registerScan(structure)
	assert(structure and structure.id, "Must have a structure and a structure.id!");
	SCAN_STRUCTURES[structure.id] = structure;
	if structure.scanResponder and structure.scanCommand then
		Comm.broadcast.registerCommand(structure.scanCommand, structure.scanResponder);
	end
	if structure.scanAssembler and structure.scanCommand then
		if not structure.saveStructure then
			structure.saveStructure = {};
		end
		Comm.broadcast.registerP2PCommand(structure.scanCommand, function(...)
			structure.scanAssembler(structure.saveStructure, ...);
		end)
	end

end
TRP3_API.map.registerScan = registerScan;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Display
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local WorldMapTooltip, WorldMapPOIFrame = WorldMapTooltip, WorldMapPOIFrame;
local MARKER_NAME_PREFIX = "TRP3_WordMapMarker";

local MAX_DISTANCE_MARKER = math.sqrt(0.5 * 0.5 + 0.5 * 0.5);

local function hideAllMarkers()
	local i = 1;
	while(_G[MARKER_NAME_PREFIX .. i]) do
		_G[MARKER_NAME_PREFIX .. i]:Hide();
		i = i + 1;
	end
end

local function displayMarkers(structure)
	if not WorldMapFrame:IsVisible() then
		return;
	end

	local count = tsize(structure.saveStructure);
	local i = 1;
	for key, entry in pairs(structure.saveStructure) do
		local marker = _G[MARKER_NAME_PREFIX .. i];
		if not marker then
			marker = CreateFrame("Frame", MARKER_NAME_PREFIX .. i, WorldMapButton, "TRP3_WorldMapUnit");
			
			-- map icon strata
			if getConfigValue(CONFIG_MAP_MARKERS_HIGH_STRATA) then
				marker:SetFrameStrata("HIGH");
			end
			
			marker:SetScript("OnEnter", function(self)
				WorldMapPOIFrame.allowBlobTooltip = false;
				WorldMapTooltip:Hide();
				WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
				WorldMapTooltip:AddLine(structure.scanTitle, 1, 1, 1, true);
				local j = 1;
				while(_G[MARKER_NAME_PREFIX .. j]) do
					local markerWidget = _G[MARKER_NAME_PREFIX .. j];
					if markerWidget:IsVisible() and markerWidget:IsMouseOver() then
						local scanLine = markerWidget.scanLine;
						if scanLine then
							WorldMapTooltip:AddLine(scanLine, 1, 1, 1, true);
						end
					end
					j = j + 1;
				end
				WorldMapTooltip:Show();
			end);

			marker:SetScript("OnLeave", function()
				WorldMapPOIFrame.allowBlobTooltip = true;
				WorldMapTooltip:Hide();
			end);
		end

		local x = (entry.x or 0) * WorldMapDetailFrame:GetWidth();
		local y = - (entry.y or 0) * WorldMapDetailFrame:GetHeight();
		
		marker:ClearAllPoints();
		marker:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", x, y);

		local iconWidget = _G[marker:GetName() .. "Icon"];
		local iconType = getConfigValue(CONFIG_MAP_MARKER_ICON_TYPE) or 1;
		local targetRace = entry.race;
		local targetGender = entry.gender;
		local targetFaction = entry.faction;
		
		-- default icon
		local function setDefaultIcon()
			iconWidget:SetTexture("Interface\\AddOns\\totalRP3\\Resources\\UI\\OBJECTICONS");
			iconWidget:SetTexCoord(0.52734375, 0.6015625, 0.09375, 0.390625);
		end
		
		if iconType == 1 and targetRace and targetGender then
			local raceTexture = TRP3_API.ui.misc.getUnitTexture(targetRace, targetGender);

			if raceTexture then
				iconWidget:SetTexture("Interface\\Icons\\" .. raceTexture);
				iconWidget:SetTexCoord(0, 1, 0, 1);
			else
				setDefaultIcon();
			end
		elseif iconType == 2 and targetFaction == "Alliance" then
			iconWidget:SetTexture("Interface\\AddOns\\totalRP3\\Resources\\UI\\UI-PVP-Alliance");
			iconWidget:SetTexCoord(0.09375, 0.5625, 0.046875, 0.578125);
		elseif iconType == 2 and targetFaction == "Horde" then
			iconWidget:SetTexture("Interface\\AddOns\\totalRP3\\Resources\\UI\\UI-PVP-Horde");
			iconWidget:SetTexCoord(0.09375, 0.53125, 0.046875, 0.5625);
		else
			setDefaultIcon();
		end

		if structure.scanMarkerDecorator then
			structure.scanMarkerDecorator(key, entry, marker);
		end

		if getConfigValue(CONFIG_UI_ANIMATIONS) then
			local distanceX = 0.5 - entry.x;
			local distanceY = 0.5 - entry.y;
			local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY);
			local factor = distance/MAX_DISTANCE_MARKER;

			after(4 * factor, function()
				marker:Show();
				marker:SetAlpha(0);
				playAnimation(_G[marker:GetName() .. "Bounce"]);

				-- Ensure the marker becomes fully visible after animation
				after(1, function()
					marker:SetAlpha(1);
				end);
			end);

		else
			marker:Show();
			marker:SetAlpha(1);
		end
		
		i = i + 1;
	end
end

local function launchScan(scanID)
	assert(SCAN_STRUCTURES[scanID], ("Unknown scan id %s"):format(scanID));
	local structure = SCAN_STRUCTURES[scanID];
	if structure.scan then
		hideAllMarkers();
		wipe(structure.saveStructure);
		structure.scan();
		if structure.scanDuration and structure.scanComplete then
			local mapID = GetCurrentMapAreaID();
			TRP3_WorldMapButton:Disable();
			setupIconButton(TRP3_WorldMapButton, "INV_MISC_ENGGIZMOS_20");
			TRP3_ScanLoaderFrame.time = structure.scanDuration;
			TRP3_ScanLoaderFrame:Show();
			TRP3_ScanLoaderAnimationRotation:SetDuration(structure.scanDuration);
			TRP3_ScanLoaderGlowRotation:SetDuration(structure.scanDuration);
			TRP3_ScanLoaderBackAnimation1Rotation:SetDuration(structure.scanDuration);
			TRP3_ScanLoaderBackAnimation2Rotation:SetDuration(structure.scanDuration);
			playAnimation(TRP3_ScanLoaderAnimation);
			playAnimation(TRP3_ScanFadeIn);
			playAnimation(TRP3_ScanLoaderGlow);
			playAnimation(TRP3_ScanLoaderBackAnimation1);
			playAnimation(TRP3_ScanLoaderBackAnimation2);
			TRP3_API.ui.misc.playSoundKit(40216);
			after(structure.scanDuration, function()
				TRP3_WorldMapButton:Enable();
				setupIconButton(TRP3_WorldMapButton, "INV_MISC_ENGGIZMOS_20");
				if mapID == GetCurrentMapAreaID() then
					structure.scanComplete(structure.saveStructure);
					displayMarkers(structure);
				end
				playAnimation(TRP3_ScanLoaderBackAnimationGrow1);
				playAnimation(TRP3_ScanLoaderBackAnimationGrow2);
				playAnimation(TRP3_ScanFadeOut);
				TRP3_API.ui.misc.playSoundKit(43493);
				if getConfigValue(CONFIG_UI_ANIMATIONS) then
					after(1, function()
						TRP3_ScanLoaderFrame:Hide();
						TRP3_ScanLoaderFrame:SetAlpha(1);
					end);
				else
					TRP3_ScanLoaderFrame:Hide();
				end
			end);
		end
	end
end
TRP3_API.map.launchScan = launchScan;

local function onButtonClicked(self)
	-- Directly launch the character scan instead of showing dropdown
	local playerScanStructure = SCAN_STRUCTURES["playerScan"];
	if playerScanStructure and (not playerScanStructure.canScan or playerScanStructure.canScan() == true) then
		launchScan("playerScan");
	end
end

local currentMapID;

local function onWorldMapUpdate()
	local mapID = GetCurrentMapAreaID();
	
	if currentMapID ~= mapID and not TRP3_WorldMapButton.doNotHide then
		currentMapID = mapID;
		hideAllMarkers();
	end
end

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOAD, function()
	setupIconButton(TRP3_WorldMapButton, "INV_MISC_ENGGIZMOS_20");
	TRP3_WorldMapButton.title = loc("MAP_BUTTON_TITLE");
	TRP3_WorldMapButton.subtitle = "|cffff9900" .. loc("MAP_BUTTON_SUBTITLE");
	TRP3_WorldMapButton:SetScript("OnClick", onButtonClicked);
	-- 3.3.5 compatibility: Set font before SetText to avoid "Font not set" error
	TRP3_ScanLoaderFrameScanning:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
	TRP3_ScanLoaderFrameScanning:SetText(loc("MAP_BUTTON_SCANNING"));
	TRP3_ScanLoaderFrameScanning:SetTextColor(1, 0.82, 0); -- Gold color

	TRP3_ScanLoaderFrame:SetScript("OnShow", function(self)
		self.refreshTimer = 0;
	end);
	TRP3_ScanLoaderFrame:SetScript("OnUpdate", function(self, elapsed)
		self.refreshTimer = self.refreshTimer + elapsed;
		local percent = math.ceil((self.refreshTimer / self.time) * 100);
		-- TRP3_ScanLoaderFramePercent:SetText(percent .. "%");
	end);

	Utils.event.registerHandler("WORLD_MAP_UPDATE", onWorldMapUpdate);
	
	-- auto-scan functionality
	local originalWorldMapFrameShow = WorldMapFrame.Show;
	WorldMapFrame.Show = function(self)
		originalWorldMapFrameShow(self);
		
		if getConfigValue(CONFIG_MAP_AUTO_SCAN) then
			local playerScanStructure = SCAN_STRUCTURES["playerScan"];
			if playerScanStructure and (not playerScanStructure.canScan or playerScanStructure.canScan() == true) then
				after(0.5, function()
					launchScan("playerScan");
				end);
			end
		end
	end;
end);