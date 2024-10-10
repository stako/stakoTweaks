local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  RaidBossEmoteFrame:ClearAllPoints()
  RaidBossEmoteFrame:SetPoint("BOTTOM", UIErrorsFrame, "TOP", 0, -30)
end