local Class = require("laravel.utils.class")

local laravel_picker = Class({
  commands = "laravel.commands",
})

function laravel_picker:run()
  local max_text_length = 0
  for _, command in ipairs(self.commands) do
    max_text_length = math.max(max_text_length, #command.signature)
  end

  local items = vim
    .iter(self.commands)
    :map(function(command)
      return {
        value = command,
        text = command.signature,
      }
    end)
    :totable()
  table.sort(items, function(a, b)
    return a.text < b.text
  end)

  Snacks.picker.pick({
    title = "Laravel Commands",
    layout = "vscode",
    items = items,
    format = function(item)
      local padding = string.rep(" ", max_text_length - #item.text + 4) -- 4 spaces for alignment
      return {
        { item.text .. padding, "@string" },
        { item.value.description, "@comment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        item.value:handle()
      end
    end,
  })
end

return laravel_picker
