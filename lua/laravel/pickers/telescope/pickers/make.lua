local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local preview = require("laravel.pickers.telescope.preview")
local actions = require("laravel.pickers.telescope.actions")
local is_make_command = require("laravel.utils").is_make_command

---@class LaravelMakePicker
---@field commands_repository CommandsRepository
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
    pickers
      .new(opts, {
        prompt_title = "Make commands",
        finder = finders.new_table({
          results = vim
            .iter(commands)
            :filter(function(command)
              return is_make_command(command.name)
            end)
            :totable(),
          entry_maker = function(command)
            return {
              value = command,
              display = command.name,
              ordinal = command.name,
            }
          end,
        }),
        previewer = previewers.new_buffer_previewer({
          title = "Help",
          get_buffer_by_name = function(_, entry)
            return entry.value.name
          end,
          define_preview = function(preview_self, entry)
            local command_preview = preview.command(entry.value)

            vim.api.nvim_buf_set_lines(preview_self.state.bufnr, 0, -1, false, command_preview.lines)

            local hl = vim.api.nvim_create_namespace("laravel")
            for _, value in pairs(command_preview.highlights) do
              vim.api.nvim_buf_add_highlight(preview_self.state.bufnr, hl, value[1], value[2], value[3], value[4])
            end
          end,
        }),
        sorter = conf.file_sorter(),
        attach_mappings = function(_, map)
          map("i", "<cr>", actions.make_run)

          return true
        end,
      })
      :find()
  end)
end

return make_picker
