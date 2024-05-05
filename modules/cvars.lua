local addonName, addon = ...
local module = addon:NewModule()

local cvarList = {
  ColorNameplateNameBySelection = 1,
  noBuffDebuffFilterOnTarget = 0,
  WorldTextScale = 0.6,
  nameplateGlobalScale = 0.85,
  nameplateSelectedScale = 1.08,
  clampTargetNameplateToScreen = 1,
  nameplateTargetRadialPosition = 1,
}

addon:RegisterEvent("VARIABLES_LOADED")

function module:VARIABLES_LOADED(name)
  for cvar, value in pairs(cvarList) do
    SetCVar(cvar, value)
  end
end
