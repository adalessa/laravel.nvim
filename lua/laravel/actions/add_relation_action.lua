local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local nio = require("nio")

---@class laravel.actions.add_relation_action
---@field model laravel.services.model
---@field templates laravel.utils.templates
---@field loader laravel.loaders.models_loader
---@field string_helper laravel.services.laravel_string
---@field info laravel.dto.model_response|nil
local action = Class({
  model = "laravel.services.model",
  templates = "laravel.utils.templates",
  loader = "laravel.loaders.models_loader",
  string_helper = "laravel.services.laravel_string",
}, { info = nil })

---@async
function action:check(bufnr)
  local info, err = self.model:get(bufnr)
  if err then
    return false
  end
  self.info = info

  return true
end

function action:format()
  return "Add relation"
end

---@async
function action:run(bufnr)
  local resp, err = self.loader:load()
  if err then
    notify.error("Error loading models. " .. err:toString())
    return
  end

  local available = vim
    .iter(resp.models)
    :filter(function(name, item)
      return self.info.model.class ~= name
        and not vim.tbl_contains(
          vim
            .iter(self.info.model.relations)
            :map(function(r)
              return r.related
            end)
            :totable(),
          name
        )
    end)
    :totable()

  local selected = nio.ui.select(vim.tbl_values(available), {
    prompt = "Select model to relate to: ",
    ---@param item table
    format_item = function(item)
      return item[2].class
    end,
  })
  if not selected then
    return
  end

  ---@type laravel.dto.model
  selected = selected[2]

  local relation = nio.ui.select({
    {
      name = "BelongsTo",
      plural = false,
      template = [[
    public function %s(): BelongsTo
    {
         return $this->BelongsTo(%s);
    }]],
      import = "Illuminate\\Database\\Eloquent\\Relations\\BelongsTo",
    },
    {
      name = "HasMany",
      plural = true,
      template = [[
    public function %s(): HasMany
    {
         return $this->hasMany(%s);
    }]],
      import = "Illuminate\\Database\\Eloquent\\Relations\\HasMany",
    },
    {
      name = "HasOne",
      plural = false,
      template = [[
    public function %s(): HasOne
    {
         return $this->hasOne(%s);
    }]],
      import = "Illuminate\\Database\\Eloquent\\Relations\\HasOne",
    },
  }, {
    prompt = "Select model to relate to: ",
    format_item = function(item)
      return item.name
    end,
  })

  if not relation then
    return
  end

  local class_name = selected.class:match("([^\\]+)$")
  local function_name = class_name:lower()
  if relation.plural then
    local plural, err = self.string_helper:pluralize(function_name)
    if err then
      notify.error("Error pluralizing function name: " .. err:toString())
      return
    end
    function_name = plural
  end

  -- WARN: this will not work when having the doc block
  local toInsert = string.format(relation.template, function_name, class_name .. "::class")
  local lines = vim.split(toInsert:gsub("\n$", ""), "\n")
  table.insert(lines, 1, "") -- add a new line before

  local row = self.info.class.position.end_.row
  nio.api.nvim_buf_set_lines(bufnr, row, row, false, lines)

  -- get the last use import
  local lastUse = 0
  vim.iter(self.info.class.uses):each(function(_, use)
    if use.position.end_.row > lastUse then
      lastUse = use.position.end_.row
    end
  end)

  if not vim.tbl_contains(vim.tbl_keys(self.info.class.uses), relation.import) then
    nio.api.nvim_buf_set_lines(bufnr, lastUse, lastUse, false, {
      "use " .. relation.import .. ";",
    })

    lastUse = lastUse + 1
  end

  local selectedNamespace = selected.class:match("^(.*)\\[^\\]+$")

  if
    not vim.tbl_contains(vim.tbl_keys(self.info.class.uses), selected.class)
    and self.info.class.namespace ~= selectedNamespace
  then
    vim.api.nvim_buf_set_lines(bufnr, lastUse, lastUse, false, {
      "use " .. selected.class .. ";",
    })
  end
end

return action
