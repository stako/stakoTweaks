local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  TargetFrameNameBackground:SetTexture()
  TargetFrameHealthBar.lockColor = true
  FocusFrameHealthBar.lockColor = true
  TargetFrameHealthBar:SetSize(120, 25)
  TargetFrameHealthBar:SetPoint("TOPRIGHT", -106, -24)
  TargetFrameManaBar:SetSize(120, 12)
  TargetFrameTextureFrameDeadText:SetPoint("CENTER", -50, 7)
  FocusFrameTextureFrameDeadText:SetPoint("CENTER", -50, 7)
  TargetFrameTextureFrame.HealthBarText:SetPoint("CENTER", -50, 7)
  TargetFrameTextureFrame.HealthBarTextLeft:SetPoint("LEFT", 6, 7)
  TargetFrameTextureFrame.HealthBarTextRight:SetPoint("RIGHT", -110, 7)
  TargetFrameTextureFrame.ManaBarText:SetPoint("CENTER", -50, -7)
  TargetFrameTextureFrame.ManaBarTextLeft:SetPoint("LEFT", 6, -7)
  TargetFrameTextureFrame.ManaBarTextRight:SetPoint("RIGHT", -110, -7)

  FocusFrameNameBackground:SetTexture()
  FocusFrameHealthBar:SetSize(120, 25)
  FocusFrameHealthBar:SetPoint("TOPRIGHT", -106, -24)

  hooksecurefunc("TargetFrame_CheckClassification", module.TargetFrame_CheckClassification)
  hooksecurefunc("UnitFrameHealthBar_Update", module.UnitFrameHealthBar_Update)
end

function module.TargetFrame_CheckClassification(self, forceNormalTexture)
  local classification = UnitClassification(self.unit)

  if forceNormalTexture then
    self.borderTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame")
  elseif classification == "minus" then
    self.borderTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame-Minus")
  elseif classification == "worldboss" or classification == "elite" then
		self.borderTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame-Elite")
		-- self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
	elseif classification == "rareelite" then
		self.borderTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame-Rare-Elite")
	elseif classification == "rare" then
		self.borderTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame-Rare")
	else
		self.borderTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame")
	end

  self.Background:SetPoint("BOTTOMLEFT", 6, 35)
  self.Background:SetSize(119, 41)
end

function module.UnitFrameHealthBar_Update(statusbar, unit)
  if  (statusbar ~= TargetFrameHealthBar and statusbar ~= FocusFrameHealthBar) or unit ~= statusbar.unit then
    return
  end

  if statusbar.disconnected then
    statusbar:SetStatusBarColor(0.5, 0.5, 0.5)
  elseif UnitIsPlayer(unit) then
    local _, class = UnitClass(unit)
    statusbar:SetStatusBarColor(RAID_CLASS_COLORS[class]:GetRGB())
  else
    statusbar:SetStatusBarColor(0, 1, 0)
  end
end
