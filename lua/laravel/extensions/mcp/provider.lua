local nio = require("nio")
local mcp = {}

function mcp:boot(app)
  local status, mcphub = pcall(require, "mcphub")
  if not status then
    return
  end

  mcphub.add_tool("laravel", {
    name = "artisan",
    description = "run php artisan commands for a laravel application",
    inputSchema = {
      type = "object",
      properties = {
        command = {
          type = "string",
          description = "artisan command to run",
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
          res:error("Laravel is not active"):send()

          return
        end

        local result, err = app("api"):run("artisan", { command, unpack(arguments) })
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
end

return mcp
