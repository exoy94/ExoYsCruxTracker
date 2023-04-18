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

local Gui

--[[ -------------- ]]
--[[ -- Graphics -- ]]
--[[ -------------- ]]

local function InitializeGui() 
  local name = idECT

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

  SV = ZO_SavedVars:NewCharacterIdSettings("ECTSV", 1, nil, GetDefaults() )


  -- create menu 
  -- create gui 
  InitializeGui() 

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



