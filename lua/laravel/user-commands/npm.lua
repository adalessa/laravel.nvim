local utils = require("laravel.utils")


local commands = {
	dev = function()
    -- FIX: need to check if should use sail or not
		-- TODO: want to store the buffer, and if it is ask again display the windows
		-- use nvim_open_win with the buffer
		-- and map q to quit
		local result = require("laravel.sail").run({ "npm", "run", "dev" }, "buffer", { open = false })

		print(vim.inspect(result))
    print(vim.inspect(vim.fn.jobwait({result.job}, 1000)))
    print(vim.inspect(vim.api.nvim_get_chan_info(result.job)))
		-- TODO: have another command to stop it.
		-- prevent to start it again
	end,
	install = function()
		require("laravel.sail").run({ "npm", "install" })
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

			utils.notify("npm", { msg = "Unkown command", level = "ERROR" })
		end, {
			nargs = "+",
			complete = function()
				return vim.tbl_keys(commands)
			end,
		})
	end,
}
