local list = {}

local M = {}

function M.add(jobId, name, args, opts)
  table.insert(list, {
    jobId = jobId,
    name = name,
    args = args,
    opts = opts,
  })
end

function M.all()
  return list
end

return M
