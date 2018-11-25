
--# assume global class MCM
--# assume global class MCM_MOD
--# assume global class MCM_VAR
--# assume global class MCM_TWEAKER
--# assume global class MCM_OPTION

--MOD CONFIGURATION MANAGER
--# assume MCM.register_mod: method(key: string, ui_name: string, ui_tooltip: string) --> MCM_MOD
--# assume MCM.get_mod: method(key: string) --> MCM_MOD
--# assume MCM.started_with_mod: method(key: string) --> boolean
--# assume MCM.add_pre_process_callback: method(callback: function())
    --// happens before any MCM value callbacks. Happens regardless of whether the game is new or loaded. 
--# assume MCM.add_post_process_callback: method(callback: function())
    --// happens after any MCM value callbacks. Happens regardless of whether the game is new or loaded. 
    --// This is the recommended method for using your settings.
--# assume MCM.add_new_game_only_callback: method(callback: function())
    --// happens after any MCM value callbacks only in new saves.
    --// this is the recommended method for using settings only applicable to game start. 

--MOD OBJECT
--# assume MCM_MOD.name: method() --> string
--# assume MCM_MOD.add_tweaker: method(key: string, ui_name: string, tooltip: string) --> MCM_TWEAKER
    --// All tweakers set a save value "mcm_tweaker_<mod_key>_<tweaker_key>_value" 
    --// This value equals the option key of the selected option
    --// Tweakers additionally trigger an event called "mcm_tweaker_<mod_key>_<tweaker_key>_event".
    --// The value is easily accessible within this event through context.string
--# assume MCM_MOD.add_variable: method(key: string,
--# minimum: number, maximum: number, default: number, step_value: number,
--# ui_name: string, ui_tooltip: string) --> MCM_VAR
    --// All variables set a save value "mcm_variable_<mod_key>_<variable_key>_value" 
    --// This value equals the option key of the selected option
    --// variables additionally trigger an event called "mcm_variable_<mod_key>_<variable_key>_event".
    --// The value is easily accessible within this event through tonumber(context.string)

--TWEAKER OBJECT
--# assume MCM_TWEAKER.name: method() -->string
--# assume MCM_TWEAKER.selected_option: method() --> MCM_OPTION
--# assume MCM_TWEAKER.get_option_with_key: method(key: string) --> MCM_OPTION
--# assume MCM_TWEAKER.add_option: method(key: string, ui_name: string, ui_tooltip: string) --> MCM_OPTION
    --// the first option added to any tweaker is the default value.

--OPTION OBJECT
--# assume MCM_OPTION.name: method() -->string
--# assume MCM_OPTION.has_callback: method() --> boolean
--# assume MCM_OPTION.add_callback: method(callback: function(context: MCM)) 
    --// The added callback will happen both in new and saved games.
    --// The callback will occur when the MCM panel closes.
    --// These callbacks are best used to load values into another defined data structure or object; 
    --// general purpose uses are better off using the methods of MCM for callbacks.

--VAR OBJECT
--# assume MCM_VAR.name: method() --> string
--# assume MCM_VAR.current_value: method() --> number
--# assume MCM_VAR.has_callback: method() --> boolean
--# assume MCM_VAR.add_callback: method(callback: function(context: MCM)) 
    --// The added callback will happen both in new and saved games.
    --// The callback will occur when the MCM panel closes.
    --// These callbacks are best used to load values into another defined data structure or object; 
    --// general purpose uses are better off using the methods of MCM for callbacks.

--GLOBAL ACCESS
--# assume mcm:MCM
_G.mcm = mcm


--# assume global class LLR_MANAGER
--# assume global class LLR_LORD


--# assume global class CIM
--# assume global class CIP


--# assume global class KOU_MODEL

--# assume global class RECRUITER_MANAGER
--# assume global class RECRUITER_CHARACTER
--# type global RM_UIPROFILE = {_image: string, _text: string}

---Geopolitics system
--# assume global class GEOPOLITIC_FACTION
--# assume global class GEOPOLITIC_REGION
--# assume global class GEOPOLITIC_BLACKLIST
--# assume global class GEOPOLITICAL_MANAGER
--# assume global class GEOPOLITIC_LOADER


--# assume global class PM
--# assume global class PM_VIEW
--# assume global class FPD
--# type global FPD_SAVE = {_subjectWhitelist: map<string, boolean>, _UISubjectSources: map<string, string>, _prodControl: number}
--# assume global class RD
--# type global RD_SAVE = {_wealth: number, _maxWealth: number, _UIWealthChanges:map<string, number>, _partialUnits:map<string, number>, _UIUnitProduction:map<string,number>, _regionEffects: map<string, boolean>}
--# assume global class SUBJECT
--# type global SUBJECT_STATE = 0 | 1 | 2 | 3 | 4
--# type global SUBJECT_SAVE = {_nextDemandTurn:number, _currentState: SUBJECT_STATE}
--# assume global class SUBJECT_DEMAND
--# type global DEMAND_TEMPLATE = {key: string, validity: (function(cm: CM)--> boolean), event: string, cnd: function(context: WHATEVER) --> boolean, can_pay_off: boolean}

--provinces
--# assume global class PROVINCE_REGISTER

--region detail


--imperium
--# assume global class IMPERIUM_EFFECTS_MANAGER


--tech unlocks
--# assume global class TECH_UNLOCK


--lord unlocks
--# assume global class CUSTOM_LORD_UNLOCK







--# assume global class LOREFUL_EMPIRES_MANAGER


--# type global SPAWN_INFO = {
--# region: string, forename: string, surname: string, subtype: string, army: string, x: number, y: number, is_faction_leader: boolean
--#}
--# assume global class DEV_TOOL_MANAGER



--# assume global class SCRIPTED_MISSION_CONTROLLER

--# assume global class SCRIPTED_MISSION
--# type global SCRIPTED_MISSION_OBJECTIVE = {
--# _event: string, _callback: (function(context: WHATEVER) --> boolean ) | boolean, _scriptkey: string?
--#}
--# type global MISSION_INFO_TABLE = {
--# _key: string, _scriptedObjectives: (vector<SCRIPTED_MISSION_OBJECTIVE>)?, 
--# _successCallback: (function())?, _additionalOperations: (function(mm: MISSION_MANAGER))?
--# }

