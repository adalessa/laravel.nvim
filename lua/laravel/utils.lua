local M = {}

function M.runRipgrep(pattern)
  -- Build the ripgrep command
  local rg_command = string.format('rg --vimgrep "%s"', pattern)

  -- Run the command and capture the output
  local result = vim.fn.systemlist(rg_command)

  -- Process the result
  local matches = {}
  for _, line in ipairs(result) do
    local parts = vim.fn.split(line, ":", true)
    local file = parts[1]
    local line_number = parts[2]
    local text = parts[3]

    table.insert(matches, { file = file, line_number = line_number, text = text })
  end

  return matches
end

---@param var string
---@return string|nil
function M.get_env(var)
  local envVal
  if vim.api.nvim_call_function("exists", { "*DotenvGet" }) == 1 then
    envVal = vim.api.nvim_call_function("DotenvGet", { var })
  else
    envVal = vim.api.nvim_call_function("eval", { "$" .. var })
  end

  if envVal == "" then
    return nil
  end

  return envVal
end

return M
