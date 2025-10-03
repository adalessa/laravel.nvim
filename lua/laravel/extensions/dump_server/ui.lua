local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Class = require("laravel.utils.class")

---@class laravel.extensions.dump_server.ui
---@field service laravel.extensions.dump_server.lib
---@field config table
local ui = Class({
  service = "laravel.extensions.dump_server.lib",
}, {
  instance = nil,
  dump_tree = nil,
  dump_preview = nil,
  current_index = nil,
  config = nil,
})

function ui:setConfig(config)
  self.config = config
end

function ui:_create_layout()
  self.dump_tree, self.dump_preview = Popup(self.config.ui.tree), Popup(self.config.ui.preview)

  local layout = Layout(
    self.config.ui.layout,
    Layout.Box({
      Layout.Box(self.dump_tree, { size = "30%" }),
      Layout.Box(self.dump_preview, { size = "70%" }),
    }, { dir = "row" })
  )

  self.dump_tree:map("n", "q", function()
    self:close()
  end)

  self.dump_preview:map("n", "q", function()
    self:close()
  end)

  self.dump_tree:map("n", "<Tab>", function()
    vim.api.nvim_set_current_win(self.dump_preview.winid)
  end)

  self.dump_preview:map("n", "<Tab>", function()
    vim.api.nvim_set_current_win(self.dump_tree.winid)
  end)

  self.instance = layout
end

function ui:update()
  if not self.instance then
    return
  end

  local records = self.service:getRecords()
  local lines = vim
    .iter(records)
    :rev()
    :map(function(record)
      local dateHeader = vim
        .iter(record.headers)
        :filter(function(header)
          return header.key == "date"
        end)
        :totable()[1] or {}

      return dateHeader.value
    end)
    :totable()

  vim.bo[self.dump_tree.bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(self.dump_tree.bufnr, 0, -1, false, lines)
  vim.bo[self.dump_tree.bufnr].modifiable = false
  -- set the highlight base on the current, news and unseen records
  local ns = vim.api.nvim_create_namespace("dump_server")
  vim.api.nvim_buf_clear_namespace(self.dump_tree.bufnr, ns, 0, -1)

  for index, record in ipairs(records) do
    local list_index = #records - index
    local highlight = record.seen and "Comment" or "WarningMsg"
    if self.current_index == index then
      highlight = "CursorLine"

      vim.bo[self.dump_preview.bufnr].modifiable = true
      vim.api.nvim_buf_set_lines(self.dump_preview.bufnr, 0, -1, false, record.body)
      vim.bo[self.dump_preview.bufnr].modifiable = false
    end
    vim.hl.range(self.dump_tree.bufnr, ns, highlight, { list_index, 0 }, { list_index, -1 })
  end

  self.dump_tree:map("n", "<CR>", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local index = #records - cursor[1] + 1
    self.service:markRecordAsSeen(index)
    self.current_index = index
    self:update()
  end)
end

---@async
function ui:open()
  if not self.instance then
    if not self.service:isRunning() then
      local res = self.service:start()
      if res then
        vim.schedule(function()
          self:_create_layout()
          self:update()
          self.instance:mount()
        end)
      end
    else
      vim.schedule(function()
        self:_create_layout()
        self:update()
        self.instance:mount()
      end)
    end
  end
end

function ui:close()
  self.instance:unmount()
  self.instance = nil
end

---@async
function ui:toggle()
  if self.instance then
    self:close()
  else
    self:open()
  end
end

return ui
