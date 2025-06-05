local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_composer
local actions = require("laravel.pickers.common.actions")
local fzf_exec = require("fzf-lua").fzf_exec
local CommandPreviewer = require("laravel.pickers.fzf_lua.previewer").ComposerPreviewer

local composer_picker = Class({
  composer_loader = "laravel.loaders.composer_commands_cache_loader",
})

function composer_picker:run()
  local commands, err = self.composer_loader:load()
  if err then
    return notify.error("Failed to load composer commands: " .. err)
  end

  vim.schedule(function()
    local command_names, command_table = format_entry(commands)

    fzf_exec(command_names, {
      actions = {
        ["default"] = function(selected)
          local command = command_table[selected[1]]
          actions.composer_run(command)
        end,
      },
      prompt = "Composer > ",
      previewer = CommandPreviewer(command_table),
      fzf_opts = {
        ["--preview-window"] = "nohidden,70%",
      },
    })
  end)
end

return composer_picker
