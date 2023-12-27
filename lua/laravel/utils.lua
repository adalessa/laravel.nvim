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

return M
