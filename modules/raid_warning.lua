local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  RaidBossEmoteFrame:ClearAllPoints()
  RaidBossEmoteFrame:SetPoint("BOTTOM", UIErrorsFrame, "TOP", 0, -30)
end