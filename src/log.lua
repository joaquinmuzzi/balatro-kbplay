-- Output goes to the lovely console window.
local M = {}

function M.info(...)
  print("[kbplay]", ...)
end

function M.error(...)
  print("[kbplay] ERROR:", ...)
end

return M
