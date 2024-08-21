local routes = require "laravel.routes"
local config = require "laravel.config"

local get_node_text = vim.treesitter.get_node_text
local options = config.options.features.route_info

local function is_same_class(action, class)
  return string.sub(action, 1, string.len(class)) == class
end

local function get_line_indent(line)
  local line_content = vim.fn.getline(line)
  return string.match(line_content, "^%s*")
end

local function generate_virtual_text_options(route, indent)
  if options.position == "right" then
    local virt_text = {
      { "[", "comment" },
    }

    if options.method then
      table.insert(virt_text, { " Method: ", "comment" })
      table.insert(virt_text, { route.methods[1], "@enum" })
    end

    if options.uri then
      table.insert(virt_text, { " Uri: ", "comment" })
      table.insert(virt_text, { route.uri, "@enum" })
    end

    if options.middlewares then
      table.insert(virt_text, { " Middleware: ", "comment" })
      table.insert(virt_text, { vim.fn.join(route.middlewares or { "None" }, ","), "@enum" })
    end

    table.insert(virt_text, { "]", "comment" })

    return {
      virt_text = virt_text,
    }
  end
  if options.position == "top" then

    local middleware_lines = {}
    if options.middlewares then
      for _, mw in ipairs(route.middlewares or { "None" }) do
        table.insert(middleware_lines, { {indent .. "  " .. mw, "@enum"} })
      end
    end

    local virt_lines = {
      { { indent .. "[", "comment" } }
    }

    if options.method then
      table.insert(virt_lines, { { indent .. " Method: ", "comment" }, { vim.fn.join(route.methods, "|"), "@enum" } })
    end

    if options.uri then
      table.insert(virt_lines, { { indent .. " Uri: ", "comment" }, { route.uri, "@enum" } })
    end

    if options.middlewares then
      table.insert(virt_lines,  { { indent .. " Middleware: ", "comment" } })
      for _, line in ipairs(middleware_lines) do
        table.insert(virt_lines, line)
      end
    end

    table.insert(virt_lines, { { indent .. "]", "comment" } })

    return {
      virt_lines = virt_lines,
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

  local setRouteInfo = function()
    local php_parser = vim.treesitter.get_parser(bufnr, "php")
    local tree = php_parser:parse()[1]
    if tree == nil then
      error("Could not retrieve syntx tree", vim.log.levels.ERROR)
    end

    local query = vim.treesitter.query.get("php", "php_class")
    if not query then
      error("Could not get treesitter query", vim.log.levels.ERROR)
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
        local method_pos = node:start()
        local method_indent = get_line_indent(method_pos + 1)
        table.insert(methods, {
          pos = node:start(),
          name = get_node_text(node, bufnr),
          indent = method_indent
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
          indent = method.indent,
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
          vim.api.nvim_buf_set_extmark(bufnr, namespace, method.pos, 0, generate_virtual_text_options(route, method.indent))
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

  if #routes.list == 0 then
    routes.asyncLoad(function(result)
      if result:successful() then
        setRouteInfo()
      end
    end)
  else
    setRouteInfo()
  end
end

local group = vim.api.nvim_create_augroup("laravel.route_info", {})

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "routes/*.php" },
    group = group,
    callback = function()
      routes.asyncLoad()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = set_route_to_methods,
  })
end

return M
