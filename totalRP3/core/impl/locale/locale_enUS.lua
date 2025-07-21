----------------------------------------------------------------------------------
-- Total RP 3
-- English locale (default locale)
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

local LOCALE_EN = {
	locale = "enUS",
	localeText = "English",
	localeContent = {
	
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- GENERAL
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		GEN_WELCOME_MESSAGE = "Thank you for using Total RP 3 (v %s) ! Have fun !",
		GEN_VERSION = "Version: %s (Build %s)",
		GEN_NEW_VERSION_AVAILABLE = "A new version for Total RP 3 is available.\n\n|cffff0000Your version: %s\n|c0000ff00New version: %s|r\n\n|cffff9900We strongly encourage you to stay up-to-date.|r\n\nThis message will only appear once per session and can be disabled in the settings.",
		
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- REGISTER
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		REG_PLAYER = "Character",
		REG_PLAYER_CHANGE_CONFIRM = "You may have unsaved data changes.\nDo you want to change page anyway ?\n|cffff9900Any changes will be lost.",
		REG_PLAYER_CARACT = "You",
		REG_PLAYER_NAMESTITLES = "Name",
		REG_PLAYER_CHARACTERISTICS = "Characteristics",
		REG_PLAYER_REGISTER = "Character Records",
		REG_PLAYER_ICON = "Character's icon",
		REG_PLAYER_ICON_TT = "Select a graphic representation for your character.",
		REG_PLAYER_TITLE = "Title",
		REG_PLAYER_TITLE_TT = "Your character's title is the title by which your character is usually called. Avoid long titles, as for those should you use the Full title attribute bellow.\n\n"
								.."Example of |c0000ff00appropriate titles |r:\n|c0000ff00- Countess,\n- Marquis,\n- Magus,\n- Lord,\n- etc.\n|r"
								.."Example of |cffff0000inappropriate titles|r:\n|cffff0000- Countess of the North Marshes,\n- Magus of the Stormwind Tower,\n- Diplomat for the Draenei Government,\n- etc.",
		REG_PLAYER_FIRSTNAME = "First name",
		REG_PLAYER_FIRSTNAME_TT = "This is your character's first name. This is a mandatory field, so if you don't specify a name, the default character's name (|cffffff00%s|r) will be used."
								.."\n\nYou can use a |c0000ff00nickname |r!",
		REG_PLAYER_LASTNAME = "Last name",
		REG_PLAYER_LASTNAME_TT = "This is your character's family name.",
		REG_PLAYER_HERE = "Get position",
		REG_PLAYER_HERE_TT = "Click to get your current position",
		REG_PLAYER_COLOR_CLASS = "Class color",
		REG_PLAYER_COLOR_CLASS_TT = "This will also determines the name color.\n\n",
		REG_PLAYER_COLOR_TT = "|cffffff00Click:|r Select a color\n|cffffff00Right-click:|r Discard color",
		REG_PLAYER_FULLTITLE = "Full title",
		REG_PLAYER_FULLTITLE_TT = "Here you can write down your character's full title. It can either be a longer version of the Title or another title entirely.\n\nHowever, you may want to avoid repetitions, in case there's no additional info to mention.",
		REG_PLAYER_RACE = "Race",
		REG_PLAYER_RACE_TT = "Here goes your character's race. It doesn't have to be restricted to playable races. There are many Warcraft races that can assume common shapes ...",
		REG_PLAYER_BKG = "Background layout",
		REG_PLAYER_BKG_TT = "This represents the graphical background to use for your Characteristics layout.",
		REG_PLAYER_CLASS = "Class",
		REG_PLAYER_CLASS_TT = "This is your character's custom class.\n\n|cff00ff00For instance :|r\nKnight, Pyrotechnist, Necromancer, Elite shooter, Arcanist ...",
		REG_PLAYER_AGE = "Age",
		REG_PLAYER_AGE_TT = "Here you can indicate how old your character is.\n\nThere are several way to do this:|c0000ff00\n- Either use years,\n- Or an adjective (Young, Mature, Adult, Venerable, etc.).",
		REG_PLAYER_EYE = "Eye color",
		REG_PLAYER_EYE_TT = "Here your can indicate the color of your character's eyes.\n\nKeep in mind that, even if your character's face is constantly hidden, that might still be worth mentioning, just in case.",
		REG_PLAYER_HEIGHT = "Height",
		REG_PLAYER_HEIGHT_TT = "This is your character's height.\nThere are several way to do this:|c0000ff00\n- A precise number: 170 cm, 6'5\" ...\n- A qualificative: Tall, short ...",
		REG_PLAYER_WEIGHT = "Body shape",
		REG_PLAYER_WEIGHT_TT = "This is your character's body shape.\nFor instance they could be |c0000ff00slim, fat or muscular...|r Or they could simply be regular !",
		REG_PLAYER_BIRTHPLACE = "Birthplace",
		REG_PLAYER_BIRTHPLACE_TT = "Here you can indicate the birthplace of your character. This can either be a region, a zone, or even a continent. It's for you to decide how accurate you want to be.\n\n"
									.."|c00ffff00You can use the button to the right to easily set your current location as Birthplace.",
		REG_PLAYER_RESIDENCE = "Residence",
		REG_PLAYER_RESIDENCE_TT = "Here you can indicate where you character normally lives. This could be their personal address (their home) or a place they can crash."
									.."\nNote that if your character is a wanderer or even homeless, you will need to change the information accordingly.\n\n|c00ffff00You can use the button to the right to easily set your current location as Residence.",
		REG_PLAYER_MSP_MOTTO = "Motto",
		REG_PLAYER_MSP_HOUSE = "House name",
		REG_PLAYER_MSP_NICK = "Nickname",
		REG_PLAYER_TRP2_TRAITS = "Physiognomy",
		REG_PLAYER_TRP2_PIERCING = "Piercings",
		REG_PLAYER_TRP2_TATTOO = "Tattoos",
		REG_PLAYER_OTHER = "Personality traits",
		REG_PLAYER_ADD_NEW = "Create new",
		REG_PLAYER_HISTORY = "History",
		REG_PLAYER_MORE_INFO = "Extended character records",
		REG_PLAYER_PHYSICAL = "Personality & Physical",
		REG_PLAYER_NO_CHAR = "No characteristics",
		REG_PLAYER_SHOWPSYCHO = "Show personality frame",
		REG_PLAYER_SHOWPSYCHO_TT = "Check if you want to use the personality description.\n\nIf you don't want to indicate your character's personality this way, keep this box unchecked and the personality frame will remain totally hidden.",
		REG_PLAYER_PSYCHO_ADD = "Add a personality trait",
		REG_PLAYER_PSYCHO_POINT = "Add a point",
		REG_PLAYER_PSYCHO_MORE = "Add a point to \"%s\"",
		REG_PLAYER_PSYCHO_ATTIBUTENAME_TT = "Attribute name",
		REG_PLAYER_PSYCHO_RIGHTICON_TT = "Set the right attribute icon.",
		REG_PLAYER_PSYCHO_LEFTICON_TT = "Set the left attribute icon.",
		REG_PLAYER_PSYCHO_SOCIAL = "Social traits",
		REG_PLAYER_PSYCHO_PERSONAL = "Personal traits",
		REG_PLAYER_PSYCHO_CHAOTIC = "Chaotic";
		REG_PLAYER_PSYCHO_Loyal = "Lawful";
		REG_PLAYER_PSYCHO_Chaste = "Chaste";
		REG_PLAYER_PSYCHO_Luxurieux = "Lustful";
		REG_PLAYER_PSYCHO_Indulgent = "Forgiving";
		REG_PLAYER_PSYCHO_Rencunier = "Vindictive";
		REG_PLAYER_PSYCHO_Genereux = "Altruistic";
		REG_PLAYER_PSYCHO_Egoiste = "Selfish";
		REG_PLAYER_PSYCHO_Sincere = "Truthful";
		REG_PLAYER_PSYCHO_Trompeur = "Deceitful";
		REG_PLAYER_PSYCHO_Misericordieux = "Gentle ";
		REG_PLAYER_PSYCHO_Cruel = "Brutal";
		REG_PLAYER_PSYCHO_Pieux = "Superstitious";
		REG_PLAYER_PSYCHO_Pragmatique = "Renegade";
		REG_PLAYER_PSYCHO_Conciliant = "Paragon";
		REG_PLAYER_PSYCHO_Rationnel = "Rational";
		REG_PLAYER_PSYCHO_Reflechi = "Cautious";
		REG_PLAYER_PSYCHO_Impulsif = "Impulsive";
		REG_PLAYER_PSYCHO_Acete = "Ascetic";
		REG_PLAYER_PSYCHO_Bonvivant = "Bon vivant";
		REG_PLAYER_PSYCHO_Valeureux = "Valorous";
		REG_PLAYER_PSYCHO_Couard = "Spineless";
		REG_PLAYER_PSYCHO_CUSTOM = "Custom trait",
		REG_PLAYER_PSYCHO_CREATENEW = "Create a trait",
		-- New trait system localization
		REG_PLAYER_TRAIT_SOCIAL = "Social traits",
		REG_PLAYER_TRAIT_PERSONAL = "Personal traits",
		REG_PLAYER_TRAIT_CHAOTIC = "Chaotic",
		REG_PLAYER_TRAIT_LOYAL = "Lawful",
		REG_PLAYER_TRAIT_CHASTE = "Chaste",
		REG_PLAYER_TRAIT_LUSTFUL = "Lustful",
		REG_PLAYER_TRAIT_FORGIVING = "Forgiving",
		REG_PLAYER_TRAIT_VENGEFUL = "Vindictive",
		REG_PLAYER_TRAIT_GENEROUS = "Generous",
		REG_PLAYER_TRAIT_SELFISH = "Selfish",
		REG_PLAYER_TRAIT_SINCERE = "Sincere",
		REG_PLAYER_TRAIT_DECEPTIVE = "Deceptive",
		REG_PLAYER_TRAIT_MERCIFUL = "Merciful",
		REG_PLAYER_TRAIT_CRUEL = "Cruel",
		REG_PLAYER_TRAIT_SPIRITUAL = "Spiritual",
		REG_PLAYER_TRAIT_RATIONAL = "Rational",
		REG_PLAYER_TRAIT_PRAGMATIC = "Pragmatic",
		REG_PLAYER_TRAIT_DIPLOMATIC = "Diplomatic",
		REG_PLAYER_TRAIT_THOUGHTFUL = "Thoughtful",
		REG_PLAYER_TRAIT_IMPULSIVE = "Impulsive",
		REG_PLAYER_TRAIT_ASCETIC = "Ascetic",
		REG_PLAYER_TRAIT_HEDONISTIC = "Hedonistic",
		REG_PLAYER_TRAIT_VALOROUS = "Valorous",
		REG_PLAYER_TRAIT_COWARDLY = "Cowardly",
		REG_PLAYER_TRAIT_CUSTOM = "Custom trait",
		REG_PLAYER_TRAIT_CREATENEW = "Create a trait",
		-- Warcraft Chronicles Cosmology traits
		REG_PLAYER_TRAIT_COSMIC = "Cosmic traits",
		REG_PLAYER_TRAIT_LIGHT = "Light",
		REG_PLAYER_TRAIT_SHADOW = "Shadow",
		REG_PLAYER_TRAIT_LIFE = "Life",
		REG_PLAYER_TRAIT_DEATH = "Death",
		REG_PLAYER_TRAIT_ORDER = "Order",
		REG_PLAYER_TRAIT_DISORDER = "Disorder",
		REG_PLAYER_LEFTTRAIT = "Left attribute",
		REG_PLAYER_RIGHTTRAIT = "Right attribute",
		REG_DELETE_WARNING = "Are you sure you want to delete %s's profile?\n",
		REG_IGNORE_TOAST = "Character ignored",
		REG_PLAYER_IGNORE = "Ignore linked characters (%s)",
		REG_PLAYER_IGNORE_WARNING = "Do you want to ignore those characters ?\n\n|cffff9900%s\n\n|rYou can optionally enter the reason below. This is a personal note that will serve as reminder.",
		REG_PLAYER_SHOWMISC = "Show miscellaneous frame",
		REG_PLAYER_SHOWMISC_TT = "Check if you want to show custom fields for your character.\n\nIf you don't want to show custom fields, keep this box unchecked and the miscellaneous frame will remain totally hidden.",
		REG_PLAYER_MISC_ADD = "Add an additional field",
		REG_PLAYER_ABOUT = "About",
		REG_PLAYER_ABOUTS = "About %s",
		REG_PLAYER_ABOUT_MUSIC = "Character theme",
		REG_PLAYER_ABOUT_NOMUSIC = "|cffff9900No theme",
		REG_PLAYER_ABOUT_UNMUSIC = "|cffff9900Unknown theme",
		REG_PLAYER_ABOUT_MUSIC_SELECT = "Select character theme",
		REG_PLAYER_ABOUT_MUSIC_REMOVE = "Unselect theme",
		REG_PLAYER_ABOUT_MUSIC_LISTEN = "Play theme",
		REG_PLAYER_ABOUT_MUSIC_STOP = "Stop theme",
		REG_PLAYER_ABOUT_MUSIC_SELECT2 = "Select theme",
		REG_PLAYER_ABOUT_T1_YOURTEXT = "Your text here",
		REG_PLAYER_ABOUT_HEADER = "Title tag",
		REG_PLAYER_ABOUT_ADD_FRAME = "Add a frame",
		REG_PLAYER_ABOUT_REMOVE_FRAME = "Remove this frame",
		REG_PLAYER_ABOUT_P = "Paragraph tag",
		REG_PLAYER_ABOUT_TAGS = "Formatting tools",
		REG_PLAYER_ABOUT_SOME = "Some text ...",
		REG_PLAYER_ABOUT_VOTE_UP = "I like this content",
		REG_PLAYER_ABOUT_VOTE_DOWN = "I don't like this content",
		REG_PLAYER_ABOUT_VOTE_TT = "Your vote is totally anonymous and can only be seen by this player.",
		REG_PLAYER_ABOUT_VOTE_TT2 = "You can vote only if the player is online.",
		REG_PLAYER_ABOUT_VOTE_NO = "No characters linked to this profile seem to be online.\nDo you want to force Total RP 3 to send your vote anyway ?",
		REG_PLAYER_ABOUT_VOTE_SENDING = "Sending your vote to %s ...",
		REG_PLAYER_ABOUT_VOTE_SENDING_OK = "Your vote has been sent to %s !",
		REG_PLAYER_ABOUT_VOTES = "Statistics",
		REG_PLAYER_ABOUT_VOTES_R = "|cff00ff00%s like this content\n|cffff0000%s dislike this content",
		REG_PLAYER_ABOUT_EMPTY = "No description",
		REG_PLAYER_STYLE_RPSTYLE_SHORT = "RP style",
		REG_PLAYER_STYLE_RPSTYLE = "Roleplay style",
		REG_PLAYER_STYLE_HIDE = "Do not show",
		REG_PLAYER_STYLE_WOWXP = "World of Warcraft experience",
		REG_PLAYER_STYLE_FREQ = "In-character frequence",
		REG_PLAYER_STYLE_FREQ_1 = "Full-time, no OOC",
		REG_PLAYER_STYLE_FREQ_2 = "Most of the time",
		REG_PLAYER_STYLE_FREQ_3 = "Mid-time",
		REG_PLAYER_STYLE_FREQ_4 = "Casual",
		REG_PLAYER_STYLE_FREQ_5 = "Full-time OOC, not a RP character",
		REG_PLAYER_STYLE_PERMI = "With player permission",
		REG_PLAYER_STYLE_ASSIST = "Roleplay assistance",
		REG_PLAYER_STYLE_INJURY = "Accept character injury",
		REG_PLAYER_STYLE_DEATH = "Accept character death",
		REG_PLAYER_STYLE_ROMANCE = "Accept character romance",
		REG_PLAYER_STYLE_BATTLE = "Roleplay battle resolution",
		REG_PLAYER_STYLE_BATTLE_1 = "Duel or PVP",
		REG_PLAYER_STYLE_BATTLE_2 = "TRP roll battle (Not available yet)",
		REG_PLAYER_STYLE_BATTLE_3 = "/roll battle",
		REG_PLAYER_STYLE_BATTLE_4 = "Emote battle",
		REG_PLAYER_STYLE_EMPTY = "No roleplay attribute shared",
		REG_PLAYER_STYLE_GUILD = "Guild membership",
		REG_PLAYER_STYLE_GUILD_IC = "IC membership",
		REG_PLAYER_STYLE_GUILD_OOC = "OOC membership",
		REG_PLAYER_ALERT_HEAVY_SMALL = "|cffff0000The total size of your profile is quite big.\n|cffff9900You should reduce it.",
		CO_GENERAL_HEAVY = "Heavy profile alert",
		CO_GENERAL_HEAVY_TT = "Get an alert when your profile total size exceed a reasonable value.",
		REG_PLAYER_PEEK = "Miscellaneous",
		REG_PLAYER_CURRENT = "Currently",
		REG_PLAYER_CURRENTOOC = "Currently (OOC)",
		REG_PLAYER_CURRENT_OOC = "This is a OOC information";
		REG_PLAYER_GLANCE = "At first glance..",
		REG_PLAYER_GLANCE_USE = "Activate this slot",
		REG_PLAYER_GLANCE_TITLE = "Attribute name",
		REG_PLAYER_GLANCE_UNUSED = "Unused slot",
		REG_PLAYER_GLANCE_CONFIG = "|cff00ff00\"At first glance\"|r is a set of slots you can use to define important information about this character.\n\nYou can use these actions on the slots:\n|cffffff00Click:|r configure slot\n|cffffff00Double-click:|r toggle slot activation\n|cffffff00Right-click:|r slot presets\n|cffffff00Drag & drop:|r reorder slots",
		REG_PLAYER_GLANCE_EDITOR = "At first glance: %s",
		REG_PLAYER_GLANCE_BAR_TARGET = "\"At first glance\" presets",
		REG_PLAYER_GLANCE_BAR_LOAD_SAVE = "Group presets",
		REG_PLAYER_GLANCE_BAR_SAVE = "Save group as a preset",
		REG_PLAYER_GLANCE_BAR_LOAD = "Group preset",
		REG_PLAYER_GLANCE_BAR_EMPTY = "The preset name can't be empty.",
		REG_PLAYER_GLANCE_BAR_NAME = "Please enter the preset name.\n\n|cff00ff00Note: If the name is already used by another group preset, this another group will be replaced.",
		REG_PLAYER_GLANCE_BAR_SAVED = "Group preset |cff00ff00%s|r has been created.",
		REG_PLAYER_GLANCE_BAR_DELETED = "Group preset |cffff9900%s|r deleted.",
		REG_PLAYER_GLANCE_PRESET = "Load a preset",
		REG_PLAYER_GLANCE_PRESET_SELECT = "Select a preset",
		REG_PLAYER_GLANCE_PRESET_SAVE = "Save information as a preset",
		REG_PLAYER_GLANCE_PRESET_SAVE_SMALL = "Save as a preset",
		REG_PLAYER_GLANCE_PRESET_CATEGORY = "Preset category",
		REG_PLAYER_GLANCE_PRESET_NAME = "Preset name",
		REG_PLAYER_GLANCE_PRESET_CREATE = "Create preset",
		REG_PLAYER_GLANCE_PRESET_REMOVE = "Removed preset |cff00ff00%s|r.";
		REG_PLAYER_GLANCE_PRESET_ADD = "Created preset |cff00ff00%s|r.";
		REG_PLAYER_GLANCE_PRESET_ALERT1 = "You must enter a preset category.",
		REG_PLAYER_GLANCE_PRESET_GET_CAT = "%s\n\nPlease enter the category name for this preset.",
		REG_PLAYER_TUTO_ABOUT_COMMON = [[|cff00ff00Character theme:|r
You can choose a |cffffff00theme|r for your character. Think of it as an |cffffff00ambiance music for reading your character description|r.

|cff00ff00Background:|r
This is a |cffffff00background texture|r for your character description.

|cff00ff00Template:|r
The chosen template defines |cffffff00the general layout and writing possibilities|r for your description.
|cffff9900Only the selected template is visible by others, so you don't have to fill them all.|r
Once a template is selected, you can open this tutorial again to have more help about each template.]],
		REG_PLAYER_TUTO_ABOUT_T1 = [[This template allows you to |cff00ff00freely structure your description|r.

The description doesn't have to be limited to your character |cffff9900physical description|r. Feel free to indicate parts from his |cffff9900background|r or details about his |cffff9900personality|r.

With this template you can use the formatting tools to access several layout parameters like |cffffff00texts sizes, colors and alignments|r.
These tools also allow you to insert |cffffff00images, icons or links to external web sites|r.]],
		REG_PLAYER_TUTO_ABOUT_T2 = [[This template is more structured and consist of |cff00ff00a list of independant frames|r.

Each frame is caracterized by an |cffffff00icon, a background and a text|r. Note that you can use some text tags in these frames, like the color and the icon text tags.

The description doesn't have to be limited to your character |cffff9900physical description|r. Feel free to indicate parts from his |cffff9900background|r or details about his |cffff9900personality|r.]],
		REG_PLAYER_TUTO_ABOUT_T3 = [[This template is cut in 3 sections: |cff00ff00Physical description, personality and history|r.

You don't have to fill all the frames, |cffff9900if you leave an empty frame it won't be shown on your description|r.

Each frame is caracterized by an |cffffff00icon, a background and a text|r. Note that you can use some text tags in these frames, like the color and the icon text tags.]],
		REG_PLAYER_TUTO_ABOUT_MISC_1 = [[This section provides you |cffffff005 slots|r with which you can describe |cff00ff00the most important pieces of information about your character|r.

These slots will be visible on the |cffffff00"At first glance bar"|r when someone selects your character.

|cff00ff00Hint: You can drag & drop slots to reorder them.|r
It also works on the |cffffff00"At first glance bar"|r!]],
		REG_PLAYER_TUTO_ABOUT_MISC_3 = [[This section contains |cffffff00a list of flags|r to answer a lot of |cffffff00common questions people could ask about you, your character and the way you want to play him/her|r.]],
		REG_RELATION = "Relationship",
		REG_RELATION_BUTTON_TT = "Relation: %s\n|cff00ff00%s\n\n|cffffff00Click to display possible actions",
		REG_RELATION_UNFRIENDLY = "Unfriendly",
		REG_RELATION_NONE = "None",
		REG_RELATION_NEUTRAL = "Neutral",
		REG_RELATION_BUSINESS = "Business",
		REG_RELATION_FRIEND = "Friendly",
		REG_RELATION_LOVE = "Love",
		REG_RELATION_FAMILY = "Family",
		REG_RELATION_UNFRIENDLY_TT = "%s clearly doesn't like %s.",
		REG_RELATION_NONE_TT = "%s doesn't know %s.",
		REG_RELATION_NEUTRAL_TT = "%s doesn't feel anything particular toward %s.",
		REG_RELATION_BUSINESS_TT = "%s and %s are in a business relationship.",
		REG_RELATION_FRIEND_TT = "%s considers %s a friend.",
		REG_RELATION_LOVE_TT = "%s is in love with %s !",
		REG_RELATION_FAMILY_TT = "%s shares blood bound with %s.",
		REG_RELATION_TARGET = "|cffffff00Click: |rChange relation",
		REG_REGISTER = "Directory",
		REG_REGISTER_CHAR_LIST = "Characters list",
		REG_TT_GUILD_IC = "IC member",
		REG_TT_GUILD_OOC = "OOC member",
		REG_TT_LEVEL = "Level %s %s",
		REG_TT_REALM = "Realm: |cffff9900%s",
		REG_TT_GUILD = "%s of |cffff9900%s",
		REG_TT_TARGET = "Target: |cffff9900%s",
		REG_TT_NOTIF = "Unread description",
		REG_TT_IGNORED = "< Character is ignored >",
		REG_TT_IGNORED_OWNER = "< Owner is ignored >",
		REG_LIST_CHAR_TITLE = "Character list",
		REG_LIST_CHAR_SEL = "Selected character",
		REG_LIST_CHAR_TT = "Click to show page",
		REG_LIST_CHAR_TT_RELATION = "Relation:\n|cff00ff00%s",
		REG_LIST_CHAR_TT_CHAR = "Bounded WoW character(s):",
		REG_LIST_CHAR_TT_CHAR_NO = "Not bounded to any character",
		REG_LIST_CHAR_TT_DATE = "Last seen date: |cff00ff00%s|r\nLast seen location: |cff00ff00%s|r",
		REG_LIST_CHAR_TT_GLANCE = "At first glance",
		REG_LIST_CHAR_TT_NEW_ABOUT = "Unread description",
		REG_LIST_CHAR_TT_IGNORE = "Ignored character(s)",
		REG_LIST_CHAR_FILTER = "Characters: %s / %s",
		REG_LIST_CHAR_EMPTY = "No character",
		REG_LIST_CHAR_EMPTY2 = "No character matches your selection",
		REG_LIST_CHAR_IGNORED = "Ignored",
		REG_LIST_IGNORE_TITLE = "Ignored list",
		REG_LIST_IGNORE_EMPTY = "No ignored character",
		REG_LIST_IGNORE_TT = "Reason:\n|cff00ff00%s\n\n|cffffff00Click to remove from ignore list",
		REG_LIST_PETS_FILTER = "Companions: %s / %s",
		REG_LIST_PETS_TITLE = "Companion list",
		REG_LIST_PETS_EMPTY = "No companion",
		REG_LIST_PETS_EMPTY2 = "No companion matches your selection",
		REG_LIST_PETS_TOOLTIP = "Has been seen on",
		REG_LIST_PETS_TOOLTIP2 = "Has been seen with",
		REG_LIST_PET_NAME = "Companion's name",
		REG_LIST_PET_TYPE = "Companion's type",
		REG_LIST_PET_MASTER = "Master's name",
		REG_LIST_FILTERS = "Filters",
		REG_LIST_FILTERS_TT = "|cffffff00Click:|r Apply filters\n|cffffff00Right-Click:|r Clear filters",
		REG_LIST_REALMONLY = "This realm only",
		REG_LIST_GUILD = "Character's guild",
		REG_LIST_NAME = "Character's name",
		REG_LIST_FLAGS = "Flags",
		REG_LIST_ACTIONS_PURGE = "Purge register",
		REG_LIST_ACTIONS_PURGE_ALL = "Remove all profiles",
		REG_LIST_ACTIONS_PURGE_ALL_COMP_C = "This purge will remove all companions from the directory.\n\n|cff00ff00%s companions.",
		REG_LIST_ACTIONS_PURGE_ALL_C = "This purge will remove all profiles and linked characters from the directory.\n\n|cff00ff00%s characters.",
		REG_LIST_ACTIONS_PURGE_TIME = "Profiles not seen for 1 month",
		REG_LIST_ACTIONS_PURGE_TIME_C = "This purge will remove all profiles whose has not been seen for a month.\n\n|cff00ff00%s",
		REG_LIST_ACTIONS_PURGE_UNLINKED = "Profiles not bounded to a character",
		REG_LIST_ACTIONS_PURGE_UNLINKED_C = "This purge will remove all profiles whose are not bounded to a WoW character.\n\n|cff00ff00%s",
		REG_LIST_ACTIONS_PURGE_IGNORE = "Profiles from ignored characters",
		REG_LIST_ACTIONS_PURGE_IGNORE_C = "This purge will remove all profiles linked to a ignored WoW character.\n\n|cff00ff00%s",
		REG_LIST_ACTIONS_PURGE_EMPTY = "No profile to purge.",
		REG_LIST_ACTIONS_PURGE_COUNT = "%s profiles will be removed.",
		REG_LIST_ACTIONS_MASS = "Action on %s selected profiles",
		REG_LIST_ACTIONS_MASS_REMOVE = "Remove profiles",
		REG_LIST_ACTIONS_MASS_REMOVE_C = "This action will remove |cff00ff00%s selected profile(s)|r.",
		REG_LIST_ACTIONS_MASS_IGNORE = "Ignore profiles",
		REG_LIST_ACTIONS_MASS_IGNORE_C = [[This action will add |cff00ff00%s character(s)|r to the ignore list.

You can optionally enter the reason below. This is a personal note, it will serves as a reminder.]],
		REG_LIST_CHAR_TUTO_ACTIONS = "This column allows you to select multiple characters and perform an action on all of them.",
		REG_LIST_CHAR_TUTO_LIST = [[The first column shows the character's name.

The second column shows the relation between these characters and your current character.

The last column is for various flags. (ignored ..etc.)]],
		REG_LIST_CHAR_TUTO_FILTER = [[You can filter the character list.

The |cff00ff00name filter|r will perform a search on the profile full name (first name + last name) but also on any bounded WoW characters.

The |cff00ff00guild filter|r will search on guild name from bounded WoW characters.

The |cff00ff00realm only filter|r will show only profiles bounded to a WoW character of your current realm.]],
		REG_LIST_NOTIF_ADD = "New profile discovered for |cff00ff00%s",
		REG_LIST_NOTIF_ADD_CONFIG = "New profile discovered",
		REG_LIST_NOTIF_ADD_NOT = "This profile doesn't exist anymore.",
		REG_COMPANION_LINKED = "The companion %s is now linked to the profile %s.",
		REG_COMPANION = "Companion",
		REG_COMPANIONS = "Companions",
		REG_COMPANION_BOUNDS = "Bounds",
		REG_COMPANION_TARGET_NO = "Your target is not a valid pet, minion, ghoul, mage elemental or a renamed battle pet.",
		REG_COMPANION_BOUND_TO = "Bound to ...",
		REG_COMPANION_UNBOUND = "Unbound from ...",
		REG_COMPANION_LINKED_NO = "The companion %s is no more linked to any profile.",
		REG_COMPANION_BOUND_TO_TARGET = "Target",
		REG_COMPANION_BROWSER_BATTLE = "Battle pet browser",
		REG_COMPANION_BROWSER_MOUNT = "Mount browser",
		REG_COMPANION_PROFILES = "Companions profiles",
		REG_COMPANION_TF_PROFILE = "Companion profile",
		REG_COMPANION_TF_PROFILE_MOUNT = "Mount profile",
		REG_COMPANION_TF_NO = "No profile",
		REG_COMPANION_TF_CREATE = "Create new profile",
		REG_COMPANION_TF_UNBOUND = "Unlink from profile",
		REG_COMPANION_TF_BOUND_TO = "Select a profile",
		REG_COMPANION_TF_OPEN = "Open page",
		REG_COMPANION_TF_OWNER = "Owner: %s",
		REG_COMPANION_INFO = "Information",
		REG_COMPANION_NAME = "Name",
		REG_COMPANION_TITLE = "Title",
		REG_COMPANION_NAME_COLOR = "Name color",
		REG_MSP_ALERT = [[|cffff0000WARNING

You can't have simultaneously more than one addon using the Mary Sue Protocol, as they would be in conflict.|r

Currently loaded: |cff00ff00%s

|cffff9900Therefore the MSP support for Total RP3 will be disabled.|r

If you don't want TRP3 to be your MSP addon and don't want to see this alert again, you can disable the Mary Sue Protocol module in the TRP3 Settings -> Module status.]],
		REG_COMPANION_PAGE_TUTO_C_1 = "Consult",
		REG_COMPANION_PAGE_TUTO_E_1 = "This is |cff00ff00your companion main information|r.\n\nAll these information will appear on |cffff9900your companion's tooltip|r.",
		REG_COMPANION_PAGE_TUTO_E_2 = [[This is |cff00ff00your companion description|r.

It isn't limited to |cffff9900physical description|r. Feel free to indicate parts from his |cffff9900background|r or details about his |cffff9900personality|r.

There are a lot of ways to customize the description.
You can choose a |cffffff00background texture|r for the description. You can also use the formatting tools to access several layout parameters like |cffffff00texts sizes, colors and alignments|r.
These tools also allow you to insert |cffffff00images, icons or link to external web site|r.]],

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- CONFIGURATION
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		CO_CONFIGURATION = "Settings",
		CO_GENERAL = "General settings",
		CO_GENERAL_CHANGELOCALE_ALERT = "Reload the interface in order to change the language to %s now ?\n\nIf not, the language will be changed on the next connection.",
		CO_GENERAL_LOCALE = "Addon locale",
		CO_GENERAL_COM = "Communication",
		CO_GENERAL_BROADCAST = "Use broadcast channel",
		CO_GENERAL_BROADCAST_TT = "The broadcast channel is used by a lot of features. Disabling it will disable all the feature like characters position on the map, playing local sounds, stashes and signposts access...",
		CO_GENERAL_BROADCAST_C = "Broadcast channel name",
		CO_GENERAL_MISC = "Miscellaneous",
		CO_GENERAL_TT_SIZE = "Info tooltip text size",
		CO_GENERAL_NEW_VERSION = "Update alert",
		CO_GENERAL_NEW_VERSION_TT = "Get an alert when a new version is available.",
		CO_GENERAL_UI_SOUNDS = "UI sounds",
		CO_GENERAL_UI_SOUNDS_TT = "Activate the UI sounds (when opening windows, switching tabs, clicking buttons).",
		CO_GENERAL_UI_ANIMATIONS = "UI animations",
		CO_GENERAL_UI_ANIMATIONS_TT = "Activate the UI animations.",
		CO_TOOLTIP = "Tooltip settings",
		CO_TOOLTIP_USE = "Use characters/companions tooltip",
		CO_TOOLTIP_COMBAT = "Hide during combat",
		CO_TOOLTIP_CHARACTER = "Characters tooltip",
		CO_TOOLTIP_ANCHORED = "Anchored frame",
		CO_TOOLTIP_ANCHOR = "Anchor point",
		CO_TOOLTIP_HIDE_ORIGINAL = "Hide original tooltip",
		CO_TOOLTIP_MAINSIZE = "Main font size",
		CO_TOOLTIP_SUBSIZE = "Secondary font size",
		CO_TOOLTIP_TERSIZE = "Tertiary font size",
		CO_TOOLTIP_SPACING = "Show spacing",
		CO_TOOLTIP_SPACING_TT = "Places spaces to lighten the tooltip, in the style of MyRoleplay tooltip.",
		CO_TOOLTIP_PETS = "Companions tooltip",
		CO_TOOLTIP_OWNER = "Show owner",
		CO_TOOLTIP_PETS_INFO = "Show companion info",
		CO_TOOLTIP_COMMON = "Common settings",
		CO_TOOLTIP_ICONS = "Show icons",
		CO_TOOLTIP_FT = "Show full title",
		CO_TOOLTIP_RACE = "Show race, class and level",
		CO_TOOLTIP_REALM = "Show realm",
		CO_TOOLTIP_GUILD = "Show guild info",
		CO_TOOLTIP_TARGET = "Show target",
		CO_TOOLTIP_TITLE = "Show title",
		CO_TOOLTIP_CLIENT = "Show client",
		CO_TOOLTIP_NOTIF = "Show notifications",
		CO_TOOLTIP_NOTIF_TT = "The notifications line is the line containing the client version, the unread description marker and the 'At first glance' marker.",
		CO_TOOLTIP_RELATION = "Show relationship color",
		CO_TOOLTIP_RELATION_TT = "Set the character tooltip border to a color representing the relation.",
		CO_TOOLTIP_CURRENT = "Show \"current\" information",
		CO_TOOLTIP_CURRENT_SIZE = "Max \"current\" information length",
		CO_TOOLTIP_PROFILE_ONLY = "Use only if target has a profile",
		CO_REGISTER = "Register settings",
		CO_REGISTER_ABOUT_VOTE = "Use voting system",
		CO_REGISTER_ABOUT_VOTE_TT = "Enables the voting system, allowing you to vote ('like' or 'unlike') for other's descriptions and allowing them to do the same for you.",
		CO_REGISTER_AUTO_ADD = "Auto add new players",
		CO_REGISTER_AUTO_ADD_TT = "Automatically add new players you encounter to the register.",
		CO_MODULES = "Modules status",
		CO_MODULES_VERSION = "Version: %s",
		CO_MODULES_ID = "Module ID: %s",
		CO_MODULES_STATUS = "Status: %s",
		CO_MODULES_STATUS_0 = "Missing dependencies",
		CO_MODULES_STATUS_1 = "Loaded",
		CO_MODULES_STATUS_2 = "Disabled",
		CO_MODULES_STATUS_3 = "Total RP 3 update required",
		CO_MODULES_STATUS_4 = "Error on initialization",
		CO_MODULES_STATUS_5 = "Error on startup",
		CO_MODULES_TT_NONE = "No dependencies";
		CO_MODULES_TT_DEPS = "Dependencies";
		CO_MODULES_TT_TRP = "%sFor Total RP 3 build %s minimum.|r",
		CO_MODULES_TT_DEP = "\n%s- %s (version %s)|r",
		CO_MODULES_TT_ERROR = "\n\n|cffff0000Error:|r\n%s";
		CO_MODULES_TUTO = [[A module is a independent feature that can be enable or disable.

Possible status:
|cff00ff00Loaded:|r The module is enabled and loaded.
|cff999999Disabled:|r The module is disabled.
|cffff9900Missing dependencies:|r Some dependencies are not loaded.
|cffff9900TRP update required:|r The module required a more recent version of TRP3.
|cffff0000Error on init or on startup:|r The module loading sequence failed. The module will likely create errors !

|cffff9900When disabling a module, a UI reload is necessary.]],
		CO_MODULES_SHOWERROR = "Show error",
		CO_MODULES_DISABLE = "Disable module",
		CO_MODULES_ENABLE = "Enable module",
		CO_TOOLBAR = "Frames settings",
		CO_TOOLBAR_CONTENT = "Toolbar settings",
		CO_TOOLBAR_ICON_SIZE = "Icons size",
		CO_TOOLBAR_MAX = "Max icons per line",
		CO_TOOLBAR_MAX_TT = "Set to 1 if you want to display the bar vertically !",
		CO_TOOLBAR_CONTENT_CAPE = "Cape switch",
		CO_TOOLBAR_CONTENT_HELMET = "Helmet switch",
		CO_TOOLBAR_CONTENT_STATUS = "Player status (AFK/DND)",
		CO_TOOLBAR_CONTENT_RPSTATUS = "Character status (IC/OOC)",
		CO_TOOLBAR_SHOW_ON_LOGIN = "Show toolbar on login",
		CO_TOOLBAR_SHOW_ON_LOGIN_HELP = "If you don't want the toolbar to be displayed on login, you can disable this option.",
		CO_TARGETFRAME = "Target frame settings",
		CO_TARGETFRAME_USE = "Display conditions",
		CO_TARGETFRAME_USE_TT = "Determines in which conditions the target frame should be shown on target selection.",
		CO_TARGETFRAME_USE_1 = "Always",
		CO_TARGETFRAME_USE_2 = "Only when IC",
		CO_TARGETFRAME_USE_3 = "Never (Disabled)",
		CO_TARGETFRAME_ICON_SIZE = "Icons size",
		CO_MINIMAP_BUTTON = "Minimap button",
		CO_MINIMAP_BUTTON_SHOW_TITLE = "Show minimap button",
		CO_MINIMAP_BUTTON_SHOW_HELP = [[If you are using an other add-on to display Total RP 3's minimap button (FuBar, Titan, Bazooka) you can remove the button from the minimap.

|cff00ff00Reminder : You can open Total RP 3 using /trp3 switch main|r]],
		CO_MINIMAP_BUTTON_FRAME = "Frame to anchor",
		CO_MINIMAP_BUTTON_RESET = "Reset position",
		CO_MINIMAP_BUTTON_RESET_BUTTON = "Reset",
		CO_ANCHOR_TOP = "Top",
		CO_ANCHOR_TOP_LEFT = "Top left",
		CO_ANCHOR_TOP_RIGHT = "Top right",
		CO_ANCHOR_BOTTOM = "Bottom",
		CO_ANCHOR_BOTTOM_LEFT = "Bottom left",
		CO_ANCHOR_BOTTOM_RIGHT = "Bottom right",
		CO_ANCHOR_LEFT = "Left",
		CO_ANCHOR_RIGHT = "Right",
		CO_ANCHOR_CURSOR = "Show on cursor",
		CO_CHAT = "Chat settings",
		CO_CHAT_MAIN = "Chat main settings",
		CO_CHAT_MAIN_NAMING = "Naming method",
		CO_CHAT_MAIN_NAMING_1 = "Keep original names",
		CO_CHAT_MAIN_NAMING_2 = "Use custom names",
		CO_CHAT_MAIN_NAMING_3 = "First name + last name",
		CO_CHAT_MAIN_COLOR = "Use custom colors for names",
		CO_CHAT_USE = "Used chat channels",
		CO_CHAT_USE_SAY = "Say channel",
		CO_CHAT_MAIN_NPC = "NPC talk detection",
		CO_CHAT_MAIN_NPC_USE = "Use NPC talk detection",
		CO_CHAT_MAIN_NPC_PREFIX = "NPC talk detection pattern",
		CO_CHAT_MAIN_NPC_PREFIX_TT = "If a chat line said in SAY, EMOTE, GROUP or RAID channel begins with this prefix, it will be interpreted as a NPC chat.\n\n|cff00ff00By default : \"|| \"\n(without the \" and with a space after the pipe)",
		CO_CHAT_MAIN_EMOTE = "Emote detection",
		CO_CHAT_MAIN_EMOTE_USE = "Use emote detection",
		CO_CHAT_MAIN_EMOTE_PATTERN = "Emote detection pattern",
		CO_CHAT_MAIN_OOC = "OOC detection",
		CO_CHAT_MAIN_OOC_USE = "Use OOC detection",
		CO_CHAT_MAIN_OOC_PATTERN = "OOC detection pattern",
		CO_CHAT_MAIN_OOC_COLOR = "OOC color",
		CO_CHAT_MAIN_EMOTE_YELL = "No yelled emote",
		CO_CHAT_MAIN_EMOTE_YELL_TT = "Do not show *emote* or <emote> in yelling.",
		CO_GLANCE_MAIN = "\"At first glance\" bar",
		CO_GLANCE_RESET_TT = "Reset the bar position to the bottom left of the anchored frame.",
		CO_GLANCE_LOCK = "Lock bar",
		CO_GLANCE_LOCK_TT = "Prevent the bar for being dragged",
		CO_GLANCE_PRESET_TRP2 = "Use Total RP 2 style positions",
		CO_GLANCE_PRESET_TRP2_BUTTON = "Use",
		CO_GLANCE_PRESET_TRP2_HELP = "Shortcut to setup the bar in a TRP2 style : to the right of WoW target frame.",
		CO_GLANCE_PRESET_TRP3 = "Use Total RP 3 style positions",
		CO_GLANCE_PRESET_TRP3_HELP = "Shortcut to setup the bar in a TRP3 style : to the bottom of the TRP3 target frame.",
		CO_GLANCE_TT_ANCHOR = "Tooltips anchor point",
		CO_MSP = "Mary Sue Protocol",
		CO_MSP_T3 = "Use template 3 only",
		CO_MSP_T3_TT = "Event if you choose another \"about\" template, the template 3 will always be used for MSP compatibility.",
		CO_WIM = "|cffff9900Whisper channels are disabled.",
		CO_WIM_TT = "You are using |cff00ff00WIM|r, the handling for whisper channels is disabled for compatibility purpose",
		CO_LOCATION = "Location settings",
		CO_LOCATION_ACTIVATE = "Enable character location",
		CO_LOCATION_ACTIVATE_TT = "Enable the character location system, allowing you to scan for other Total RP users on the world map and allowing them to find you.",
		CO_LOCATION_DISABLE_OOC = "Disable OOC location",
		CO_LOCATION_DISABLE_OOC_TT = "You will not respond to location request from other players when you've set your RP status to Out Of Character.",
		CO_LOCATION_DISABLE_PVP = "Disable PVP location",
		CO_LOCATION_DISABLE_PVP_TT = "You will not respond to location request from other players when you are flagged for PvP.\n\nThis option is particularly useful on PvP realms where players from the other faction can abuse the location system to track you.",
		CO_LOCATION_WARBORN = "Enable Warborn mode",
		CO_LOCATION_WARBORN_TT = "Enable the Warborn mode, allowing you to always broadcast your location and faction icon even when PvP flagged. This overrides PvP and OOC location restrictions, making you always visible on scans.",

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- TOOLBAR AND UI BUTTONS
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		TB_TOOLBAR = "Toolbar",
		TB_SWITCH_TOOLBAR = "Switch toolbar",
		TB_SWITCH_CAPE_ON = "Cloak: |cff00ff00Shown",
		TB_SWITCH_CAPE_OFF = "Cloak: |cffff0000Hidden",
		TB_SWITCH_CAPE_1 = "Show cloak",
		TB_SWITCH_CAPE_2 = "Hide cloak",
		TB_SWITCH_HELM_ON = "Helm: |cff00ff00Shown",
		TB_SWITCH_HELM_OFF = "Helm: |cffff0000Hidden",
		TB_SWITCH_HELM_1 = "Show helmet",
		TB_SWITCH_HELM_2 = "Hide helmet",
		TB_GO_TO_MODE = "Switch to %s mode",
		TB_NORMAL_MODE = "Normal",
		TB_DND_MODE = "Do not disturb",
		TB_AFK_MODE = "Away",
		TB_STATUS = "Player",
		TB_RPSTATUS_ON = "Character: |cff00ff00In character",
		TB_RPSTATUS_OFF = "Character: |cffff0000Out of character",
		TB_RPSTATUS_TO_ON = "Go |cff00ff00in character",
		TB_RPSTATUS_TO_OFF = "Go |cffff0000out of character",
		TB_SWITCH_PROFILE = "Switch to another profile",
		TF_OPEN_CHARACTER = "Show character page",
		TF_OPEN_COMPANION = "Show companion page",
		TF_OPEN_MOUNT = "Show mount page",
		TF_PLAY_THEME = "Play character theme",
		TF_PLAY_THEME_TT = "|cffffff00Click:|r Play |cff00ff00%s\n|cffffff00Right-click:|r Stop theme",
		TF_IGNORE = "Ignore player",
		TF_IGNORE_TT = "|cffffff00Click:|r Ignore player",
		TF_IGNORE_CONFIRM = "Are you sure you want to ignore this ID ?\n\n|cffffff00%s|r\n\n|cffff7700You can optionally enter below the reason why you ignore it. This is a personal note, it won't be visible by others and will serve as a reminder.",
		TF_IGNORE_NO_REASON = "No reason",
		TB_LANGUAGE = "Language",
		TB_LANGUAGES_TT = "Change language",
		
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- PROFILES
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		PR_PROFILEMANAGER_TITLE = "Characters profiles",
		PR_PROFILEMANAGER_DELETE_WARNING = "Are you sure you want to delete the profile %s?\nThis action cannot be undone and all TRP3 information linked to this profile (Character info, inventory, quest log, applied states ...) will be destroyed !",
		PR_PROFILE = "Profile",
		PR_PROFILES = "Profiles",
		PR_PROFILE_CREATED = "Profile %s created.",
		PR_CREATE_PROFILE = "Create profile",
		PR_PROFILE_DELETED = "Profile %s deleted.",
		PR_PROFILE_HELP = "A profile contains all information about a |cffffff00\"character\"|r as a |cff00ff00roleplay character|r.\n\nA real |cffffff00\"WoW character\"|r can be bounded to only one profile at a time, but can switch from one to another whenever you want.\n\nYou can also bound several |cffffff00\"WoW characters\"|r to the same |cff00ff00profile|r !",
		PR_PROFILE_DETAIL = "This profile is currently bounded to these WoW characters",
		PR_DELETE_PROFILE = "Delete profile",
		PR_DUPLICATE_PROFILE = "Duplicate profile",
		PR_UNUSED_PROFILE = "This profile is currently not bounded to any WoW character.",
		PR_PROFILE_LOADED = "The profile %s is loaded.",
		PR_PROFILEMANAGER_CREATE_POPUP = "Please enter a name for the new profile.\nThe name cannot be empty.",
		PR_PROFILEMANAGER_DUPP_POPUP = "Please enter a name for the new profile.\nThe name cannot be empty.\n\nThis duplication will not change the character's bounds to %s.",
		PR_PROFILEMANAGER_EDIT_POPUP = "Please enter a new name for this profile %s.\nThe name cannot be empty.\n\nChanging the name will not change any link between this profile and your characters.",
		PR_PROFILEMANAGER_ALREADY_IN_USE = "The profile name %s is not available.",
		PR_PROFILEMANAGER_COUNT = "%s WoW character(s) bounded to this profile.",
		PR_PROFILEMANAGER_ACTIONS = "Actions",
		PR_PROFILEMANAGER_SWITCH = "Select profile",
		PR_PROFILEMANAGER_RENAME = "Rename profile",
		PR_PROFILEMANAGER_CURRENT = "Current profile",
		PR_CO_PROFILEMANAGER_TITLE = "Companions profiles",
		PR_CO_PROFILE_HELP = [[A profile contains all information about a |cffffff00"pet"|r as a |cff00ff00roleplay character|r.

A companion profile can be linked to:
- A battle pet |cffff9900(only if it has been renamed)|r
- A hunter pet
- A warlock minion
- A mage elemental
- A death knight ghoul |cffff9900(see below)|r

Just like characters profiles, a |cff00ff00companion profile|r can be linked to |cffffff00several pets|r, and a |cffffff00pet|r can switch easily from one profile to another.

|cffff9900Ghouls:|r As ghouls get a new name each time they are summoned, you will have to re-link the profile to the ghoul for all possible names.]],
		PR_CO_PROFILE_HELP2 = [[Click here to create a new companion profile.

|cff00ff00To link a profile to a pet (hunter pet, warlock minion ...), just summon the pet, select it and use the target frame to link it to a existing profile (or create a new one).|r]],
		PR_CO_MASTERS = "Masters",
		PR_CO_EMPTY = "No companion profile",
		PR_CO_NEW_PROFILE = "New companion profile",
		PR_CO_COUNT = "%s pets/mounts bounded to this profile.",
		PR_CO_UNUSED_PROFILE = "This profile is currently not bounded to any pet or mount.",
		PR_CO_PROFILE_DETAIL = "This profile is currently bounded to",
		PR_CO_PROFILEMANAGER_DELETE_WARNING = "Are you sure you want to delete the companion profile %s?\nThis action cannot be undone and all TRP3 information linked to this profile will be destroyed !",
		PR_CO_PROFILEMANAGER_DUPP_POPUP = "Please enter a name for the new profile.\nThe name cannot be empty.\n\nThis duplication will not change your pets/mounts bounds to %s.",
		PR_CO_PROFILEMANAGER_EDIT_POPUP = "Please enter a new name for this profile %s.\nThe name cannot be empty.\n\nChanging the name will not change any link between this profile and your pets/mounts.",
		PR_CO_WARNING_RENAME = "|cffff0000Warning:|r it's strongly recommended that you rename your pet before linking it to a profile.\n\nLink it anyway ?",
		PR_CO_PET = "Pet",
		PR_CO_BATTLE = "Battle pet",
		PR_CO_MOUNT = "Mount",
		PR_IMPORT_CHAR_TAB = "Characters importer",
		PR_IMPORT_PETS_TAB = "Companions importer",
		PR_IMPORT_IMPORT_ALL = "Import all",
		PR_IMPORT_WILL_BE_IMPORTED = "Will be imported",
		PR_IMPORT_EMPTY = "No importable profile",

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- DASHBOARD
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		DB_STATUS = "Status",
		DB_STATUS_CURRENTLY_COMMON = "These statuses will be displayed on your character's tooltip. Keep it clear and brief as |cffff9900by default TRP3 players will only see the first 140 characters of them!",
		DB_STATUS_CURRENTLY = "Currently (IC)",
		DB_STATUS_CURRENTLY_TT = "Here you can indicate something important about your character.",
		DB_STATUS_CURRENTLY_OOC = "Other information (OOC)",
		DB_STATUS_CURRENTLY_OOC_TT = "Here you can indicate something important about you, as a player, or anything out of your character.",
		DB_STATUS_RP = "Character status",
		DB_STATUS_RP_IC = "In character",
		DB_STATUS_RP_IC_TT = "That means you are currently playing your character.\nAll your actions will be interpreted as if it's your character doing them.",
		DB_STATUS_RP_OOC = "Out of character",
		DB_STATUS_RP_OOC_TT = "You are out of your character.\nYour actions can't be associated to him/her.",
		DB_STATUS_XP = "Roleplayer status",
		DB_STATUS_XP_BEGINNER = "Rookie roleplayer",
		DB_STATUS_XP_BEGINNER_TT = "This selection will show an icon on your tooltip, indicating\nto others that you are a beginner roleplayer.",
		DB_STATUS_RP_EXP = "Experienced roleplayer",
		DB_STATUS_RP_EXP_TT = "Shows that you are an experienced roleplayer.\nIt will not show any specific icon on your tooltip.",
		DB_STATUS_RP_VOLUNTEER = "Volunteer roleplayer",
		DB_STATUS_RP_VOLUNTEER_TT = "This selection will show an icon on your tooltip, indicating\nto beginner roleplayers that you are willing to help them.",
		DB_TUTO_1 = [[|cffffff00The character status|r indicates if you are currently playing your character's role or not.

|cffffff00The roleplayer status|r allows you to state that you are a beginner or a veteran willing to help rookies !

|cff00ff00These information will be placed in your character's tooltip.]],
		DB_NEW = "What's new?",
		DB_ABOUT = "About Total RP 3",
		DB_HTML_GOTO = "Click to open",
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- COMMON UI TEXTS
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		UI_BKG = "Background %s",
		UI_ICON_BROWSER = "Icon browser",
		UI_ICON_BROWSER_HELP = "Copy icon",
		UI_ICON_BROWSER_HELP_TT = [[While this frame is open you can |cffffff00ctrl + click|r on a icon to copy its name.

This will works:|cff00ff00
- On any item in your bags
- On any icon in the spellbook|r]],
		UI_COMPANION_BROWSER_HELP = "Select a battle pet",
		UI_COMPANION_BROWSER_HELP_TT = "|cffffff00Warning: |rOnly renamed battle pets can be bound to a profile.\n\n|cff00ff00This section lists these battle pets only.",
		UI_ICON_SELECT = "Select icon",
		UI_MUSIC_BROWSER = "Music browser",
		UI_MUSIC_SELECT = "Select music",
		UI_COLOR_BROWSER = "Color browser",
		UI_COLOR_BROWSER_SELECT = "Select color",
		UI_IMAGE_BROWSER = "Image browser",
		UI_IMAGE_SELECT = "Select image",
		UI_FILTER = "Filter",
		UI_LINK_URL = "http://your.url.here",
		UI_LINK_TEXT = "Your text here",
		UI_LINK_WARNING = [[Here's the link URL.
You can copy/paste it in your web browser.

|cffff0000!! Disclaimer !!|r
Total RP is not responsible for links leading to harmful content.]],
		UI_TUTO_BUTTON = "Tutorial mode",
		UI_TUTO_BUTTON_TT = "Click to toggle on/off the tutorial mode",
		UI_CLOSE_ALL = "Close all",
		
		NPC_TALK_SAY_PATTERN = "says: ",
		NPC_TALK_YELL_PATTERN = "yells: ",
		NPC_TALK_WHISPER_PATTERN = "whispers: ",
		
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- COMMON TEXTS
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		CM_SHOW = "Show",
		CM_ACTIONS = "Actions",
		CM_IC = "IC",
		CM_OOC = "OOC",
		CM_CLICK = "Click",
		CM_R_CLICK = "Right-click",
		CM_L_CLICK = "Left-click",
		CM_CTRL = "Ctrl",
		CM_SHIFT = "Shift",
		CM_DRAGDROP = "Drag & drop",
		CM_LINK = "Link",
		CM_SAVE = "Save",
		CM_CANCEL = "Cancel",
		CM_NAME = "Name",
		CM_VALUE = "Value",
		CM_UNKNOWN = "Unknown",
		CM_PLAY = "Play",
		CM_STOP = "Stop",
		CM_LOAD = "Load",
		CM_REMOVE = "Remove",
		CM_EDIT = "Edit",
		CM_LEFT = "Left",
		CM_CENTER = "Center",
		CM_RIGHT = "Right",
		CM_COLOR = "Color",
		CM_ICON = "Icon",
		CM_IMAGE = "Image",
		CM_SELECT = "Select",
		CM_OPEN = "Open",
		CM_APPLY = "Apply",
		CM_MOVE_UP = "Move up",
		CM_MOVE_DOWN = "Move down",
		CM_CLASS_WARRIOR = "Warrior",
		CM_CLASS_PALADIN = "Paladin",
		CM_CLASS_HUNTER = "Hunter",
		CM_CLASS_ROGUE = "Rogue",
		CM_CLASS_PRIEST = "Priest",
		CM_CLASS_DEATHKNIGHT = "Death Knight",
		CM_CLASS_SHAMAN = "Shaman",
		CM_CLASS_MAGE = "Mage",
		CM_CLASS_WARLOCK = "Warlock",
		CM_CLASS_MONK = "Monk",
		CM_CLASS_DRUID = "Druid",
		CM_CLASS_UNKNOWN = "Unknown",
		
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- Minimap button
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		MM_SHOW_HIDE_MAIN = "Show/hide the main frame",
		MM_SHOW_HIDE_SHORTCUT = "Show/hide the toolbar",
		MM_SHOW_HIDE_MOVE = "Move button",
		
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- Browsers
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		BW_COLOR_CODE = "Color code",
		BW_COLOR_CODE_TT = "You can paste an 6 figures hexadecimal color code here and press Enter.",
		BW_COLOR_CODE_ALERT = "Wrong hexadecimal code !",

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- Databroker
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		DTBK_HELMET = "Total RP 3 - Helmet",
		DTBK_CLOAK = "Total RP 3 - Cloak",
		DTBK_AFK = "Total RP 3 - AFK/DND",
		DTBK_RP = "Total RP 3 - IC/OOC",
		DTBK_LANGUAGES = "Total RP 3 - Languages",

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- Bindings
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		BINDING_NAME_TRP3_TOGGLE = "Toogle main frame";
		BINDING_NAME_TRP3_TOOLBAR_TOGGLE = "Toogle toolbar";

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- About TRP3
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		ABOUT_TITLE = "About",

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- MAP
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		MAP_BUTTON_TITLE = "Scan for roleplay",
		MAP_BUTTON_SUBTITLE = "Click to show available scans",
		MAP_BUTTON_NO_SCAN = "No scan available",
		MAP_BUTTON_SCANNING = "Scanning",

		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		-- COMMANDS
		--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

		COM_LIST = "List of commands:",
		COM_SWITCH_USAGE = "Usage: |cff00ff00/trp3 switch main|r to switch main frame or |cff00ff00/trp3 switch toolbar|r to switch the toolbar.",
		COM_RESET_USAGE = "Usage: |cff00ff00/trp3 reset frames|r to reset all frames positions.",
		COM_RESET_RESET = "The frames positions have been reset!",

		WHATS_NEW = [[{h3:c}For clients running {col:6eff51}3.3.5{/col}{/h3}
			{h3}1. Merged templates{/h3}
			Templates 2 and 3 have been merged into a single template allowing for more customisation. Template 1 remains unchanged and still fully supports markdown!

			{h3}2. Cross-faction compatibility{/h3}
			Scans and registering now work across factions, allowing you to find and register characters from the opposite faction. This is a major change that will allow for more roleplay opportunities between factions.
			
			Also introduces Warborn Mode, for those who enjoy the thrill of being hunted by the opposing faction.]]
	},
};

TRP3_API.locale.registerLocale(LOCALE_EN);