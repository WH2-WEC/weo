
--# assume global class LLR_MANAGER
--# assume global class LLR_LORD


--# assume global class CIM
--# assume global class CIP


--# assume global class KOU_MODEL

--# assume global class RECRUITER_MANAGER
--# assume global class RECRUITER_CHARACTER
--# assume global class RECRUITER_QUEUED_UNIT

---Geopolitics system
--# assume global class GEOPOLITIC_FACTION
--# assume global class GEOPOLITIC_REGION
--# assume global class GEOPOLITIC_BLACKLIST
--# assume global class GEOPOLITICAL_MANAGER
--# assume global class GEOPOLITIC_LOADER


--provinces
--# assume global class PROVINCE_MANAGER
--# assume global class PROVINCE













--# type global QUEUED_UNIT_RECORD = { 
--# _char: CA_CQI, _unitID: string, _buildTime: number
--#}



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



