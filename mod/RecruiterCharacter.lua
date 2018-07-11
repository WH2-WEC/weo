--v function(text: any)
local function LOG(text)
	ftext = "LESCRIPT"

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



local recruiter_queued_unit = {} --# assume recruiter_queued_unit: RECRUITER_QUEUED_UNIT

--v function(cqi: CA_CQI, unitID: UNIT_ID, duration: number) --> RECRUITER_QUEUED_UNIT
function recruiter_queued_unit.new(cqi, unitID, duration)
    LOG("Creating a queued unit record for cqi: ["..tostring(cqi).."], unit_record: ["..tostring(unitID).."], duration: ["..duration.."]  ")
    local self = {} 
    setmetatable(self, {
        __index = recruiter_queued_unit,
        __tostring = function() return "RECRUITER_QUEUED_UNIT" end
    }) --# assume self: RECRUITER_QUEUED_UNIT

    self._cqi = cqi
    self._unitID = unitID
    self._duration = duration

    return self
end

--v function(self: RECRUITER_QUEUED_UNIT) --> number
function recruiter_queued_unit.duration(self)
    return self._duration
end

--v function(self: RECRUITER_QUEUED_UNIT) --> CA_CQI
function recruiter_queued_unit.cqi(self)
    return self._cqi
end

--v function(self: RECRUITER_QUEUED_UNIT) --> UNIT_ID
function recruiter_queued_unit.key(self)
    return self._unitID
end

--v function(self: RECRUITER_QUEUED_UNIT)
function recruiter_queued_unit.pass_turn(self)
    self._duration = self._duration - 1
end



local recruiter_character = {} --# assume recruiter_character: RECRUITER_CHARACTER




--v function (cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_character.new(cqi)

    local self = {}
    setmetatable(self, {
        __index = recruiter_character,
        __tostring = function() return "RECRUITER_CHARACTER" end
    }) --# assume self: RECRUITER_CHARACTER

    self._queuedUnits = {} --:vector<QUEUED_UNIT_RECORD>


    return self
end


