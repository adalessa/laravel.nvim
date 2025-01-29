local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_composer
local actions = require("laravel.pickers.common.actions")
local fzf_exec = require("fzf-lua").fzf_exec
local CommandPreviewer = require("laravel.pickers.fzf_lua.previewer").ComposerPreviewer

---@class LaravelFzfLuaComposerPicker
---@field composer_repository ComposerRepository
local ui_composer_picker = {}

function ui_composer_picker:new(composer_repository)
  local instance = {
    composer_repository = composer_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function ui_composer_picker:run(opts)
  opts = opts or {}

  return self.composer_repository:all():thenCall(function(commands)
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
  end, function(error)
    vim.api.nvim_err_writeln(error)
  end)
end

return ui_composer_picker
