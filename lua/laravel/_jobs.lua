local M = {}

local cleanup_autocmd
local all_channels = {}

local keys = vim.api.nvim_replace_termcodes("<c-c>", true, false, true)
local function terminate(job_id)
  vim.api.nvim_chan_send(job_id, keys)
  vim.fn.jobstop(job_id)
end

---@param job_id number
---@param bufnr number
M.register = function(job_id, bufnr)
  if not cleanup_autocmd then
    cleanup_autocmd = vim.api.nvim_create_autocmd("VimLeavePre", {
      desc = "Clean up running overseer tasks on exit",
      callback = function()
        local job_ids = vim.tbl_keys(all_channels)
        for _, j in ipairs(job_ids) do
          terminate(j)
        end
      end,
    })
  end
  all_channels[job_id] = true

  vim.api.nvim_create_autocmd({ "BufUnload" }, {
    buffer = bufnr,
    callback = function()
      M.terminate(job_id)
    end,
  })
end

M.unregister = function(job_id)
  all_channels[job_id] = nil
end

M.terminate = function(job_id)
  if all_channels[job_id] ~= nil then
    terminate(job_id)
    all_channels[job_id] = nil
  end
end

return M
