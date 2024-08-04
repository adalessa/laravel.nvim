local get_node_text = vim.treesitter.get_node_text

---@class LaravelClass
---@field fqn string
---@field class string
---@field namespace string
---@field line number
---@field methods table[]
---@field properties table[]

---@class LaravelClassService
local class = {}

---@param bufnr number
---@param callback fun(class: LaravelClass)
function class:get(bufnr, callback)
  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    error("Could not retrieve syntx tree", vim.log.levels.ERROR)
  end

  local query = vim.treesitter.query.get("php", "php_class")
  if not query then
    error("Could not get treesitter query", vim.log.levels.ERROR)
  end

  local response = {
    fqn = "",
    class = "",
    namespace = "",
    line = 0,
    methods = {},
    properties = {},
  }

  local methods_visibility = {}
  local properties_visibility = {}

  for id, node in query:iter_captures(tree:root(), bufnr) do
    if query.captures[id] == "class" then
      response.class = get_node_text(node, bufnr)
      response.line = node:start()
    elseif query.captures[id] == "namespace" then
      response.namespace = get_node_text(node, bufnr)
    elseif query.captures[id] == "method_name" then
      table.insert(response.methods, {
        pos = node:start(),
        name = get_node_text(node, bufnr),
      })
    elseif query.captures[id] == "method_visibility" then
      table.insert(methods_visibility, get_node_text(node, bufnr))
    elseif query.captures[id] == "property_name" then
      table.insert(response.properties, {
        pos = node:start(),
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

  callback(response)
end

function class:views(bufnr, callback)
  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    error("Could not retrive syntax tree", vim.log.levels.ERROR)
  end

  local query = vim.treesitter.query.get("php", "laravel_views")

  if not query then
    error("Could not get treesitter query", vim.log.levels.ERROR)
  end

  local founds = {}
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      local view = vim.treesitter.get_node_text(node, bufnr):gsub("'", "")
      founds[view] = true
    end
  end

  founds = vim.tbl_keys(founds)

  callback(founds)
end

return class
