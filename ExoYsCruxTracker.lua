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
local nECT = "|c00FF00ExoY|rs Crux Tracker"
local vECT = "0.1.0"

local cruxId = 184220

local Gui = {}

local Lib = LibExoYsUtilities

local Numeric
local Graphic


--[[ --------------- ]]
--[[ -- Interface -- ]]
--[[ --------------- ]]

local function InitializeNumeric() 
  local name = idECT.."NumericTracker"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.numeric.x, SV.numeric.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetHidden(true)
  win:SetClampedToScreen(true) 
  win:SetHandler( "OnMoveStop", function() 
    SV.numeric.x = win:GetLeft() 
    SV.numeric.y = win:GetTop()
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
  ctrl:SetDimensions( 0,0 )
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
  label:SetColor(unpack(SV.numeric.color[1]))
  label:SetText("0")

  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  return {DefineFragmentScenes = DefineFragmentScenes, win = win, label = label}
end



local function InitializeGraphic() 
  local name = idECT.."GraphicTracker"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.graphical.x, SV.graphical.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )
  win:SetHidden(true)
  win:SetHandler( "OnMoveStop", function() 
    SV.graphical.x = win:GetLeft() 
    SV.graphical.y = win:GetTop()
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
    icon:SetTexture("/art/fx/texture/arcanist_trianglerune_01.dds")

    local highlight  = WM:CreateControl(name.."Highlight"..tostring(i), ind, CT_TEXTURE )
    highlight:ClearAnchors()
    highlight:SetAnchor( CENTER, ind, CENTER, 0, 0)
    highlight:SetDesaturation(0.4)
    highlight:SetTexture( "esoui/art/champion/actionbar/champion_bar_world_selection.dds")
    highlight:SetColor(0,1,0)

    local function Activate()
      icon:SetColor(0,1,0,1)
      highlight:SetAlpha(0.8)    
    end

    local function Deactivate()
      icon:SetColor(1,1,1,0.2)
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
  Numeric.DefineFragmentScenes(SV.numeric.enabled)
  local fontList = Lib.GetFontList() 
  Numeric.label:SetFont( Lib.GetFont({font=fontList[SV.numeric.font], size = SV.numeric.size, outline=2}) ) 
  local numericHeight = Numeric.label:GetTextHeight() 
  local numericWidth = Numeric.label:GetTextWidth() 
  Numeric.win:SetDimensions(2*numericWidth, 2*numericHeight)

  Graphic.DefineFragmentScenes(SV.graphical.enabled)
  Graphic.indicator.ApplyDistance(SV.graphical.distance, SV.graphical.size)
  Graphic.indicator.ApplySize(SV.graphical.size)
end

--[[ ------------------ ]]
--[[ -- Crux Handler -- ]]
--[[ ------------------ ]]

local function SetCrux(crux)

  if true then return end
    
  -- numeric
  Numeric.label:SetText(tostring(crux))
  Numeric.label:SetColor(unpack(SV.numeric.color[crux+1]))

  -- graphic
  for i=1,3 do 
    Graphic.indicator[i].Deactivate() 
  end
  if crux == 0 then return end
  for i=1,crux do 
    Graphic.indicator[i].Activate() 
  end
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
  Numeric.label:SetColor(unpack(SV.numeric.color[crux+1]))
  -- graphic
  for i=1,3 do 
    Graphic.indicator[i].Deactivate() 
  end
  if crux == 0 then return end
  for i=1,crux do 
    Graphic.indicator[i].Activate() 
  end

end


local function OnCruxChange(_, changeType, _, _, _, _, _, stackCount) 
  if changeType == EFFECT_RESULT_FADED then
    SetCrux(0)
    return
  end
  SetCrux(3)
end

--[[ ---------- ]]
--[[ -- Menu -- ]]
--[[ ---------- ]]

local function DefineSetting(setting, name, t, k, param, half) 
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
  if half then 
    s.width = "half"
  end
  return s
end

local function NumericSubmenu() 
  local controls = {}

  table.insert(controls, DefineSetting("checkbox", "Enabled", SV.numeric, "enabled"))
  table.insert(controls, {type="divider"})
  table.insert(controls, DefineSetting("slider", "Size", SV.numeric, "size", {10,80,5}))
  table.insert(controls, {
    type = "dropdown",
    name = "Font",  
    choices = Lib.GetFontList(), 
    getFunc = function() 
      local fontList = Lib.GetFontList()
      return fontList[SV.numeric.font] end, 
    setFunc = function(selection)
      local fontList = Lib.GetFontList() 
      for id, font in ipairs(fontList) do 
        if selection == font then 
          SV.numeric.font = id
        end
      end
      ApplySettings()
    end,
  }) 
  table.insert(controls, {type="divider"})
  local numberStr = {"Zero", "One", "Two", "Three"}
  for i=1,4 do 
    table.insert(controls, {
      type = "colorpicker",
      name = "Color "..numberStr[i],
      getFunc = function() return unpack(SV.numeric.color[i]) end,	--(alpha is optional)
      setFunc = function(r,g,b)
        SV.numeric.color[i] = {r, g, b}
      end,
      width = "half",	--or "half" (optional)
    })
  end

  return { 
    type = "submenu", 
    name = "Numeric Indicator", 
    controls = controls,
  }
end

local function InitializeMenu() 
  local LAM2 = LibAddonMenu2

  local panelData = {
      type="panel", 
      name=nECT, 
      displayName=nECT, 
      author = "@|c00FF00ExoY|r94 (PC/EU)", 
      version = vECT, 
      registerForRefresh = true, 
  }
  local optionsTable = {} 

  --TODO add describtions and maybe support for multiple languages? 
  table.insert(optionsTable, Lib.FeedbackSubmenu(nECT, "info3619-ExoYsCruxTracker.html"))

  table.insert(optionsTable, NumericSubmenu() ) 

  table.insert(optionsTable, {type="header", name="Graphical Indicator"})
  table.insert(optionsTable, DefineSetting("checkbox", "Enabled", SV.graphical, "enabled"))
  table.insert(optionsTable, DefineSetting("slider", "Size", SV.graphical, "size", {20, 120, 10}))



  LAM2:RegisterAddonPanel('ExoYCruxTracker_Menu', panelData)
  LAM2:RegisterOptionControls('ExoYCruxTracker_Menu', optionsTable)
end 


--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function GetDefaults() 
  local defaults = {}
    defaults.numeric = { 
      x = 600, 
      y = 600, 
      center = false,
      locked = false, 
      font = 2, 
      size = 20, 
      enabled = true,  
      color = { {0,1,0},{0,1,0},{0,1,0},{0,1,0} }
    }
    defaults.graphical = {
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

  SV = ZO_SavedVars:NewAccountWide("ExoYsCruxTrackerSavedVariables", 1, nil, GetDefaults() )

  InitializeMenu() 

  Numeric = InitializeNumeric() 
  Graphic = InitializeGraphic() 
  ApplySettings() 

  EM:RegisterForUpdate(idECT, 100, OnUpdate)

  EM:RegisterForEvent(idECT, EVENT_EFFECT_CHANGED, OnCruxChange)
  EM:AddFilterForEvent(idECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, cruxId)
  EM:AddFilterForEvent(idECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

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
