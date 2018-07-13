--v function(text: any)
local function LOG(text)
	ftext = "LESCRIPT" --:string

    if not __write_output_to_logfile then
      return;
    end

  local logText = tostring(text)
  local logContext = tostring(ftext)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("recruitment_log.txt","a")
  --# assume logTimeStamp: string
  popLog :write("LE:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
  popLog :flush()
  popLog :close()
end




local recruiter_character = {} --# assume recruiter_character: RECRUITER_CHARACTER

--this holds basic information about the characters who hold recruited units.
--It is identified in both the Recruitment model and the game itself through the command queue index
--It contains what it believes to be it's current queue, its most recent army count, and its most recent queue counts. 
--v function (cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_character.new(cqi)

    local self = {}
    setmetatable(self, {
        __index = recruiter_character,
        __tostring = function() return "RECRUITER_CHARACTER" end
    }) --# assume self: RECRUITER_CHARACTER

    self._queuedUnits = {} --:vector<string>
    self._armyUnits = {} --:vector<string>
    self._cqi = cqi 
    self._shouldEvaluateQueue = false --:boolean
    self._unitCounts = {} --: map<string, number>
    

    return self
end

--v function (self: RECRUITER_CHARACTER) --> CA_CQI
function recruiter_character.cqi(self)
    return self._cqi
end

--v function (self: RECRUITER_CHARACTER) --> boolean
function recruiter_character.get_should_evaluate_queue(self)
    return self._shouldEvaluateQueue
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_should_evaluate_queue(self)
    self._shouldEvaluateQueue = true
end

--v function(self: RECRUITER_CHARACTER, unit_ID: string)
function recruiter_character.add_unit_to_queue(self, unit_ID)
    

end


