local telescope = require("telescope")

return {
	setup = function()
		vim.api.nvim_create_user_command("Routes", function()
      return telescope.extensions.laravel.routes()
    end, {})
	end,
}
