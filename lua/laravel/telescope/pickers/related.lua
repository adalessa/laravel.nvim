local pickers = require "telescope.pickers"
local run = require "laravel.run"
local lsp = require "laravel._lsp"
local make_entry = require "laravel.telescope.make_entry"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local notify = require("laravel.notify")

return function(opts)
  opts = opts or {}

  local file_type = vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(file_type)
  if lang ~= "php" then
    return false
  end

  local get_model_class_name = function()
    local query = vim.treesitter.query.parse(
      lang,
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

  local class = get_model_class_name()
  if class ~= "" then
    local result, ok = run("artisan", { "model:show", class, "--json" }, { runner = "sync" })
    if not ok then
      notify(
        "Artisan",
        { msg = "'php artisan model:show " .. class .. " --json' command failed", level = "ERROR" }
      )
      return nil
    end

    if result.exit_code ~= 0 or string.sub(result.out[1], 1, 1) ~= "{" or string.sub(result.out[1], -1) ~= "}" then
      notify(
        "Artisan",
        { msg = "'php artisan model:show" .. class .. "  --json' response could not be decoded", level = "ERROR" }
      )
      return nil
    end

    local model_info = vim.fn.json_decode(result.out[1])
    if model_info == nil then
      notify(
        "Artisan",
        { msg = "'php artisan model:show" .. class .. "  --json' response could not be decoded", level = "ERROR" }
      )
      return nil
    end

    ---@return ModelRelation|nil
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

    local relations = {}
    local types = { "observers", "relations", "policy" }
    for _, relation_type in ipairs(types) do
      if model_info[relation_type] ~= vim.NIL and #model_info[relation_type] > 0 then
        if type(model_info[relation_type]) == "table" and model_info[relation_type][1] ~= vim.NIL then
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
          map("i", "<cr>", function(prompt_bufnr)
            actions.close(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            vim.schedule(function()
              local action = vim.fn.split(entry.value.class, "@")
              lsp.go_to(action[1], action[2])
            end)
          end)

          return true
        end,
      })
      :find()
  end
end
