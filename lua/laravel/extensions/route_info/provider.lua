---@type laravel.extensions.provider
local route_info = {}
local buffer_utils = require("laravel.utils.buffer")

function route_info.register(app, opts)
  app:singletonIf("laravel.extensions.route_info.lib")
  app:bindIf("laravel.extensions.route_info.view_factory", function()
    return require("laravel.extensions.route_info.view_factory"):new(opts, {
      top = require("laravel.extensions.route_info.view_top"),
      right = require("laravel.extensions.route_info.view_right"),
      simple = require("laravel.extensions.route_info.view_simple"),
    })
  end)

  vim.tbl_map(function(command)
    app:addCommand("laravel.extensions.route_info." .. command.signature, command)
  end, require("laravel.extensions.route_info.commands"))
end

function route_info.boot(app)
  local group = vim.api.nvim_create_augroup("laravel.route_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = app:whenActive(function(ev)
      if not buffer_utils.is_valid_buffer(ev.buf) then
        return
      end

      local cwd = vim.uv.cwd()
      if vim.startswith(ev.file, cwd .. "/vendor") then
        return
      end

      app("laravel.extensions.route_info.lib"):handle(ev.buf)
    end),
  })
end

return route_info
