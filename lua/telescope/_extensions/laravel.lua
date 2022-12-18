local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

local artisan = require("laravel.artisan")
local laravel_utils = require("laravel.utils")

local function run_command(command, ask_options, runner_type)
    local arguments = {}
    for _, argument in pairs(command.definition.arguments) do
        local arg = vim.fn.input(argument.name .. ": ")
        if arg == "" then
            return
        end
        table.insert(arguments, arg)
    end

    local options = ""
    if ask_options then
        options = vim.fn.input("Options: ")
    end

    local cmd = command.name

    if #arguments > 0 then
        cmd = cmd .. ' ' .. vim.fn.join(arguments, ' ')
    end

    if options ~= "" then
        cmd = cmd .. ' ' .. options
    end

    artisan.run(cmd, runner_type)
end

local commands = function(opts)
	opts = opts or {}

	pickers
		.new(opts, {
			prompt_title = "Artisan commands",
			finder = finders.new_table({
				results = artisan.commands(false),
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
					local cmd = laravel_utils.get_artisan_cmd({ entry.value.name, "-h" })
					putils.job_maker(cmd, self.state.bufnr, {
						value = entry.value,
						bufname = self.state.bufname,
					})
				end,
			}),
			sorter = conf.file_sorter(),
			attach_mappings = function(_, map)
				map("i", "<cr>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type Command command
					local command = entry.value

                    run_command(command)
				end)
				map("i", "<C-y>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type Command command
					local command = entry.value

                    run_command(command, true)
				end)
				map("i", "<c-t>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type Command command
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

	pickers
		.new(opts, {
			prompt_title = "Artisan Routes",
			finder = finders.new_table({
				results = artisan.routes(false),
				entry_maker = function(route)
					return {
						value = route,
                        display = string.format("%s %s", route.uri, vim.F.if_nil(route.name, "")),
						--display = function (entry)
                            ---- TODO check how to use better columns with telescope to diplsya like that
                            ---- Uri <name>       METHOD
                            ----
						--end,
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
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(vim.inspect(entry.value), "\n"))
				end,
			}),
			sorter = conf.file_sorter(),
			attach_mappings = function(_, map)
				map("i", "<cr>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type Command command
					local command = entry.value

                    run_command(command)
				end)
				map("i", "<C-y>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type Command command
					local command = entry.value

                    run_command(command, true)
				end)
				map("i", "<c-t>", function(prompt_bufnr)
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					---@type Command command
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
