local nio = require("nio")
local mcphub = require("mcphub")
local app = require("laravel.core.app")

mcphub.add_tool("laravel", {
  name = "composer",
  description = "run compsoer commands for php project",
  inputSchema = {
    type = "object",
    properties = {
      command = {
        type = "string",
        description = "composer command to run",
      },
      arguments = {
        type = "array",
        items = {
          type = "string",
        },
        description = "arguments for the command use the help to check what is requried",
      },
    },
    required = { "command", "arguments" },
  },
  handler = function(req, res)
    nio.run(function()
      local command = req.params.command
      local arguments = req.params.arguments or {}

      if not app:isActive() then
        res:error("Laravel plugin is not active"):send()

        return
      end

      local result, err = app("api"):run("composer", { command, unpack(arguments) })
      if err then
        res:error(err):send()
        return
      end

      if result:failed() then
        res:error(result:prettyErrors()):send()
        return
      end

      res:text(result:content()):send()
    end)
  end,
})
