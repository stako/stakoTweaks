local addonName, ns = ...
local module = ns.Module:new()
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

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

local searingSeed = 98620
local lastSearingSeedTimestamp = 0

local function pluralizeFail(count)
  return count > 1 and "fails" or "fail"
end

module:RegisterEvent("ADDON_LOADED")
module:RegisterEvent("CHAT_MSG_WHISPER")
module:RegisterEvent("ENCOUNTER_START")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:BuildDB()
end

function module:CHAT_MSG_WHISPER(msg, _, _, _, name, _, _, _, _, _, _, guid)
  if string.lower(msg) ~= "failscore" or not guid then return end

  local leader = self.db.playerData[self.db.leaderGuid]
  if not leader then return end

  local message
  local leaderMessage = string.format("  ||  Leader: %s (%d %s)", leader.name, leader.failCount, pluralizeFail(leader.failCount))

  local player = self.db.playerData[guid]
  if player then
    message = string.format("Rank: %s (%d %s)", player.rank, player.failCount, pluralizeFail(player.failCount))
    if player.rank == "TBD" or player.rank > 1 then
      message = message .. leaderMessage
    end
  else
    message = "No fails on record" .. leaderMessage
  end

  SendChatMessage(message, "WHISPER", nil, name)
end

function module:COMBAT_LOG_EVENT_UNFILTERED()
  local timestamp, event, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

  if event == "SPELL_DAMAGE" then
    if spellList[spellId] then
      SendChatMessage(string.format("FAILSCORE: %s got hit by %s", destName, spellName), "RAID")
      self:AddFail(destGuid, destName)
    elseif spellId == searingSeed and sourceGuid ~= destGuid and timestamp - lastSearingSeedTimestamp > 1.0 then
      lastSearingSeedTimestamp = timestamp
      SendChatMessage(string.format("FAILSCORE: %s friendly fired with %s", sourceName, spellName), "RAID")
      self:AddFail(sourceGuid, sourceName)
    end
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
    db.failscore = { playerData = {}, createdTime = time() }
  end

  self.db = db.failscore
end

function module:GetPlayerDB(guid)
  if not self.db.playerData[guid] then
    self.db.playerData[guid] = { failCount = 0, rank = "TBD" }
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
  if self.db.leaderGuid ~= guid then
    self.db.leaderGuid = guid
    self:AnnounceLeader(true)
  else
    self:AnnounceLeader(false)
  end
end

function module:AnnounceLeader(new)
  local leader = self.db.playerData[self.db.leaderGuid]
  local message = new and "has taken the lead with" or "continues to lead, now with"

  message = string.format(
    "FAILSCORE: %s %s %d %s. Whisper me 'failscore' for your score.",
    leader.name,
    message,
    leader.failCount,
    pluralizeFail(leader.failCount)
  )

  SendChatMessage(message, "RAID")
end
