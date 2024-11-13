local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:HidePlayerPowerBarAlt()
end

function module:HidePlayerPowerBarAlt()
  if not PlayerPowerBarAlt then return end

  PlayerPowerBarAlt:UnregisterAllEvents()
  PlayerPowerBarAlt:Hide()
end