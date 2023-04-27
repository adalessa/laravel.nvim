local utils = require "laravel.utils"

local commands = {
  ["cache:clean"] = function()
    require("laravel.cache_manager").purge()
    utils.notify("laravel.cache:clean", { msg = "Cache cleaned", level = "INFO" })
  end,
  ["routes"] = function()
    return require("telescope").extensions.laravel.routes()
  end,
  ["artisan"] = function()
    return require("telescope").extensions.laravel.commands()
  end,
  ["test"] = function()
    return require("laravel.artisan").run { "test" }
  end,
  ["test:watch"] = function()
    return require("laravel.artisan").run({ "test" }, "watch")
  end,
  ["test_file:watch"] = function()
    local currentFile = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd() .. "/", "")
    return require("laravel.artisan").run({ "test", currentFile }, "watch")
  end,
  ["test_method:watch"] = function()
    local currentFile = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd() .. "/", "")
    local node = vim.treesitter.get_node()
    local testMethod = function(node)
      if node:type() == "method_declaration" then
        return true
      end
      return false
    end

    if not testMethod(node) then
      while node do
        if not testMethod(node) then
          node = node:parent()
        else
          break
        end
      end
    end

    if node then
      local method_name = vim.inspect(vim.treesitter.get_node_text(node:field("name")[1], 0))
      if string.sub(method_name, 2, 5) == "test" then
        return require("laravel.artisan").run({ "test", currentFile, "--filter", method_name }, "watch")
      end
    end

    utils.notify("artisan.run", { msg = "cursor is not on the testable method", level = "ERROR" })
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

      utils.notify("laravel", { msg = "Unkown command", level = "ERROR" })
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
