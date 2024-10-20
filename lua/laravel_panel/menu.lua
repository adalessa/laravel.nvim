local Popup = require("nui.popup")
local NuiTree = require("nui.tree")
local NuiLine = require("nui.line")

local menu = {}

function menu:new(properties, callback)
  local instance = {
    callback = callback,
    _selected_index = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  instance._popup = instance:_create_popup(properties)
  instance._tree = instance:_create_tree()
  instance:_add_mappings()

  return instance
end

function menu:_create_popup(properties)
  return Popup(vim.tbl_extend("force", {
    enter = true,
    border = {
      style = "single",
      text = {
        top = "Menu",
      },
    },
  }, properties or {}))
end

function menu:_create_tree()
  if not self._popup then
    error("cant create tree without popup")
  end

  return NuiTree({
    bufnr = self._popup.bufnr,
    get_node_id = function(node)
      return node.id
    end,
    prepare_node = function(node)
      local line = NuiLine()

      if node:get_id() == self._selected_index then
        line:append("> ", "WarningMsg")
      end

      line:append(string.rep("  ", node:get_depth() - 1))
      line:append(node.text)

      return line
    end,
  })
end

function menu:_add_mappings()
  if not self._popup then
    error("cant add maps wihtout popup")
  end

  self._popup:map("n", "<cr>", function()
    local node = self._tree:get_node()
    if not node then
      return
    end
    local previous = self._selected_index

    self._selected_index = node:get_id()

    self._tree:render()
    if self.callback then
      self.callback(self._selected_index, previous)
    end
  end)
end

function menu:add(id, text)
  self._tree:add_node(NuiTree.Node({ id = id, text = text }))

  if not self._selected_index then
    self._selected_index = self._tree:get_nodes()[1]:get_id()
  end

  self._tree:render()
end

function menu:set_selection_callback(callback)
  self.callback = callback
end

function menu:popup()
  return self._popup
end

function menu:tree()
  return self._tree
end

function menu:selected()
  return self._selected_index
end

function menu:set_selected(id)
  if not self._tree:get_node(id) then
    return
  end
  self._selected_index = id
  self._tree:render()
end

return menu
