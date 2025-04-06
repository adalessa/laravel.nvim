local Popup = require("nui.popup")
local Layout = require("nui.layout")

local ui = {}

-- this as the dump server will take care of the ui interactions
function ui:new()
  local instance = {
    instance = nil,
    editor = nil,
    result = nil,
    callback = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function ui:_create_layout(bufnr, callback)
  self.editor, self.result =
    Popup({
      enter = true,
      border = {
        style = "rounded",
        text = {
          top = "Tinker",
        },
      },
      bufnr = bufnr,
      buf_options = {},
      win_options = {
        number = true,
        relativenumber = true,
      },
    }), Popup({
      border = {
        style = "rounded",
        text = {
          top = "Result",
          bottom = "Press <Tab> to switch between windows",
        },
      },
      buf_options = {
        modifiable = false,
      },
      win_options = {
        number = false,
        relativenumber = false,
      },
    })

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "80%",
        height = "80%",
      },
    },
    Layout.Box({
      Layout.Box(self.editor, { size = "65%" }),
      Layout.Box(self.result, { size = "35%" }),
    }, { dir = "row" })
  )

  self.editor:map("n", "q", function()
    self:close()
  end)

  self.editor:map("n", "<cr>", function()
    callback(self.editor.bufnr)
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

function ui:open(bufnr, callback)
  self:_create_layout(bufnr, callback)
  self.instance:mount()
end

function ui:close()
  self.instance:unmount()
  self.instance = nil
end

function ui:createTerm()
  return vim.api.nvim_open_term(self.result.bufnr, {})
end

return ui
