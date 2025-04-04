local command = {}

function command:new(dump_server, dump_server_ui)
  local instance = {
    service = dump_server,
    ui = dump_server_ui,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function command:commands()
  return { "dump" }
end

function command:handle(args)
  table.remove(args.fargs, 1)

  if args.fargs[1] == "start" or args.fargs[1] == "" or args.fargs[1] == nil then
    self.service:start()
  elseif args.fargs[1] == "stop" then
    self.service:stop()
  elseif args.fargs[1] == "open" then
    self.ui:open()
  elseif args.fargs[1] == "close" then
    self.ui:close()
  elseif args.fargs[1] == "toggle" then
    self.ui:toggle()
  elseif args.fargs[1] == "install" then
    self.service:install()
  end
end

function command:complete(argLead)
  return vim
    .iter({
      "start",
      "stop",
      "open",
      "close",
      "toggle",
      "install",
    })
    :filter(function(name)
      return vim.startswith(name, argLead)
    end)
    :totable()
end

return command
