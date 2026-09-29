--[[
  Entry point: intercepts key presses before the vanilla controller.
  A key we handle is swallowed; anything else (Esc, menus, debug keys,
  other mods) reaches the game untouched.
]]
local actions = require("kbplay.actions")
local keymap = require("kbplay.keymap")
local log = require("kbplay.log")
local states = require("kbplay.states")
local zones = require("kbplay.zones")

keymap.load()

local focus = { screen = nil, index = 1 }

local function screen_name()
  for name, value in pairs(G.STATES) do
    if value == G.STATE then return name end
  end
end

-- Leave the keyboard to the game in menus or mid-animation.
local function busy()
  return G.SETTINGS.paused or G.OVERLAY_MENU or not G.GAME or (G.GAME.STOP_USE or 0) > 0
end

local function handle(controller, key)
  if controller.text_input_hook or controller.locks.frame then return false end

  local action = keymap.action_for(key, controller.held_keys)
  if not action then return false end

  -- works on any in-run screen, and closes the view it opened
  if action == "view_deck" then return actions.deck_key(key) end

  if busy() then return false end

  local name = screen_name()
  local screen = name and states[name]
  if not screen then return false end

  if focus.screen ~= name then
    focus.screen, focus.index = name, 1
  end
  local zone = screen.zones[focus.index]

  local n = action:match("^card_(%d+)$")
  if n then
    zones.toggle(zone, tonumber(n))
    return true
  end

  if action == "focus_next" or action == "focus_prev" then
    local step = action == "focus_next" and 1 or -1
    focus.index = (focus.index - 1 + step) % #screen.zones + 1
    zones.announce(screen.zones[focus.index])
    return true
  end

  local ctx = { zone = zone, alt = action == "secondary" }

  if action == "primary" or action == "secondary" then return actions.primary(ctx, screen.primary) end
  if action == "sell" then return actions.sell(ctx) end
  if action == "move_left" then return zones.move(zone, -1) end
  if action == "move_right" then return zones.move(zone, 1) end
  if action == "deselect" then
    zones.deselect(zone)
    return true
  end

  local fn = screen.keys and screen.keys[action]
  return fn and fn(ctx) or false
end

local vanilla_key_press_update = Controller.key_press_update

function Controller:key_press_update(key, dt)
  -- a bug in the mod must never crash the run: log it and let vanilla handle the key
  local ok, handled = pcall(handle, self, key)
  if not ok then
    log.error(handled)
    handled = false
  end
  if not handled then return vanilla_key_press_update(self, key, dt) end
end

log.info("loaded")
