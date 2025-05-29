local Class = require("laravel.utils.class")

local action = Class({
  model = "laravel.services.model",
  templates = "laravel.utils.templates",
}, { info = nil })

---@async
function action:check(bufnr)
  local info, err = self.model:getByBuffer(bufnr)
  if err then
    return false
  end
  self.info = info

  return true
end

function action:format()
  return "Add relation"
end

---@async
function action:run(bufnr)
  -- TODO
  -- ask type of relation
  -- ask Model
  -- check if Model in same namespace
  -- check if type of relation already there
  vim.schedule(function()
    vim.lsp.util.apply_text_edits({
      {
        range = {
          start = { line = self.info.class_info.end_, character = 0 },
          ["end"] = { line = self.info.class_info.end_, character = 0 },
        },
        newText = self.templates:build("relation", "user", "BelongsTo", "belongsTo(User::class)"),
      },
    }, bufnr, "utf-8")
  end)
end

return action
