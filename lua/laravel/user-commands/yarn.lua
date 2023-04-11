local commands = {
  dev = function()
    require("laravel.yarn").run({ "run", "dev" }, "persist")
  end,
  build = function()
    require("laravel.yarn").run { "run", "build" }
  end,
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Yarn", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return require("laravel.yarn").run(args.fargs)
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
