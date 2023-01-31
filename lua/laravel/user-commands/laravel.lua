local utils = require("laravel.utils")
local commands = {
	["cache:clean"] = function()
		require("laravel.cache_manager").purge()
		utils.notify("Laravel cache:clean", { msg = "Cache cleaned", level = "INFO" })
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

			utils.notify("Laravel", { msg = "Unkown command", level = "ERROR" })
		end, {
			nargs = "+",
			complete = function()
				return vim.tbl_keys(commands)
			end,
		})
	end,
}
