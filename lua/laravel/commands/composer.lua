local composer = {}

function composer:new(runner, pickers, api, cache)
  local instance = {
    runner = runner,
    pickers = pickers,
    api = api,
    cache = cache,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function composer:commands()
  return { "composer" }
end

function composer:handle(args)
  table.remove(args.fargs, 1)
  if vim.tbl_isempty(args.fargs) then
    if self.pickers:exists("composer") then
      self.pickers:run("composer")
      return
    end

    vim.ui.select(self.sub_commands, { prompt = "Composer commands" }, function(selected)
      if selected == nil then
        return
      end

      self.runner:run("composer", { selected })
    end)
    return
  end
  self.runner:run("composer", args.fargs)
end

function composer:complete(argLead)
  local commands = self.cache:remember("composer-commands", 60, function()
    local resp = {}
    self.api
      :async("composer", { "list", "--format=json" }, function(result)
        resp = result
      end)
      :wait()

    if resp:failed() then
      return {}
    end

    return vim.tbl_filter(function(cmd)
      return not cmd.hidden
    end, resp:json().commands)
  end)

  return vim
    .iter(commands)
    :map(function(cmd)
      return cmd.name
    end)
    :filter(function(name)
      return vim.startswith(name, argLead)
    end)
    :totable()
end

return composer
