local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_artisan
local actions = require("laravel.pickers.common.actions")
local fzf_exec = require("fzf-lua").fzf_exec
local CommandPreviewer = require("laravel.pickers.fzf_lua.previewer").CommandPreviewer
local Class = require("laravel.services.class")
local nio = require("nio")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.fzf_lua.pickers.artisan
---@field artisan_loader laravel.loaders.artisan_cache_loader
local artisan_picker = Class({
  artisan_loader = "laravel.loaders.artisan_cache_loader",
})

function artisan_picker:run(opts)
  nio.run(function()
    local commands, err = self.artisan_loader:load()
    if err then
      return notify.error("Error loading artisan commands: " .. err)
    end

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
  end)
end

return artisan_picker
