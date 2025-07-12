local laravel_picker = {}

function laravel_picker.run(opts, commands)
  local max_text_length = 0
  for _, command in ipairs(commands) do
    max_text_length = math.max(max_text_length, #command.signature)
  end

  local items = vim
    .iter(commands)
    :map(function(command)
      return {
        value = command,
        text = command.signature,
      }
    end)
    :totable()

  Snacks.picker.pick(vim.tbl_extend("force", {
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
  }, opts or {}))
end

return laravel_picker
