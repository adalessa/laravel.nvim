local M = {}

local cleanup_autocmd
local all_channels = {}

M.register = function(job_id)
  if not cleanup_autocmd then
    cleanup_autocmd = vim.api.nvim_create_autocmd("VimLeavePre", {
      desc = "Clean up running overseer tasks on exit",
      callback = function()
        local keys = vim.api.nvim_replace_termcodes("<c-c>", true, false, true)
        local job_ids = vim.tbl_keys(all_channels)
        for _, chan_id in ipairs(job_ids) do
          -- sail npm run dev does not close properly I have to do this
          vim.api.nvim_chan_send(chan_id, keys)
          vim.fn.jobstop(chan_id)
        end
      end,
    })
  end
  all_channels[job_id] = true
end

M.unregister = function(job_id)
  all_channels[job_id] = nil
end

return M
