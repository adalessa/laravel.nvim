local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_artisan
local actions = require("laravel.pickers.common.actions")
local fzf_exec = require("fzf-lua").fzf_exec
local CommandPreviewer = require("laravel.pickers.fzf_lua.previewer").CommandPreviewer

---@class LaravelFzfLuaArtisanPicker
---@field commands_repository CommandsRepository
local ui_artisan_picker = {}

function ui_artisan_picker:new(cache_commands_repository)
  local instance = {
    commands_repository = cache_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function ui_artisan_picker:run(opts)
  return self.commands_repository:all():thenCall(function(commands)
    local command_names, command_table = format_entry(commands)

    fzf_exec(
      command_names,
      vim.tbl_extend("force", {
        actions = {
          ["default"] = function(selected)
            local command = command_table[selected[1]]
            actions.artisan_run(command)
          end,
        },
        prompt = "Artisan > ",
        previewer = CommandPreviewer(command_table),
        fzf_opts = {
          ["--preview-window"] = "nohidden,70%",
        },
      }, opts or {})
    )
  end, function(error)
    vim.api.nvim_err_writeln(error)
  end)
end

return ui_artisan_picker
