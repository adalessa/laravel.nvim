---@class ComposerDevProvider : LaravelProvider
local composer_dev = {}

function composer_dev:register(app)
  app:singeltonIf("dev_command", "laravel.extensions.composer_dev.command", { tags = { "command" } })
end

function composer_dev:boot(app)
end

return composer_dev
