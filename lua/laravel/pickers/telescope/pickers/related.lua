local pickers = require("telescope.pickers")
local make_entry = require("laravel.pickers.telescope.make_entry")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("laravel.pickers.telescope.actions")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.telescope.related
---@field related laravel.services.related
local related_picker = Class({
  related = "laravel.services.related",
})

function related_picker:run(opts)
  local relations, err = self.related:get(vim.api.nvim_get_current_buf())
  if err then
    return notify.error("Error loading related items: " .. err)
  end

  vim.schedule(function()
    pickers
      .new(opts, {
        prompt_title = "Related Files",
        finder = finders.new_table({
          results = relations,
          entry_maker = make_entry.gen_from_model_relations(opts),
        }),
        sorter = conf.prefilter_sorter({
          sorter = conf.generic_sorter(opts or {}),
        }),
        attach_mappings = function(_, map)
          map("i", "<cr>", actions.open_relation)

          return true
        end,
      })
      :find()
  end)
end

return related_picker
