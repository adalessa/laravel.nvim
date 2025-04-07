local Popup = require("nui.popup")
local Layout = require("nui.layout")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")

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

function ui:_create_layout(bufnr, name, callback)
  local title = NuiLine()
  title:append("Tinkering: ", "@attribute")
  title:append(name, "@character")

  self.editor, self.result =
    Popup({
      enter = true,
      border = {
        style = "rounded",
        text = {
          top = title,
          bottom = NuiText("Press <Tab> to switch between windows", "comment"),
        },
      },
      bufnr = bufnr,
      buf_options = {},
      win_options = {
        number = true,
        relativenumber = true,
        signcolumn = "yes",
      },
    }), Popup({
      border = {
        style = "rounded",
        text = {
          top = NuiText("Result", "@string"),
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
      Layout.Box(self.editor, { size = "60%" }),
      Layout.Box(self.result, { size = "40%" }),
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

function ui:open(bufnr, name, callback)
  self:_create_layout(bufnr, name, callback)
  self.instance:mount()
end

function ui:close()
  if not self.instance then
    return
  end

  self.editor:unmap("n", "q")
  self.editor:unmap("n", "<tab>")
  self.editor:unmap("n", "<cr>")

  self.result:unmap("n", "q")
  self.result:unmap("n", "<tab>")

  self.instance:unmount()
  self.instance = nil
end

function ui:createTerm()
  return vim.api.nvim_open_term(self.result.bufnr, {})
end

return ui
