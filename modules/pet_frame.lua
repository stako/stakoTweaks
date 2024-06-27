local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  PetFrame:ClearAllPoints()
  PetFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 70, -18)
end