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

function M.combine_tables(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for _, value in ipairs(tbl) do
      table.insert(result, value)
    end
  end

  return result
end

---@param command string|nil
---@return boolean
function M.is_make_command(command)
  if not command then
    return false
  end
  local prefix = "make"

  return command:sub(1, #prefix) == prefix or command == "livewire:make" or command == "pest:test"
end

---@param text string
---@return string|nil
function M.find_class_from_make_output(text)
  local make_rules = { "%[(.-)%]", "CLASS:%s+(.-)\n" }
  text = text:gsub("\r", "")
  for _, rule in ipairs(make_rules) do
    local matche
    matche = text:gmatch(rule)()
    if matche then
      return matche
    end
  end

  return nil
end

function M.split(str, sep)
  local result = {}
  local regex = ("([^%s]+)"):format(sep)
  for each in str:gmatch(regex) do
    table.insert(result, each)
  end
  return result
end

function M.get_line_indent(line)
  local line_content = vim.fn.getline(line)

  return string.match(line_content, "^%s*")
end

function M.match_complete(list, search)
  return vim.tbl_filter(function(name)
    return vim.startswith(name, search)
  end, list)
end

return M
