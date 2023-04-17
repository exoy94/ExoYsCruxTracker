CruxTracker = CruxTracker or {}

local ECT = CruxTracker
local Lib = LibExoYsUtilities

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

local EM = GetEventManager() 
local WM = GetWindowManager()
local SV 

local idECT = "ExoYsCruxTracker"

local Gui

--[[ -------------- ]]
--[[ -- Graphics -- ]]
--[[ -------------- ]]

local function InitializeGui() 
  local name = idECT

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 600, 600)
  win:SetMouseEnabled(true) 
  win:SetClampedToScreen(true) 
  win:SetDimensions( 50,50 )

  local frag = ZO_HUDFadeSceneFragment:New( win ) 
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = WM:CreateControl( name.."Ctrl", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(CENTER, win, CENTER, 0, 0)

  local label = WM:CreateControl( name.."Label", ctrl, CT_LABEL )
  label:ClearAnchors() 
  label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  label:SetFont( Lib.GetFont(30) )

  -- function to change indicator (probably only needed for propper graphical ui )

  local function PlaceHolder() 
    local numCrux = 0 

    label:SetText(tostring(numCrux))
  end

    -- register here the event, necessary to track the crux 

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
  return defaults 
end

local function Initialize()
  -- x,y, snapToMiddle, locked, showOutsideCombat, 

  -- SV = ZO_SavedVars:NewCharacterIdSettings("ECTSV", 1, nil, GetDefaults() )


  -- create menu 
  -- create gui 
  Gui = InitializeGui() 

  -- TODO publish version 6 of lib!!! 
  -- Lib.RegisterCombatStart( OnCombatStart )
  -- Lib.RegisterCombatEnd( OnCombatEnd ) 
end


local function OnAddonLoaded(_, addonName)
  if addonName == idECT then
    Initialize()
    EM:UnregisterForEvent(idECT, EVENT_ADD_ON_LOADED)
  end
end
EM:RegisterForEvent(idECT), EVENT_ADD_ON_LOADED, OnAddonLoaded)



