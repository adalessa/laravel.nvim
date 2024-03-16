local conf = require("telescope.config").values
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local preview = require "laravel.telescope.preview"
local commands = require "laravel.commands"
local actions = require "laravel.telescope.actions"

return function(opts)
  opts = opts or {}

  if vim.tbl_isempty(commands.list) then
    if not commands.load() then
      return
    end
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
        map("i", "<cr>", actions.run)

        return true
      end,
    })
    :find()
end
