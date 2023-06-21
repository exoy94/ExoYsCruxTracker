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
local vECT = "1.1.0"

local cruxId = 184220

local Gui = {}

local Lib = LibExoYsUtilities

local Numeric
local Graphic
local Timer

local soundList = {
  "ABILITY_COMPANION_ULTIMATE_READY",
  "ABILITY_WEAPON_SWAP_FAIL",
  "ACTIVE_SKILL_UNMORPHED",
  "ALCHEMY_CLOSED", 
  "ALCHEMY_OPENED",
  "ANTIQUITIES_DIGGING_DIG_POWER_REFUND",
  "ANTIQUITIES_FANFARE_FRAGMENT_DISCOVERED_FINAL",
  "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM",
  "BATTLEGROUND_COUNTDOWN_FINISH",
  "BATTLEGROUND_MURDERBALL_RETURNED",
  "COUNTDOWN_TICK",
}

local previousCrux = 0 

local stats = {earlyCast = 0, tardyCast = 0}
local Display
local HidePending = false

--[[ ---------------- ]]
--[[ -- Statistics -- ]] 
--[[ ---------------- ]]

local function ResetStats() 
  stats = {earlyCast = 0, tardyCast = 0}
end

local function InitializeStatistics() 
  local name = idECT.."Statistics"
  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.stats.display.x, SV.stats.display.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetHidden(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions(100,35) 
  win:SetHandler( "OnMoveStop", function() 
    SV.stats.display.x = win:GetLeft() 
    SV.stats.display.y = win:GetTop()
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

  local back = WM:CreateControl( name.."back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  back:SetDimensions( 200, 60)
  back:SetCenterColor(0,0,0,0.5)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil , 2, 2, 2)

  local icon = WM:CreateControl( name.."Icon", ctrl, CT_TEXTURE )
  icon:ClearAnchors() 
  icon:SetAnchor( CENTER, ctrl, CENTER, 0, -2 ) 
  icon:SetDimensions(60,60)
  icon:SetDesaturation(0.1)
  icon:SetColor(0,1,0,0.7)
  --icon:SetTexture("/art/fx/texture/arcanist_support_portalgroundrune.dds")
  icon:SetTexture("esoui/art/icons/class/gamepad/gp_class_arcanist.dds")

  local labelL = WM:CreateControl( name.."LabelL", ctrl, CT_LABEL )
  labelL:ClearAnchors() 
  labelL:SetAnchor(CENTER, icon, LEFT, -30, -10)
  labelL:SetColor(1,1,1,1)
  labelL:SetText("0")
  labelL:SetFont( Lib.GetFont(36) )
  labelL:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  labelL:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  local Early = WM:CreateControl( name.."Early", ctrl, CT_LABEL )
  Early:ClearAnchors() 
  Early:SetAnchor(TOP, labelL, BOTTOM, 0, -5)
  Early:SetColor(1,1,1,1)
  Early:SetText("Premature")
  Early:SetFont( Lib.GetFont(14) )
  Early:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  Early:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  local labelR = WM:CreateControl( name.."LabelR", ctrl, CT_LABEL )
  labelR:ClearAnchors() 
  labelR:SetAnchor(CENTER, icon, RIGHT, 30, -10)
  labelR:SetColor(1,1,1,1)
  labelR:SetText("0")
  labelR:SetFont( Lib.GetFont(36) )
  labelR:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  labelR:SetHorizontalAlignment( TEXT_ALIGN_LEFT  )

  local Late = WM:CreateControl( name.."Late", ctrl, CT_LABEL )
  Late:ClearAnchors() 
  Late:SetAnchor(TOP, labelR, BOTTOM, 0, -5)
  Late:SetColor(1,1,1,1)
  Late:SetText("Overcast")
  Late:SetFont( Lib.GetFont(14) )
  Late:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  Late:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  local function UpdateStats() 
    labelR:SetText(tostring(stats.tardyCast)) 
    labelL:SetText(tostring(stats.earlyCast))
  end

  return {DefineFragmentScenes = DefineFragmentScenes, UpdateStats = UpdateStats, win = win}
end


--[[ --------------- ]]
--[[ -- Interface -- ]]
--[[ --------------- ]]

local function InitializeTimer() 
  local name = idECT.."Timer"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.timer.x, SV.timer.y)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetHidden(true)
  win:SetClampedToScreen(true) 
  win:SetHandler( "OnMoveStop", function() 
    SV.timer.x = win:GetLeft() 
    SV.timer.y = win:GetTop()
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



  local label = WM:CreateControl( name.."Label", ctrl, CT_LABEL )
  label:ClearAnchors() 
  label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  label:SetColor(unpack(SV.timer.color))
  label:SetText("xxx")

  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

  return {DefineFragmentScenes = DefineFragmentScenes, win = win, label = label}
end


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
    return {win = win, controls = controls, Activate = Activate, Deactivate = Deactivate}
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
  local fontList = Lib.GetFontList() 

  Numeric.DefineFragmentScenes(SV.numeric.enabled)

  Numeric.label:SetFont( Lib.GetFont({font=fontList[SV.numeric.font], size = SV.numeric.size, outline=2}) ) 
  local numericHeight = Numeric.label:GetTextHeight() 
  local numericWidth = Numeric.label:GetTextWidth() 
  Numeric.win:SetDimensions(2*numericWidth, 2*numericHeight)

  Timer.DefineFragmentScenes(SV.timer.enabled)
  Timer.label:SetFont( Lib.GetFont({font=fontList[SV.timer.font], size = SV.timer.size, outline=2}) )
  Timer.label:SetText("0s")
  local timerHeight = Timer.label:GetTextHeight() 
  local timerWidth = Timer.label:GetTextWidth() 
  Timer.win:SetDimensions(2*timerWidth, 2*timerHeight)
  Timer.label:SetColor(unpack(SV.timer.color))

  Graphic.DefineFragmentScenes(SV.graphical.enabled)
  Graphic.indicator.ApplyDistance(SV.graphical.distance, SV.graphical.size)
  Graphic.indicator.ApplySize(SV.graphical.size)

  Display.DefineFragmentScenes(SV.stats.display.enabled)

  Numeric.win:SetMovable(not SV.locked) 
  Graphic.win:SetMovable(not SV.locked) 
  Display.win:SetMovable(not SV.locked)
  Timer.win:SetMovable(not SV.locked)

end

local function HideAllGui() 
  Numeric.DefineFragmentScenes(false)
  Timer.DefineFragmentScenes(false)
  Graphic.DefineFragmentScenes(false)
end

--[[ ------------------ ]]
--[[ -- Crux Handler -- ]]
--[[ ------------------ ]]

local function SetCrux(crux) 
  previousCrux = crux
end

local function SoundWarning() 

  if previousCrux == 3 then 
    if SV.soundCue.overcast.enabled then 
      for i=1,SV.soundCue.overcast.volume do 
        PlaySound(SOUNDS[soundList[SV.soundCue.overcast.sound]])
      end
    end
  elseif SV.soundCue.full.enabled then
    for i=1,SV.soundCue.full.volume do 
      PlaySound(SOUNDS[soundList[SV.soundCue.full.sound]])
    end
  end

end

--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnCombatStart() 
  HidePending = false
  ApplySettings() 

  ResetStats()
  Display.UpdateStats()
end 

local function OnCombatEnd()
  if SV.hideOutsideCombat then
    if SV.onlyHideIfZero then  
      HidePending = true
    else 
      HideAllGui()
    end
  end
  
  if SV.stats.chatOutput then  
    --local str = Lib.AddIconToString(Lib.ColorString("Crux Score", {0,1,0,1}), "esoui/art/icons/class_buff_arcanist_crux.dds", 24, "front")
    local str = Lib.ColorString( Lib.AddIconToString("Crux Score", "esoui/art/icons/class/gamepad/gp_class_arcanist.dds", 24, "front"), {0,1,0,1})
    local earlyNum = Lib.ColorString( tostring(stats.earlyCast), {1,0,0,1})
    local earlyStr = Lib.ColorString( "Premature", {0,1,0,1})
    local tardyNum = Lib.ColorString( tostring(stats.tardyCast), {1,0,0,1})
    local tardyStr = Lib.ColorString( "Overcast", {0,1,0,1})
    d(zo_strformat("<<1>>: <<2>> <<3>> <<6>> <<4>> <<5>>", str, earlyNum, earlyStr, tardyNum, tardyStr, Lib.ColorString("&", {1,1,1,1}) ) )
  end
end

local function OnUpdate() 
  local crux = 0 
  local hasCrux = false 
  for i=1,GetNumBuffs("player") do
    local _,_,endTime,_,stack,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
    if abilityId == 184220 then 
      hasCrux = true
      crux = stack 
      Timer.label:SetText( Lib.GetCountdownString( endTime-GetGameTimeSeconds(), true, false, true ) ) 
      break 
    end 
  end

  if not hasCrux then 
    Timer.label:SetText(SV.locked and "" or "0s")  
    if HidePending then 
      HideAllGui()
      HidePending = false
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
    if previousCrux < 3 then 
      stats.earlyCast = stats.earlyCast + 1 
      Display.UpdateStats()
    end
    SetCrux(0)
    return
  end
  if stackCount == 3 then 
    SoundWarning() 
    if previousCrux == 3 then 
      stats.tardyCast = stats.tardyCast + 1 
      Display.UpdateStats()
    end
  end
  SetCrux(stackCount)
end


local function OnPlayerActivated() 
  local crux = 0 
  for i=1,GetNumBuffs("player") do
    local _,_,_,_,stack,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
    if abilityId == 184220 then 
      previousCrux = stack
    end 
  end
end

--[[ ---------- ]]
--[[ -- Menu -- ]]
--[[ ---------- ]]

local function DefineSetting(setting, name, t, k, param, half, tt) 
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
  if tt then 
    s.tooltip = tt 
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

local function TimerSubmenu() 
  local controls = {}

  table.insert(controls, DefineSetting("checkbox", "Enabled", SV.timer, "enabled"))
  table.insert(controls, {type="divider"})
  table.insert(controls, DefineSetting("slider", "Size", SV.timer, "size", {10,80,5}))
  table.insert(controls, {
    type = "dropdown",
    name = "Font",  
    choices = Lib.GetFontList(), 
    getFunc = function() 
      local fontList = Lib.GetFontList()
      return fontList[SV.timer.font] end, 
    setFunc = function(selection)
      local fontList = Lib.GetFontList() 
      for id, font in ipairs(fontList) do 
        if selection == font then 
          SV.timer.font = id
        end
      end
      ApplySettings()
    end,
  }) 
  table.insert(controls, {
    type = "colorpicker",
    name = "Color",
    getFunc = function() return unpack(SV.timer.color) end,	--(alpha is optional)
    setFunc = function(r,g,b)
      SV.timer.color = {r, g, b}
      ApplySettings()
    end,
  })

  return { 
    type = "submenu", 
    name = "Timer", 
    controls = controls,
  }
end


local function GraphicalSubmenu()
  local controls = {}

  table.insert(controls, DefineSetting("checkbox", "Enabled", SV.graphical, "enabled"))
  table.insert(controls, DefineSetting("slider", "Size", SV.graphical, "size", {20, 120, 10}))
  table.insert(controls, DefineSetting("slider", "Spacing", SV.graphical, "distance", {0, 120, 10}))

  return {
    type = "submenu", 
    name = "Graphical Indicator", 
    controls = controls, 
  }
end


local function SoundSubmenu() 
  local controls = {} 

  table.insert(controls, {type="header", name="Full Crux"})
  table.insert(controls, DefineSetting("checkbox", "Enabled", SV.soundCue.full, "enabled", nil, nil, "Plays a sound when you reach three crux."))
  table.insert(controls, {
    type = "dropdown",
    name = "Sound",  
    choices = soundList, 
    getFunc = function() return soundList[SV.soundCue.full.sound] end, 
    setFunc = function(selection)
      for id, sound in ipairs(soundList) do 
        if selection == sound then 
          SV.soundCue.full.sound = id
        end
      end
      PlaySound(SOUNDS[selection])
    end,
  }) 
  table.insert(controls, DefineSetting("slider", "Volume", SV.soundCue.full, "volume", {1,30,1}))

  table.insert(controls, {type="header", name="Overcast"})
  table.insert(controls, DefineSetting("checkbox", "Enabled", SV.soundCue.overcast, "enabled", nil, nil, "Plays a sound when you already have three crux and cast a crux-generating skill."))
  table.insert(controls, {
    type = "dropdown",
    name = "Sound",  
    choices = soundList, 
    getFunc = function() return soundList[SV.soundCue.overcast.sound] end, 
    setFunc = function(selection)
      for id, sound in ipairs(soundList) do 
        if selection == sound then 
          SV.soundCue.overcast.sound = id
        end
      end
      PlaySound(SOUNDS[selection])
    end,
  }) 
  table.insert(controls, DefineSetting("slider", "Volume", SV.soundCue.overcast, "volume", {1,30,1}))


  return {
    type="submenu", 
    name="Sound Cues", 
    controls = controls, 
  }
end


local function StatsSubmenu() 
  local controls = {} 
    table.insert(controls, DefineSetting("checkbox", "Display", SV.stats.display, "enabled", nil, nil, "Window showing coaching stats."))
    table.insert(controls, DefineSetting("checkbox", "Chat Message", SV.stats, "chatOutput", nil, nil, "Outputs coaching stats in chat after each fight."))
    table.insert(controls, {type="header", name="Information"})
    table.insert(controls, {type="description", text=zo_strformat("Mainly aimed at helping <<1>>, the coach is providing statistics on how effectively you handle your Crux.", Lib.ColorString("Damage Dealers", {0,1,1,1}))})
    table.insert(controls, {type="description", title="Premature", text="Using a Crux spending skill, when you have less than 3 Crux. ", width = "half"})
    table.insert(controls, {type="description", title="Overcast", text="Casting a Crux generating skill, when you have already 3 Crux. ", width = "half"})
    table.insert(controls, {type="header", name="Known Issues"})
    table.insert(controls, {type="description", text="Premature cast not registered, if you dont have at least 1 Crux."})
  return {  
    type="submenu", 
    name="Crux Coach (BETA)", 
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
  table.insert(optionsTable, {
    type = "checkbox", 
    name = "Lock Position", 
    getFunc = function() return SV.locked end,
    setFunc = function(bool) 
      SV.locked = bool
      ApplySettings() 
    end,})
  table.insert(optionsTable, {type="divider"})
  table.insert(optionsTable, {
    type = "checkbox", 
    name = "Hide outside Combat", 
    getFunc = function() return SV.hideOutsideCombat end,
    setFunc = function(bool) 
      SV.hideOutsideCombat = bool
      if bool and not Lib.IsInCombat() then 
        HideAllGui() 
      end
      if not bool then 
        ApplySettings() 
      end
    end,})  
    table.insert(optionsTable, {
      disabled = function() return not SV.hideOutsideCombat end,
      type = "checkbox", 
      tooltip = "Changes take effect the next time you leave combat.",
      name = "Keep showing as long as you have Crux", 
      getFunc = function() return SV.onlyHideIfZero end,
      setFunc = function(bool) 
        SV.onlyHideIfZero = bool
      end,})   
  table.insert(optionsTable, NumericSubmenu() ) 
  table.insert(optionsTable, GraphicalSubmenu() )
  table.insert(optionsTable, TimerSubmenu() ) 
  table.insert(optionsTable, SoundSubmenu() ) 
  table.insert(optionsTable, StatsSubmenu() )

  LAM2:RegisterAddonPanel('ExoYCruxTracker_Menu', panelData)
  LAM2:RegisterOptionControls('ExoYCruxTracker_Menu', optionsTable)
end 


--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function GetDefaults() 
  local width, height = GuiRoot:GetDimensions() 
  local defaults = {}
    defaults.locked = false
    defaults.hideOutsideCombat = false
    defaults.onlyHideIfZero = false
    defaults.numeric = { 
      x = width/2, 
      y = height/2, 
      font = 2, 
      size = 30, 
      enabled = true,  
      color = { {0,1,0},{0,1,0},{0,1,0},{0,1,0} }
    }
    defaults.graphical = {
      size = 50,
      distance = 5, 
      x = width/2, 
      y = height/2+100, 
      enabled = true, 
      size = 30, 
      enabled = true,  
    }
    defaults.timer = {
      x = width/2, 
      y = height/2+200, 
      color = {0,1,0},
      enabled = true,
      font = 2, 
      size = 20, 
    }
    defaults.soundCue= {
      full = {
        enabled = true, 
        volume = 1, 
        sound = 1, 
        },
      overcast = {
      enabled = false, 
      volume = 1, 
      sound = 1, 
      },
    }
    defaults.stats = {
      display = {
        enabled = false,
        x = 600, 
        y = 600, 
      }, 
      chatOutput = false,
    }
  return defaults 
end

local function Initialize()
  -- x,y, snapToMiddle, locked, showOutsideCombat, 

  SV = ZO_SavedVars:NewAccountWide("ExoYsCruxTrackerSavedVariables", 1, nil, GetDefaults() )

  InitializeMenu() 

  Numeric = InitializeNumeric() 
  Graphic = InitializeGraphic() 
  Display = InitializeStatistics()
  Timer = InitializeTimer()
  ApplySettings() 

  if not Lib.IsInCombat() and SV.hideOutsideCombat then 
    HideAllGui()
  end

  EM:RegisterForUpdate(idECT, 100, OnUpdate)

  EM:RegisterForEvent(idECT, EVENT_EFFECT_CHANGED, OnCruxChange)
  EM:AddFilterForEvent(idECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, cruxId)
  EM:AddFilterForEvent(idECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

  EM:RegisterForEvent(idECT, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

  Lib.RegisterCombatStart( OnCombatStart )
  Lib.RegisterCombatEnd( OnCombatEnd ) 
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
