local command = {}

function command:new(dump_server, dump_server_ui)
  local instance = {
    service = dump_server,
    ui = dump_server_ui,
    command = "dump",
    subCommands = {
      "start",
      "stop",
      "open",
      "close",
      "toggle",
      "install",
    },
    default = "start",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function command:start()
  self.service:start()
end

function command:stop()
  self.service:stop()
end

function command:open()
  self.ui:open()
end

function command:close()
  self.ui:close()
end

function command:toggle()
  self.ui:toggle()
end
function command:install()
  self.service:install()
end

return command
