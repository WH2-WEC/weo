
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
--# assume global class FPD
--# type global FPD_SAVE = {_subjectWhitelist: map<string, boolean>, _UISubjectSources: map<string, string>, _taxRate: number}
--# assume global class RD
--# type global RD_SAVE = {_wealth: number, _maxWealth: number, _UIWealthChanges:map<string, number>, _partialUnits:map<string, number>, _UIUnitProduction:map<string,number>, _regionEffects: map<string, boolean>}
--# assume global class SUBJECT
--# type global SUBJECT_SAVE = {_activeDemand:string, _nextDemandTurn: number}
--# type global SUBJECT_STATE = "hidden" | "angry" | "normal" | "happy" 
--# assume global class SUBJECT_DEMAND

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

