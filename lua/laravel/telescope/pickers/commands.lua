local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local config = require "laravel.config"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local run = require "laravel.run"

return function(opts)
  opts = opts or {}

  local commands = {}

  for command_name, group_commands in pairs(config.options.user_commands) do
    for name, details in pairs(group_commands) do
      table.insert(commands, {
        executable = command_name,
        name = name,
        display = string.format("[%s] %s", command_name, name),
        cmd = details.cmd,
        desc = details.desc,
        opts = details.opts or {},
      })
    end
  end

  if vim.tbl_isempty(commands) then
    vim.notify("No user command defined in the config", vim.log.levels.WARN, {})
    return
  end

  pickers
    .new(opts, {
      prompt_title = "User Commands",
      finder = finders.new_table {
        results = commands,
        entry_maker = function(command)
          return {
            value = command,
            display = command.display,
            ordinal = command.display,
          }
        end,
      },
      previewer = previewers.new_buffer_previewer {
        title = "Description",
        get_buffer_by_name = function(_, entry)
          return entry.value.name
        end,
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { entry.value.desc })
        end,
      },
      sorter = conf.file_sorter(),
      attach_mappings = function(_, map)
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local command = entry.value

          run(command.executable, command.cmd, command.opts)
        end)

        return true
      end,
    })
    :find()
end
