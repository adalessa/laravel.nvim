local Popup = require("nui.popup")
local Layout = require("nui.layout")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")
local Class = require("laravel.utils.class")

---@class laravel.extensions.tinker.ui
local ui = Class({}, {
  instance = nil,
  editor = nil,
  result = nil,
  callback = nil,
  config = {},
  channelId = nil,
})

function ui:setConfig(config)
  self.config = config
end

function ui:_create_layout(bufnr, name, callback)
  local title = NuiLine()
  title:append("Tinkering: ", "@attribute")
  title:append(name, "@character")

  local editor_opts = vim.tbl_deep_extend("force", self.config.ui.editor, {
    border = {
      text = {
        top = title,
        bottom = NuiText("Press <Tab> to switch between windows", "comment"),
      },
    },
    win_options = {
      winfixbuf = true,
    },
    bufnr = bufnr,
  })

  local result_opts = vim.tbl_deep_extend("force", self.config.ui.result, {
    border = {
      text = {
        top = NuiText("Result", "@string"),
      },
    },
    win_options = {
      winfixbuf = true,
    },
  })

  self.editor, self.result = Popup(editor_opts), Popup(result_opts)

  local layout = Layout(
    self.config.ui.layout,
    Layout.Box({
      Layout.Box(self.editor, { size = "60%" }),
      Layout.Box(self.result, { size = "40%" }),
    }, { dir = "row" })
  )

  self.editor:map("n", "q", function()
    self:close()
  end)

  self.editor:map("n", "<cr>", function()
    local new_buf = vim.api.nvim_create_buf(false, true)
    self.channelId = vim.api.nvim_open_term(new_buf, {})
    vim.api.nvim_set_option_value("winfixbuf", false, { win = self.result.winid })
    vim.api.nvim_win_set_buf(self.result.winid, new_buf)
    vim.api.nvim_set_option_value("winfixbuf", true, { win = self.result.winid })
    self.result.bufnr = new_buf
    -- need to reset the keymaps
    self.result:map("n", "q", function()
      self:close()
    end)
    self.result:map("n", "<Tab>", function()
      vim.api.nvim_set_current_win(self.editor.winid)
    end)

    callback(self.editor.bufnr, self.channelId, function(time, memory)
      -- self.result.border.text.bottom = NuiText(string.format("Execution time: %s, Memory: %s", time, memory), "comment")
      self.result.border:set_text(
        "bottom",
        NuiText(string.format("[Time: %.2f ms - Memory: %.2f MB]", time, memory), "@string"),
        "center"
      )
    end)
  end)

  self.result:map("n", "q", function()
    self:close()
  end)

  self.editor:map("n", "<Tab>", function()
    vim.api.nvim_set_current_win(self.result.winid)
  end)

  self.result:map("n", "<Tab>", function()
    vim.api.nvim_set_current_win(self.editor.winid)
  end)

  self.instance = layout
end

function ui:open(bufnr, name, callback)
  self:_create_layout(bufnr, name, callback)
  self.channelId = vim.api.nvim_open_term(self.result.bufnr, {})
  self.instance:mount()
end

function ui:close()
  if not self.instance then
    return
  end

  self.instance:unmount()
  self.instance = nil
  self.editor = nil
  self.result = nil
  self.channelId = nil
end

function ui:getChannelId()
  return self.channelId
end

return ui
