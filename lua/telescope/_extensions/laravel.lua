local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local artisan = require("laravel.artisan")
local preview = require("laravel.telescope.preview")
local utils = require("laravel.utils")

--- runs a command from telescope
---@param command LaravelCommand
---@param ask_options boolean | nil
---@param runner string | nil
local function run_command(command, ask_options, runner)
	local arguments = {}
	for _, argument in pairs(command.definition.arguments) do
		if argument.is_required then
			local arg = vim.fn.input(argument.name .. ": ")
			if arg == "" then
				return
			end
			table.insert(arguments, arg)
		end
	end

	local options = ""
	if ask_options then
		options = vim.fn.input("Options: ")
	end

	local cmd = { command.name }

	for _, value in pairs(arguments) do
		table.insert(cmd, value)
	end

	if options ~= "" then
		for _, value in pairs(vim.fn.split(options, " ")) do
			table.insert(cmd, value)
		end
	end

	local resources = require("laravel.resources")
	if resources.is_resource(cmd[1]) then
		return resources.create(cmd)
	end
	artisan.run(cmd, runner)
end

local commands = function(opts)
	opts = opts or {}

	local commands = require("laravel").app.commands()

	if commands == nil then
		utils.notify("Telescope", {
			msg = "Can't get commands check if sail is running",
			level = "WARN",
		})

		return
	end

	pickers
		.new(opts, {
			prompt_title = "Artisan commands",
			finder = finders.new_table({
				results = commands,
				entry_maker = function(command)
					return {
						value = command,
						display = command.name,
						ordinal = command.name,
					}
				end,
			}),
			previewer = previewers.new_buffer_previewer({
				title = "Help",
				get_buffer_by_name = function(_, entry)
					return entry.value
				end,

				define_preview = function(self, entry)
					local command_preview = preview.command(entry.value)

					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, command_preview.lines)

					local hl = vim.api.nvim_create_namespace("laravel")
					for _, value in pairs(command_preview.highlights) do
						vim.api.nvim_buf_add_highlight(self.state.bufnr, hl, value[1], value[2], value[3], value[4])
					end
				end,
			}),
			sorter = conf.file_sorter(),
			attach_mappings = function(_, map)
				map("i", "<cr>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type LaravelCommand command
					local command = entry.value

					run_command(command)
				end)
				map("i", "<C-y>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type LaravelCommand command
					local command = entry.value

					run_command(command, true)
				end)
				map("i", "<c-t>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type LaravelCommand command
					local command = entry.value

					run_command(command, false, "terminal")
				end)
				return true
			end,
		})
		:find()
end

local routes = function(opts)
	opts = opts or {}

	local routes = require("laravel").app.routes()
	if routes == nil then
		utils.notify("Telescope", {
			msg = "Can't get routes check if sail is running",
			level = "WARN",
		})

		return
	end

	pickers
		.new(opts, {
			prompt_title = "Artisan Routes",
			finder = finders.new_table({
				results = routes,
				entry_maker = function(route)
					return {
						value = route,
						display = function(entry)
              ---@type LaravelRoute r
              local r = entry.value
              local display_name = ""
              if r.name ~= nil then
                display_name = string.format("<%s>", r.name)
              end

              return string.format("[%s] %s %s", vim.fn.join(r.methods, '|') , r.uri, display_name)
						end,
						ordinal = route.uri,
					}
				end,
			}),
			previewer = previewers.new_buffer_previewer({
				title = "Help",
				get_buffer_by_name = function(_, entry)
					return entry.value
				end,

				define_preview = function(self, entry)
					local route_preview = preview.route(entry.value)

					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, route_preview.lines)

					local hl = vim.api.nvim_create_namespace("laravel")
					for _, value in pairs(route_preview.highlights) do
						vim.api.nvim_buf_add_highlight(self.state.bufnr, hl, value[1], value[2], value[3], value[4])
					end
				end,
			}),
			sorter = conf.file_sorter(),
			attach_mappings = function(_, map)
				map("i", "<cr>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type LaravelCommand command
					local command = entry.value

					run_command(command)
				end)
				map("i", "<C-y>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type LaravelCommand command
					local command = entry.value

					run_command(command, true)
				end)
				map("i", "<c-t>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type LaravelCommand command
					local command = entry.value

					run_command(command, false, "terminal")
				end)
				return true
			end,
		})
		:find()
end

return telescope.register_extension({
	exports = {
		commands = commands,
		routes = routes,
	},
})
