local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:HideFrame(PlayerPowerBarAlt)
  self:HideFrame(TargetFramePowerBarAlt)
  self:HideFrame(FocusFramePowerBarAlt)
end

function module:HideFrame(frame)
  if not frame then return end

  frame:UnregisterAllEvents()
  frame:Hide()
end