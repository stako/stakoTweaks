local addonName, addon = ...
local module = addon:NewModule()

-- Bug in Cataclysm Classic: "characterFrameCollapsed" CVar doesn't exist.
-- As a result, character stats sheet is always collapsed.

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  PaperDollFrame:HookScript("OnShow", function() CharacterFrame:Expand() end)
  PetPaperDollFrame:HookScript("OnShow", function() CharacterFrame:Expand() end)
end
