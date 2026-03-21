--CruxTracker = CruxTracker or {}

--local ECT = CruxTracker
--local Lib = LibExoYsUtilities

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

local EM = GetEventManager() 
local WM = GetWindowManager()
local SV 

local LibExoY = LibExoYsUtilities

local arcanistId = 117

local idECT = "ExoYsCruxTracker"
local nameECT = "|c00FF00ExoY|rs Crux Tracker"
local versionECT = "2.0.0"

local cruxId = 184220
local cruxDuration = GetAbilityDuration( cruxId )

local Gui = {}
local CruxTracker = {} 
local Update = {}

local uiIsUnlocked = false 
local addonIsSleeping = true 


--[[ ---------------- ]]
--[[ -- Visibility -- ]]
--[[ ---------------- ]]

local function HideGui( ) 
  Giu.symbolic.SetScenes( false ) 
end 


local function ShowGui( showAll )
  Gui.symbolic.SetScenes( showAll or SV.p.symbolic.enabled ) 
end


function SetVisibility() 
  if uiIsUnlocked then ShowGui( true ) return end 
  if addonIsSleeping then HideGui() return end 
  if CruxTracker.hasCrux then ShowGui() return end
  if LibExoY.isInCombat inCombat and SV.p.showAlwaysInCombat then ShowGui() return end 
  if not CruxTracker.hasCrux and SV.p.hideWhenNoCrux then HideGui() return end 
end




--[[ ---------------- ]]
--[[ -- Audio Cues -- ]]
--[[ ---------------- ]]

local soundSelection = {
  [1] = "ABILITY_COMPANION_ULTIMATE_READY",
  [2] = "ABILITY_WEAPON_SWAP_FAIL",
  [3] = "ACTIVE_SKILL_UNMORPHED",
  [4] = "ALCHEMY_CLOSED", 
  [5] = "ALCHEMY_OPENED",
  [6] = "ANTIQUITIES_DIGGING_DIG_POWER_REFUND",
  [7] = "ANTIQUITIES_FANFARE_FRAGMENT_DISCOVERED_FINAL",
  [8] = "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM",
  [9] = "BATTLEGROUND_COUNTDOWN_FINISH",
 [10] = "BATTLEGROUND_MURDERBALL_RETURNED",
 [11] = "COUNTDOWN_TICK",
}

local audioCueList = {
  [1] = {id = "oneCrux", name = ECT_AUDIO_CUE_ONE_CRUX, defaultSound = 1},
  [2] = {id = "twoCrux", name = ECT_AUDIO_CUE_TWO_CRUX, defaultSound = 2}, 
  [3] = {id = "threeCrux", name = ECT_AUDIO_CUE_THREE_CRUX, defaultSound = 3}, 
  [4] = {id = "wasteCrux", name = ECT_AUDIO_CUE_WASTE_CRUX, defaultSound = 4}, 
  [5] = {id = "consumeCrux", name = ECT_AUDIO_CUE_ZERO_CRUX, defaultSound = 5}, 
}

local function GetAudioCueDefaults() 
  local defaults = {}
  local function GetCueDefault( defaultSound ) 
    return {
      enabled = false, 
      sound = defaultSound, 
      volume = 1
    }
  end
  for _, cueInfo in pairs(audioCueList) do 
    defaults[cueInfo.id] = GetCueDefault( cueInfo.defaultSound ) 
  end
  return defaults 
end

local function PlayAudioCue( cueId, overwrite ) 
  local setting = SV.p.audioCue[cueId] 
  if setting.enabled or overwrite then 
    for i = 1, setting.volume do 
      PlaySound(SOUNDS[soundSelection[setting.sound]])
    end
  end 
  d("playing")
end


