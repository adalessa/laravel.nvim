local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_artisan
local is_make_command = require("laravel.utils.init").is_make_command
local actions = require("laravel.pickers.common.actions")
local fzf_exec = require("fzf-lua").fzf_exec
local CommandPreviewer = require("laravel.pickers.fzf_lua.previewer").CommandPreviewer

---@class laravel.pickers.fzf_lua.make
---@field commands_loader laravel.loaders.artisan_cache_loader
local make_picker = Class({
  commands_loader = "laravel.loaders.artisan_cache_loader",
})

function make_picker:run()
  local commands, err = self.commands_loader:load()
  if err then
    notify.error("Failed to load artisan commands: " .. err)
    return
  end

  local cmds = vim
    .iter(commands)
    :filter(function(command)
      return is_make_command(command.name)
    end)
    :totable()

  local command_names, command_table = format_entry(cmds)

  vim.schedule(function()
    fzf_exec(command_names, {
      actions = {
        ["default"] = function(selected)
          local command = command_table[selected[1]]
          actions.make_run(command)
        end,
      },
      prompt = "Make > ",
      previewer = CommandPreviewer(command_table),
      fzf_opts = {
        ["--preview-window"] = "nohidden,70%",
      },
    })
  end)
end

return make_picker
