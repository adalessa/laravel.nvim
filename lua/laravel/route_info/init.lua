local notify = require "laravel.notify"
local routes = require "laravel.routes"
local config = require "laravel.config"

local get_node_text = vim.treesitter.get_node_text
local options = config.options.route_info

local function is_same_class(action, class)
  return string.sub(action, 1, string.len(class)) == class
end

local function generate_virtual_text_options(route)
  if options.position == "right" then
    return {
      virt_text = {
        { "[", "comment" },
        { "Method: ", "comment" },
        { vim.fn.join(route.methods, "|"), "@enum" },
        { " Uri: ", "comment" },
        { route.uri, "@enum" },
        { " Middleware: ", "comment" },
        { vim.fn.join(route.middlewares or { "None" }, ","), "@enum" },
        { "]", "comment" },
      },
    }
  end
  if options.position == "top" then
    return {
      virt_lines = {
        {
          { "    ", "" },
          { "[", "comment" },
          { "Method: ", "comment" },
          { vim.fn.join(route.methods, "|"), "@enum" },
          { " Uri: ", "comment" },
          { route.uri, "@enum" },
          { " Middleware: ", "comment" },
          { vim.fn.join(route.middlewares or { "None" }, ","), "@enum" },
          { "]", "comment" },
        },
      },
      virt_lines_above = true,
    }
  end
end

local function set_route_to_methods(event)
  local bufnr = event.buf
  local namespace = vim.api.nvim_create_namespace "laravel.routes"

  -- clean namespace
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.diagnostic.reset(namespace, bufnr)

  if #routes.list == 0 then
    if not routes.load() then
      return
    end
  end

  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    notify("route_info.set_route_to_methods", { msg = "Could not retrive syntax tree", level = "WARN" })
    return
  end

  local query = vim.treesitter.query.get("php", "laravel_route_info")
  if query == nil then
    vim.treesitter.query.set(
      "php",
      "laravel_route_info",
      [[
        (namespace_definition (namespace_name) @namespace)
        (class_declaration (name) @class)
        (method_declaration
            (visibility_modifier) @visibility
            (name) @method
        )
    ]]
    )

    query = vim.treesitter.query.get("php", "laravel_route_info")
  end

  local class, class_namespace, methods, visibilities = "", "", {}, {}
  local class_pos = 0

  for id, node in query:iter_captures(tree:root(), bufnr) do
    if query.captures[id] == "class" then
      class = get_node_text(node, bufnr)
      class_pos = node:start()
    elseif query.captures[id] == "namespace" then
      class_namespace = get_node_text(node, bufnr)
    elseif query.captures[id] == "method" then
      table.insert(methods, {
        pos = node:start(),
        name = get_node_text(node, bufnr),
      })
    elseif query.captures[id] == "visibility" then
      table.insert(visibilities, get_node_text(node, bufnr))
    end
  end

  local class_methods = {}

  local full_class = string.format("%s\\%s", class_namespace, class)
  for idx, method in ipairs(methods) do
    if visibilities[idx] == "public" then
      table.insert(class_methods, {
        full = string.format("%s\\%s@%s", class_namespace, class, method.name),
        name = method.name,
        pos = method.pos,
      })
    end
  end

  local errors = {}
  for _, route in pairs(routes.list) do
    local found = false
    for _, method in pairs(class_methods) do
      local action_full = route.action
      if vim.fn.split(route.action, "@")[2] == nil then
        action_full = action_full .. "@__invoke"
      end
      if action_full == method.full then
        vim.api.nvim_buf_set_extmark(bufnr, namespace, method.pos, 0, generate_virtual_text_options(route))
        found = true
      end
    end

    if is_same_class(route.action, full_class) and not found then
      table.insert(errors, {
        lnum = class_pos,
        col = 0,
        message = string.format(
          "missing method %s [Method: %s, URI: %s]",
          vim.fn.split(route.action, "@")[2] or "__invoke",
          vim.fn.join(route.methods, "|"),
          route.uri
        ),
      })
    end
  end

  if #errors > 0 then
    vim.diagnostic.set(namespace, bufnr, errors)
  end
end

local group = vim.api.nvim_create_augroup("laravel.route_info", {})

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "routes/*.php" },
    group = group,
    callback = function()
      routes.load()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = set_route_to_methods,
  })
end

return M
