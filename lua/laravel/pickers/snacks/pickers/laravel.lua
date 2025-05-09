local laravel_picker = {
  _inject = {
    commands = "user_commands",
  },
}

function laravel_picker:new(commands)
  local instance = {
    commands = commands,
  }
  setmetatable(instance, laravel_picker)
  laravel_picker.__index = laravel_picker
  return instance
end

function laravel_picker:items()
  return vim
    .iter(self.commands)
    :map(function(command)
      if type(command.command) == "string" then
        return { command.command }
      elseif type(command.commands) == "table" then
        return command.commands
      end
      return command:commands()
    end)
    :flatten()
    :map(function(command)
      return {
        value = command,
        text = command,
      }
    end)
    :totable()
end

function laravel_picker:run()
  Snacks.picker.pick({
    title = "Laravel Commands",
    layout = "vscode",
    items = self:items(),
    format = function(item)
      return {
        { item.text, "@string" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.api.nvim_command("Laravel " .. item.value)
      end
    end,
  })
end

return laravel_picker
