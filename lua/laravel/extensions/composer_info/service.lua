local promise = require("promise")

---@class laravel.extensions.composer_info.service
---@field composer laravel.services.composer
local composer_info = {}

---@param composer laravel.services.composer
function composer_info:new(composer)
  local instance = {
    composer = composer,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function composer_info:handle(bufnr)
  local ns = vim.api.nvim_create_namespace("composer-deps")

  return promise
      .all({
        self.composer:info(),
        self.composer:outdated(),
        self.composer:dependencies(bufnr),
      })
      :thenCall(function(results)
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        local infos, outdates, dependencies = unpack(results)

        for _, dep in ipairs(dependencies) do
          local info = vim.iter(infos):find(function(inst)
            return dep.name == inst.name
          end)
          local outdated = vim.iter(outdates):find(function(inst)
            return dep.name == inst.name
          end)

          if info then
            vim.api.nvim_buf_set_extmark(bufnr, ns, dep.line, 0, {
              virt_text = { { string.format("<- %s", info.version), "comment" } },
              virt_text_pos = "eol",
            })
          end

          if outdated then
            vim.api.nvim_buf_set_extmark(bufnr, ns, dep.line, 0, {
              virt_text = { { string.format("^ %s (new version)", outdated.latest), "error" } },
              virt_text_pos = "eol",
            })
          end
        end
      end)
      :catch(function()
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      end)
end

return composer_info