local function GetAudioCueMenuControls() 
  local controls = {} 
  for _, cueInfo in ipairs(audioCueList) do 
    table.insert(controls, {
      type = "header", 
      name = cueInfo.name,
    })
    table.insert( controls, {
      type = "checkbox", 
      name = ECT_SETTING_ENABLE, 
      getFunc = function() return SV.p.audioCue[cueInfo.id].enabled end, 
      setFunc = function(bool) 
        SV.p.audioCue[cueInfo.id].enabled = bool
      end,
    })
    table.insert(controls, {
      type = "dropdown",
      name = ECT_SETTING_SOUND, 
      choices = soundSelection, 
      getFunc = function() return soundSelection[SV.p.audioCue[cueInfo.id].sound] end, 
      setFunc = function(sound) 
        for idx, str in ipairs(soundSelection) do 
          if str == sound then 
            SV.p.audioCue[cueInfo.id].sound = idx
            PlayAudioCue( cueInfo.id, true )
            break
          end
        end  
      end, 
      width = "half", 
    })
    table.insert(controls, {
      type = "slider",
      name = ECT_SETTING_VOLUME,
      min = 1, 
      max = 10, 
      step = 1, 
      getFunc = function() return SV.p.audioCue[cueInfo.id].volume end, 
      setFunc = function(value) 
        SV.p.audioCue[cueInfo.id].volume = value  
        PlayAudioCue( cueInfo.id, true )
      end, 
      width = "half", 
    })
  end 
  return {
    type = "submenu", 
    name = LibExoY.AddIconToString(ECT_SETTING_AUDIO_CUE, "esoui/art/icons/achievement_u24_teaser_2.dds", 36, "front"), 
    controls = controls,
  }
end

--[[ ---------------------- ]]
--[[ -- Symbolic Tracker -- ]]
--[[ ---------------------- ]]

local function GetSymbolicTrackerSettingDefaults() 
  return {
    enabled = true, 
    posX = 600, 
    posY = 600,
    layout = 2, 
    spacing = 1, 
    size = 1,
  }
end

