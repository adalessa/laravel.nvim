local preview = require("laravel.pickers.common.preview")

local M = {}

local function _preview(ctx, prev)
  ctx.preview:reset()
  ctx.preview:set_lines(prev.lines)

  vim.bo[ctx.preview.win.buf].modifiable = true
  local hl = vim.api.nvim_create_namespace("laravel")
  for _, value in pairs(prev.highlights) do
    vim.api.nvim_buf_add_highlight(ctx.preview.win.buf, hl, value[1], value[2], value[3], value[4])
  end

  vim.bo[ctx.preview.win.buf].modifiable = false
end

M.command = function(ctx)
  _preview(ctx, preview.command(ctx.item.value))
end

M.composer_command = function(ctx)
  _preview(ctx, preview.composer(ctx.item.value))
end

M.user_command = function(ctx)
  ctx.preview:reset()
  ctx.preview:set_lines({ ctx.item.value.desc })
end

M.route = function(ctx)
  _preview(ctx, preview.route(ctx.item.value))
end

return M
