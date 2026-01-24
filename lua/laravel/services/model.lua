local nio = require("nio")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.model
---@field class laravel.services.class
---@field loader laravel.loaders.models_loader
---@field path laravel.services.path
local model = Class({
  class = "laravel.services.class",
  path = "laravel.services.path",
  loader = "laravel.loaders.models_loader",
})

---@async
---@param bufnr? number
---@return laravel.dto.model_response, laravel.utils.error|nil
function model:get(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local response, err = self.loader:load()

  if err then
    return {}, Error:new("Failed to load models"):wrap(err)
  end

  nio.scheduler()

  local uri = vim.uri_from_bufnr(bufnr)
  local fname = vim.uri_to_fname(uri)

  ---@type laravel.dto.model|nil
  local _, m = vim.iter(response.models):find(
    ---@param m laravel.dto.model
    function(_, m)
      return self.path:handle(m.uri) == fname
    end
  )

  if not m then
    return {}, Error:new("No model found for this buffer")
  end

  nio.scheduler()
  local class, err = self.class:get(bufnr)

  return {
    model = m,
    class = class,
  }, nil
end

---@async
---@param uri string
---@return laravel.dto.model, laravel.utils.error|nil
function model:byUri(uri)
  local response, err = self.loader:load()

  if err then
    return {}, Error:new("Failed to load models"):wrap(err)
  end

  nio.scheduler()

  ---@type laravel.dto.model|nil
  local _, m = vim.iter(response.models):find(
    ---@param m laravel.dto.model
    function(_, m)
      return self.path:handle(m.uri) == uri
    end
  )

  if not m then
    return {}, Error:new("No model found for this uri")
  end

  return m, nil
end

return model
