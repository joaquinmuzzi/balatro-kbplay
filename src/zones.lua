--[[
  A zone is a group of cards the keyboard can point at. Most zones are one
  CardArea; the shop zone merges the three shop rows so 1..0 index across
  jokers, vouchers and boosters.

  Only the hand allows several highlighted cards; in other zones selecting a
  card releases the previous one.
]]
local M = {}

local function concat(...)
  local out = {}
  for _, area in ipairs { ... } do
    if area and area.cards then
      for _, card in ipairs(area.cards) do
        out[#out + 1] = card
      end
    end
  end
  return out
end

M.defs = {
  hand = {
    label = "Mano",
    multi = true,
    cards = function() return concat(G.hand) end,
  },
  jokers = {
    label = "Jokers",
    cards = function() return concat(G.jokers) end,
  },
  consumables = {
    label = "Consumibles",
    cards = function() return concat(G.consumeables) end,
  },
  shop = {
    label = "Tienda",
    cards = function() return concat(G.shop_jokers, G.shop_vouchers, G.shop_booster) end,
  },
  pack = {
    label = "Sobre",
    cards = function() return concat(G.pack_cards) end,
  },
}

function M.cards(zone)
  local def = M.defs[zone]
  return def and def.cards() or {}
end

function M.selected(zone)
  local out = {}
  for _, card in ipairs(M.cards(zone)) do
    if card.highlighted then out[#out + 1] = card end
  end
  return out
end

-- The card whose tooltip we are showing, as if the mouse hovered it.
local hovered

local function show_tooltip(card)
  if hovered and hovered ~= card then pcall(hovered.stop_hover, hovered) end
  hovered = card
  if card then card:hover() end
end

function M.toggle(zone, index)
  local def = M.defs[zone]
  local card = def and def.cards()[index]
  if not card then
    play_sound("cancel")
    return
  end
  if not def.multi then
    for _, other in ipairs(M.selected(zone)) do
      if other ~= card then other:click() end
    end
  end
  card:click()
  show_tooltip(card.highlighted and card or nil)
end

function M.deselect(zone)
  if zone == "hand" and G.hand then
    G.hand:unhighlight_all()
  else
    for _, card in ipairs(M.selected(zone)) do
      card:click()
    end
  end
  show_tooltip(nil)
  play_sound("cardSlide2", nil, 0.3)
end

-- Move the single selected card one slot left (-1) or right (+1) inside its
-- own area. Useful for joker order and hand arrangement.
function M.move(zone, step)
  local selected = M.selected(zone)
  if #selected ~= 1 then return false end
  local card = selected[1]
  local cards = card.area and card.area.cards
  if not cards then return false end
  for i, c in ipairs(cards) do
    if c == card then
      local j = i + step
      if j < 1 or j > #cards then return true end
      cards[i], cards[j] = cards[j], cards[i]
      play_sound("cardSlide1")
      return true
    end
  end
  return false
end

-- Feedback when focus changes: a floating label plus a nudge on the zone.
function M.announce(zone)
  local def = M.defs[zone]
  if not def then return end
  play_sound("cardSlide1")
  if G.play then
    pcall(attention_text, {
      text = def.label,
      scale = 0.6,
      hold = 0.6,
      major = G.play,
      align = "cm",
      offset = { x = 0, y = -1 },
      silent = true,
    })
  end
  local first = def.cards()[1]
  if first then first:juice_up(0.15, 0.15) end
end

return M
