local M = {}

local REQUIRED = {
  "plenary.nvim",
  "nvim-nio",
  "nui.nvim",
  "nvim-treesitter",
}

local OPTIONAL = {
  "telescope.nvim",
  "fzf-lua",
  "snacks.nvim",
  "nvim-cmp",
  "blink.cmp",
}

local function is_directory(path)
  return type(path) == "string" and path ~= "" and vim.fn.isdirectory(path) == 1
end

---@param opts { env: table<string, string>, repo_root: string, data_dir: string }
---@return table<string, string>, string[]
function M.resolve(opts)
  opts = opts or {}
  local env = opts.env or {}
  local candidates = {
    env.LARAVEL_TEST_DEPS,
    (opts.repo_root or "") .. "/.tests/deps",
    opts.data_dir,
  }

  local root
  for index = 1, 3 do
    local candidate = candidates[index]
    if is_directory(candidate) then
      root = candidate
      break
    end
  end

  local resolved = {}
  local missing = {}

  if not root then
    for _, name in ipairs(REQUIRED) do
      table.insert(missing, name)
    end
    return resolved, missing
  end

  for _, name in ipairs(REQUIRED) do
    local path = root .. "/" .. name
    if is_directory(path) then
      resolved[name] = path
    else
      table.insert(missing, name)
    end
  end

  for _, name in ipairs(OPTIONAL) do
    local path = root .. "/" .. name
    if is_directory(path) then
      resolved[name] = path
    end
  end

  return resolved, missing
end

---@param resolved table<string, string>
function M.setup(resolved)
  for _, name in ipairs(REQUIRED) do
    if resolved[name] then
      vim.opt.rtp:append(resolved[name])
    end
  end

  for _, name in ipairs(OPTIONAL) do
    if resolved[name] then
      vim.opt.rtp:append(resolved[name])
    end
  end

  local parsers = vim.env.LARAVEL_TS_PARSERS
  if type(parsers) == "string" and parsers ~= "" then
    for path in parsers:gmatch("[^:]+") do
      vim.opt.rtp:append(path)
    end
  end

  vim.cmd("runtime! plugin/plenary.vim")
end

return M
