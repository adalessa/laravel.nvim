local builtin = require("fzf-lua.previewer.builtin")
local preview = require("laravel.pickers.common.preview")

local M = {}

M.CommandPreviewer = function(command_table)
  local previewer = builtin.base:extend()

  function previewer:new(o, fzf_opts, fzf_win)
    previewer.super.new(self, o, fzf_opts, fzf_win)
    setmetatable(self, previewer)
    return self
  end

  function previewer:populate_preview_buf(selected)
    local tmpbuf = self:get_tmp_buffer()
    local command = command_table[selected]
    local command_preview = preview.command(command)

    vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, command_preview.lines)

    local hl = vim.api.nvim_create_namespace("laravel")
    for _, value in pairs(command_preview.highlights) do
      vim.api.nvim_buf_add_highlight(tmpbuf, hl, value[1], value[2], value[3], value[4])
    end

    self:set_preview_buf(tmpbuf)
    self.win:update_scrollbar()
  end

  return previewer
end

M.RoutePreviewer = function(route_table)
  local previewer = builtin.base:extend()

  function previewer:new(o, fzf_opts, fzf_win)
    previewer.super.new(self, o, fzf_opts, fzf_win)
    setmetatable(self, previewer)
    return self
  end

  function previewer:populate_preview_buf(selected)
    local tmpbuf = self:get_tmp_buffer()
    local route = route_table[selected]
    local route_preview = preview.route(route)

    vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, route_preview.lines)

    local hl = vim.api.nvim_create_namespace("laravel")
    for _, value in pairs(route_preview.highlights) do
      vim.api.nvim_buf_add_highlight(tmpbuf, hl, value[1], value[2], value[3], value[4])
    end

    self:set_preview_buf(tmpbuf)
    self.win:update_scrollbar()
  end

  return previewer
end

return M
