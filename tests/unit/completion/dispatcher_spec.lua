local dispatcher = require("laravel.extensions.completion")

local function context(overrides)
  return vim.tbl_extend("force", {
    bufnr = 1,
    filetype = "php",
    line = "return view('we",
    before = "return view('we",
  }, overrides or {})
end

local function provider(overrides)
  return vim.tbl_extend("force", {
    name = "provider",
    matches = function()
      return false
    end,
    complete = function()
      return {}
    end,
  }, overrides or {})
end

describe("completion dispatcher", function()
  it("knows which filetypes expose laravel completions", function()
    assert.is_true(dispatcher.is_supported(context({ filetype = "php" })))
    assert.is_true(dispatcher.is_supported(context({ filetype = "blade" })))
    assert.is_true(dispatcher.is_supported(context({ filetype = "tinker" })))
    assert.is_false(dispatcher.is_supported(context({ filetype = "lua" })))
  end)

  it("skips unsupported filetypes without consulting providers", function()
    local called = false
    local items = dispatcher.resolve(context({ filetype = "lua" }), {
      providers = {
        provider({
          matches = function()
            called = true
            return true
          end,
        }),
      },
      is_active = function()
        return true
      end,
    })

    assert.same({}, items)
    assert.is_false(called)
  end)

  it("skips completion when the laravel environment is not active", function()
    local called = false
    local items = dispatcher.resolve(context(), {
      providers = {
        provider({
          matches = function()
            called = true
            return true
          end,
        }),
      },
      is_active = function()
        return false
      end,
    })

    assert.same({}, items)
    assert.is_false(called)
  end)

  it("uses the first matching provider and ignores the rest", function()
    local calls = {}
    local items = dispatcher.resolve(context(), {
      is_active = function()
        return true
      end,
      providers = {
        provider({
          name = "views",
          matches = function()
            return false
          end,
          complete = function()
            table.insert(calls, "views")
            return { { label = "view" } }
          end,
        }),
        provider({
          name = "routes",
          matches = function()
            return true
          end,
          complete = function()
            table.insert(calls, "routes")
            return { { label = "route" } }
          end,
        }),
        provider({
          name = "model",
          matches = function()
            return true
          end,
          complete = function()
            table.insert(calls, "model")
            return { { label = "column" } }
          end,
        }),
      },
    })

    assert.same({ { label = "route" } }, items)
    assert.same({ "routes" }, calls)
  end)

  it("resolves only the dependencies of the matching provider", function()
    local requested = {}
    local received
    dispatcher.resolve(context(), {
      is_active = function()
        return true
      end,
      get_service = function(name)
        table.insert(requested, name)
        return { name = name }
      end,
      providers = {
        provider({
          dependencies = { routes_loader = "laravel.loaders.routes_loader" },
        }),
        provider({
          matches = function()
            return true
          end,
          dependencies = {
            views_loader = "laravel.loaders.views_loader",
            templates = "laravel.utils.templates",
          },
          complete = function(_, deps)
            received = deps
            return {}
          end,
        }),
      },
    })

    table.sort(requested)
    assert.same({ "laravel.loaders.views_loader", "laravel.utils.templates" }, requested)
    assert.same("laravel.loaders.views_loader", received.views_loader.name)
    assert.same("laravel.utils.templates", received.templates.name)
  end)

  it("propagates a provider error", function()
    local items, err = dispatcher.resolve(context(), {
      is_active = function()
        return true
      end,
      providers = {
        provider({
          matches = function()
            return true
          end,
          complete = function()
            return nil, "loader failed"
          end,
        }),
      },
    })

    assert.same({}, items)
    assert.same("loader failed", err)
  end)

  it("returns an empty list when no provider matches", function()
    local items, err = dispatcher.resolve(context(), {
      is_active = function()
        return true
      end,
      providers = { provider() },
    })

    assert.same({}, items)
    assert.is_nil(err)
  end)

  it("builds a context from an nvim-cmp completion request", function()
    local ctx = dispatcher.from_cmp({
      context = {
        bufnr = 7,
        filetype = "blade",
        cursor_line = "return view('welcome')",
        cursor_before_line = "return view('we",
      },
    })

    assert.same({
      bufnr = 7,
      filetype = "blade",
      line = "return view('welcome')",
      before = "return view('we",
    }, ctx)
  end)

  it("builds a context from a blink.cmp completion context", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = "php"

    local ok, ctx = pcall(dispatcher.from_blink, {
      bufnr = bufnr,
      line = "return view('welcome')",
      cursor = { 1, 15 },
    })

    vim.api.nvim_buf_delete(bufnr, { force = true })
    if not ok then
      error(ctx)
    end

    assert.same({
      bufnr = bufnr,
      filetype = "php",
      line = "return view('welcome')",
      before = "return view('we",
    }, ctx)
  end)

  it("merges and deduplicates the trigger characters of every provider", function()
    local characters = dispatcher.trigger_characters({
      provider({ trigger_characters = { "'", '"' } }),
      provider({ trigger_characters = { '"', "(" } }),
      provider(),
    })

    assert.same({ "'", '"', "(" }, characters)
  end)
end)
