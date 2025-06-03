local nio = require("nio")
local notify = require("laravel.utils.notify")

---@class laravel.extensions.composer_info.lib
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

local clean = vim.schedule_wrap(function(bufnr, ns)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end)

function composer_info:handle(bufnr)
  local ns = vim.api.nvim_create_namespace("composer-deps")
  nio.run(function()
    local infos, err = self.composer:info()
    if err then
      clean(bufnr, ns)
      notify.error("Could not get composer info: " .. err)
      return
    end
    local outdates, err = self.composer:outdated()
    if err then
      clean(bufnr, ns)
      notify.error("Could not get composer outdated: " .. err)
      return
    end

    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      local dependencies, err = self.composer:dependencies(bufnr)
      if err then
        notify.error("Could not get composer dependencies: " .. err)
        return
      end
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
  end)
end

return composer_info
