local Class = require("laravel.class")
local Layout = require("laravel.extensions.command_center.layout")

local command_center = Class({})

function command_center:open()
  local layout = Layout(function(value)
    dd(value)
  end, function(value)
    -- on change
  end)
  -- artisan + auto complete
  -- composer + autocomplete
  -- routes (simplemente abrir picker)
  -- npm (yarn)
  -- extensiones
  -- composer dev
  -- dump server
  -- tinker

  layout:mount()

  vim.defer_fn(function()
    vim.api.nvim_command("startinsert!")
  end, 20)
end

return command_center
