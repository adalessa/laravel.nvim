local promise = require("promise")
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
---@return Promise
function class:get(bufnr)
  return promise:new(function(resolve, reject)
    local php_parser = vim.treesitter.get_parser(bufnr, "php")
    if php_parser == nil then
      reject("Could not get the parser")
      return
    end

    local tree = php_parser:parse()[1]
    if tree == nil then
      reject("Could not retrieve syntx tree")
      return
    end

    local query = vim.treesitter.query.get("php", "php_class")
    if not query then
      reject("Could not get treesitter query")
      return
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

    if response.class == "" then
      reject("Buffer is not a class")
      return
    end

    resolve(response)
  end)
end

---@return Promise
function class:views(bufnr)
  return promise:new(function(resolve, reject)
    local php_parser = vim.treesitter.get_parser(bufnr, "php")
    if php_parser == nil then
      reject("Could not get the parser")
      return
    end

    local tree = php_parser:parse()[1]
    if tree == nil then
      reject("Could not retrive syntax tree")
      return
    end

    local query = vim.treesitter.query.get("php", "laravel_views")

    if not query then
      reject("Could not get treesitter query")
      return
    end

    local founds = {}
    for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      if query.captures[id] == "view" then
        local view = vim.treesitter.get_node_text(node, bufnr):gsub("'", "")
        founds[view] = true
      end
    end

    founds = vim.tbl_keys(founds)

    resolve(founds)
  end)
end

return class
