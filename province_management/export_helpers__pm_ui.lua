pm = _G.pm
local UIBUTTONNAME = "REGION_DETAILS_BUTTON"
local UIPANELNAME = "REGION_DETAILS_PANEL"



--v function(DetailsFrame: FRAME,fpd: FPD)
local function PopulatePanel(DetailsFrame, fpd)
    local subculture = fpd:subculture()
    
end



--v function()
local function CreatePanel()
    local existingFrame = Util.getComponentWithName(UIPANELNAME)
    if not not existingFrame then
        --# assume existingFrame: FRAME
        existingFrame:Delete()
    end
    local ProvinceDetailsFrame = Frame.new(UIPANELNAME)
    
    --resize frame to match UI of the settlement panel
    local SettlementPanel = find_uicomponent(core:get_ui_root(), "settlement_panel")
    if not not SettlementPanel then
        local sX, sY = core:get_screen_resolution()
        local pX, pY = SettlementPanel:Dimensions()
        ProvinceDetailsFrame:Resize(1060, 320)
        local fX, fY = ProvinceDetailsFrame:Bounds()
        local pPosX, pPosY = SettlementPanel:Position()
        ProvinceDetailsFrame:MoveTo(pPosX, pPosY - fY)
        --create a close button and move it to top right.

        --set the panel title.
        ProvinceDetailsFrame:SetTitle("Province Details")
        --send to the populator
        local currentFPD = pm:current_fpd()
        PopulatePanel(ProvinceDetailsFrame, currentFPD)
    else
        pm:log("UI: failed to launch panel, could not find settlement panel")
        ProvinceDetailsFrame:Delete()
    end
end

local function UIOnSettlementSelected()
    local ButtonParent
    local existingElement = Util.getComponentWithName(UIBUTTONNAME)
    if not not existingElement then
        --# assume existingElement: BUTTON
        existingElement:SetVisible(true)
        existingElement:Resize(56, 56)
        existingElement:MoveTo(8, 1016)
    else
        local ButtonParent = find_uicomponent(core:get_ui_root(), "layout") --, "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "parchment_banner"
        local DetailsButton = Button.new(UIBUTTONNAME, ButtonParent, "CIRCULAR", "ui/skins/default/icon_province_details.png")
        DetailsButton:Resize(56, 56)
        DetailsButton:MoveTo(8, 1016)
        DetailsButton:RegisterForClick(function() CreatePanel() end)
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
        cm:callback(function() 
            local existingFrame = Util.getComponentWithName(UIPANELNAME)
            if not not existingFrame then
                --# assume existingFrame: FRAME
                existingFrame:Delete()
            end
            UIOnSettlementSelected() 
        end, 0.1)
    end,
    true
)

core:add_listener(
    "SettlementSelectedUI",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() ~= cm:get_local_faction(true)
    end,
    function(context)
        cm:callback(function()
            local existingElement = Util.getComponentWithName(UIBUTTONNAME)
            if not not existingElement then
                --# assume existingElement: BUTTON
                existingElement:SetVisible(false)
            end
            local existingFrame = Util.getComponentWithName(UIPANELNAME)
            if not not existingFrame then
                --# assume existingFrame: FRAME
                existingFrame:Delete()
            end
        end, 0.1)
    end,
    true
)

core:add_listener(
    "SettlementPanelClosed", 
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
        local existingFrame = Util.getComponentWithName(UIPANELNAME)
        if not not existingFrame then
            --# assume existingFrame: FRAME
            existingFrame:Delete()
        end
    end,
    true
)


