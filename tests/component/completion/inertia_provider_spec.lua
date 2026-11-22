local nio = require("nio")
local a = nio.tests

local inertia_path = "laravel.extensions.completion.inertia_completion"
local scan_path = "plenary.scandir"

local function with_scanner(view, callback)
  local previous_scan = package.loaded[scan_path]
  local previous_inertia = package.loaded[inertia_path]

  package.loaded[scan_path] = {
    scan_dir_async = function(_, opts)
      nio.run(function()
        nio.sleep(0)
        opts.on_exit({ view })
      end)
    end,
  }
  package.loaded[inertia_path] = nil

  local ok, result = pcall(function()
    return callback(require(inertia_path))
  end)

  package.loaded[scan_path] = previous_scan
  package.loaded[inertia_path] = previous_inertia

  if not ok then
    error(result, 0)
  end

  return result
end

describe("inertia completion provider", function()
  local root

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root .. "/Pages", "p")
  end)

  after_each(function()
    vim.fn.delete(root, "rf")
  end)

  a.it("returns pages relative to the configured path", function()
    local items = with_scanner(root .. "/Pages/Home.vue", function(inertia)
      return inertia.complete({}, {
        inertia_loader = {
          load = function()
            return { page_paths = { root }, page_extensions = { "vue" } }
          end,
        },
      })
    end)

    assert.same({
      {
        label = "Pages/Home",
        insertText = "Pages/Home",
        kind = vim.lsp.protocol.CompletionItemKind.Value,
        documentation = root .. "/Pages/Home.vue",
      },
    }, items)
  end)

  it("reports loader errors", function()
    local items, err = require(inertia_path).complete({}, {
      inertia_loader = {
        load = function()
          return nil, "loader failed"
        end,
      },
    })

    assert.same({}, items)
    assert.same("loader failed", err)
  end)
end)
