local app = require("laravel").app
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local dev_panel = {}

function dev_panel:new()
  local instance = {
    id = "dev",
    text = "Dev",
    running = false,
  }

  setmetatable(instance, self)
  self.__index = self

  instance._panel = instance:_create_panel()
  instance._layout = instance:_create_layout()

  return instance
end

function dev_panel:_create_panel()
  return Popup({
    border = {
      style = "single",
      text = {
        top = self.text,
      },
    },
    buf_options = {
      modifiable = false,
    },
  })
end

function dev_panel:_create_layout()
  return Layout.Box(self._panel, { size = "100%" })
end

--- interface
function dev_panel:active()
  return true
end

function dev_panel:getTargetWinId()
  return self._panel.winid
end

function dev_panel:setup(opts)
  self._panel:map("n", "q", opts.quit)
  self._panel:map("n", "<tab>", opts.menu_focus)
  self._panel:map("n", "r", function()
    self:activate()
  end)
  self._panel:map("n", "s", function()
    self:_start_process()
  end)
  self._panel:map("n", "p", function()
    self:_stop_process()
  end)

  self._panel:map("n", "g?", function()
    local help = Popup({
      size = "40%",
      position = "50%",
      zindex = 100,
      border = 'double',
      enter = true,
    })

    vim.api.nvim_buf_set_lines(help.bufnr, 0, -1, false, {
      "q -> quit",
      "tab -> move to menu",
      "s -> start process",
      "p -> stop process",
    })
    help:mount()

    help:map("n", "q", function()
      help:unmount()
    end)

    help:on("BufLeave", function()
      help:unmount()
    end)
  end)
end

function dev_panel:layout()
  return self._layout
end

function dev_panel:activate()
  if not self.running then
    vim.api.nvim_set_option_value("modifiable", true, { buf = self._panel.bufnr })
    vim.api.nvim_buf_set_lines(self._panel.bufnr, 0, -1, false, {
      "This will run composer run dev",
      "start by pressing s",
      "stop by pressing p",
    })
    vim.api.nvim_set_option_value("modifiable", false, { buf = self._panel.bufnr })
    return
  end
end

function dev_panel:_start_process()
  if self.running then
    return
  end

  local cmd = app("api"):generate_command("composer", { "run", "dev" })
  self._channel_id = vim.api.nvim_open_term(self._panel.bufnr, {})
  vim.api.nvim_set_option_value("modifiable", true, { buf = self._panel.bufnr })
  vim.api.nvim_buf_set_lines(self._panel.bufnr, 0, -1, false, {})
  vim.api.nvim_set_option_value("modifiable", false, { buf = self._panel.bufnr })
  self._job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      vim.fn.chansend(self._channel_id, data)
    end,
    on_exit = function()
      self.running = false
      self:activate()
    end,
    pty = true,
  })

  self.running = true
  self:activate()
end

function dev_panel:_stop_process()
  vim.fn.jobstop(self._job_id)
end

return dev_panel
