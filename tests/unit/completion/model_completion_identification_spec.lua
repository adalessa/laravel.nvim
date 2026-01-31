local nio = require("nio")
local a = nio.tests

local resolver = require("laravel.extensions.completion.model_completion_type_resolver")

local function with_buffer(lines, cursor, fn)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(bufnr)

  vim.api.nvim_win_set_cursor(0, cursor)

  fn(bufnr)

  vim.api.nvim_buf_delete(bufnr, { force = true })
end

describe("model completion identification", function()
  a.it("resolves model from static where call", function()
    with_buffer({
      "<?php",
      "User::where('email', 'a@b.com')->first();",
    }, { 2, 13 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "User::where('")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves model from static first call", function()
    with_buffer({
      "<?php",
      "User::where('email', 'a@b.com')->first();",
    }, { 2, 39 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "User::where('email', 'a@b.com')->first(")
      assert.equals("User", result.model)
      assert.equals("first", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves model from static where call at second parameter", function()
    with_buffer({
      "<?php",
      "User::where('email', 'a@b.com')->first();",
    }, { 2, 25 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "User::where('email', 'a@b")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(1, result.param_position)
    end)
  end)

  a.it("resolves model from variable assigned via static call not in param", function()
    with_buffer({
      "<?php",
      "$q = User::query();",
      "$q->where('active', 1);",
    }, { 3, 5 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "$q->w")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.is_nil(result.param_position)
    end)
  end)

  a.it("resolves model from variable assigned via static call in first param", function()
    with_buffer({
      "<?php",
      "$q = User::query();",
      "$q->where('active', 1);",
    }, { 3, 13 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "$q->where('ac")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves model through variable chaining", function()
    with_buffer({
      "<?php",
      "$a = User::query();",
      "$b = $a;",
      "$b->where('id', 1);",
    }, { 4, 5 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "$b->w")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(nil, result.param_position)
    end)
  end)

  a.it("does not resolve assignment from outer scope", function()
    with_buffer({
      "<?php",
      "$q = User::query();",
      "function test() {",
      "  $q->where('id', 1);",
      "}",
    }, { 4, 7 }, function(bufnr)
      local model = resolver.resolve_model_at_cursor(bufnr)
      assert.is_nil(model)
    end)
  end)

  a.it("resolves scope method parameter as model", function()
    with_buffer({
      "<?php",
      "class User {",
      "  public function scopeActive($query) {",
      "    $query->where('active', 1);",
      "  }",
      "}",
    }, { 4, 22 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "    $query->where('act")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves in anonymous_function", function()
    with_buffer({
      "<?php",
      "use App\\Models\\User;",
      "use Illuminate\\Support\\Facades\\Route;",
      'Route::get("/test", function(){',
      "    $q = User::query();",
      "    $q->where('key', 1);",
      "});",
    }, { 6, 17 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "    $q->where('ke")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves in the middle of the writting", function()
    with_buffer({
      "<?php",
      "User::where('",
    }, { 2, 13 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "User::where('")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves in the middle of the writting with query", function()
    with_buffer({
      "<?php",
      "User::query()->where('",
    }, { 2, 22 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "User::query()->where('")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)

  a.it("resolves in the middle of writting in anonymous_function", function()
     with_buffer({
      "<?php",
      "use App\\Models\\User;",
      "use Illuminate\\Support\\Facades\\Route;",
      'Route::get("/test", function(){',
      "    $q = User::query();",
      "    $q->where('",
      "});",
    }, { 6, 15 }, function(bufnr)
      local result = resolver.resolve_model_at_cursor(bufnr, "    $q->where('")
      assert.equals("User", result.model)
      assert.equals("where", result.method)
      assert.equals(0, result.param_position)
    end)
  end)
end)
