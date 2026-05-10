---@class laravel.core.options_manager
local manager = {}

local _options = {}
local _plugin_options = {}
local _project_options = {}
local _cwd = ""
local _file_path = ""
local _default = {}
local _data = {}

local function load()
  if vim.fn.isdirectory(vim.fs.dirname(_file_path)) == 0 then
    return {}
  end
  local file = io.open(_file_path, "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()
  if content == "" then
    return {}
  end

  local json = vim.json.decode(content)
  if not json then
    return {}
  end

  if type(json) ~= "table" then
    return {}
  end

  for _, project in pairs(json) do
    _data[project.path] = project
  end

  return _data[_cwd] or {}
end

manager.init = function(plugin_options, default, cwd, file_path)
  _plugin_options = plugin_options
  _cwd = cwd
  _file_path = file_path
  _project_options = load()
  _default = default

  _options = vim.tbl_deep_extend("force", _default, _plugin_options, _project_options)
end

---@param key string
---@param default any
---@return any
manager.get = function(key, default)
  if not key then
    return _options
  end

  local value = _options
  for _, seg in ipairs(vim.split(key, "%.")) do
    if type(value) ~= "table" then
      return default
    end
    value = value[seg]
  end

  return value or default
end

manager.set = function(key, value) if type(key) == "table" then
    for k, v in pairs(key) do
      _project_options[k] = v
    end
  else
    local segments = vim.split(key, "%.")
    local current = _plugin_options

    for i = 1, #segments - 1 do
      if not current[segments[i]] then
        current[segments[i]] = {}
      end
      current = current[segments[i]]
    end

    current[segments[#segments]] = value
  end

  -- regenerate the options
  _options = vim.tbl_deep_extend("force", _default, _plugin_options, _project_options)
  -- save the data
  _data[_cwd] = _project_options

  manager.save()
end

manager.save = function()
  if vim.fn.isdirectory(vim.fs.dirname(_file_path)) == 0 then
    vim.fn.mkdir(vim.fs.dirname(_file_path), "p")
  end
  local file = io.open(_file_path, "w")
  if not file then
    return false
  end

  local json = vim.json.encode(_data)
  if vim.fn.executable("jq") == 1 then
    local out = vim.system({ "jq" }, { stdin = json }):wait()
    json = out.stdout
  end
  file:write(json)
  file:close()

  return true
end

manager.get_path = function()
  return _file_path
end

return manager
