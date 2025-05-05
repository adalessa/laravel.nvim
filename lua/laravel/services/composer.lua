local promise = require("promise")

---@class laravel.services.composer
---@field api laravel.api
local composer = {}

function composer:new(api)
  local instance = {
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function composer:info()
  return self.api:send("composer", { "info", "-f", "json" }):thenCall(
    ---@param response laravel.dto.apiResponse
    function(response)
      return response:json().installed
    end
  )
end

---@return Promise
function composer:outdated()
  return self.api:send("composer", { "outdated", "-f", "json" }):thenCall(
    ---@param response laravel.dto.apiResponse
    function(response)
      return response:json().installed
    end
  )
end

---@return Promise
function composer:dependencies(bufnr)
  return promise:new(function(resolve, reject)
    local parser = vim.treesitter.get_parser(bufnr, "json")
    if not parser then
      reject("Could not get treesitter parser")
      return
    end
    local tree = parser:parse()[1]
    if tree == nil then
      reject("Could not retrieve syntx tree")
      return
    end

    local query = vim.treesitter.query.get("json", "composer_dependencies")
    if not query then
      reject("Could not get treesitter query")
      return
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

    resolve(dependencies)
  end)
end

return composer
