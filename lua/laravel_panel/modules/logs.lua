local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local NuiTree = require("nui.tree")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local uv = vim.uv
local function readFileSync(path)
  local fd = assert(uv.fs_open(path, "r", 438))
  local stat = assert(uv.fs_fstat(fd))
  local data = assert(uv.fs_read(fd, stat.size, 0))
  assert(uv.fs_close(fd))
  return data
end

local function parse_log_line(log_line)
  -- Regular expression to parse log line
  local pattern = "%[(%d+%-%d+%-%d+ %d+:%d+:%d+)%]%s+(%a+)%.(%u+):%s+(.+)%s+({.+)"

  -- Capture the relevant components from the log line
  local date, env, level, message, context = log_line:match(pattern)

  if date == nil then
    -- this only works with no context
    pattern = "%[(%d+%-%d+%-%d+ %d+:%d+:%d+)%]%s+(%a+)%.(%u+):%s+(.+)"
    date, env, level, message, context = log_line:match(pattern)
  end

  return {
    date = date or "",
    env = env or "",
    level = level or "",
    message = message or "",
    context = context or "",
  }
end

local function split_lines(content)
  local lines = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  return lines
end

local function parse_log_content(content)
  local parsed_logs = {}

  -- Split content by lines
  local lines = split_lines(content)

  -- Iterate over each line and parse it
  for _, line in ipairs(lines) do
    local parsed_line = parse_log_line(line)
    table.insert(parsed_logs, parsed_line)
  end

  return parsed_logs
end

local function get_log_files()
  return vim.fs.find(function(name)
    return name:match(".*%.log")
  end, {
    type = "file",
    limit = math.huge,
    path = "storage/logs/",
  })
end

local logs_panel = {}

function logs_panel:new()
  local instance = {
    id = "logs",
    text = "Logs",
  }
  setmetatable(instance, self)
  self.__index = self

  instance._panel = instance:_create_panel()
  instance._layout = instance:_create_layout()

  return instance
end

-- private
function logs_panel:_create_panel()
  return Popup({
    border = {
      style = "single",
      text = {
        top = self.text,
      },
      buf_options = {
        modifiable = false,
      },
    },
  })
end

function logs_panel:_create_layout()
  return Layout.Box(self._panel, { size = "100%" })
end

function logs_panel:_set_no_logs_message()
  vim.api.nvim_set_option_value("modifiable", true, { buf = self._panel.bufnr })
  vim.api.nvim_buf_set_lines(self._panel.bufnr, 0, -1, false, {
    "No log files found",
  })
  vim.api.nvim_set_option_value("modifiable", false, { buf = self._panel.bufnr })
end

-- interface
function logs_panel:active()
  return true
end

function logs_panel:getTargetWinId()
  return self._panel.winid
end

function logs_panel:setup(opts)
  self._panel:map("n", "q", opts.quit)
  self._panel:map("n", "<tab>", opts.menu_focus)
  self._panel:map("n", "r", function()
    self:load_logs()
  end)
  self._panel:map("n", "s", function()
    vim.ui.select(get_log_files(), { prompt = "Select the log file" }, function(selected)
      if not selected then
        self._current_log_file = selected
        self:load_logs()
      end
    end)
  end)
  self._panel:map("n", "g?", function()
    local help = Popup({
      size = "40%",
      position = "50%",
      zindex = 100,
      border = 'double',
      enter = true,
    })

    vim.api.nvim_buf_set_lines(help.bufnr, 0, -1, false, {
      "q -> quit",
      "tab -> move to menu",
      "r -> reload",
      "s -> select log file",
    })
    help:mount()

    help:map("n", "q", function()
      help:unmount()
    end)

    help:on("BufLeave", function()
      help:unmount()
    end)
  end)
end

function logs_panel:layout()
  return self._layout
end

function logs_panel:activate()
  if not self._current_log_file then
    local log_files = get_log_files()
    if vim.tbl_isempty(log_files) then
      self:_set_no_logs_message()
      return
    end

    if vim.tbl_count(log_files) == 1 then
      self._current_log_file = log_files[1]
      self:load_logs()
    else
      vim.ui.select(log_files, { prompt = "Select the log file" }, function(selected)
        if not selected then
          self._current_log_file = selected
          self:load_logs()
        end
      end)
    end
  else
    self:load_logs()
  end
end

function logs_panel:load_logs()
  if not self._current_log_file then
    return
  end

  local logs_lines = vim
      .iter(parse_log_content(readFileSync(self._current_log_file)))
      :filter(function(l)
        return l.date ~= ""
      end)
      :rev()
      :map(function(log)
        local hl = "String"
        if log.level == "ERROR" then
          hl = "ErrorMsg"
        elseif log.level == "WARNING" then
          hl = "WarningMsg"
        end
        local lines = {
          NuiLine({ NuiText(string.format("[%s] (%s) -> %s", log.date, log.env, log.level), hl) }),
          NuiLine({ NuiText("    " .. log.message, hl) }),
        }
        if log.context ~= "" then
          table.insert(lines, NuiLine({ NuiText("    " .. log.context) }))
        end

        return lines
      end)
      :totable()

  vim.api.nvim_set_option_value("modifiable", true, { buf = self._panel.bufnr })
  vim.api.nvim_buf_set_lines(self._panel.bufnr, 0, -1, false, {})
  local empty_line = NuiLine({ NuiText("") })
  local line = 0
  local i = 1
  for _, log_lines in ipairs(logs_lines) do
    for _, detail in ipairs(log_lines) do
      detail:render(self._panel.bufnr, -1, line + i)
      i = i + 1
    end
    empty_line:render(self._panel.bufnr, -1, line + i)
    i = i + 1
  end
  vim.api.nvim_set_option_value("modifiable", false, { buf = self._panel.bufnr })
end

return logs_panel
