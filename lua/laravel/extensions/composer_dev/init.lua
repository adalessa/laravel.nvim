---@class ComposerDevProvider : laravel.providers.provider
local composer_dev = {}

function composer_dev:register(app)
  app:singletonIf("dev_command", "laravel.extensions.composer_dev.command", { tags = { "command" } })
end

function composer_dev:boot(app)
end

return composer_dev
