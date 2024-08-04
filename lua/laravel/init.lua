local M = {}

M.app = {}

function M.setup(opts)
  M.app = require("laravel.app"):new(opts):start()
end

return M

-- history = require("telescope").extensions.laravel.history,
-- make = require("telescope").extensions.laravel.make,
-- commands = require("telescope").extensions.laravel.commands,
-- resources = require("telescope").extensions.laravel.resources,
-- recies = require("laravel.recipes").run,
-- viewFinder = require("laravel.view_finder").auto,
