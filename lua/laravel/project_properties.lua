local M = {}

M.get = function()
    ---@class laravel.project_properties
    ---@field uses_sail boolean
    ---@field has_phpstan boolean
    ---@field has_artisan boolean
    local project_properties = {}

    local has_sail_cmd = vim.fn.filereadable("vendor/bin/sail") == 1
    local has_docker_compose_config = vim.fn.filereadable("docker-compose.yml") == 1

    project_properties.has_artisan = vim.fn.filereadable("artisan") == 1
    project_properties.has_phpstan = vim.fn.filereadable("vendor/bin/phpstan") == 1
    project_properties.uses_sail = has_sail_cmd and has_docker_compose_config

    return project_properties
end

return M
