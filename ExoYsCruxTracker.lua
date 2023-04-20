--CruxTracker = CruxTracker or {}

--local ECT = CruxTracker
--local Lib = LibExoYsUtilities

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

local EM = GetEventManager() 
local WM = GetWindowManager()
local SV 

local idECT = "ExoYsCruxTracker"
local vECT = "0.1.0"

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
  win:SetHidden(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )
  win:SetHandler( "OnMoveStop", function() 
    SV.counter.x = win:GetLeft() 
    SV.counter.y = win:GetTop()
  end)  

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  local function DefineFragmentScenes(enabled)
    if enabled then 
      HUD_UI_SCENE:AddFragment( frag )
      HUD_SCENE:AddFragment( frag )
    else 
      HUD_UI_SCENE:RemoveFragment( frag )
      HUD_SCENE:RemoveFragment( frag )
    end
  end

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
  label:SetFont( "ZoFontWinH1" )
  label:SetDimensions( 50,50 )
  label:SetColor(0,1,0,1)
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  return {DefineFragmentScenes = DefineFragmentScenes, label = label}
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
  win:SetHidden(true)
  win:SetHandler( "OnMoveStop", function() 
    SV.display.x = win:GetLeft() 
    SV.display.y = win:GetTop()
  end)

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  local function DefineFragmentScenes(enabled)
    if enabled then 
      HUD_UI_SCENE:AddFragment( frag )
      HUD_SCENE:AddFragment( frag )
    else 
      HUD_UI_SCENE:RemoveFragment( frag )
      HUD_SCENE:RemoveFragment( frag )
    end
  end

  local indicator = {}

  local function GetIndicator(i) 

    local ind = WM:CreateControl(name.."Indicator"..tostring(i), win, CT_CONTROL)

    local back  = WM:CreateControl(name.."Back"..tostring(i), ind, CT_TEXTURE )
    back:ClearAnchors()
    back:SetAnchor( CENTER, ind, CENTER, 0, 0)
    back:SetAlpha(0.8)
    back:SetTexture( "esoui/art/champion/champion_center_bg.dds")

    local frame = WM:CreateControl(name.."Frame"..tostring(i), ind, CT_TEXTURE )
    frame:ClearAnchors()
    frame:SetAnchor( CENTER, ind, CENTER, 0, 0)
    frame:SetTexture( "esoui/art/champion/actionbar/champion_bar_slot_frame_disabled.dds")

    local icon = WM:CreateControl( name.."Icon"..tostring(i), ind, CT_TEXTURE )
    icon:ClearAnchors() 
    icon:SetAnchor( CENTER, ind, CENTER, 0, 0 ) 
    icon:SetDesaturation(0.1)
    icon:SetTexture( "exoyscruxtracker/art/crux.dds")



    local highlight  = WM:CreateControl(name.."Highlight"..tostring(i), ind, CT_TEXTURE )
    highlight:ClearAnchors()
    highlight:SetAnchor( CENTER, ind, CENTER, 0, 0)
    highlight:SetDesaturation(0.4)
    highlight:SetTexture( "esoui/art/champion/actionbar/champion_bar_world_selection.dds")
    highlight:SetColor(0,1,0,0.9)

    local function Activate()
      icon:SetAlpha(0.9) 
      highlight:SetAlpha(0.8)    
    end

    local function Deactivate()
      icon:SetAlpha(0)
      highlight:SetAlpha(0)
    end

    local controls = {ind = ind, back = back, frame = frame, icon = icon, highlight = highlight}
    return {controls = controls, Activate = Activate, Deactivate = Deactivate}
  end

  for i =1,3 do 
    indicator[i] = GetIndicator(i)
  end 

  local function ApplySize(size) 
    for i=1,3 do 
      indicator[i].controls.back:SetDimensions(size*0.85,size*0.85)
      indicator[i].controls.frame:SetDimensions(size,size)
      indicator[i].controls.highlight:SetDimensions(size,size)
      indicator[i].controls.icon:SetDimensions(size*0.75,size*0.75)   
    end
  end
  indicator.ApplySize = ApplySize

  local function ApplyDistance(distance, size) 
    for i=1,3 do 
      local xOffset = (i-2)*(size+distance)
      indicator[i].controls.ind:ClearAnchors()
      indicator[i].controls.ind:SetAnchor( CENTER, win, CENTER, xOffset, 0)
    end
  end
  indicator.ApplyDistance = ApplyDistance

  return {win = win, indicator = indicator, DefineFragmentScenes = DefineFragmentScenes}
end


local function ApplySettings() 
  Numeric.DefineFragmentScenes(SV.counter.enabled)

  Graphic.DefineFragmentScenes(SV.display.enabled)
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

local function DefineSetting(setting, name, t, k, param) 
  local s = { type=setting, name=name }
  s.getFunc = function() return t[k] end 
  s.setFunc = function(v) 
    t[k] = v
    ApplySettings()  
    end 
  if setting == "slider" then 
    s.min, s.max, s.step = param[1], param[2], param[3] 
    s.decimals = 2
  end
  return s
end


local function InitializeMenu() 
  local LAM2 = LibAddonMenu2

  local panelData = {
      type="panel", 
      name=idECT, 
      displayName=idECT, 
      author = "@|c00FF00ExoY|r94 (PC/EU)", 
      version = vECT, 
      registerForRefresh = true, 
  }
  local optionsTable = {} 

  --TODO add describtions and maybe support for multiple languages? 
 -- table.insert(optionsTable, Lib.FeedbackSubmenu(idLFI, "info3599-LibFloatingIcons.html"))
  table.insert(optionsTable, {type="header", name="Counter"})
  table.insert(optionsTable, DefineSetting("checkbox", "Enabled", SV.counter, "enabled"))

  table.insert(optionsTable, {type="header", name="Indicator"})
  table.insert(optionsTable, DefineSetting("checkbox", "Enabled", SV.display, "enabled"))
  table.insert(optionsTable, DefineSetting("slider", "Size", SV.display, "size", {20, 120, 10}))



  LAM2:RegisterAddonPanel('ExoYCruxTracker_Menu', panelData)
  LAM2:RegisterOptionControls('ExoYCruxTracker_Menu', optionsTable)
end 


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
      enabled = true,  
    }
    defaults.display = {
      size = 20,
      distance = 2, 
      x = 600, 
      y = 600, 
      center = false, 
      enabled = true, 
    }
  return defaults 
end

local function Initialize()
  -- x,y, snapToMiddle, locked, showOutsideCombat, 

  SV = ZO_SavedVars:NewCharacterIdSettings("ECTSV", 1, nil, GetDefaults() )

  InitializeMenu() 

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


--SLASH_COMMANDS["/ect"] = function() d(SV.display.enabled) end