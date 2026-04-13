local BaseCommand = require("laravel.base_command")

local PtyCommand = setmetatable({}, { __index = BaseCommand })
PtyCommand.__index = PtyCommand

function PtyCommand:addCallback(callback)
  self.on_output = callback

  return self
end

function PtyCommand:execute()
  self.bufnr = vim.api.nvim_create_buf(false, true)
  self.channel_id = vim.api.nvim_open_term(self.bufnr, {})

  self.job_id = vim.fn.jobstart(self.cmd, {
    pty = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.fn.chansend(self.channel_id, line .. "\n")
          if self.on_output then
            self.on_output(line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      self.exit_code = exit_code
      self.exited = true
    end,
  })
end

return PtyCommand
