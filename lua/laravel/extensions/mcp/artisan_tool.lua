local nio = require("nio")
local mcphub = require("mcphub")
local app = require("laravel.core.app")

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
        vim.schedule(function()
          res:error("Laravel is not active"):send()
        end)
        return
      end

      local result, err = app("api"):run("artisan", { command, unpack(arguments) })
      if err then
        vim.schedule(function()
          res:error(err):send()
        end)
        return
      end

      if result:failed() then
        vim.schedule(function()
          res:error(result:prettyErrors()):send()
        end)
        return
      end

      vim.schedule(function()
        res:text(result:content()):send()
      end)
    end)
  end,
})
