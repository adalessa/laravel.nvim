local M = {}

local modules = {
  "sail",
  "artisan",
  "composer",
  "laravel",
  "npm",
  "yarn",
}

M.setup = function()
  for _, module in pairs(modules) do
    require(string.format("laravel.user-commands.%s", module)).setup()
  end
end

return M
