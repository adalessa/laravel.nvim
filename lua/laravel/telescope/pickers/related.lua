local pickers = require "telescope.pickers"
local make_entry = require "laravel.telescope.make_entry"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local api = require "laravel.api"
local actions = require "laravel.telescope.actions"

local get_model_class_name = function()
  local query = vim.treesitter.query.parse(
    "php",
    [[ (namespace_definition name: (namespace_name) @namespace)
        (class_declaration name: (name) @class) ]]
  )
  local tree = vim.treesitter.get_parser():parse()[1]:root()
  local bufNr = vim.fn.bufnr()
  local class = ""
  for id, node, _ in query:iter_captures(tree, bufNr, tree:start(), tree:end_()) do
    if query.captures[id] == "class" then
      class = class .. "\\" .. vim.treesitter.get_node_text(node, 0)
    elseif query.captures[id] == "namespace" then
      class = vim.treesitter.get_node_text(node, 0) .. class
    end
  end
  return class
end

local build_relation = function(info, relation_type)
  if next(info) == nil then
    return nil
  end
  if relation_type == "observers" and info["observer"][2] ~= nil then
    return {
      class = info["observer"][2],
      type = relation_type,
      extra_information = info["event"],
    }
  elseif relation_type == "relations" then
    return {
      class = info["related"],
      type = relation_type,
      extra_information = info["type"] .. " " .. info["name"],
    }
  elseif relation_type == "policy" then
    return {
      class = info[1],
      type = relation_type,
      extra_information = "",
    }
  end
  return nil
end

return function(opts)
  opts = opts or {}

  local file_type = vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(file_type)
  if lang ~= "php" then
    return false
  end

  local class = opts.class or get_model_class_name()

  if not class or class == "" then
    return
  end

  api.async("artisan", { "model:show", class, "--json" }, function(response)
    local model_info = response:json()

    if model_info == nil then
      error(string.format("'artisan model:show %s --json' response could not be decoded", class), vim.log.levels.ERROR)
    end

    local relations = {}
    local types = { "observers", "relations", "policy" }
    for _, relation_type in ipairs(types) do
      if model_info[relation_type] ~= nil and #model_info[relation_type] > 0 then
        if type(model_info[relation_type]) == "table" and model_info[relation_type][1] ~= nil then
          for _, info in ipairs(model_info[relation_type]) do
            local relation = build_relation(info, relation_type)
            if relation ~= nil then
              table.insert(relations, relation)
            end
          end
        else
          local relation = build_relation({ model_info[relation_type] }, relation_type)
          if relation ~= nil then
            table.insert(relations, relation)
          end
        end
      end
    end

    pickers
        .new(opts, {
          prompt_title = "Related Files",
          finder = finders.new_table {
            results = relations,
            entry_maker = make_entry.gen_from_model_relations(opts),
          },
          sorter = conf.prefilter_sorter {
            sorter = conf.generic_sorter(opts or {}),
          },
          attach_mappings = function(_, map)
            map("i", "<cr>", actions.open_relation)

            return true
          end,
        })
        :find()
  end, function(errResponse)
    error(errResponse:prettyErrors(), vim.log.levels.ERROR)
  end)
end
