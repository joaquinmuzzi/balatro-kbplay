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

-- UIElement:click is what the mouse triggers: it honours one_press,
-- visibility and the click cooldown, and plays the button sound.
local function click(element)
  if not element then return false end
  local before = element.last_clicked
  element:click()
  return element.last_clicked ~= before
end

---Press it, like a mouse click would. Returns whether it was pressed.
function M.press(box, button)
  return click(M.find(box, button))
end

---Same, for buttons in UIBoxes the game keeps no reference to (e.g. cash out):
---every UIBox registers itself in G.I.UIBOX.
function M.press_any(button)
  for _, box in ipairs(G.I.UIBOX) do
    local element = M.find(box, button)
    if element then return click(element) end
  end
  return false
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
