-- Game actions. Each returns true if it did something, so the dispatcher can
-- let the key fall through to the vanilla game otherwise.
local ui = require("kbplay.ui")
local zones = require("kbplay.zones")

local A = {}

-- Buttons on screen

function A.play() return ui.press(G.buttons, "play_cards_from_highlighted") end
function A.discard() return ui.press(G.buttons, "discard_cards_from_highlighted") end
function A.sort_rank() return ui.press(G.buttons, "sort_hand_value") end
function A.sort_suit() return ui.press(G.buttons, "sort_hand_suit") end

function A.cash_out() return ui.press_any("cash_out") end

function A.reroll_shop() return ui.press(G.shop, "reroll_shop") end
function A.next_round() return ui.press(G.shop, "toggle_shop") end

function A.skip_booster() return ui.press(G.booster_pack, "skip_booster") end

local function blind_on_deck_box()
  local on_deck = G.GAME and G.GAME.blind_on_deck
  return on_deck and G.blind_select_opts and G.blind_select_opts[string.lower(on_deck)]
end

function A.select_blind() return ui.press(blind_on_deck_box(), "select_blind") end
function A.skip_blind() return ui.press(blind_on_deck_box(), "skip_blind") end
-- only exists with Director's Cut / Retcon, above the three blinds
function A.reroll_boss() return ui.press(G.blind_prompt_box, "reroll_boss") end

-- Overlays

-- The overlay we opened, so the same key closes it but never closes
-- anything else (options, run info...).
local deck_overlay

function A.toggle_deck()
  if G.OVERLAY_MENU then
    if G.OVERLAY_MENU ~= deck_overlay then return false end
    G.FUNCS.exit_overlay_menu()
    deck_overlay = nil
    return true
  end
  if G.STAGE ~= G.STAGES.RUN or not G.deck or G.SETTINGS.paused then return false end
  G.FUNCS.deck_info()
  deck_overlay = G.OVERLAY_MENU
  return true
end

-- Cards

---What "Enter" means for the selected card of a single-select zone.
---@param alt boolean shift held: buy and use instead of buy
function A.use_card(zone, card, alt)
  if zone == "shop" then
    local set = card.ability.set
    if set == "Voucher" then return ui.card_action("can_redeem", card) end
    if set == "Booster" then return ui.card_action("can_open", card) end
    if alt and card.ability.consumeable then
      return ui.card_action("can_buy_and_use", card, "buy_and_use")
    end
    return ui.card_action("can_buy", card)
  elseif zone == "pack" then
    return ui.card_action("can_select_card", card)
  elseif zone == "consumables" then
    return ui.card_action("can_use_consumeable", card)
  end
  return false
end

---Enter: act on the focused card if there is one, otherwise do the screen's
---main action (play hand, select blind, cash out...).
function A.primary(ctx, screen_primary)
  local def = zones.defs[ctx.zone]
  if def and not def.multi then
    local card = zones.selected(ctx.zone)[1]
    if card then return A.use_card(ctx.zone, card, ctx.alt) end
  end
  return screen_primary and screen_primary(ctx) or false
end

function A.sell(ctx)
  if ctx.zone ~= "jokers" and ctx.zone ~= "consumables" then return false end
  local card = zones.selected(ctx.zone)[1]
  return ui.card_action("can_sell_card", card)
end

return A
