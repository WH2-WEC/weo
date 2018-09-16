pm = _G.pm
local UIBUTTONNAME = "REGION_DETAILS_BUTTON"
local UIPANELNAME = "REGION_DETAILS_PANEL"




local function UIOnSettlementSelected()
    local ButtonParent
    local existingElement = Util.getComponentWithName(UIBUTTONNAME)
    if not not existingElement then
        --# assume existingElement: BUTTON
        existingElement:SetVisible(true)
        existingElement:MoveTo(8, 1008)
    else
        local ButtonParent = find_uicomponent(core:get_ui_root(), "layout", "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "parchment_banner")
        local DetailsButton = Button.new(UIBUTTONNAME, ButtonParent, "CIRCULAR", "ui/skins/default/icon_province_details.png")
        DetailsButton:MoveTo(8, 1008)
        DetailsButton:RegisterForClick(function() end)
    end
end




--listeners

core:add_listener(
    "SettlementSelectedUI",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() == cm:get_local_faction(true)
    end,
    function(context)
        cm:callback(function() UIOnSettlementSelected() end, 0.1)
    end,
    true
)

core:add_listener(
    "SettlementSelectedUI",
    "SettlementSelected",
    function(context)
        return (not context:garrison_residence():faction():name() == cm:get_local_faction(true))
    end,
    function(context)
        cm:callback(function()
            local existingElement = Util.getComponentWithName(UIBUTTONNAME)
            if not not existingElement then
                --# assume existingElement: BUTTON
                existingElement:SetVisible(false)
            end
        end, 0.1)
    end,
    true
)

core:add_listener(
    "PanelClosed", 
    "PanelClosedCampaign",
    function(context)
        return context.string == "settlement_panel"
    end,
    function(context)
        local existingElement = Util.getComponentWithName(UIBUTTONNAME)
        if not not existingElement then
            --# assume existingElement: BUTTON
            existingElement:SetVisible(false)
        end
    end,
    true
)
