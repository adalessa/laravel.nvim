local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local preview = require("laravel.pickers.common.preview")
local actions = require("laravel.pickers.telescope.actions")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local composer_picker = Class({
  composer_loader = "laravel.loaders.composer_commands_cache_loader",
})

function composer_picker:run(opts)
  local commands, err = self.composer_loader:load()
  if err then
    return notify.error("Failed to load composer commands: " .. err)
  end

  vim.schedule(function()
    pickers
      .new(opts or {}, {
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
  end)
end

return composer_picker
