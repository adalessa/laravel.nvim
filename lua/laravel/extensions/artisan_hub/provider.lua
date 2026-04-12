---@type laravel.extensions.provider
local provider = {}

function provider.register(app, opts)
  app:addCommand("laravel.extensions.artisan_hub.hub_command")
  app:singleton("laravel.extensions.artisan_hub.commands", opts.commands or {
    {
      name = "Serve",
      cmd = "artisan serve",
    },
    {
      name = "Assets",
      cmd = "npm run dev",
    },
    {
      name = "Pail",
      cmd = "artisan pail --timeout=0",
    },
    {
      name = "Logs",
      cmd = "tail -f -n 0 storage/logs/laravel.log",
      callback = function(line)
        if not line or line == "" then
          return nil
        end

        -- match: [date] env.LEVEL: message
        local level, message = line:match("%] %w+%.([A-Z]+):%s(.+)")

        if not level or not message then
          return nil
        end

        -- strip JSON/context if present
        message = message:gsub("%s*%b{}", "")

        -- trim message
        if #message > 50 then
          message = message:sub(1, 47) .. "..."
        end

        -- map the level
        if level == "ERROR" then
          level = vim.log.levels.ERROR
        elseif level == "WARNING" then
          level = vim.log.levels.WARN
        elseif level == "INFO" then
          level = vim.log.levels.INFO
        else
          level = vim.log.levels.DEBUG
        end

        vim.notify(vim.trim(message), level, { title = "Laravel Log" })
      end,
    },
  })
end

function provider.boot(app) end

return provider
