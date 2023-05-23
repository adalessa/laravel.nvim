local M = {}

local modules = {
  "artisan",
  "composer",
  "docker_compose",
  "laravel",
  "laravel_info",
  "npm",
  "sail",
  "yarn",
}

M.setup = function()
  for _, module in pairs(modules) do
    require(string.format("laravel.user-commands.%s", module)).setup()
  end
end

return M
