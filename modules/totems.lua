local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  -- remove count from totem cooldown swipes
  for i = 1, 4 do
    local frame = _G["TotemFrameTotem"..i.."IconCooldown"]

    if frame then
     frame:SetHideCountdownNumbers(true)
    end
  end

  local timers = {
    TotemFrameTotem1Duration,
    TotemFrameTotem2Duration,
    TotemFrameTotem3Duration,
    TotemFrameTotem4Duration,
  }

  -- for index, timer in ipairs(timers) do
  --   timer:ClearAllPoints()
  --   timer:SetPoint("BOTTOM", timer:GetParent(), "TOP", 0, 0)
  -- end

  -- TotemFrame:ClearAllPoints()
  -- TotemFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 96, -38)
end