local get_node_text = vim.treesitter.get_node_text
local Error = require("laravel.utils.error")

---@class laravel.services.class
local class = {}

local function posFromNode(node)
  local start_row, start_col = node:start()
  local end_row, end_col = node:end_()

  return {
    start = { row = start_row, col = start_col },
    end_ = { row = end_row, col = end_col },
  }
end

---[this needs to run in scheduler]
---@param bufnr number
---@return laravel.dto.class, laravel.utils.error|nil
function class:get(bufnr)
  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  if php_parser == nil then
    return {}, Error:new("Could not get the parser")
  end

  local tree = php_parser:parse()[1]
  if tree == nil then
    return {}, Error:new("Could not retrieve syntx tree")
  end

  local query = vim.treesitter.query.get("php", "php_class")
  if not query then
    return {}, Error:new("Could not get treesitter query")
  end

  ---@type laravel.dto.class
  local response = {
    fqn = "",
    class = "",
    namespace = "",
    methods = {},
    properties = {},
  }

  local methods_visibility = {}
  local properties_visibility = {}

  for id, node in query:iter_captures(tree:root(), bufnr) do
    if query.captures[id] == "class" then
      response.class = get_node_text(node, bufnr)
      response.position = posFromNode(node:parent())
    elseif query.captures[id] == "namespace" then
      response.namespace = get_node_text(node, bufnr)
    elseif query.captures[id] == "method_name" then
      table.insert(response.methods, {
        position = posFromNode(node:parent()),
        name = get_node_text(node, bufnr),
      })
    elseif query.captures[id] == "method_visibility" then
      table.insert(methods_visibility, get_node_text(node, bufnr))
    elseif query.captures[id] == "property_name" then
      table.insert(response.properties, {
        position = posFromNode(node:parent():parent()),
        name = get_node_text(node, bufnr),
      })
    elseif query.captures[id] == "property_visibility" then
      table.insert(properties_visibility, get_node_text(node, bufnr))
    end
  end

  response.fqn = string.format("%s\\%s", response.namespace, response.class)

  for idx, _ in ipairs(response.properties) do
    response.properties[idx].visibility = properties_visibility[idx]
  end
  for idx, _ in ipairs(response.methods) do
    response.methods[idx].visibility = methods_visibility[idx]
    response.methods[idx].fqn = string.format("%s@%s", response.fqn, response.methods[idx].name)
  end

  if response.class == "" then
    return {}, Error:new("Buffer is not a class")
  end

  return response
end

---@return string[], laravel.error
function class:views(bufnr)
  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  if php_parser == nil then
    return {}, Error:new("Could not get the parser")
  end

  local tree = php_parser:parse()[1]
  if tree == nil then
    return {}, Error:new("Could not retrive syntax tree")
  end

  local query = vim.treesitter.query.get("php", "laravel_views")

  if not query then
    return {}, Error:new("Could not get treesitter query")
  end

  local founds = {}
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      local view = vim.treesitter.get_node_text(node, bufnr):gsub("'", "")
      founds[view] = true
    end
  end

  founds = vim.tbl_keys(founds)

  return founds
end

return class
