local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  -- remove count from totem cooldown swipes
  for i = 1, 4 do
    local frame = _G["TotemFrameTotem"..i.."IconCooldown"]

    if frame then
     frame:SetHideCountdownNumbers(true)
    end
  end
end