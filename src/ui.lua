--[[
  Pressing the game's own UI buttons instead of calling game logic directly.

  Most Balatro buttons re-evaluate every frame whether they are enabled
  (a `func` like `can_play` sets or clears `config.button`). By only pressing
  buttons that are currently enabled, every rule — money, boss blinds, locks,
  other mods — stays in the game's hands.
]]
local M = {}

local function find(node, button)
  if not node then return nil end
  if node.config and node.config.button == button then return node end
  for _, child in ipairs(node.children or {}) do
    local found = find(child, button)
    if found then return found end
  end
end

---Find the enabled button that would call `G.FUNCS[button]` inside `box`.
---@param box table|nil UIBox
---@param button string
function M.find(box, button)
  return box and find(box.UIRoot, button)
end

---Press it, like a mouse click would. Returns whether it was pressed.
function M.press(box, button)
  local element = M.find(box, button)
  if not (element and G.FUNCS[button]) then return false end
  G.FUNCS[button](element)
  return true
end

--[[
  Card buttons (buy, use, sell, redeem...) only exist while a card is
  highlighted, so instead of finding them we mimic them: run the same
  `G.FUNCS.can_*` check the button would run, and if it enables the button,
  call the function it points to.
]]
function M.card_action(check, card, id)
  if not (card and G.FUNCS[check]) then return false end
  local e = { config = { ref_table = card, id = id }, UIBox = { states = {} } }
  G.FUNCS[check](e)
  local fn = e.config.button and G.FUNCS[e.config.button]
  if not fn then return false end
  fn(e)
  return true
end

return M
