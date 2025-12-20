local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local is_make_command = require("laravel.utils.init").is_make_command

local make_picker = Class({
  commands_loader = "laravel.loaders.artisan_cache_loader",
  log = "laravel.utils.log",
})

function make_picker:run(picker, opts)
  local commands, err = self.commands_loader:load()
  if err then
    notify.error("Failed to load artisan commands")
    self.log:error(err)
    return
  end

  picker(
    opts,
    vim.tbl_filter(function(command)
      return is_make_command(command.name)
    end, commands)
  )
end

return make_picker