local function InitializeSymbolicTracker() 
  local name = idECT.."SymbolicIndicator"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.p.symbolic.posX, SV.p.symbolic.posY)
  win:SetMouseEnabled(true) 
  win:SetMovable(true)
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )
  win:SetHidden(false)  --@ToDo
  win:SetHandler( "OnMoveStop", function() 
    SV.p.symbolic.posX = win:GetLeft() 
    SV.p.symbolic.posY = win:GetTop()
  end)

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  local function SetScenes( showUi )
    if showUi then 
      HUD_UI_SCENE:AddFragment( frag )
      HUD_SCENE:AddFragment( frag )
    else 
      HUD_UI_SCENE:RemoveFragment( frag )
      HUD_SCENE:RemoveFragment( frag )
    end
  end 

  local symbols = {}

  local function DefineSymbol(i) 

    local ctrl = WM:CreateControl(name.."_SymbolCtrl"..tostring(i), win, CT_CONTROL)

    local back  = WM:CreateControl(name.."_SymbolBack"..tostring(i), ctrl, CT_TEXTURE )
    back:ClearAnchors()
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    back:SetAlpha(0.8)
    back:SetTexture( "esoui/art/champion/champion_center_bg.dds")

    local frame = WM:CreateControl(name.."_SymbolFrame"..tostring(i), ctrl, CT_TEXTURE )
    frame:ClearAnchors()
    frame:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    frame:SetTexture( "esoui/art/champion/actionbar/champion_bar_slot_frame_disabled.dds")

    local icon = WM:CreateControl( name.."_SymbolIcon"..tostring(i), ctrl, CT_TEXTURE )
    icon:ClearAnchors() 
    icon:SetAnchor( CENTER, ctrl, CENTER, 0, 0 ) 
    icon:SetDesaturation(0.1)
    icon:SetTexture("/art/fx/texture/arcanist_trianglerune_01.dds")

    local highlight  = WM:CreateControl(name.."_SymbolHighlight"..tostring(i), ctrl, CT_TEXTURE )
    highlight:ClearAnchors()
    highlight:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    highlight:SetDesaturation(0.4)
    highlight:SetTexture( "esoui/art/champion/actionbar/champion_bar_world_selection.dds")
    highlight:SetColor(0,1,0,0)


    local function Activate()
      icon:SetColor(0,1,0,1)    
      highlight:SetAlpha(0.8)    
    end

    local function Deactivate()
      icon:SetColor(1,1,1,0.2)
      highlight:SetAlpha(0)
    end

    local function ChangeSize(size)
      back:SetDimensions(size*0.85,size*0.85)  
      frame:SetDimensions(size,size)
      highlight:SetDimensions(size,size)
      icon:SetDimensions(size*0.75,size*0.75)
    end

    return {ctrl = ctrl, Activate = Activate, Deactivate = Deactivate, ChangeSize = ChangeSize}
  end

  for i =1,3 do 
    symbols[i] = DefineSymbol(i)
  end


  local function UpdateLayout()
    local layout = SV.p.symbolic.layout
    local size = SV.p.symbolic.size 
    local spacing = SV.p.symbolic.spacing
    local orientation = {
          [1] = {-1, 0},  -- left
          [2] = { 1, 0},   -- right 
          [3] = { 0,-1},    -- up
          [4] = { 0, 1},  -- down
        }
        local coef = orientation[layout]
    for i = 2,3 do 
      local symbol = symbols[i]
      local offsetX = coef[1]*(i-1)*(size+spacing)
      local offsetY = coef[2]*(i-1)*(size+spacing)
      symbol.ctrl:ClearAnchors() 
      symbol.ctrl:SetAnchor(CENTER, win, CENTER, offsetX, offsetY)      
    end
    for _, symbol in ipairs(symbols) do 
      symbol.ChangeSize( SV.p.symbolic.size ) 
    end
  end

  local function UpdateCrux( crux )
    if crux == 0 then 
      for i = 1,3 do 
        symbols[i].Deactivate()
      end
    else 
      symbols[crux].Activate()
    end

  end

  -- initialize current settings
  symbols[1].ctrl:ClearAnchors() 
  symbols[1].ctrl:SetAnchor(CENTER, win, CENTER, 0, 0) 
  UpdateLayout()

  return {UpdateLayout = UpdateLayout, UpdateCrux = UpdateCrux, SetScenes = SetScenes}
end -- of "InitializeSymbolicTracker"

local function GetSymbolicTrackerMenuControls()
  local controls = {} 
  table.insert( controls, {
    type = "checkbox", 
    name = ECT_SETTING_ENABLE, 
    getFunc = function() return SV.p.symbolic.enabled end, 
    setFunc = function(bool) 
      SV.p.symbolic.enabled = bool
    end,
  })
    table.insert( controls, {
    type = "header", 
    name = ECT_SETTING_DESIGN,
    width = "full", 
  })
  table.insert( controls, {
    type = "slider", 
    name = ECT_SETTING_SIZE, 
    min = 20, 
    max = 80, 
    step = 2, 
    getFunc = function() return SV.p.symbolic.size end, 
    setFunc = function(value) 
      SV.p.symbolic.size = value
      Gui.symbolic.UpdateLayout()
    end
  })
    table.insert( controls, {
    type = "slider", 
    name = ECT_SETTING_SPACING, 
    min = 0, 
    max = 100, 
    step = 2, 
    getFunc = function() return SV.p.symbolic.spacing end, 
    setFunc = function(value) 
      SV.p.symbolic.spacing = value
      Gui.symbolic.UpdateLayout()
    end
  })
  local symbolicLayoutChoices = {
    ECT_SETTING_LAYOUT_LEFT,
    ECT_SETTING_LAYOUT_RIGHT, 
    ECT_SETTING_LAYOUT_UP, 
    ECT_SETTING_LAYOUT_DOWN
  }
  ectGlobal = symbolicLayoutChoices
  table.insert( controls, {
    type = "dropdown", 
    name = ECT_SETTING_LAYOUT, 
    choices = symbolicLayoutChoices, 
    getFunc = function() return symbolicLayoutChoices[SV.p.symbolic.layout] end, 
    setFunc = function(layout)
      for idx, str in ipairs(symbolicLayoutChoices) do 
        if str == layout then 
          SV.p.symbolic.layout = idx
          Gui.symbolic.UpdateLayout()
          break
        end
      end
    end,
  })
  return {
    type = "submenu", 
    name = LibExoY.AddIconToString(ECT_SETTING_SYMBOLIC_TRACKER, "esoui/art/icons/ability_arcanist_010.dds", 36, "front"),
    controls = controls, 
  }
