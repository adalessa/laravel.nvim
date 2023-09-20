local M = {}

local modules = {
  "artisan",
  "bun",
  "composer",
  "docker_compose",
  "laravel",
  "npm",
  "sail",
  "yarn",
}

M.setup = function()
  for _, module in pairs(modules) do
    require(string.format("laravel.user_commands.%s", module)).setup()
  end
end

return M
