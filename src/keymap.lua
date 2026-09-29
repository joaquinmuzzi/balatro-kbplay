--[[
  Keybinds: action -> key combo. A combo is a LÖVE key name optionally
  prefixed by modifiers, e.g. "return", "shift+return", "ctrl+alt+x".

  Players can override any bind without touching the mod by creating
  `kbplay-keys.lua` in the Balatro save folder (%AppData%/Balatro on Windows):

    return { discard = "q", sell = "ctrl+backspace", sort_suit = false }

  `false` disables an action.
]]
local log = require("kbplay.log")

local M = {}

M.defaults = {
  -- toggle the Nth card of the focused zone
  card_1 = "1",
  card_2 = "2",
  card_3 = "3",
  card_4 = "4",
  card_5 = "5",
  card_6 = "6",
  card_7 = "7",
  card_8 = "8",
  card_9 = "9",
  card_10 = "0",

  focus_next = "tab",
  focus_prev = "shift+tab",

  primary = "return", -- play hand / select blind / cash out / buy / use / pick
  secondary = "shift+return", -- buy and use
  discard = "d",
  sell = "delete",
  deselect = "backspace",
  move_left = "shift+left",
  move_right = "shift+right",

  sort_rank = "z",
  sort_suit = "x",
  skip = "k", -- skip blind / skip booster pack
  reroll = "r", -- reroll shop / reroll boss
  next_round = "n", -- leave the shop
}

M.OVERRIDES_FILE = "kbplay-keys.lua"

local MODIFIERS = { "ctrl", "alt", "shift" }

-- Canonical form so "shift+ctrl+x" and "ctrl+shift+x" match the same combo.
local function normalize(combo)
  local parts = {}
  for part in combo:gmatch("[^+]+") do
    parts[#parts + 1] = part
  end
  local key = table.remove(parts)
  local held = {}
  for _, part in ipairs(parts) do
    held[part] = true
  end
  local out = {}
  for _, mod in ipairs(MODIFIERS) do
    if held[mod] then out[#out + 1] = mod end
  end
  out[#out + 1] = key
  return table.concat(out, "+")
end

local function read_overrides()
  if not love.filesystem.getInfo(M.OVERRIDES_FILE) then return {} end
  local ok, result = pcall(function()
    return love.filesystem.load(M.OVERRIDES_FILE)()
  end)
  if ok and type(result) == "table" then return result end
  log.error("ignoring " .. M.OVERRIDES_FILE .. ": " .. tostring(result))
  return {}
end

-- combo -> action
M.by_combo = {}

function M.load()
  local binds = {}
  for action, combo in pairs(M.defaults) do
    binds[action] = combo
  end
  for action, combo in pairs(read_overrides()) do
    binds[action] = combo or nil
  end

  M.by_combo = {}
  for action, combo in pairs(binds) do
    local canonical = normalize(combo)
    if M.by_combo[canonical] then
      log.error(("'%s' is bound to both %s and %s"):format(canonical, M.by_combo[canonical], action))
    end
    M.by_combo[canonical] = action
  end
end

---@param key string key just pressed
---@param held table<string, boolean> G.CONTROLLER.held_keys
---@return string|nil action
function M.action_for(key, held)
  local out = {}
  for _, mod in ipairs(MODIFIERS) do
    if held["l" .. mod] or held["r" .. mod] then out[#out + 1] = mod end
  end
  out[#out + 1] = key
  return M.by_combo[table.concat(out, "+")]
end

return M
