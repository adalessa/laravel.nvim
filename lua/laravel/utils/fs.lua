local nio = require("nio")

local M = {}

function M.scanDir(directory, depth)
  depth = depth or 4
  local _, dir = nio.uv.fs_scandir(directory)
  if not dir then
    return {}
  end

  local files = {}

  while true do
    local name, type = vim.uv.fs_scandir_next(dir)
    if not name then
      break
    end

    local full_path = directory .. "/" .. name
    if type == "directory" and depth > 1 then
      local sub_files = M.scanDir(full_path, depth - 1)
      for _, file in ipairs(sub_files) do
        table.insert(files, file)
      end
    elseif type == "file" then
      table.insert(files, full_path)
    end
  end

  return files
end

return M
