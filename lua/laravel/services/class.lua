local nio = require("nio")
local get_node_text = vim.treesitter.get_node_text
local Error = require("laravel.utils.error")

---@class laravel.dto.class
---@field fqn string
---@field class string
---@field namespace string
---@field line number
---@field methods table[]
---@field properties table[]

---@class laravel.services.class
local class = {}

class.getByBuffer = nio.wrap(function(self, bufnr, cb)
  vim.schedule(function()
    local cls, err = self:get(bufnr)
    cb(cls, err)
  end)
end, 3)

---@async
---@param bufnr number
---@return laravel.dto.class, laravel.error
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
      response.end_ = node:parent():end_()
    elseif query.captures[id] == "namespace" then
      response.namespace = get_node_text(node, bufnr)
    elseif query.captures[id] == "method_name" then
      local s = node:start()
      local e = node:parent():end_()
      table.insert(response.methods, {
        pos = { s, e },
        name = get_node_text(node, bufnr),
      })
    elseif query.captures[id] == "method_visibility" then
      table.insert(methods_visibility, get_node_text(node, bufnr))
    elseif query.captures[id] == "property_name" then
      local s = node:start()
      local e = node:parent():parent():parent():end_()
      table.insert(response.properties, {
        pos = { s, e },
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
