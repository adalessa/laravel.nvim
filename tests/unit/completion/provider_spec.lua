local provider = require("laravel.extensions.completion.provider")

local function application()
  local requested = {}
  local app = setmetatable({}, {
    __call = function(_, abstract)
      table.insert(requested, abstract)
      return "laravel-source"
    end,
  })

  return app, requested
end

local function fake_cmp(calls)
  return {
    register_source = function(name, source)
      table.insert(calls, { engine = "cmp", name = name, source = source })
    end,
  }
end

local function fake_blink(calls, config)
  return {
    add_source_provider = function(id, source)
      config.sources.providers[id] = source
      table.insert(calls, { engine = "blink", id = id, source = source })
    end,
    add_filetype_source = function(filetype, id)
      table.insert(calls, { engine = "blink", filetype = filetype, id = id })
    end,
  }
end

local function blink_config()
  return { sources = { providers = {} } }
end

describe("completion provider", function()
  it("registers the nvim-cmp source when nvim-cmp is available", function()
    local app, requested = application()
    local calls = {}

    provider.boot(app, { enable = true }, {
      cmp = fake_cmp(calls),
      blink = false,
      blink_config = false,
      watch = false,
    })

    assert.same({ "completion" }, requested)
    assert.same({ { engine = "cmp", name = "laravel", source = "laravel-source" } }, calls)
  end)

  it("registers a blink provider for php, blade and tinker", function()
    local app = application()
    local calls = {}
    local config = blink_config()

    provider.boot(app, { enable = true }, {
      cmp = false,
      blink = fake_blink(calls, config),
      blink_config = config,
      watch = false,
    })

    assert.same({
      { engine = "blink", id = "laravel", source = config.sources.providers.laravel },
      { engine = "blink", filetype = "php", id = "laravel" },
      { engine = "blink", filetype = "blade", id = "laravel" },
      { engine = "blink", filetype = "tinker", id = "laravel" },
    }, calls)
    assert.same("laravel.extensions.completion.blink", config.sources.providers.laravel.module)
    assert.same("Laravel", config.sources.providers.laravel.name)
  end)

  it("does not override a provider the user already configured", function()
    local app = application()
    local calls = {}
    local config = blink_config()
    config.sources.providers.laravel = { module = "blink.compat.source" }

    provider.boot(app, { enable = true }, {
      cmp = false,
      blink = fake_blink(calls, config),
      blink_config = config,
      watch = false,
    })

    assert.same({}, calls)
    assert.same("blink.compat.source", config.sources.providers.laravel.module)
  end)

  it("registers nothing when the extension is disabled", function()
    local app, requested = application()
    local calls = {}
    local config = blink_config()

    provider.boot(app, { enable = false }, {
      cmp = fake_cmp(calls),
      blink = fake_blink(calls, config),
      blink_config = config,
      watch = false,
    })

    assert.same({}, calls)
    assert.same({}, requested)
  end)
end)
