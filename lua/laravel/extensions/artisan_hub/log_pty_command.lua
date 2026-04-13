local PtyCommand = require("laravel.pty_command")

local LogPtyCommand = setmetatable({}, { __index = PtyCommand })
LogPtyCommand.__index = LogPtyCommand

function LogPtyCommand:onStdout(data)
  for _, line in ipairs(data) do
    if line ~= "" then
      vim.fn.chansend(self.channel_id, line .. "\n")
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
    end
  end
end

return LogPtyCommand
