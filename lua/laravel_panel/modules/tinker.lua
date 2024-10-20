local app = require("laravel").app
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local function get_tinker_files()
  return vim.fs.find(function(name)
    return name:match(".*%.tinker")
  end, {
    type = "file",
    limit = math.huge,
  })
end

local tinker_panel = {}

function tinker_panel:new()
  local instance = {
    id = "tinker",
    text = "Tinker",
    _current_tinker_file = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  instance._code_panel = instance:_create_code_panel()
  instance._result_panel = instance:_create_result_panel()

  return instance
end

-- private

function tinker_panel:_create_code_panel()
  self._current_tinker_file = self._current_tinker_file
      or get_tinker_files()[1]
      or string.format("%s/main.tinker", vim.uv.cwd())

  local bufnr = self:_get_tinker_buffer()

  return Popup({
    border = {
      style = "single",
      text = {
        top = self.text,
      },
    },
    buf_options = {},
    win_options = {
      number = true,
      relativenumber = true,
      signcolumn = "yes:2",
    },
    bufnr = bufnr,
  })
end

function tinker_panel:_create_result_panel()
  return Popup({
    border = {
      style = "single",
      text = {
        top = "Result",
      },
    },
    buf_options = {},
  })
end

function tinker_panel:_create_layout()
  return Layout.Box({
    Layout.Box(self._code_panel, { size = "50%" }),
    Layout.Box(self._result_panel, { size = "50%" }),
  }, { size = "100%", dir = "row" })
end

function tinker_panel:_select_file()
  vim.ui.select(get_tinker_files(), {
    prompt = "Select tinker file",
  }, function(file)
    if file then
      self._current_tinker_file = file
      self:set_tinker_file()
    end
  end)
end

function tinker_panel:_new_file()
  vim.ui.input({ prompt = "Create new tinker file" }, function(value)
    if not value then
      return
    end
    if not vim.endswith(value, ".tinker") then
      value = value .. ".tinker"
    end
    value = string.format("%s/%s", vim.uv.cwd(), value)
    self._current_tinker_file = value
    self:set_tinker_file()
  end)
end

function tinker_panel:_get_tinker_buffer()
  local file = string.format("file://%s", self._current_tinker_file)
  local bufnr = vim.uri_to_bufnr(file)
  vim.fn.bufload(bufnr)

  return bufnr
end

function tinker_panel:set_tinker_file()
  self:deactivate()
  self._code_panel = self:_create_code_panel()
  self:_set_code_mapping()
  self._update_panel()
  vim.api.nvim_set_current_win(self._code_panel.winid)
  self:activate()
end

-- interface
function tinker_panel:active()
  return true
end

function tinker_panel:getTargetWinId()
  return self._code_panel.winid
end

function tinker_panel:setup(opts)
  self._opts = opts
  self:_set_code_mapping()

  self._result_panel:map("n", "q", opts.quit)
  self._update_panel = opts.update

  self._result_panel:map("n", "<tab>", opts.menu_focus)

  self._result_panel:map("n", "gr", function()
    self:_select_file()
  end)
  self._result_panel:map("n", "gn", function()
    self:_new_file()
  end)
end

function tinker_panel:_set_code_mapping()
  self._code_panel:map("n", "q", self._opts.quit)
  self._code_panel:map("n", "<tab>", function()
    vim.api.nvim_set_current_win(self._result_panel.winid)
  end)
  self._code_panel:map("n", "gr", function()
    self:_select_file()
  end)
  self._code_panel:map("n", "gn", function()
    self:_new_file()
  end)
end

function tinker_panel:layout()
  return self:_create_layout()
end

function tinker_panel:_tinker_action()
  local lines = vim.api.nvim_buf_get_lines(self._code_panel.bufnr, 1, -1, false)
  lines = vim.tbl_filter(function(raw_line)
    local line = raw_line:gsub("^%s*(.-)%s*$", "%1")
    return line ~= ""
        and line:sub(1, 2) ~= "//"
        and line:sub(1, 2) ~= "/*"
        and line:sub(1, 2) ~= "*/"
        and line:sub(1, 1) ~= "*"
        and line:sub(1, 1) ~= "#"
  end, lines)

  if #lines == 0 then
    return
  end

  -- FIX: don't want to always add the dump and this way is not functional
  -- if
  --     lines[#lines] ~= "}"
  --     and lines[#lines]:sub(1, 4) ~= "dump"
  --     and lines[#lines]:sub(1, 8) ~= "var_dump"
  --     and lines[#lines]:sub(1, 4) ~= "echo"
  --     and ((not lines[#lines - 1]) or string.len(lines[#lines - 1]) > 0 and lines[#lines - 1]:sub(1, -1) == ";")
  -- then
  --   lines[#lines] = string.format("dump(%s);", lines[#lines]:sub(1, -2))
  -- end
  --
  -- TODO: here the treesitter query can get the last expression can defin if there is a dump or not.
  --
  -- (function_call_expression
  --   (name) @out (#any-of? @out "dump" "dd" "var_dump")
  --   )
  --
  -- (member_call_expression
  --   (name) @out (#eq? @out "dump")
  --   )
  --
  -- (echo_statement) @out
  --
  -- (expression_statement) @expression
  --
  -- if there is no capture with out
  -- get the last expression and wrap it un dump
  -- to wrap it can get the text, remove the last character for the ;
  -- and done ?

  local cmd = app("api"):generate_command("artisan", { "tinker", "--execute", table.concat(lines, "\n") })

  local channel_id = vim.api.nvim_open_term(self._result_panel.bufnr, {})
  vim.fn.jobstart(cmd, {
    stdeout_buffered = true,
    on_stdout = function(_, data)
      data = vim.tbl_map(function(line)
        if line:find("vendor/psy/psysh/src") then
          local sub = line:gsub("vendor/psy/psysh/src.*$", "")
          return sub:sub(1, -14)
        end
        return line
      end, data)

      vim.fn.chansend(channel_id, data)
    end,
    on_exit = function() end,
    pty = true,
  })
end

function tinker_panel:activate()
  self._code_panel:on("BufWritePost", function()
    self:_tinker_action()
  end)
end

function tinker_panel:deactivate()
  self._code_panel:off("BufWritePost")
end

return tinker_panel
