local scan = require("plenary.scandir")
local nio = require("nio")

local inertia_completion = {}

function inertia_completion.complete(inertia_loader, templates, params, callback)
  local inertia, err = inertia_loader:load()
  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end
  local pattern = ".[" .. table.concat(inertia.page_extensions, "|") .. "]$"
  local paths = vim.tbl_filter(function(dir)
    local _, stat = nio.uv.fs_stat(dir)
    return stat ~= nil
  end, inertia.page_paths)

  scan.scan_dir_async(paths, {
    depth = 6,
    search_pattern = pattern,
    on_exit = function(finds)
      callback({
        items = vim
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

            local filename, _ = view_name:match("^(.+)%.(.+)$")

            return {
              label = filename,
              insertText = filename,
              kind = vim.lsp.protocol.CompletionItemKind["Value"],
              documentation = view,
            }
          end)
          :totable(),
        isIncomplete = false,
      })
    end,
  })
end

function inertia_completion.shouldComplete(text)
  return text:match("inertia%([%'|%\"]") or text:match("Inertia::render%([%'|%\"]")
end

return inertia_completion
