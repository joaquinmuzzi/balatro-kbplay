--[[
  What the keyboard can do on each screen, keyed by G.STATES name.

  zones   - what Tab cycles through; the first one has focus on arrival
  primary - what Enter does when no card of a single-select zone is chosen
  keys    - screen-specific actions (action name from keymap -> function)
]]
local A = require("kbplay.actions")

local S = {}

S.SELECTING_HAND = {
  zones = { "hand", "jokers", "consumables" },
  primary = A.play,
  keys = {
    discard = A.discard,
    sort_rank = A.sort_rank,
    sort_suit = A.sort_suit,
  },
}

S.BLIND_SELECT = {
  zones = { "jokers", "consumables" },
  primary = A.select_blind,
  keys = {
    skip = A.skip_blind,
    reroll = A.reroll_boss,
  },
}

S.ROUND_EVAL = {
  zones = { "jokers", "consumables" },
  primary = A.cash_out,
}

S.SHOP = {
  zones = { "shop", "jokers", "consumables" },
  keys = {
    reroll = A.reroll_shop,
    next_round = A.next_round,
  },
}

-- Arcana / Spectral packs target hand cards, so the hand is reachable too.
local booster = {
  zones = { "pack", "hand", "jokers", "consumables" },
  keys = {
    skip = A.skip_booster,
  },
}
for _, name in ipairs {
  "TAROT_PACK",
  "PLANET_PACK",
  "SPECTRAL_PACK",
  "STANDARD_PACK",
  "BUFFOON_PACK",
  "SMODS_BOOSTER_OPENED", -- only exists with Steamodded
} do
  S[name] = booster
end

return S
