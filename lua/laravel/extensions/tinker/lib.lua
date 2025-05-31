local scan = require("plenary.scandir")
local notify = require("laravel.utils.notify")
local Class = require("laravel.utils.class")

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
    return line
  end, data)
end

local function get_lines(bufnr)
  local php_parser = vim.treesitter.get_parser(bufnr, "php")

  if not php_parser then
    error("parser not found")
  end

  local tree = php_parser:parse()[1]

  local nodes = {}
  for node in tree:root():iter_children() do
    -- remove the comment and others
    if not vim.tbl_contains({ "php_tag", "comment" }, node:type(), {}) then
      table.insert(nodes, vim.treesitter.get_node_text(node, bufnr, {}))
    end
  end

  local last = nodes[#nodes]

  if not (last:match("dump") or last:match("echo") or last:match("print_r")) then
    local body = last:gsub("%s*;%s*$", "")
    local output = "dump(" .. body .. ");"
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

  self.ui:open(bufnr, filename, function()
    self.data.file = {}

    local lines = get_lines(bufnr)

    local cmd = self.command_generator:generate("artisan", { "tinker", "--execute", table.concat(lines, "\n") })
    if not cmd then
      notify.error("Tinker command not found")
      return
    end

    local channelId = self.ui:createTerm()
    vim.fn.jobstart(cmd, {
      stdeout_buffered = true,
      on_stdout = function(_, data)
        data = cleanResult(data)
        vim.fn.chansend(channelId, data)
        for _, line in ipairs(data) do
          table.insert(self.data[filename], line)
        end
      end,
      on_exit = function() end,
      pty = true,
    })
  end)

  if not vim.tbl_isempty(self.data[filename]) then
    local channelId = self.ui:createTerm()
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
