local scan = require("plenary.scandir")
local notify = require("laravel.utils.notify")
local Class = require("laravel.utils.class")
local nio = require("nio")

---@class laravel.extensions.tinker.lib
---@field command_generator laravel.services.command_generator
---@field ui laravel.extensions.tinker.ui
---@field data table<string, string[]>
local tinker = Class({
  command_generator = "laravel.services.command_generator",
  ui = "laravel.extensions.tinker.ui",
}, { data = {} })

local function cleanResult(data)
  return vim.tbl_map(function(line)
    if line:find("vendor/psy/psysh/src") then
      local sub = line:gsub("vendor/psy/psysh/src.*$", "")
      return sub:sub(1, -14)
    end
    if line:find("vendor/nvim%-laravel") then
      local sub = line:gsub("vendor/nvim%-laravel.*$", "")
      return sub:sub(1, -14)
    end
    return line
  end, data)
end

local function get_lines(bufnr)
  local php_parser = vim.treesitter.get_parser(bufnr, "php")

  if not php_parser then
    notify.error("PHP parser not found")
    return
  end

  local tree = php_parser:parse()[1]

  local nodes = {}
  for node in tree:root():iter_children() do
    -- remove the comment and others
    if not vim.tbl_contains({ "php_tag", "comment" }, node:type(), {}) then
      local text = vim.treesitter.get_node_text(node, bufnr, {}):gsub("%%","%%%%")
      table.insert(nodes, text)
    end
  end

  -- TODO: want to change that, could use the template with specific code added to handle this.
  -- should execute and get the last value

  local last = nodes[#nodes]

  if not (last:match("dump") or last:match("echo") or last:match("print_r")) then
    local body = last:gsub("%s*;%s*$", "")
    local output = "nvim_dump(" .. body .. ");"
    nodes[#nodes] = output
  end

  return nodes
end

function tinker:open(filename)
  filename = filename or "main.tinker"
  -- need to pass the main.tinker file at least for now
  local file = vim.fs.find(filename, {})[1]

  self.data[filename] = self.data[filename] or {}

  if not file then
    -- file not found, create it
    local cwd = vim.uv.cwd()
    file = vim.fs.joinpath(cwd, filename)
  end

  local bufnr = vim.uri_to_bufnr(vim.uri_from_fname(file))
  vim.fn.bufload(bufnr)

  self.ui:open(bufnr, filename, function(_, channelId, info_callback)
    pcall(function()
      vim.cmd("write")
    end)
    nio.run(function()
      self.data[filename] = {}

      if Laravel.app("laravel.extensions.dump_server.lib"):isRunning() then
        notify.warn("Dump server is running, please stop it before using tinker")

        return
      end

      local lines = get_lines(bufnr) or {}
      local code_block = table.concat(lines, "\n")
      -- Use the new PHP template-based execution for extensibility
      local code_service = require("laravel.services.code")
      -- Future extensibility: uses template system so new output modes are trivial
      local php_file
      local ok, err = pcall(function()
        php_file = code_service:make_php_file(code_block, "tinker")
      end)
      if not ok or not php_file then
        notify.error("Could not generate tinker PHP file:" .. (err or "unknown error"))
        return
      end

      -- Execute it in PTY mode as with tinker, preserving current UI/UX
      -- TODO: To support more type-based outputs, only the PHP template is changed
      nio.scheduler()
      vim.fn.jobstart({ "php", php_file }, {
        stdeout_buffered = true,
        on_stdout = function(_, data)
          data = cleanResult(data)
          for i = #data, 1, -1 do
            if data[i] == "" then
              table.remove(data, i)
            end
          end
          local last = data[#data] or ""
          if last:match("^__tinker_info:") then
            local info = last:gsub("^__tinker_info:", "")
            local ok, decoded = pcall(vim.fn.json_decode, info)
            if ok and decoded then
              table.remove(data, #data)
              if info_callback then
                info_callback(decoded.time, decoded.memory)
              end
            end
          end
          vim.fn.chansend(channelId, data)
          for _, line in ipairs(data) do
            table.insert(self.data[filename], line)
          end
        end,
        on_exit = function() end,
        pty = true,
      })
    end)
  end)

  if not vim.tbl_isempty(self.data[filename]) then
    local channelId = self.ui:getChannelId()
    vim.fn.chansend(channelId, self.data[filename])
  end
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

function tinker:create()
  vim.ui.input({ prompt = "Enter the name of the tinker file" }, function(input)
    if not input then
      return
    end

    -- check if name end with .tinker if not add it and call the tinker:open with it
    if not vim.endswith(input, ".tinker") then
      input = input .. ".tinker"
    end

    self:open(input)
  end)
end

return tinker
