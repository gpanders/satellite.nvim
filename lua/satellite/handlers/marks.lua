local highlight = 'Normal'

---@type Handler
local handler = {
  name = 'marks',
}

local BUILTIN_MARKS = { "'.", "'^", "''", "'\"", "'<", "'>", "'[", "']" }

local config = {}

local function refresh()
  require('satellite').refresh_bars()
end

---@param m string mark name
---@return boolean
local function mark_is_builtin(m)
  for _, mark in pairs(BUILTIN_MARKS) do
    if mark == m then
      return true
    end
  end
  return false
end

function handler.init(config0)
  config = config0
  -- range over a-z
  for char = 97, 122 do
    local map = 'm' .. string.char(char)
    vim.keymap.set({ 'n', 'v' }, map, function()
      vim.schedule(refresh)
      return map
    end, { unique = true, expr = true })
  end
end

function handler.update(bufnr)
  local marks = {}
  local buffer_marks = vim.fn.getmarklist(bufnr)
  for _, mark in ipairs(buffer_marks) do
    if config.show_builtins or not mark_is_builtin(mark.mark) then
      marks[#marks + 1] = {
        -- [bufnum, lnum, col, off]
        lnum = mark.pos[2],
        -- first char of mark name is a single quote
        symbol = string.sub(mark.mark, 2, 3),
        highlight = highlight,
      }
    end
  end
  return marks
end

require('satellite.handlers').register(handler)