end






--[[ ------------- ]]
--[[ -- Visuals -- ]]
--[[ ------------- ]]





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
  Banner.DefineFragmentScenes(false) 
end


--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]



--[[ ------------------ ]]
--[[ -- Crux Tracker -- ]]
--[[ ------------------ ]]

CruxTracker.hasCrux = false
CruxTracker.maxCrux = false

function CruxTracker:SetCruxInfo( currentCrux, endTimeCrux )
  self.endTimeCrux = endTimeCrux or GetGameTimeSeconds() + cruxDuration/1000

  if currentCrux == 0 then  --- crux consumed/expired 
    self.hasCrux = false 
    PlayAudioCue("consumeCrux")
    Gui.symbolic.UpdateCrux( currentCrux )

  elseif  currentCrux == self.previousCrux then   --- crux wasted
    PlayAudioCue("wasteCrux")
    -- @idea: visual warning (red flash)

  else  --- crux generated
    self.hasCrux = true
    Gui.symbolic.UpdateCrux( currentCrux )
    PlayAudioCue( audioCueList[currentCrux].id )
  end

  self.previousCrux = currentCrux 
end


function CruxTracker:ReadCharacterInfo() 
  for i=1,GetNumBuffs("player") do
    local _,_,endTime,_,stackCount,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
    if abilityId == cruxId then 
      self:SetCruxInfo(stackCount, endTime) 
      break 
    end 
  end  


end


--[[ ------------ ]]
--[[ -- Update -- ]]
--[[ ------------ ]]



local function OnUpdate()   

end


function Update:AddToList() 

end 


function Update:RemoveFromList() 

end


function Update:Start() 
  if not self.isRunning then 
    EM:RegisterForUpdate() 
  end
  self.isRunning = true; 
end


function Update:Stop() 
  if self.isRunning then 
    EM:UnregisterForUpdate() 
  end 
  self.isRunning = false;
end

--[[ ------------------------------- ]]
--[[ -- Activate/Deactivate Addon -- ]]
--[[ --   based on Skill-Lines    -- ]]
--[[ ------------------------------- ]]


local function WakeUp() 
  if not addonIsSleeping then return end    -- cant get any more awake
  addonIsSleeping = false 
  -- Update:Start() if any feature that requires an unpdate is active, start the update 

  -- check settings and apply them 
  -- register events 
  -- initial check of crux 

 
end

local function GoToSleep() 
  if addonIsSleeping then return end  -- dont need to poke a sleeping bear
  addonIsSleeping = true 



  -- unregister all events / updates 
  -- hide ui 



  CruxTracker:SetCruxAmount(0) 
  Update:Stop() 

end




local function CheckSkillLines() 
  hasArcanistSkillLine = false 
  for i=1,3 do
		if SKILLS_DATA_MANAGER:GetActiveClassSkillLine(i):GetClassId() == arcanistId then hasArcanistSkillLine = true end 
	end

  if hasArcanistSkillLine then 
    WakeUp()
  else 
    GoToSleep() 
  end
end









--[[ --------------------------------------- ]]
--[[ -- Initialization, Profiles and Menu -- ]]
--[[ --------------------------------------- ]]

