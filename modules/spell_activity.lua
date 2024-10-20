local addonName, ns = ...
local module = ns.Module:new()

local SPELL_ACTIVITY_SPEED = 0.4
local SPELL_ACTIVITY_DURATION = 5
local SPELL_ACTIVITY_MAX = 5

local BLOCKLISTED_ACTIVITY_SPELLS = {
  -- Misc
  [93079] = "Launch Quest",
  [836] = "LOGINEFFECT",
  [6478] = "Opening",

  -- Hunter
  [75] = "Auto Shot",
  [37506] = "Scatter Shot",
  [80325] = "Camouflage",

  -- Rogue
  [5374] = "Mutilate",
  [27576] = "Mutilate Off-Hand"
}

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self.spellActivityFrames = CreateFramePool("Frame", UIParent, "stakoSpellActivityFrameTemplate", self.ResetSpellActivityFrame)
  self.spellActivityFrames.last = nil

  module:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

  local animManager = CreateFrame("Frame")
  animManager:SetScript("OnUpdate", self.OnUpdate)
end

function module:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
  if BLOCKLISTED_ACTIVITY_SPELLS[spellID] then return end

  local _, spellTextureNoOverride = GetSpellTexture(spellID)
  self:AddSpellActivityFrame(spellTextureNoOverride)
end

function module:AddSpellActivityFrame(icon, fast)
  local lastFrame = self.spellActivityFrames.last

  if lastFrame ~= nil and lastFrame.AnimIn:IsPlaying() then
    C_Timer.After(lastFrame.AnimIn:GetDuration(), function()
      if lastFrame ~= nil then
        self:AddSpellActivityFrame(icon, true)
      end
    end)
    return
  end

  local newFrame = self.spellActivityFrames:Acquire()
  newFrame.createdAt = GetTime()
  newFrame.Icon:SetTexture(icon)
  if fast then
    newFrame.AnimIn.Alpha:SetDuration(SPELL_ACTIVITY_SPEED / 2)
    newFrame.AnimIn.Translation:SetDuration(SPELL_ACTIVITY_SPEED / 2)
  end
  newFrame.AnimIn:Play()

  if lastFrame ~= nil and lastFrame ~= newFrame and not lastFrame.AnimOut:IsPlaying() then
    if fast then
      lastFrame.AnimRight.Translation:SetDuration(SPELL_ACTIVITY_SPEED / 2)
    end
    lastFrame.AnimRight:Play()
    lastFrame.AnimRight:SetScript("OnFinished", function(self)
      local parent = self:GetParent()
      parent:ClearAllPoints()
      parent:SetPoint("RIGHT", newFrame, "RIGHT", 32, 0)
      parent:SetParent(newFrame)
    end)
  end

  self.spellActivityFrames.last = newFrame
end

function module.ResetSpellActivityFrame(framePool, frame)
  if frame.AnimOut:IsPlaying() then
      frame.AnimOut:Stop()
  end
  if frame.AnimIn:IsPlaying() then
      frame.AnimIn:Stop()
  end
  if frame.AnimRight:IsPlaying() then
      frame.AnimRight:Stop()
  end
  frame:SetAlpha(0)
  frame:Hide()
  frame:SetParent(UIParent)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 55, 18)
  frame.AnimIn.Alpha:SetDuration(SPELL_ACTIVITY_SPEED)
  frame.AnimIn.Translation:SetDuration(SPELL_ACTIVITY_SPEED)
  frame.AnimOut.Alpha:SetDuration(SPELL_ACTIVITY_SPEED)
  frame.AnimRight.Translation:SetDuration(SPELL_ACTIVITY_SPEED)
  frame.createdAt = nil
  frame.expired = false
end

local timeElapsed = 0

function module.OnUpdate(frame, elapsed)
  timeElapsed = timeElapsed + elapsed
  if timeElapsed < 0.2 then return end

  timeElapsed = 0
  local sortedFrames = {}

  for frame in module.spellActivityFrames:EnumerateActive() do
    table.insert(sortedFrames, frame)
  end

  table.sort(sortedFrames, module.SortFunc)

  for i, frame in ipairs(sortedFrames) do
    if GetTime() >= (frame.createdAt + SPELL_ACTIVITY_DURATION) and not (frame.AnimOut:IsPlaying() or frame.expired) then
      frame.AnimOut:Play()
    end

    if module.spellActivityFrames:GetNumActive() > SPELL_ACTIVITY_MAX or frame.expired then
      module.spellActivityFrames:Release(frame)
    end
  end
end

function module.SortFunc(a, b)
    return a.createdAt < b.createdAt
end