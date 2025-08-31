local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local resources_picker = {}

function resources_picker.run(opts, resources)
  pickers
    .new(opts or {}, {
      prompt_title = "User Commands",
      finder = finders.new_table({
        results = resources,
        entry_maker = function(resource)
          return {
            value = resource,
            display = resource.name,
            ordinal = resource.name,
          }
        end,
      }),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          return { "ls", "-1", entry.value.path }
        end,
      }),

      sorter = conf.file_sorter(),

      attach_mappings = function(_, map)
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local resource = entry.value

          require("telescope.builtin").find_files({ cwd = resource.path })
        end)

        return true
      end,
    })
    :find()
end

return resources_picker
