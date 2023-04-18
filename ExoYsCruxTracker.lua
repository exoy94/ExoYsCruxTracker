--CruxTracker = CruxTracker or {}

--local ECT = CruxTracker
local Lib = LibExoYsUtilities

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

local EM = GetEventManager() 
local WM = GetWindowManager()
local SV 

local idECT = "ExoYsCruxTracker"

local Gui = {}

local Numeric
local Graphic

--[[ --------------- ]]
--[[ -- Interface -- ]]
--[[ --------------- ]]

local function InitializeNumeric() 
  local name = idECT.."NumericTracker"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.counter.x, SV.counter.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )
  win:SetHandler( "OnMoveStop", function() 
    SV.counter.x = win:GetLeft() 
    SV.counter.y = win:GetTop()
  end)  

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = WM:CreateControl( name.."Ctrl", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(CENTER, win, CENTER, 0, 0)
  ctrl:SetDimensions( 25,25 )
  ctrl:SetScale(2)

  --[[
  local back = WM:CreateControl( name.."back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  back:SetDimensions( 25, 25)
  back:SetCenterColor(0,0,0,1)
  ]]

  local label = WM:CreateControl( name.."Label", ctrl, CT_LABEL )
  label:ClearAnchors() 
  label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  label:SetFont( Lib.GetFont( 30 ) )
  label:SetDimensions( 50,50 )
  label:SetColor(0,1,0,1)
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  return {label = label}
end


local function InitializeNumericTracker() 
  local name = idECT.."NumericTracker"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.counter.x, SV.counter.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )
  win:SetHandler( "OnMoveStop", function() 
    SV.counter.x = win:GetLeft() 
    SV.counter.y = win:GetTop()
  end)

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = WM:CreateControl( name.."Ctrl", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(CENTER, win, CENTER, 0, 0)
  ctrl:SetDimensions( 25,25 )
  ctrl:SetScale(2)

  --[[
  local back = WM:CreateControl( name.."back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  back:SetDimensions( 25, 25)
  back:SetCente.rColor(0,0,0,1)
  ]]


  local label = WM:CreateControl( name.."Label", ctrl, CT_LABEL )
  label:ClearAnchors() 
  label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  label:SetFont( "ZoFontWinH1" )
  label:SetDimensions( 50,50 )
  label:SetColor(0,1,0,1)
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  -- function to change indicator (probably only needed for propper graphical ui )

  local function OnUpdate() 
    local crux = 0 
    for i=1,GetNumBuffs("player") do
      local _,_,_,_,stack,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
      if abilityId == 184220 then 
        crux = stack 
        break 
      end 
    end
    label:SetText(tostring(crux))
    --d(crux)
  end 

  EM:RegisterForUpdate(idECT, 100, OnUpdate)
    -- register here the event, necessary to track the crux 

  return {win, ctrl, label}
end



local function InitializeGraphic() 
  local name = idECT.."GraphicTracker"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.display.x, SV.display.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )
  win:SetHandler( "OnMoveStop", function() 
    SV.display.x = win:GetLeft() 
    SV.display.y = win:GetTop()
  end)

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = WM:CreateControl( name.."Ctrl", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(CENTER, win, CENTER, 0, 0)
  ctrl:SetDimensions( 25,25 )
  ctrl:SetScale(2)

  --[[
  local back = WM:CreateControl( name.."back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  back:SetDimensions( 25, 25)
  back:SetCente.rColor(0,0,0,1)
  ]]

  --[[
  local label = WM:CreateControl( name.."Label", ctrl, CT_LABEL )
  label:ClearAnchors() 
  label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  label:SetFont( "ZoFontWinH1" )
  label:SetDimensions( 50,50 )
  label:SetColor(0,1,0,1)
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )
  ]]

  local indicator = {}

  local function GetIndicator(i) 

    local ind = WM:CreateControl(name.."Indicator"..tostring(i), ctrl, CT_CONTROL)

    local back  = WM:CreateControl(name.."Back"..tostring(i), ind, CT_TEXTURE )
    back:ClearAnchors()
    back:SetAnchor( CENTER, ind, CENTER, 0, 0)
    back:SetTexture( "esoui/art/champion/champion_center_bg.dds")

    local frame = WM:CreateControl(name.."Frame"..tostring(i), ind, CT_TEXTURE )
    frame:ClearAnchors()
    frame:SetAnchor( CENTER, ind, CENTER, 0, 0)
    frame:SetTexture( "esoui/art/champion/actionbar/champion_bar_slot_frame_disabled.dds")

    local icon = WM:CreateControl( name.."Icon"..tostring(i), ind, CT_TEXTURE )
    icon:ClearAnchors() 
    icon:SetAnchor( CENTER, ind, CENTER, 0, 0 ) 
    icon:SetTexture( "/esoui/art/icons/passive_arcanist_08.dds")

    local highlight  = WM:CreateControl(name.."Highlight"..tostring(i), ind, CT_TEXTURE )
    highlight:ClearAnchors()
    highlight:SetAnchor( CENTER, ind, CENTER, 0, 0)
    highlight:SetDesaturation(0.3)
    highlight:SetTexture( "esoui/art/champion/actionbar/champion_bar_world_selection.dds")
    highlight:SetColor(0,1,0,0.9)

    local function Activate()
      icon:SetAlpha(1) 
      highlight:SetAlpha(0.9)    
    end

    local function Deactivate()
      icon:SetAlpha(0)
      highlight:SetAlpha(0)
    end

    return {ind = ind, back = back, frame = frame, icon = icon, highlight = highlight, Activate = Activate, Deactivate = Deactivate}
  end

  for i =1,3 do 
    indicator[i] = GetIndicator(i)
  end 

  local function ApplySize(size) 
    for i=1,3 do 
      indicator[i].back:SetDimensions(size,size)
      indicator[i].frame:SetDimensions(size,size)
      indicator[i].highlight:SetDimensions(size,size)
      indicator[i].icon:SetDimensions(size*0.8,size*0.8)   
    end
  end
  indicator.ApplySize = ApplySize

  local function ApplyDistance(distance, size) 
    for i=1,3 do 
      local xOffset = (i-2)*(size+distance)
      indicator[i].ind:ClearAnchors()
      indicator[i].ind:SetAnchor( CENTER, win, CENTER, xOffset, 0)
    end
  end
  indicator.ApplyDistance = ApplyDistance

  return {win = win, indicator = indicator}
end


local function ApplySettings() 
  Graphic.indicator.ApplyDistance(SV.display.distance, SV.display.size)
  Graphic.indicator.ApplySize(SV.display.size)
end


--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnCombatStart() 
  -- show all ui that should 
end 

local function OnCombatEnd() 
  -- hide all ui 
end

local function OnUpdate() 
  local crux = 0 
  for i=1,GetNumBuffs("player") do
    local _,_,_,_,stack,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
    if abilityId == 184220 then 
      crux = stack 
      break 
    end 
  end
  -- numeric
  Numeric.label:SetText(tostring(crux))

  -- graphic
  for i=1,3 do 
    Graphic.indicator[i].Deactivate() 
  end
  if crux == 0 then return end
  for i=1,crux do 
    Graphic.indicator[i].Activate() 
  end


  
end

--[[ ---------- ]]
--[[ -- Menu -- ]]
--[[ ---------- ]]

--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function GetDefaults() 
  local defaults = {}
    defaults.counter = {
      x = 600, 
      y = 600, 
      center = false,
      locked = false, 
      size = 20,  
    }
    defaults.display = {
      size = 20,
      distance = 2, 
      x = 600, 
      y = 600, 
      center = false, 
    }
  return defaults 
end

local function Initialize()
  -- x,y, snapToMiddle, locked, showOutsideCombat, 

  SV = ZO_SavedVars:NewCharacterIdSettings("ECTSV", 1, nil, GetDefaults() )


  -- create menu 

  Numeric = InitializeNumeric() 
  Graphic = InitializeGraphic() 
  ApplySettings() 

  -- old 
  --Gui.NumericTracker = InitializeNumericTracker() 
  --Gui.VisualTracker = InitializeVisualTracker() 


  EM:RegisterForUpdate(idECT, 100, OnUpdate)
  -- TODO publish version 6 of lib!!! 
  -- Lib.RegisterCombatStart( OnCombatStart )
  -- Lib.RegisterCombatEnd( OnCombatEnd ) 
end


local function OnAddonLoaded(_, addonName)
  if addonName == idECT then
    EM:UnregisterForEvent(idECT, EVENT_ADD_ON_LOADED)
    if GetUnitClassId("player") == 117 then 
      Initialize()
    end
  end
end
EM:RegisterForEvent(idECT, EVENT_ADD_ON_LOADED, OnAddonLoaded)



