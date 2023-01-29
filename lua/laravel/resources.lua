local log = require("laravel.dev").log
local utils = require("laravel.utils")

local M = {}

---Opens the resource
---@param resource string
---@param name string
M.open = function(resource, name)

    local directory = require("laravel.app").options.resources[resource]
    if directory == "" then
        return
    end
    -- TODO: handle migration since that includes a generated name
    -- need to find a way to search just by a part of the name
    local filename = string.format("%s/%s.php", directory, name)
    if vim.fn.findfile(filename) then
        local uri = vim.uri_from_fname(string.format("%s/%s", vim.fn.getcwd(), filename))
        local buffer = vim.uri_to_bufnr(uri)
        vim.api.nvim_win_set_buf(0, buffer)

        return
    end

    utils.notify("open_resource", {
        msg = string.format("Can't find resource %s", filename)
    })
end

--- Identifies if the given command is a resource
---@param name string
---@return boolean
M.is_resource = function(name)
    return require("laravel.app").options.resources[string.gsub(name, "make:", "")] ~= nil
end

--- Creates the resource and opens the file
---@param cmd table
M.create = function(cmd)
    if not M.is_resource(cmd[1]) then
        log.error("resource.create(): Invalid command", cmd)
        return
    end

    require("laravel.artisan").run(cmd, "async", function()
        M.open(string.gsub(cmd[1], "make:", ""), cmd[2])
    end)
end



return M
