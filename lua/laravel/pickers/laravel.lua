local Class = require("laravel.utils.class")

local laravel_picker = Class({
  commands = "laravel.commands",
})

function laravel_picker:run(picker, opts)
  local items = self.commands

  table.sort(items, function(a, b)
    return a.signature < b.signature
  end)

  vim.schedule(function()
    picker.run(opts, items)
  end)
end

return laravel_picker
