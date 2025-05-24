local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_artisan
local is_make_command = require("laravel.utils").is_make_command
local actions = require("laravel.pickers.common.actions")
local fzf_exec = require("fzf-lua").fzf_exec
local CommandPreviewer = require("laravel.pickers.fzf_lua.previewer").CommandPreviewer

---@class LaravelFzfLuaMakePicker
---@field commands_repository laravel.repositories.artisan_commands
local make_picker = {}

function make_picker:new(cache_commands_repository)
  local instance = {
    commands_repository = cache_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function make_picker:run(opts)
  opts = opts or {}

  self.commands_repository:all():thenCall(function(commands)
    local cmds = vim
      .iter(commands)
      :filter(function(command)
        return is_make_command(command.name)
      end)
      :totable()

    local command_names, command_table = format_entry(cmds)

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
