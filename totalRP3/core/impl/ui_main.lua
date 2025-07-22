----------------------------------------------------------------------------------
-- Total RP 3
-- Main UI API and Widgets API
--	---------------------------------------------------------------------------
--	Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--  Copyright 2014 Renaud Parize (Ellypse) (renaud@parize.me)
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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Minimap button widget
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Config
local displayMessage = TRP3_API.utils.message.displayMessage;
local CONFIG_MINIMAP_SHOW = "minimap_show";
local CONFIG_MINIMAP_POSITION = "minimap_icon_position";
local getConfigValue, registerConfigKey = TRP3_API.configuration.getValue, TRP3_API.configuration.registerConfigKey;
local color, loc, strconcat = TRP3_API.utils.str.color, TRP3_API.locale.getText, strconcat;

-- Minimap button API initialization
TRP3_API.navigation.minimapicon = {};

local LDBObject;
local icon;

-- Initialize LDBIcon and display the minimap button
local showMinimapButton = function()
	icon:Show("Total RP 3");
end
TRP3_API.navigation.minimapicon.show = showMinimapButton;

-- Hide the minimap button and release LDBIcon from the memory
local hideMinimapButton = function()
	icon:Hide("Total RP 3");
end
TRP3_API.navigation.minimapicon.hide = hideMinimapButton;

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()


	registerConfigKey(CONFIG_MINIMAP_SHOW, true);
	registerConfigKey(CONFIG_MINIMAP_POSITION, {});

	-- Build configuration page
	tinsert(TRP3_API.configuration.CONFIG_FRAME_PAGE.elements, {
		inherit = "TRP3_ConfigH1",
		title = loc("CO_MINIMAP_BUTTON"),
	});
	tinsert(TRP3_API.configuration.CONFIG_FRAME_PAGE.elements, {
		inherit = "TRP3_ConfigCheck",
		title = loc("CO_MINIMAP_BUTTON_SHOW_TITLE"),
		help = loc("CO_MINIMAP_BUTTON_SHOW_HELP"),
		configKey = CONFIG_MINIMAP_SHOW,
	});

	TRP3_API.configuration.registerHandler(CONFIG_MINIMAP_SHOW, function()
		local shouldShow = getConfigValue(CONFIG_MINIMAP_SHOW);
		local positionDB = getConfigValue(CONFIG_MINIMAP_POSITION);
		
		positionDB.hide = not shouldShow;
		
		if icon then
			icon:Refresh("Total RP 3");
		end
	end);

	local minimapTooltip = strconcat(color("y"), loc("CM_L_CLICK"), ": ", color("w"), loc("MM_SHOW_HIDE_MAIN"));
	if TRP3_API.toolbar then
		minimapTooltip = strconcat(minimapTooltip, "\n", color("y"), loc("CM_R_CLICK"), ": ", color("w"), loc("MM_SHOW_HIDE_SHORTCUT"));
	end
	minimapTooltip = strconcat(minimapTooltip, "\n", color("y"), loc("CM_DRAGDROP"), ": ", color("w"), loc("MM_SHOW_HIDE_MOVE"));

	LDBObject = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Total RP 3", {
		type = "launcher",
		icon = "Interface\\AddOns\\totalRP3\\resources\\trp3minimap.tga",
		tocname = "totalRP3",
		OnClick = function(clickedframe, button)
			if button == "RightButton" and TRP3_API.toolbar then
				TRP3_API.toolbar.switch();
			else
				TRP3_API.navigation.switchMainFrame();
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("Total RP 3");
			tooltip:AddLine(minimapTooltip);
		end,
	})

	icon = LibStub("LibDBIcon-1.0");
	local iconConfig = getConfigValue(CONFIG_MINIMAP_POSITION);
	if iconConfig.hide == nil then
		iconConfig.hide = not getConfigValue(CONFIG_MINIMAP_SHOW);
	end
	icon:Register("Total RP 3", LDBObject, iconConfig);

	-- Slash command to switch frames
	TRP3_API.slash.registerCommand({
		id = "switch",
		helpLine = " main || toolbar",
		handler = function(arg1)
			if arg1 ~= "main" and arg1 ~= "toolbar" then
				displayMessage(loc("COM_SWITCH_USAGE"));
			elseif arg1 == "main" then
				TRP3_API.navigation.switchMainFrame();
			else
				if TRP3_API.toolbar then
					TRP3_API.toolbar.switch();
				end
			end
		end
	});

	-- Slash command to reset frames
	TRP3_API.slash.registerCommand({
		id = "reset",
		helpLine = " frames",
		handler = function(arg1)
			if arg1 ~= "frames" then
				displayMessage(loc("COM_RESET_USAGE"));
			else
				-- Target frame
				if TRP3_API.target then
					TRP3_API.target.reset();
				end
				-- Glance bar
				if TRP3_API.register.resetGlanceBar then
					TRP3_API.register.resetGlanceBar();
				end
				-- Toolbar
				if TRP3_API.toolbar then
					TRP3_API.toolbar.reset();
				end
				ReloadUI();
			end
		end
	});
end);