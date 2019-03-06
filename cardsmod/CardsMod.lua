--# assume global class CARD_MODEL
local card_model = {} --# assume card_model: CARD_MODEL

--v function()
function card_model.init()
    local self = {}
    setmetatable(self, {
        __index = card_model
    })


end