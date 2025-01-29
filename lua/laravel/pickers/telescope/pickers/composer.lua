local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local preview = require("laravel.pickers.common.preview")
local actions = require("laravel.pickers.telescope.actions")

---@class LaravelComposerPicker
---@field composer_repository ComposerRepository
local composer_picker = {}

function composer_picker:new(composer_repository)
  local instance = {
    composer_repository = composer_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function composer_picker:run(opts)
  opts = opts or {}

  return self.composer_repository:all():thenCall(function(commands)
    pickers
      .new(opts, {
        prompt_title = "Composer commands",
        finder = finders.new_table({
          results = commands,
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
            local command_preview = preview.composer(entry.value)

            vim.api.nvim_buf_set_lines(preview_self.state.bufnr, 0, -1, false, command_preview.lines)

            local hl = vim.api.nvim_create_namespace("laravel")
            for _, value in pairs(command_preview.highlights) do
              vim.api.nvim_buf_add_highlight(preview_self.state.bufnr, hl, value[1], value[2], value[3], value[4])
            end
          end,
        }),
        sorter = conf.file_sorter(),
        attach_mappings = function(_, map)
          map("i", "<cr>", actions.composer_run)

          return true
        end,
      })
      :find()
  end, function(error)
    vim.api.nvim_err_writeln(error)
  end)
end

return composer_picker
