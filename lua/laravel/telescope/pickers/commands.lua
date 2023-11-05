local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local preview = require "laravel.telescope.preview"
local commands = require "laravel.commands"
local ui_run = require "laravel.telescope.ui_run"

return function(opts)
  opts = opts or {}

  if #commands.list == 0 then
    commands.load()
  end

  pickers
    .new(opts, {
      prompt_title = "Artisan commands",
      finder = finders.new_table {
        results = commands.list,
        entry_maker = function(command)
          return {
            value = command,
            display = command.name,
            ordinal = command.name,
          }
        end,
      },
      previewer = previewers.new_buffer_previewer {
        title = "Help",
        get_buffer_by_name = function(_, entry)
          return entry.value.name
        end,
        define_preview = function(self, entry)
          local command_preview = preview.command(entry.value)

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, command_preview.lines)

          local hl = vim.api.nvim_create_namespace "laravel"
          for _, value in pairs(command_preview.highlights) do
            vim.api.nvim_buf_add_highlight(self.state.bufnr, hl, value[1], value[2], value[3], value[4])
          end
        end,
      },
      sorter = conf.file_sorter(),
      attach_mappings = function(_, map)
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local command = entry.value

          vim.schedule(function()
            ui_run(command)
          end)
        end)
        map("i", "<C-y>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local command = entry.value

          vim.schedule(function()
            ui_run(command, true)
          end)
        end)

        return true
      end,
    })
    :find()
end
