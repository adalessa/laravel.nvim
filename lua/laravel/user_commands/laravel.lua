local commands = {
  ["cache:clean"] = function()
    require("laravel.commands").list = {}
    require("laravel.routes").list = {}
    vim.notify("Laravel plugin cache cleaned", vim.log.levels.INFO)
  end,
  ["routes"] = require("telescope").extensions.laravel.routes,
  ["artisan"] = require("telescope").extensions.laravel.commands,
  ["test:watch"] = function()
    require "laravel.watch"("artisan", { "test" })
  end,
  ["related"] = require("telescope").extensions.laravel.related,
  ["history"] = require("telescope").extensions.laravel.history,
  ["recipes"] = require("laravel.recipes").run,
  ["view-finder"] = require("laravel.view_finder").auto,
  ["health"] = function()
    vim.cmd [[checkhealth laravel]]
  end,
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Laravel", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      vim.ui.select(vim.fn.sort(vim.tbl_keys(commands)), { prompt = "Laravel Plugin:" }, function(action)
        if not action then
          return
        end
        if commands[action] ~= nil then
          commands[action]()
        end
      end)
    end, {
      nargs = "*",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
