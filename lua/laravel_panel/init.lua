local Layout = require("nui.layout")

local panels = {}

function panels:new(modules)
  local instance = {
    modules = modules,
    layout = nil,
    menu = nil,
    _has_been_mounted = false,
  }
  setmetatable(instance, self)
  self.__index = self

  instance:init()

  return instance
end

function panels:init()
  self.menu = require("laravel_panel.menu"):new()

  for _, module in ipairs(self.modules) do
    if module:active() then
      self.menu:add(module.id, module.text)
      module:setup({
        quit = function()
          self.layout:hide()
        end,
        menu_focus = function()
          vim.api.nvim_set_current_win(self.menu:popup().winid)
        end,
        update = function ()
          self.layout:update(self:get_layout_config(), self:get_layout())
          vim.print('updating layout')
        end,
      })
    end
  end

  self.menu:set_selection_callback(function(_, previous)
    self.layout:update(self:get_layout_config(), self:get_layout())
    local prevModule = vim.iter(self.modules):find(function(module)
      return module.id == previous
    end)

    if prevModule and type(prevModule["deactivate"]) == "function" then
      prevModule:deactivate()
    end

    self:currentModule():activate()
  end)

  self.layout = self:_create_layout()

  self.menu:popup():map("n", "q", function()
    self.layout:hide()
  end)

  self.menu:popup():map("n", "<tab>", function()
    vim.api.nvim_set_current_win(self:currentModule():getTargetWinId())
  end)
end

function panels:get_layout_config()
  return {
    position = "50%",
    size = "90%",
    relative = "editor",
  }
end

function panels:_create_layout()
  return Layout(self:get_layout_config(), self:get_layout())
end

function panels:get_layout()
  return Layout.Box({
    Layout.Box(self.menu:popup(), { size = "15%" }),
    Layout.Box({
      self:currentModule():layout(),
    }, { size = "85%" }),
  }, {
    dir = "row",
  })
end

function panels:currentModule()
  return vim.iter(self.modules):find(function(module)
    return module.id == self.menu:selected()
  end)
end

function panels:toggle(panel_id)
  if panel_id then
    self.menu:set_selected(panel_id)
    self.layout:update(self:get_layout_config(), self:get_layout())
  end
  -- not sure how to property change the active before mount

  if not self._has_been_mounted then
    self.layout:mount()
    self:currentModule():activate()
    self._has_been_mounted = true
    return
  end

  if self.layout.winid and vim.api.nvim_win_get_config(self.layout.winid).zindex then
    self.layout:hide()
  else
    self.layout:show()
    self:currentModule():activate()
  end
end

return panels
