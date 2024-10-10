local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  PetFrame:ClearAllPoints()
  PetFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 70, -18)
end