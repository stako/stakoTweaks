local addonName, addon = ...
local module = addon:NewModule()

local cvarList = {
  ColorNameplateNameBySelection = 1,
  noBuffDebuffFilterOnTarget = 0,
  WorldTextScale = 0.5,
  -- ShowClassColorInNameplate = 1,
  -- ShowClassColorInFriendlyNameplate = 1,
  -- nameplateGlobalScale = 0.85,
  -- nameplateSelectedScale = 1.08,
  -- NamePlateVerticalScale = 0.9,
  clampTargetNameplateToScreen = 1,
  nameplateTargetRadialPosition = 1,
  -- nameplateShowAll = 1,
  -- nameplateShowEnemyGuardians = 1,
  -- nameplateShowEnemyMinions = 1,
  -- nameplateShowEnemyMinus = 0,
  -- nameplateShowEnemyPets = 1,
  -- nameplateShowEnemyTotems = 1,
  -- nameplateShowFriendlyGuardians = 0,
  -- nameplateShowFriendlyMinions = 0,
  -- nameplateShowFriendlyNPCs = 0,
  -- nameplateShowFriendlyPets = 0,
  -- nameplateShowFriendlyTotems = 0,
  ResampleAlwaysSharpen = 1,
  ResampleSharpness = 0.5,
  weatherDensity = 0,
}

addon:RegisterEvent("VARIABLES_LOADED")

function module:VARIABLES_LOADED()
  for cvar, value in pairs(cvarList) do
    SetCVar(cvar, value)
  end
end
