local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error "This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local actions = require('telescope.actions')
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local putils = require "telescope.previewers.utils"

local artisan = require("laravel.artisan")
local laravel_utils = require("laravel.utils")

local laravel = function (opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "Artisan commands",
            finder = finders.new_table({
                results = artisan.commands(false),
                entry_maker = function(cmd)
                    return {
                        value = cmd.command,
                        display = cmd.command,
                        ordinal = cmd.command,
                    }
                end,
            }),
            previewer = previewers.new_buffer_previewer({
                title = "Help",
                get_buffer_by_name = function(_, entry)
                    return entry.value
                end,

                define_preview = function(self, entry)
                    local cmd = laravel_utils.get_artisan_cmd({entry.value, '-h'})
                    putils.job_maker(cmd, self.state.bufnr, {
                        value = entry.value,
                        bufname = self.state.bufname,
                    })
                end,
            }),
            sorter = conf.file_sorter(),
            attach_mappings = function(_, map)
                map("i", "<cr>", function(prompt_bufnr)
                    local entry = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if laravel_utils.is_make_command(entry.value) then
                        local name = vim.fn.input("Name: ")
                        local args = nil
                        if Laravel.config.ask_for_args then
                            local args_input = vim.fn.input("Args: ")
                            if args_input ~= "" then
                                args = vim.split(args_input, " ")
                            end
                        end
                        artisan.make(vim.split(entry.value, ":")[2], name, args)
                    elseif entry.value == "tinker" then
                        artisan.tinker()
                    else
                        local cmd = entry.value
                        if Laravel.config.ask_for_args then
                            local args = vim.fn.input("Args: ")
                            if args ~= "" then
                                cmd = cmd .. " " .. args
                            end
                        end

                        artisan.run(cmd)
                    end
                end)
                return true
            end,
        })
        :find()
end


return telescope.register_extension {
  exports = {
    laravel = laravel,
  },
}