local function GetMenuControls() 
  local controls = {}
  table.insert(controls, {
    type = "checkbox", 
    name = ECT_SETTING_UNLOCK_UI,
    getFunc = function() return uiIsUnlocked end, 
    setFunc = function(bool) 
      uiIsUnlocked = bool 
      SetVisibility()
    end, 
  })
  table.insert( controls, {
    type = "divider"
  })
  -- Visibility 
  table.insert( controls, {
    type = "checkbox", 
    name = ECT_SETTING_HIDE_WHEN_ZERO_CRUX,
    getFunc = function() return SV.p.hideWhenZeroCrux end,
    setFunc = function(bool) 
        SV.p.hideWhenZeroCrux = bool
      end
  })
  table.insert( controls, {
    type = "checkbox", 
    name = ECT_SETTING_SHOW_ALWAYS_IN_COMBAT,
    getFunc = function() return SV.p.showAlwaysInCombat end,
    setFunc = function(bool) 
        SV.p.showAlwaysInCombat = bool
      end
  })
  -- Submenus
  table.insert(controls, GetSymbolicTrackerMenuControls() ) 
  table.insert(controls, GetAudioCueMenuControls() )
  return controls 
end


local function OnProfilChange() 


end


local function ProfileDefaults() 
  return {
    showAlwaysInCombat = true, 
    hideWhenNoCrux = true, 
    symbolic = GetSymbolicTrackerSettingDefaults(),
    audioCue = GetAudioCueDefaults(), 
    number = {
      enabled = true,
    },
  }
end


local function Initialize()

  ---[[ Saved Variables ]]
  local SavedVariablesParameter = {
    svName = "ExoYsCruxTrackerSavedVariables", 
    version = 1, 
    globalDefaults = {}, 
    profileDefaults = ProfileDefaults(), 
    dialogTitle = "ExoYs Crux Tracker", 
    callbacks = { OnProfileChange }, 
  }
  local profileMenu = nil
  SV, GetProfileSubmenu = LibExoY.LoadSavedVariables( SavedVariablesParameter )   

  ---[[ Addon Menu ]]
  local SettingsMenuParameter = {
      name = idECT,
      displayName = nameECT,
      version = versionECT,
      esoui = "info3619-ExoYsCruxTracker.html",
      profiles = GetProfileSubmenu(), 
      controls = GetMenuControls(),  
  } 
  LibExoY.CreateSettingsMenu( SettingsMenuParameter ) 

  Gui.symbolic = InitializeSymbolicTracker() 
  
  LibExoY.RegisterCombatStart( function() SetVisibility() end )
  LibExoY.RegisterCombatEnd( function() SetVisibility() end )

  EM:RegisterForEvent(idECT.."PlayerActivated", EVENT_PLAYER_ACTIVATED, function() 
      CheckSkillLines() 
      EM:UnregisterForEvent( idECT.."PlayerActivated", EVENT_PLAYER_ACTIVATED )
    end )
  EM:RegisterForEvent(idECT.."SkillsUpdated", EVENT_SKILLS_FULL_UPDATE, CheckSkillLines)

  EM:RegisterForEvent(idECT, EVENT_EFFECT_CHANGED, function(_, changeType, _, _, _, _, _, stackCount) 
    if changeType == EFFECT_RESULT_FADED then 
      CruxTracker:SetCruxInfo( 0 ) -- crux consumed/expired
    else 
      CruxTracker:SetCruxInfo( stackCount )  
    end
  end )
  EM:AddFilterForEvent(idECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, cruxId)
  EM:AddFilterForEvent(idECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)


end


local function OnAddonLoaded(_, addonName)
  if addonName == idECT then
    EM:UnregisterForEvent(idECT, EVENT_ADD_ON_LOADED)
    Initialize()
  end
end
EM:RegisterForEvent(idECT, EVENT_ADD_ON_LOADED, OnAddonLoaded)


SLASH_COMMANDS["/ect"] = function(  )

end