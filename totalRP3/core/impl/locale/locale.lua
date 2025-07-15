----------------------------------------------------------------------------------
-- Total RP 3
-- Locale system
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

TRP3_API.locale = {}

-- Bindings locale
BINDING_HEADER_TRP3 = "Total RP 3";
local BINDINGS_KEYS = {
	"BINDING_NAME_TRP3_TOGGLE",
	"BINDING_NAME_TRP3_TOOLBAR_TOGGLE"
}

local error, pairs, tinsert, assert, table, tostring, GetLocale = error, pairs, tinsert, assert, table, tostring, GetLocale;
local getText;

local LOCALS = {};
local DEFAULT_LOCALE = "enUS";
local effectiveLocal = {};
local current;
local localeFont;

function TRP3_API.locale.getLocaleFont()
	return localeFont;
end

function TRP3_API.locale.registerLocale(localeStructure)
	assert(localeStructure and localeStructure.locale and localeStructure.localeText and localeStructure.localeContent, "Usage: localeStructure with locale, localeText and localeContent.");
	if not LOCALS[localeStructure.locale] then
		LOCALS[localeStructure.locale] = localeStructure;
	end
end

-- Initialize a locale for the addon.
function TRP3_API.locale.init()
	-- Register config
	TRP3_API.configuration.registerConfigKey("AddonLocale", GetLocale());
	current = TRP3_API.configuration.getValue("AddonLocale");
	if not LOCALS[current] then
		current = DEFAULT_LOCALE;
	end
	-- Pick the right font
	if current == "zhCN" then
		localeFont = "Fonts\\ZYKai_T.TTF";
	elseif current == "ruRU" then
		localeFont = "Fonts\\FRIZQT___CYR.TTF";
	else
		localeFont = "Fonts\\FRIZQT__.TTF";
	end
	effectiveLocal = LOCALS[current].localeContent;
	for _, bindingKey in pairs(BINDINGS_KEYS) do

	end
	BINDING_NAME_TRP3_TOGGLE = effectiveLocal["BINDING_NAME_TRP3_TOGGLE"] or LOCALS[DEFAULT_LOCALE].localeContent["BINDING_NAME_TRP3_TOGGLE"];
	BINDING_NAME_TRP3_TOOLBAR_TOGGLE = effectiveLocal["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] or LOCALS[DEFAULT_LOCALE].localeContent["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"];
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Current locale utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Get a sorted list of registered locales ID ("frFR", "enUS" ...).
function TRP3_API.locale.getLocales()
	local locales = {};
	for locale,_ in pairs(LOCALS) do
		tinsert(locales, locale);
	end
	table.sort(locales);
	return locales;
end

-- Get the display name of a locale ("Français", "English" ...)
function TRP3_API.locale.getLocaleText(locale)
	if LOCALS[locale] then
		return LOCALS[locale].localeText
	end
	return UNKNOWN;
end

function TRP3_API.locale.getEffectiveLocale()
	return effectiveLocal;
end

function TRP3_API.locale.getDefaultLocaleStructure()
	return LOCALS[DEFAULT_LOCALE];
end

function TRP3_API.locale.getCurrentLocale()
	return current;
end

function TRP3_API.locale.getLocale(localeID)
	assert(LOCALS[localeID], "Unknown locale: " .. localeID);
	return LOCALS[localeID];
end

--	Return the localized text link to this key.
--	If the key isn't present in the current Locals table, then return the default localization.
--	If the key is totally unknown from TRP3, then an error will be lifted.
function getText(key)
	if effectiveLocal[key] or LOCALS[DEFAULT_LOCALE].localeContent[key] then
		return effectiveLocal[key] or LOCALS[DEFAULT_LOCALE].localeContent[key];
	end
	error("Unknown localization key: ".. tostring(key));
end
TRP3_API.locale.getText = getText;

