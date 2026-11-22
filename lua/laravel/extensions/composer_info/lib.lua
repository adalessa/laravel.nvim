local nio = require("nio")
local Class = require("laravel.utils.class")

---@class laravel.extensions.composer_info.lib
---@field composer laravel.services.composer
---@field log laravel.utils.log
local composer_info = Class({
  composer = "laravel.services.composer",
  log = "laravel.utils.log",
})

function composer_info:handle(bufnr)
  local ns = vim.api.nvim_create_namespace("composer-deps")
  nio.run(function()
    local infos, err = self.composer:info()
    if err then
      nio.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      self.log:debug("Could not get composer info: " .. err:toString())
      return
    end
    local outdates, err = self.composer:outdated()
    if err then
      nio.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      self.log:debug("Could not get composer outdated: " .. err:toString())
      return
    end

    if not nio.api.nvim_buf_is_valid(bufnr) then
      return
    end
    nio.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    local dependencies, err = self.composer:dependencies(bufnr)
    if err then
      self.log:debug("Could not get composer dependencies: " .. err:toString())
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
        nio.api.nvim_buf_set_extmark(bufnr, ns, dep.line, 0, {
          virt_text = { { string.format("<- %s", info.version), "comment" } },
          virt_text_pos = "eol",
        })
      end

      if outdated then
        nio.api.nvim_buf_set_extmark(bufnr, ns, dep.line, 0, {
          virt_text = { { string.format("^ %s (new version)", outdated.latest), "error" } },
          virt_text_pos = "eol",
        })
      end
    end
  end)
end

return composer_info
