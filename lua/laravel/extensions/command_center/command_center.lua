local Class = require("laravel.utils.class")
local Layout = require("laravel.extensions.command_center.layout")
local nio = require("nio")

local command_center = Class({})

function command_center:open()
  local completors = {
    require("laravel.extensions.command_center.completors.artisan"),
    require("laravel.extensions.command_center.completors.composer"),
  }

  local layout = Layout(function(value)
    Laravel.run(value)
  end, function(value, details_popup)
    if not details_popup.bufnr then
      return
    end
    nio.run(function()
      local completions = nio.gather(vim
        .iter(completors)
        :map(function(completor)
          return function()
            return completor.complete(value)
          end
        end)
        :totable())

      completions = vim.iter(completions):flatten(1):totable()

      vim.schedule(function()
        if details_popup.bufnr then
          vim.api.nvim_buf_set_lines(details_popup.bufnr, 0, -1, true, completions)
        end
      end)
    end)
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
