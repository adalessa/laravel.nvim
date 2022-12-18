local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local artisan = require("laravel.artisan")

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

    artisan.run(cmd, runner)
end

local commands = function(opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "Artisan commands",
            finder = finders.new_table({
                results = require("laravel.app").commands(),
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
                    ---@type LaravelCommand command
                    local command = entry.value
                    --TODO: extend to use more internal variables from the command
                    --to generate the buffer so we don't need to run the help
                    --we already have the information
                    --define template to use it
                    --use to add hightlight group
                    -- nvim_buf_add_highlight({buffer}, {ns_id}, {hl_group}, {line}, {col_start},
                    --                        {col_end})
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
                        command.description,
                    })
                    local hl = vim.api.nvim_create_namespace("laravel")
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, hl, "ErrorMsg", 0, 0, string.len(command.description))
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

    pickers
        .new(opts, {
            prompt_title = "Artisan Routes",
            finder = finders.new_table({
                results = require("laravel.app").routes(),
                entry_maker = function(route)
                    return {
                        value = route,
                        display = string.format("%s %s", route.uri, vim.F.if_nil(route.name, "")),
                        --display = function (entry)
                        ---- TODO: check how to use better columns with telescope to diplsya like that
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
