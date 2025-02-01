local addonName, ns = ...
local module = ns.Module:new()

local spellList = {
  [99224] = true,  -- Engulfing Flames (Ragnaros)
  [98928] = true,  -- Lava Wave (Ragnaros)
  [99144] = true,  -- Blazing Heat (Ragnaros)
  [97234] = true,  -- Magma Flow (Rhyolith)
  [98885] = true,  -- Brushfire (Alysrazor)
  [99816] = true,  -- Fiery Tornado (Alysrazor)
  [99336] = true,  -- Lava Spew (Alysrazor)
  [100745] = true, -- Firestorm (Alysrazor)
}

module:RegisterEvent("ADDON_LOADED")
module:RegisterEvent("CHAT_MSG_WHISPER")
module:RegisterEvent("ENCOUNTER_START")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:BuildDB()
end

function module:CHAT_MSG_WHISPER(...)
  local msg, _, _, _, name, _, _, _, _, _, _, guid = ...
  if string.lower(msg) ~= "failscore" or not guid then return end

  local player = self.db.playerData[guid]
  local leader = self.db.playerData[self.db.leaderGuid]

  if not leader then return end

  local pluralizeFail = leader.failCount > 1 and " fails" or " fail"
  local leaderMessage = "   ||||   Leader: " .. leader.name .. " (" .. leader.failCount .. pluralizeFails .. ")"
  local message

  if player then
    local failsMessage = " || Fails: " .. player.failCount
    local rankMessage = "Rank: " .. player.rank
    message = rankMessage .. failsMessage
    if rank > 1 then
      message = message .. leaderMessage
    end
  else
    message = "No fails on record" .. leaderMessage
  end

  SendChatMessage(message, "WHISPER", nil, name)
end

function module:COMBAT_LOG_EVENT_UNFILTERED()
  local _, event, _, _, _, _, _, destGuid, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

  if event == "SPELL_DAMAGE" and spellList[spellId] then
    SendChatMessage("FAILSCORE: " .. destName .. " got hit by " .. spellName, "RAID")
    self:AddFail(destGuid, destName)
  end
end

function module:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
  local _, instanceType = GetInstanceInfo()
  if instanceType ~= "raid" then return end

  self:RegisterEvent("ENCOUNTER_END")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function module:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
  self:UnregisterEvent("ENCOUNTER_END")
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:UpdateRankings()
end

function module:BuildDB()
  local db = ns:GetDB()

  -- delete outdated db (8+ hours since creation)
  if not db.failscore or time() - db.failscore.createdTime > 28800 then
    db.failscore = { playerData = {}, createdTime = time(), leaderGuid = nil }
  end

  self.db = db.failscore
end

function module:GetPlayerDB(guid)
  if not self.db.playerData[guid] then
    self.db.playerData[guid] = { failCount = 0 }
  end

  return self.db.playerData[guid]
end

function module:AddFail(guid, name)
  local player = self:GetPlayerDB(guid)

  player.name = name
  player.failCount = player.failCount + 1
end

local function sortFunc(a, b)
  return a.failCount > b.failCount
end

function module:UpdateRankings()
  local sortedList = {}

  for guid, data in pairs(self.db.playerData) do
    tinsert(sortedList, {guid = guid, failCount = data.failCount})
  end

  table.sort(sortedList, sortFunc)

  local currentRank = 1

  for i = 1, #sortedList do
    local player = sortedList[i]

    if i > 1 and player.failCount < sortedList[i-1].failCount then
      currentRank = i
    end

    self.db.playerData[player.guid].rank = currentRank
  end

  self:UpdateLeader(sortedList[1].guid)
end

function module:UpdateLeader(guid)
  if guid ~= self.db.leaderGuid then
    self.db.leaderGuid = guid
    self:AnnounceNewLeader()
  else
    self:AnnounceSameLeader()
  end
end

function module:AnnounceNewLeader()
  local leader = self.db.playerData[self.db.leaderGuid]
  local fails = leader.failCount > 1 and " fails" or " fail"
  local message = "FAILSCORE: " .. leader.name .. " has taken the lead with " .. leader.failCount .. fails .. ". Whisper me 'failscore' for your score."

  SendChatMessage(message, "RAID")
end

function module:AnnounceSameLeader()
  local leader = self.db.playerData[self.db.leaderGuid]
  local fails = leader.failCount > 1 and " fails" or " fail"
  local message = "FAILSCORE: " .. leader.name .. " continues to lead, now with " .. leader.failCount .. fails .. ". Whisper me 'failscore' for your score."

  SendChatMessage(message, "RAID")
end
