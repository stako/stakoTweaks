local addonName, addon = ...
local module = addon:NewModule()

-- Bug in Cataclysm Classic: Bag buttons haven't been updated to fit new MainMenuBar bg texture

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:FixNormalTextures()
  self:FixAnchors()
  MainMenuBarBackpackButton:SetSize(30, 30)
  MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", -4, 6)
end

function module:FixNormalTextures()
  local textures = {
    MainMenuBarBackpackButtonNormalTexture,
    CharacterBag0SlotNormalTexture,
    CharacterBag1SlotNormalTexture,
    CharacterBag2SlotNormalTexture,
    CharacterBag3SlotNormalTexture,
  }

  for index, texture in ipairs(textures) do
    texture:SetSize(52, 52)
  end
end

function module:FixAnchors()
  local relativeFrame = MainMenuBarBackpackButton
  local buttons = {
    CharacterBag0Slot,
    CharacterBag1Slot,
    CharacterBag2Slot,
    CharacterBag3Slot,
  }

  for index, button in ipairs(buttons) do
    button:SetPoint("RIGHT", relativeFrame, "LEFT", -2, 0)
    relativeFrame = button
  end
end