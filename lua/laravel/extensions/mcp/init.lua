local mcp = {}

function mcp:boot(app)
  local mcphub = require("mcphub")

  mcphub.add_tool("laravel", {
    name = "artisan",
    description = "run artisan commands",
    inputSchema = {
      type = "object",
      properties = {
        command = {
          type = "string",
          desdcription = "artisan command to run",
        },
        arguments = {
          type = "array",
          items = {
            type = "string",
          },
          desdcription = "arguments for the command use the help to check what is requried",
        },
      },
      required = { "command", "arguments" },
    },
    handler = function(req, res)
      local command = req.params.command
      local arguments = req.params.arguments or {}

      if not app:isActive() then
        res:error("Laravel is not active"):send()

        return
      end

      app("api"):send("artisan", { command, unpack(arguments) }):thenCall(function(result)
        if result:failed() then
          res:error(result:prettyErrors()):send()
          return
        end

        res:text(result:content()):send()
      end, function(err)
        res:error(err):send()
      end)
    end,
  })
end

return mcp
