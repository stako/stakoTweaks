if WOW_PROJECT_ID ~= WOW_PROJECT_CATACLYSM_CLASSIC then return end

local addonName, ns = ...
local module = ns.Module:new()

local raptureId = 47755
local _, textureId = GetSpellTexture(raptureId)
local frameSize = 22
local framePosition = {"BOTTOMLEFT", PlayerFrame, "TOPLEFT", 98, -18}

local pixel = PixelUtil.GetNearestPixelSize(1, UIParent:GetScale())

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:BuildIcon()
  module:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function module:BuildIcon()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetSize(frameSize, frameSize)
  frame:SetPoint(unpack(framePosition))
  frame:Hide()

  local texture = frame:CreateTexture(nil, "ARTWORK")
  texture:SetAllPoints()
  texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  texture:SetTexture(textureId)

  local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
  cooldown:SetPoint("TOPLEFT", pixel, -pixel)
  cooldown:SetPoint("BOTTOMRIGHT", -pixel, pixel)
  cooldown:SetReverse(true)
  cooldown:SetDrawEdge(true)
  cooldown:SetDrawBling(false)
  cooldown:SetHideCountdownNumbers(true)
  cooldown:SetScript("OnHide", function() frame:Hide() end)

  local borderFrame = CreateFrame("Frame", nil, frame)
  borderFrame:SetFrameLevel(5)
  borderFrame:SetAllPoints()

  local border = borderFrame:CreateTexture(nil, "ARTWORK")
  border:SetAtlas("CommentatorSpellBorder")
  border:SetPoint("CENTER")
  border:SetSize(frameSize * 1.6, frameSize * 1.6)

  self.frame = frame
  self.cooldown = cooldown
end

function module:COMBAT_LOG_EVENT_UNFILTERED()
  local _, _, _, _, sourceName, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()
  if spellId ~= raptureId or sourceName ~= UnitName('player') then return end

  self.frame:Show()
  self.cooldown:SetCooldown(GetTime(), 12)
end