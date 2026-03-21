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

local Lib = LibExoYsUtilities --@ToDo

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
    color = {
      [1] = {1,1,1,1},
      [2] = {1,1,1,1},
      [3] = {1,1,1,1},
    },
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
  win:SetHidden(true)
  win:SetHandler( "OnMoveStop", function() 
    SV.p.symbol.posX = win:GetLeft() 
    SV.p.symbol.posY = win:GetTop()
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

  local symbols = {}

  local function DefineSymbol(i) 

    local ctrl = WM:CreateControl(name.."SymbolCtrl"..tostring(i), win, CT_CONTROL)

    local back  = WM:CreateControl(name.."SymbolBack"..tostring(i), ctrl, CT_TEXTURE )
    back:ClearAnchors()
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    back:SetAlpha(0.8)
    back:SetTexture( "esoui/art/champion/champion_center_bg.dds")

    local frame = WM:CreateControl(name.."SymbolFrame"..tostring(i), ctrl, CT_TEXTURE )
    frame:ClearAnchors()
    frame:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    frame:SetTexture( "esoui/art/champion/actionbar/champion_bar_slot_frame_disabled.dds")

    local icon = WM:CreateControl( name.."SymbolIcon"..tostring(i), ctrl, CT_TEXTURE )
    icon:ClearAnchors() 
    icon:SetAnchor( CENTER, ctrl, CENTER, 0, 0 ) 
    icon:SetDesaturation(0.1)
    icon:SetTexture("/art/fx/texture/arcanist_trianglerune_01.dds")

    local highlight  = WM:CreateControl(name.."SymbolHighlight"..tostring(i), ctrl, CT_TEXTURE )
    highlight:ClearAnchors()
    highlight:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    highlight:SetDesaturation(0.4)
    highlight:SetTexture( "esoui/art/champion/actionbar/champion_bar_world_selection.dds")
    highlight:SetColor(0,1,0)

    local function Activate()
      icon:SetColor(unpack(SV.p.symbolic.color[i]))    
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

  local function UpdateSize() 
    for _, symbol in ipairs(symbols) do 
      symbol.ChangeSize( SV.p.symbolic.size ) 
    end
  end

  local function UpdateLayout()
    local layout = SV.p.symbolic.layout
    local size = SV.p.symbolic.size 
    local spacing = SV.p.symbolic.spacing
    local orientation = {
          [1] = {-1, 0},  -- left
          [2] = { 1, 0},   -- right 
          [3] = { 0, 1},    -- up
          [4] = { 0,-1},  -- down
        }
        local coef = orientation[layout]
    for i = 2,3 do 
      local symbol = symbols[i]
      local offsetX = coef[1]*(i-2)*(size+spacing)
      local offsetY = coef[2]*(i-2)*(size+spacing)
      symbol.ctrl:ClearAnchors() 
      symbol.ctrl:SetAnchor(CENTER, win, CENTER, offsetX, offsetY)      
    end
  end

  -- initialize current settings 
  UpdateSize()
  UpdateLayout()

  return {UpdateSize = UpdateSize, UpdateLayout = UpdateLayout}
end

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
    end
  })
    table.insert( controls, {
    type = "slider", 
    name = ECT_SETTING_SPACING, 
    min = 20, 
    max = 80, 
    step = 2, 
    getFunc = function() return SV.p.symbolic.spacing end, 
    setFunc = function(value) 
      SV.p.symbolic.spacing = value
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
          break
        end
      end
    end,
  })
  table.insert( controls, {
    type = "header", 
    name = ECT_SETTING_COLOR,
    width = "full", 
  })
  local colorSettingStr = {
    ECT_SETTING_SYMBOLIC_COLOR_FIRST,
    ECT_SETTING_SYMBOLIC_COLOR_SECOND, 
    ECT_SETTING_SYMBOLIC_COLOR_THIRD,
  }
  for i = 1,3 do 
    table.insert( controls, {
    type = "colorpicker", 
    name = colorSettingStr[i],
    getFunc = function() return unpack(SV.p.symbolic.color[i]) end,
    setFunc = function(r,g,b,a) 
      SV.p.symbolic.color[i] = {r,g,b,a}
    end, 
  })
  end
  return {
    type = "submenu", 
    name = ECT_SETTING_SYMBOLIC_TRACKER,
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


CruxTracker.hasCrux = false;

function CruxTracker:OnCruxChange(changeType, stackCount) 
    if changeType == EFFECT_RESULT_FADED then 
    -- i just spend / lost my crux 
    -- crux amount is zero 
    -- i spend "stackCount amount" 
    self:SetCruxAmount( 0 ) 
  else 
    self:SetCruxAmount( stackCount )-- my new amount of crux is "stackCount" 
  end
end

function CruxTracker:SetCruxAmount( currentCrux, cruxEnd )
  if currentCrux == 0 then 
    self.hasCrux = false 
  else 
    self.hasCrux = true
    self.cruxEnd = cruxEnd and cruxEnd or GetGameTimeSeconds() + cruxDuration
  end
  --Interface:Update( currentCrux ) @ToDo
end

function CruxTracker:ReadCruxInfo() 
  for i=1,GetNumBuffs("player") do
    local _,_,endTime,_,stackCount,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
    if abilityId == cruxId then 
      self:SetCruxAmount(stackCount, endTime) 
      break 
    end 
  end  


end


----


local function OnPlayerActivated() 
  local crux = 0 
  for i=1,GetNumBuffs("player") do
    local _,_,_,_,stack,_,_,_,_,_,abilityId = GetUnitBuffInfo("player", i)
    if abilityId == cruxId then 
      previousCrux = stack
    end 
  end
end



--[[ ------------ ]]
--[[ -- Update -- ]]
--[[ ------------ ]]



local function OnUpdate()   
  Visuals:Update( GetGameTimeMilliSeconds() ) 
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

local isAwake = false 


local function ManageEvents( deactivateAll ) 
 
  

end


local function WakeUp() 
  if isAwake then return end    -- cant get any more awake
  
  -- Update:Start() if any feature that requires an unpdate is active, start the update 

  -- check settings and apply them 
  -- register events 
  -- initial check of crux 
  isAwake = true
end

local function GoToSleep() 
  if not isAwake then return end  -- dont need to poke a sleeping bear
  -- unregister all events / updates 
  -- hide ui 
  CruxTracker:SetCruxAmount(0) 
  Update:Stop() 

  isAwake = false
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
  d("ECT - Skill lines checked")
end









--[[ --------------------------------------- ]]
--[[ -- Initialization, Profiles and Menu -- ]]
--[[ --------------------------------------- ]]

local function GetMenuControls() 
  local controls = {}
    table.insert( controls, {
    type = "button", 
    name = "Unlock/Lock"
  })
  table.insert( controls, {
    type = "button", 
    name = "Demo"
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

  return controls 
end


local function OnProfilChange() 

end


local function ProfileDefaults() 
  return {
    showAlwaysInCombat = true, 
    hideWhenZeroCrux = true, 
    symbolic = GetSymbolicTrackerSettingDefaults(),
    number = {
      enabled = true,
    },
    audioCue = {
      oneCrux = { 
        sound = 1,
        volumne = 1,  
      },
      twoCrux = {
        sound = 1,
        volume = 1,
      },
      threeCrux = {
        sound = 1,
        volume = 1,
      }, 
      cruxConsum = {
        sound = 1, 
        volume = 1, 
      },
      cruxOverstack = {
        sound = 1, 
        volume = 1,
      }
    }
  }
end





local function Initialize()
  -- x,y, snapToMiddle, locked, showOutsideCombat, 
  
  local isLocked = true

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

  EM:RegisterForEvent(idECT.."PlayerActivated", EVENT_PLAYER_ACTIVATED, function() 
      cruxDuration = GetAbilityDuration( cruxId )  
      CheckSkillLines() -- check at character login 
      EM:UnregisterForEvent( idECT.."PlayerActivated", EVENT_PLAYER_ACTIVATED )
    end )
  EM:RegisterForEvent(idECT.."SkillsUpdated", EVENT_SKILLS_FULL_UPDATE, CheckSkillLines)



  EM:RegisterForEvent(idECT, EVENT_EFFECT_CHANGED, function(_, changeType, _, _, _, _, _, stackCount) CruxTracker:OnCruxChange( changeType, stackCount) end )
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