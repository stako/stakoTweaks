local addonName, addon = ...
local module = addon:NewModule()

-- Fixes various Cataclysm UI bugs:
-- Invalid spec on inspection window
-- Bag buttons don't fit action bar artwork
-- Character stats panel is always collapsed
-- Character stats panel is missing alternating backdrops

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name == "Blizzard_InspectUI" then
    InspectPaperDollFrame_SetLevel = self.InspectPaperDollFrame_SetLevel
  elseif name ~= addonName then return end

  self:FixBagButtons()
  self:FixStatsPanel()

	PlayerFrameGroupIndicator:SetAlpha(0)
end

function module:InspectPaperDollFrame_SetLevel()
  local unit = InspectFrame.unit
  if not unit then return end

  local activeTalentGroup = GetActiveTalentGroup(true, false)
  local primaryTalentTree = GetPrimaryTalentTree(true, false, activeTalentGroup)
  local _, specName
  if primaryTalentTree then
    _, specName = GetTalentTabInfo(primaryTalentTree, true, false, activeTalentGroup)
  end

  local classDisplayName, class = UnitClass(unit)
  local classColor = RAID_CLASS_COLORS[class]
  local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

  if (specName and specName ~= "") then
    InspectLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel(unit), classColorString, specName, classDisplayName);
  else
    InspectLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel(unit), classColorString, classDisplayName);
  end
end

function module:FixBagButtons()
  MainMenuBarBackpackButton:SetSize(30, 30)
  MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", -4, 6)

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

function module:FixStatsPanel()
  PaperDollFrame:HookScript("OnShow", function() CharacterFrame:Expand() end)
  PetPaperDollFrame:HookScript("OnShow", function() CharacterFrame:Expand() end)
  PaperDollFrame_UpdateStatCategory = module.PaperDollFrame_UpdateStatCategory
end

function module.PaperDollFrame_UpdateStatCategory(categoryFrame)
	if (not categoryFrame.Category) then
		categoryFrame:Hide()
		return
	end

	local categoryInfo = PAPERDOLL_STATCATEGORIES[categoryFrame.Category]

	categoryFrame.NameText:SetText(_G["STAT_CATEGORY_"..categoryFrame.Category])

	if (categoryFrame.collapsed) then
		return
	end

	local stat
	local totalHeight = categoryFrame.NameText:GetHeight() + 10
	local numVisible = 0
	if (categoryInfo) then
		local prevStatFrame = nil
		for index, stat in next, categoryInfo.stats do
			local statInfo = PAPERDOLL_STATINFO[stat]
			if (statInfo) then
				local statFrame = _G[categoryFrame:GetName().."Stat"..numVisible+1]
				if (not statFrame) then
					statFrame = CreateFrame("FRAME", categoryFrame:GetName().."Stat"..numVisible+1, categoryFrame, "CharacterStatFrameTemplate")
					if (prevStatFrame) then
						statFrame:SetPoint("TOPLEFT", prevStatFrame, "BOTTOMLEFT", 0, 0)
						statFrame:SetPoint("TOPRIGHT", prevStatFrame, "BOTTOMRIGHT", 0, 0)
					end
				end
				statFrame:Show()
				-- Reset tooltip script in case it's been changed
				statFrame:SetScript("OnEnter", PaperDollStatTooltip)
				statFrame.tooltip = nil
				statFrame.tooltip2 = nil
				statFrame.UpdateTooltip = nil
				statFrame:SetScript("OnUpdate", nil)
				statInfo.updateFunc(statFrame, CharacterStatsPane.unit)
				if (statFrame:IsShown()) then
					numVisible = numVisible+1
					totalHeight = totalHeight + statFrame:GetHeight()
					prevStatFrame = statFrame
					-- Update Tooltip
					if (GameTooltip:GetOwner() == statFrame) then
						statFrame:GetScript("OnEnter")(statFrame)
					end
				end
			end
		end
	end

	local i
	for index=1, numVisible do
		if (index%2 == 0) then
			local statFrame = _G[categoryFrame:GetName().."Stat"..index]
			if (not statFrame.Bg) then
				statFrame.Bg = statFrame:CreateTexture(statFrame:GetName().."Bg", "BACKGROUND")
				statFrame.Bg:SetPoint("LEFT", categoryFrame, "LEFT", 1, 0)
				statFrame.Bg:SetPoint("RIGHT", categoryFrame, "RIGHT", 0, 0)
				statFrame.Bg:SetPoint("TOP")
				statFrame.Bg:SetPoint("BOTTOM")
				statFrame.Bg:SetColorTexture(0.9, 0.9, 1)
				statFrame.Bg:SetAlpha(0.1)
			end
		end
	end

	-- Hide all other stats
	local index = numVisible + 1
	while (_G[categoryFrame:GetName().."Stat"..index]) do 
		_G[categoryFrame:GetName().."Stat"..index]:Hide()
		index = index + 1
	end

	-- Hack to fix category frames that only have 1 item in them
	if (totalHeight < 44) then
		categoryFrame.BgBottom:SetHeight(totalHeight - 2)
	else
		categoryFrame.BgBottom:SetHeight(46)
	end

	categoryFrame:SetHeight(totalHeight)
end
