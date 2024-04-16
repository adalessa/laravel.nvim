local repository = require "laravel.repositories.history_repository"

---@class HistoryService
local HistoryService = {}

function HistoryService:add(jobId, name, args, opts)
  repository:save {
    path = vim.fn.getcwd(),
    jobId = jobId,
    name = name,
    args = args,
    opts = opts,
  }
end

function HistoryService:all()
  return repository:findAll()
end

return HistoryService
