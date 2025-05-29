local Class = require("laravel.utils.class")

---@class laravel.dto.composer_package

---@class laravel.services.composer
---@field api laravel.services.api
local composer = Class({ api = "laravel.services.api" })

---@return laravel.dto.composer_package, string?
function composer:info()
  local res, err = self.api:run("composer info -f json")
  if err then
    return {}, "Error running composer info: " .. err
  end

  return res:json().installed
end

---@return laravel.dto.composer_package, string?
function composer:outdated()
  local res, err = self.api:run("composer outdated -f json")
  if err then
    return {}, "Error running composer outdated: " .. err
  end

  return res:json().installed
end

function composer:dependencies(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "json")
  if not parser then
    return {}, "Could not get treesitter parser"
  end
  local tree = parser:parse()[1]
  if tree == nil then
    return {}, "Could not retrieve syntx tree"
  end

  local query = vim.treesitter.query.get("json", "composer_dependencies")
  if not query then
    return {}, "Could not get treesitter query"
  end

  local dependencies = {}

  for id, node in query:iter_captures(tree:root(), bufnr) do
    if query.captures[id] == "depen" then
      table.insert(dependencies, {
        name = vim.treesitter.get_node_text(node, bufnr),
        line = node:start(),
      })
    end
  end

  return dependencies
end

return composer
