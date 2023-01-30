local utils = require("laravel.utils")
local commands = {
    dev = function()
        require("laravel.sail").run({"npm", "run", "dev"})
    end,
    install = function()
        require("laravel.sail").run({"npm", "install"})
    end
}
return {
    setup = function()
        vim.api.nvim_create_user_command("Npm", function(args)
            local command = args.fargs[1]
            if (commands[command] ~= nil) then
                table.remove(args.fargs, 1)
                return commands[command](unpack(args.fargs))
            end

            utils.notify("Npm", { msg = "Unkown command", level = "ERROR" })
        end, {
            nargs = "+",
            complete = function()
                return vim.tbl_keys(commands)
            end,
        })
    end
}
