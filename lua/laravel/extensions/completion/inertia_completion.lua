local scan = require("plenary.scandir")
local nio = require("nio")

---@type laravel.extensions.completion.Provider
local inertia_completion = {
  name = "inertia",
  trigger_characters = { "'", '"' },
  dependencies = {
    inertia_loader = "laravel.loaders.inertia_cache_loader",
  },
}

local scan_dir_async = nio.wrap(function(paths, opts, callback)
  opts.on_exit = callback
  scan.scan_dir_async(paths, opts)
end, 3)

function inertia_completion.matches(ctx)
  return ctx.before:match("%f[%a]inertia%s*%(%s*[\"']") ~= nil
    or ctx.before:match("%f[%a]Inertia::render%s*%(%s*[\"']") ~= nil
end

local function dir_exists_with_exact_case(path)
  local parent = vim.fn.fnamemodify(path, ":h")
  local name = vim.fn.fnamemodify(path, ":t")

  local dirs = scan.scan_dir(parent, {
    hidden = false,
    only_dirs = true,
    depth = 1,
  })

  for _, dir_path in ipairs(dirs) do
    local dir_name = vim.fn.fnamemodify(dir_path, ":t")
    if dir_name == name then
      return true
    end
  end

  return false
end

function inertia_completion.complete(_, deps)
  local inertia, err = deps.inertia_loader:load()
  if err then
    return {}, err
  end

  local pattern = ".[" .. table.concat(inertia.page_extensions, "|") .. "]$"

  local paths = vim.tbl_filter(function(dir)
    if nio.uv.fs_access(dir, "X") == false then
      return false
    end

    if vim.uv.os_uname().sysname == "Darwin" then
      return dir_exists_with_exact_case(dir)
    end

    local _, stat = nio.uv.fs_stat(dir)
    return stat ~= nil
  end, inertia.page_paths)

  if #paths == 0 then
    return {}
  end

  local finds = scan_dir_async(paths, {
    depth = 6,
    search_pattern = pattern,
  })

  return vim
    .iter(finds)
    :map(function(view)
      local view_name = vim
        .iter(paths)
        :map(function(path)
          return vim.fs.relpath(path, view)
        end)
        :filter(function(path)
          return path ~= nil
        end)
        :totable()[1]

      local filename = view_name:match("^(.+)%.(.+)$")

      return {
        label = filename,
        insertText = filename,
        kind = vim.lsp.protocol.CompletionItemKind["Value"],
        documentation = view,
      }
    end)
    :totable()
end

return inertia_completion
