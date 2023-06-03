local telescope = require "telescope"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local preview = require "laravel.telescope.preview"
local make_entry = require "laravel.telescope.make_entry"
local laravel_commands = require "laravel.commands"
local laravel_routes = require "laravel.routes"
local application = require "laravel.application"
local lsp = require "laravel._lsp"

---@class ModelRelation
---@field class string
---@field type string
---@field extra_information string

--- runs a command from telescope
---@param command LaravelCommand
---@param ask_options boolean | nil
---@param runner string | nil
local function run_command(command, ask_options, runner)
  -- use ui.input
  -- problem it uses callbacks and how to control the flow for multiple
  -- problem everything needs to be done in the callback because it does not block the execution
  -- it will feel like javascript callback hell
  -- since will have to for reach argument do an internal loop and from that pass a callback and so far

  ---@param argument CommandArgument
  ---@return string
  local function build_prompt(argument)
    local prompt = argument.name
    if argument.is_required then
      prompt = prompt .. " <require>"
    end

    return prompt
  end

  local function get_arguments(args, callback, values)
    if #args == 0 then
      callback(values)
      return
    end

    vim.ui.input({ prompt = build_prompt(args[1]) }, function(value)
      if value == "" then
        return
      end
      table.insert(values, value)
      table.remove(args, 1)
      get_arguments(args, callback, values)
    end)
  end

  local function run(args, options)
    local cmd = { command.name }
    for _, arg in pairs(args) do
      table.insert(cmd, arg)
    end

    if options ~= nil and options ~= "" then
      for _, value in pairs(vim.fn.split(options, " ")) do
        table.insert(cmd, value)
      end
    end

    local resources = require "laravel.resources"
    if resources.is_resource(cmd[1]) then
      return resources.create(cmd)
    end

    application.run("artisan", cmd, { runner = runner })
  end

  local args = {}
  for _, argument in pairs(command.definition.arguments) do
    table.insert(args, argument)
  end

  get_arguments(args, function(values)
    if ask_options then
      vim.ui.input({ prompt = "Options" }, function(options)
        run(values, options)
      end)
      return
    end
    run(values, nil)
  end, {})

  return true
end

local commands = function(opts)
  opts = opts or {}

  local commands = laravel_commands.list()

  if commands == nil then
    return
  end

  pickers
    .new(opts, {
      prompt_title = "Artisan commands",
      finder = finders.new_table {
        results = commands,
        entry_maker = function(command)
          return {
            value = command,
            display = command.name,
            ordinal = command.name,
          }
        end,
      },
      previewer = previewers.new_buffer_previewer {
        title = "Help",
        get_buffer_by_name = function(_, entry)
          return entry.value.name
        end,
        define_preview = function(self, entry)
          local command_preview = preview.command(entry.value)

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, command_preview.lines)

          local hl = vim.api.nvim_create_namespace "laravel"
          for _, value in pairs(command_preview.highlights) do
            vim.api.nvim_buf_add_highlight(self.state.bufnr, hl, value[1], value[2], value[3], value[4])
          end
        end,
      },
      sorter = conf.file_sorter(),
      attach_mappings = function(_, map)
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          ---@type LaravelCommand command
          local command = entry.value

          vim.schedule(function()
            run_command(command)
          end)
        end)
        map("i", "<C-y>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          ---@type LaravelCommand command
          local command = entry.value

          vim.schedule(function()
            run_command(command, true)
          end)
        end)
        map("i", "<c-t>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          ---@type LaravelCommand command
          local command = entry.value

          vim.schedule(function()
            run_command(command)
          end)
        end)
        return true
      end,
    })
    :find()
end

local routes = function(opts)
  opts = opts or {}

  local routes = laravel_routes.list()
  if routes == nil then
    return
  end

  pickers
    .new(opts, {
      prompt_title = "Artisan Routes",
      finder = finders.new_table {
        results = routes,
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
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          vim.schedule(function()
            laravel_routes.go_to(entry.value)
          end)
        end)

        return true
      end,
    })
    :find()
end

local related = function(opts)
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
    local result, ok = application.run("artisan", { "model:show", class, "--json" }, { runner = "sync" })
    if not ok then
      return nil
    end

    if result.exit_code ~= 0 or string.sub(result.out[1], 1, 1) ~= "{" or string.sub(result.out[1], -1) ~= "}" then
      return nil
    end

    local model_info = vim.fn.json_decode(result.out[1])
    if model_info == nil then
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

return telescope.register_extension {
  exports = {
    commands = commands,
    routes = routes,
    related = related,
  },
}
