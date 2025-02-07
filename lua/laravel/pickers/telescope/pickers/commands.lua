local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")

local commands_picker = {}

function commands_picker:new(runner, user_commands_repository)
  local instance = {
    runner = runner,
    user_commands_repository = user_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function commands_picker:run(opts)
  self.user_commands_repository:all():thenCall(function(commands)
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
