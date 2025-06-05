local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local preview = require("laravel.pickers.common.preview")
local actions = require("laravel.pickers.telescope.actions")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.telescope.artisan
---@field commands_loader laravel.loaders.artisan_cache_loader
local artisan_picker = Class({
  commands_loader = "laravel.loaders.artisan_cache_loader",
})

function artisan_picker:run(opts)
  opts = opts or {}

  local commands, err = self.commands_loader:load()
  if err then
    notify.error("Failed to load artisan commands: " .. err)
    return
  end

  vim.schedule(function()
    pickers
      .new(opts, {
        prompt_title = "Artisan commands",
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
          map("i", "<cr>", actions.run)

          return true
        end,
      })
      :find()
  end)
end

return artisan_picker
