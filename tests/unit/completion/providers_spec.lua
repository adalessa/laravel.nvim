local views = require("laravel.extensions.completion.views_completion")
local inertia = require("laravel.extensions.completion.inertia_completion")
local configs = require("laravel.extensions.completion.configs_completion")
local routes = require("laravel.extensions.completion.routes_completion")
local env_vars = require("laravel.extensions.completion.env_vars_completion")

local function templates()
  return {
    build = function(_, template, ...)
      return template .. ":" .. table.concat({ ... }, ",")
    end,
  }
end

local function failing_loader()
  return {
    load = function()
      return nil, "loader failed"
    end,
  }
end

describe("completion providers", function()
  describe("views", function()
    it("matches view helper and facade calls", function()
      assert.is_true(views.matches({ before = "return view('we" }))
      assert.is_true(views.matches({ before = 'return view ( "we' }))
      assert.is_true(views.matches({ before = "return View::make('we" }))
      assert.is_false(views.matches({ before = "return viewer('we" }))
      assert.is_false(views.matches({ before = "return review('we" }))
    end)

    it("returns the project and vendor views", function()
      local items = views.complete({}, {
        views_loader = {
          load = function()
            return {
              { key = "welcome", path = "/project/views/welcome.blade.php", isVendor = false },
              { key = "vendor::mail", path = "/vendor/mail.blade.php", isVendor = true },
            }
          end,
        },
        templates = templates(),
      })

      assert.same({
        {
          label = "view_label:welcome",
          insertText = "welcome",
          kind = vim.lsp.protocol.CompletionItemKind.Value,
          documentation = "/project/views/welcome.blade.php",
        },
        {
          label = "view_label:vendor::mail",
          insertText = "vendor::mail",
          kind = vim.lsp.protocol.CompletionItemKind.Value,
          documentation = "/vendor/mail.blade.php (vendor)",
        },
      }, items)
    end)

    it("declares the services it needs and reports loader errors", function()
      assert.same("laravel.loaders.views_loader", views.dependencies.views_loader)
      assert.same("laravel.utils.templates", views.dependencies.templates)

      local items, err = views.complete({}, { views_loader = failing_loader(), templates = templates() })
      assert.same({}, items)
      assert.same("loader failed", err)
    end)
  end)

  describe("inertia", function()
    it("matches inertia helper and facade calls", function()
      assert.is_true(inertia.matches({ before = "inertia('We" }))
      assert.is_true(inertia.matches({ before = 'Inertia::render ( "We' }))
      assert.is_false(inertia.matches({ before = "return Inertia::share('We" }))
      assert.is_false(inertia.matches({ before = "return reinertia('We" }))
    end)
  end)

  describe("configs", function()
    it("matches the config helper", function()
      assert.is_true(configs.matches({ before = "config('app.na" }))
      assert.is_true(configs.matches({ before = 'config ( "app.na' }))
      assert.is_false(configs.matches({ before = "configs('app.na" }))
      assert.is_false(configs.matches({ before = "reconfig('app.na" }))
    end)

    it("returns every config key", function()
      local items = configs.complete({}, {
        configs_loader = {
          load = function()
            return { { name = "app.name" }, { name = "database.default" } }
          end,
        },
        templates = templates(),
      })

      assert.same({
        {
          label = "config_label:app.name",
          insertText = "app.name",
          kind = vim.lsp.protocol.CompletionItemKind.Value,
          documentation = "app.name",
        },
        {
          label = "config_label:database.default",
          insertText = "database.default",
          kind = vim.lsp.protocol.CompletionItemKind.Value,
          documentation = "database.default",
        },
      }, items)
    end)
  end)

  describe("routes", function()
    it("matches the route helper", function()
      assert.is_true(routes.matches({ before = "route('ho" }))
      assert.is_true(routes.matches({ before = 'route ( "ho' }))
      assert.is_false(routes.matches({ before = "router('ho" }))
    end)

    it("skips unnamed routes", function()
      local items = routes.complete({}, {
        routes_loader = {
          load = function()
            return {
              { name = "home", methods = { "GET" }, uri = "/", middlewares = { "web" } },
              { name = nil, methods = { "POST" }, uri = "/unused" },
            }
          end,
        },
        templates = templates(),
      })

      assert.same({
        {
          label = "route_label:home",
          insertText = "home",
          kind = vim.lsp.protocol.CompletionItemKind.Value,
          documentation = "route_documentation:home,GET,/,web",
        },
      }, items)
    end)
  end)

  describe("environment variables", function()
    it("matches the env helper", function()
      assert.is_true(env_vars.matches({ before = "env('APP_" }))
      assert.is_true(env_vars.matches({ before = 'env ( "APP_' }))
      assert.is_false(env_vars.matches({ before = "environment('APP_" }))
      assert.is_false(env_vars.matches({ before = "getenv('APP_" }))
    end)

    it("shows the variable value in the documentation", function()
      local items = env_vars.complete({}, {
        environment_vars_loader = {
          load = function()
            return { { key = "APP_ENV", value = "local" } }
          end,
        },
        templates = templates(),
      })

      assert.same({
        {
          label = "env_var:APP_ENV",
          insertText = "APP_ENV",
          kind = vim.lsp.protocol.CompletionItemKind.Value,
          documentation = "APP_ENV = local",
        },
      }, items)
    end)
  end)
end)
