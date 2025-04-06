local scan = require("plenary.scandir")

local tinker = {}

function tinker:new(tinker_ui, api)
  local instance = {
    ui = tinker_ui,
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

local function cleanLines(lines)
  return vim.tbl_filter(function(raw_line)
    local line = raw_line:gsub("^%s*(.-)%s*$", "%1")
    return line ~= ""
      and line:sub(1, 2) ~= "//"
      and line:sub(1, 2) ~= "/*"
      and line:sub(1, 2) ~= "*/"
      and line:sub(1, 1) ~= "*"
      and line:sub(1, 1) ~= "#"
  end, lines)
end

local function cleanResult(data)
  return vim.tbl_map(function(line)
    if line:find("vendor/psy/psysh/src") then
      local sub = line:gsub("vendor/psy/psysh/src.*$", "")
      return sub:sub(1, -14)
    end
    return line
  end, data)
end

function tinker:open(filename)
  filename = filename or "main.tinker"
  -- need to pass the main.tinker file at least for now
  local file = vim.fs.find(filename, {})[1]

  if not file then
    -- file not found, create it
    local cwd = vim.uv.cwd()
    file = vim.fs.joinpath(cwd, filename)
  end

  local bufnr = vim.uri_to_bufnr(vim.uri_from_fname(file))
  vim.fn.bufload(bufnr)

  self.ui:open(bufnr, function()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 1, -1, false)
    lines = cleanLines(lines)

    -- TODO add the auto dump

    local cmd = self.api:generate_command("artisan", { "tinker", "--execute", table.concat(lines, "\n") })

    local channelId = self.ui:createTerm()
    vim.fn.jobstart(cmd, {
      stdeout_buffered = true,
      on_stdout = function(_, data)
        vim.fn.chansend(channelId, cleanResult(data))
      end,
      on_exit = function() end,
      pty = true,
    })
  end)
  -- prepare the callback
  -- create the ui with the callback
  -- the callback read the buffer, reset the result to get the
  -- channel id with createTerm
end

function tinker:select()
  -- list .tinker files in the directory
  local cwd = vim.uv.cwd()
  if not cwd then
    return
  end

  scan.scan_dir_async(cwd, {
    hidden = false,
    depth = 4,
    on_exit = vim.schedule_wrap(function(finds)
      vim.ui.select(
        vim
          .iter(finds)
          :filter(function(value)
            return value ~= nil and value:match("%.tinker$")
          end)
          :map(function(value)
            -- remove the cwd
            local val = value:gsub(cwd:gsub("-", "%%-") .. "/", "")
            return val
          end)
          :totable(),
        { prompt = "Select the file to tinker with" },
        function(selected)
          if not selected then
            return
          end
          self:open(selected)
        end
      )
    end),
  })
end

-- should be able to handle multiple .tinker files in the directory
-- should have the history of the output for each

-- a better auto dump to print the output

-- an idea can be how the scrat buffer handles it, a selector for the files
-- open a selector, use vim.ui.select from simplicity
-- this will open the window, which will be a popup 70 % of the screen
-- which the editor should be 70% and 30% for the ouput

-- the results should be store separetly so can be re-written for each different option.
-- the ui should not be for ever, when quits it's unmount, not keept in memory

return tinker
