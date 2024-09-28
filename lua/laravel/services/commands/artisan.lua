---@type LaravelApp
local app = require("laravel").app

---@class ArtisanCommand
---@field runner LaravelRunner
---@field api LaravelApi
---@field cache LaravelCache
local artisan = {}

function artisan:new(runner, api, cache)
  local instance = {
    runner = runner,
    api = api,
    cache = cache,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function artisan:commands()
  return { "artisan", "art" }
end

function artisan:handle(args)
  table.remove(args.fargs, 1)
  if vim.tbl_isempty(args.fargs) then
    if app:has("artisan_picker") then
      app("artisan_picker"):run()
      return
    end
  end

  self.runner:run("artisan", args.fargs)
end

function artisan:complete(argLead)
  local commands = self.cache:remember("laravel-commands", 60, function()
    local resp = self.api:sync("artisan", { "list", "--format=json" })
    if resp:failed() then
      return {}
    end

    return vim.tbl_filter(function(cmd)
      return not cmd.hidden
    end,resp:json().commands)
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

return artisan