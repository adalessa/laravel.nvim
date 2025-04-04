local Popup = require("nui.popup")
local Layout = require("nui.layout")

local ui = {}

function ui:new(dump_server)
  local instance = {
    service = dump_server,
    instance = nil,
    dump_tree = nil,
    dump_preview = nil,
    current_index = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function ui:_create_layout()
  self.dump_tree, self.dump_preview =
    Popup({
      enter = true,
      border = {
        style = "rounded",
        text = {
          top = "Dump Server",
        },
      },
      buf_options = {
        modifiable = false,
      },
      win_options = {},
    }), Popup({
      border = {
        style = "rounded",
        text = {
          top = "Preview",
          bottom = "Press <Tab> to switch between windows",
        },
      },
      buf_options = {
        modifiable = false,
        filetype = "bash",
      },
      win_options = {},
    })

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "80%",
        height = "60%",
      },
    },
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

function ui:open()
  if not self.instance then
    if not self.service:isRunning() then
      self.service
        :start()
        :thenCall(function()
          self:_create_layout()
          self:update()
          self.instance:mount()
        end)
        :catch(function() end)
    else
      self:_create_layout()
      self:update()
      self.instance:mount()
    end
  end
end

function ui:close()
  self.instance:unmount()
  self.instance = nil
end

function ui:toggle()
  if self.instance then
    self:close()
  else
    self:open()
  end
end

return ui
