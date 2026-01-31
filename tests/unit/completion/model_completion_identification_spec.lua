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
    }, { 2, 8 }, function(bufnr)
      local model = resolver.resolve_model_at_cursor(bufnr)
      assert.equals("User", model)
    end)
  end)

  a.it("resolves model from variable assigned via static call", function()
    with_buffer({
      "<?php",
      "$q = User::query();",
      "$q->where('active', 1);",
    }, { 3, 5 }, function(bufnr)
      local model = resolver.resolve_model_at_cursor(bufnr)
      assert.equals("User", model)
    end)
  end)

  a.it("resolves model through variable chaining", function()
    with_buffer({
      "<?php",
      "$a = User::query();",
      "$b = $a;",
      "$b->where('id', 1);",
    }, { 4, 5 }, function(bufnr)
      local model = resolver.resolve_model_at_cursor(bufnr)
      assert.equals("User", model)
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
    }, { 4, 11 }, function(bufnr)
      local model = resolver.resolve_model_at_cursor(bufnr)
      assert.equals("User", model)
    end)
  end)

  a.it("resolves in anonymous_function", function()
    with_buffer({
      "<?php",
      "use App\\Models\\User;",
      "use Illuminate\\Support\\Facades\\Route;",
      "Route::get(\"/test\", function(){",
      "    $q = User::query();",
      "    $q->where('key', 1);",
      "});",
    }, { 6, 11 }, function(bufnr)
      local model = resolver.resolve_model_at_cursor(bufnr)
      assert.equals("User", model)
    end)
  end)
end)
