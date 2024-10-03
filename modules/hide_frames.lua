local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  PlayerFrameGroupIndicator:SetAlpha(0)
  self:HidePlayerPowerBarAlt()
end

function module:HidePlayerPowerBarAlt()
  if not PlayerPowerBarAlt then return end

  PlayerPowerBarAlt:UnregisterAllEvents()
  PlayerPowerBarAlt:Hide()
end