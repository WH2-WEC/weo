
--# assume global class LLR_MANAGER
--# assume global class LLR_LORD


--# assume global class CIM
--# assume global class CIP


--# assume global class KOU_MODEL

--# assume global class RECRUITER_MANAGER
--# assume global class RECRUITER_CHARACTER
--# type global TOOLTIPIMAGE = {_image: string, _text: string}

---Geopolitics system
--# assume global class GEOPOLITIC_FACTION
--# assume global class GEOPOLITIC_REGION
--# assume global class GEOPOLITIC_BLACKLIST
--# assume global class GEOPOLITICAL_MANAGER
--# assume global class GEOPOLITIC_LOADER


--provinces
--# assume global class PROVINCE_REGISTER

--region detail
--# assume global class REGION_DETAIL
--# assume global class PM
--# assume global class FPD


--# type global RELIGION_NAME = 
--# "hum_sigmar" | "hum_ulric" | "hum_manann" | "hum_myrmida" | "hum_taal" | "hum_lady" | "hum_ursun"
--# | "elf_asuryan" | "elf_hoeth" | "elf_cults" | "elf_khaine" | "elf_kurnous" | "elf_isha" | "elf_loec" | "elf_vaul" | "elf_hekarti"
--# | "dwf_miners" | "dwf_bakers" | "dwf_slayers" | "dwf_engineers" | "dwf_smiths" | "dwf_sea" |
--# "lzd_sotek" 

--# type global RELIGION_DETAIL = {
--# _name: RELIGION_NAME, _UIName: string, _UIImage: string, _UIDescription: string, _thresholds: vector<number>, _bundles: map<number, string>,
--# _wealthEffects: map<number, number>, _unitProdEffects: map<number, map<string, number>>, UIEffects: map<number, vector<string>>
--# }

--# type global TAX_DETAIL = {
--# _level: number, _UIName: string, _UIEffects:vector<string>, _bundle: string, 
--# _wealthEffects: number, _unitProdEffects: number}

--# type global UNIT_DETAIL = {
--# _set: vector<string>, _UIname: string, _UIimage: string
--#}


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



