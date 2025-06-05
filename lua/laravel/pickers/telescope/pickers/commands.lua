local Class = require("laravel.utils.class")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")

---@class laravel.pickers.telescope.commands
---@field runner laravel.services.runner
---@field commands_loader laravel.loaders.user_commands_loader
local commands_picker = Class({
  runner = "laravel.services.runner",
  commands_loader = "laravel.loaders.user_commands_loader",
})

function commands_picker:run(opts)
  local commands = self.commands_loader:load()
  vim.schedule(function()
    pickers
      .new(opts, {
        prompt_title = "User Commands",
        finder = finders.new_table({
          results = commands,
          entry_maker = function(command)
            return {
              value = command,
              display = command.display,
              ordinal = command.display,
            }
          end,
        }),
        previewer = previewers.new_buffer_previewer({
          title = "Description",
          get_buffer_by_name = function(_, entry)
            return entry.value.name
          end,
          define_preview = function(self_preview, entry)
            vim.api.nvim_buf_set_lines(self_preview.state.bufnr, 0, -1, false, { entry.value.desc })
          end,
        }),
        sorter = conf.file_sorter(),
        attach_mappings = function(_, map)
          map("i", "<cr>", function(prompt_bufnr)
            actions.close(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            local command = entry.value

            self.runner:run(command.executable, command.cmd, command.opts)
          end)

          return true
        end,
      })
      :find()
  end)
end

return commands_picker
