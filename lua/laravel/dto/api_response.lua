--- ApiResponse class represents the result of a command execution.
---@class laravel.dto.apiResponse
---@field stdout string[] The standard output of the command execution.
---@field exit_code number The exit code indicating how the command ended (0 for success, non-zero for failure).
---@field stderror string[] The standard error output in case of errors during command execution.
local ApiResponse = {}

---@param stdout string[]
---@param exit_code number|nil
---@param stderror string[]
---@return laravel.dto.apiResponse
function ApiResponse:new(stdout, exit_code, stderror)
  local obj = {
    stdout = stdout,
    exit_code = exit_code,
    stderror = stderror,
  }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

---@return boolean
function ApiResponse:successful()
  if self.exit_code == nil then
    return vim.tbl_isempty(self.stderror)
  end
  return self.exit_code == 0
end

---@return boolean
function ApiResponse:failed()
  return not self:successful()
end

--- Returns the content
---@return string[]
function ApiResponse:raw()
  return self.stdout
end

---@return string
function ApiResponse:content()
  return table.concat(self:raw(), "\n")
end

function ApiResponse:json()
  local ok, res = pcall(vim.json.decode, self:content(), { luanil = { object = true } })
  if not ok then
    return nil
  end

  return res
end

---@return string|nil
function ApiResponse:first()
  if self:failed() then
    return nil
  end

  return vim.trim(self.stdout[1])
end

---@return string[]|nil
function ApiResponse:errors()
  if self:successful() then
    return nil
  end

  if not vim.tbl_isempty(vim.tbl_filter(function(line)
        return line ~= ""
      end, self.stderror)) then
    return self.stderror
  end

  return self:raw()
end

function ApiResponse:prettyErrors()
  local errors = self:errors()
  if not errors then
    return ""
  end

  return table.concat(errors, "\n")
end

return ApiResponse
