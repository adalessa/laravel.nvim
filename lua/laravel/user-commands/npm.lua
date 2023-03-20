local commands = {
  dev = function()
    require("laravel.npm").run({ "run", "dev" }, "buffer", { listed = true, buf_name = "Npm Dev" })
  end,
  build = function()
    require("laravel.npm").run { "run", "build" }
  end,
}
return {
  setup = function()
    vim.api.nvim_create_user_command("Npm", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return require("laravel.npm").run(args.fargs)
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
