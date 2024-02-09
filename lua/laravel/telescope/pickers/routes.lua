local conf = require("telescope.config").values
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local preview = require "laravel.telescope.preview"
local make_entry = require "laravel.telescope.make_entry"
local routes = require "laravel.routes"
local actions = require "laravel.telescope.actions"

return function(opts)
  opts = opts or {}

  if vim.tbl_isempty(routes.list) then
    if not routes.load() then
      return
    end
  end

  pickers
    .new(opts, {
      prompt_title = "Artisan Routes",
      finder = finders.new_table {
        results = routes.list,
        entry_maker = opts.entry_maker or make_entry.gen_from_laravel_routes(opts),
      },
      previewer = previewers.new_buffer_previewer {
        title = "Help",
        get_buffer_by_name = function(_, entry)
          return entry.value.name
        end,
        define_preview = function(self, entry)
          local route_preview = preview.route(entry.value)

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, route_preview.lines)

          local hl = vim.api.nvim_create_namespace "laravel"
          for _, value in pairs(route_preview.highlights) do
            vim.api.nvim_buf_add_highlight(self.state.bufnr, hl, value[1], value[2], value[3], value[4])
          end
        end,
      },
      sorter = conf.prefilter_sorter {
        tag = "route_method",
        sorter = conf.generic_sorter(opts or {}),
      },
      attach_mappings = function(_, map)
        map("i", "<cr>", actions.open_route)
        map("i", "<c-o>", actions.open_browser)

        return true
      end,
    })
    :find()
end
