local resolver = require("laravel.extensions.completion.model_completion_type_resolver")
local model_completion = require("laravel.extensions.completion.model_completion")

describe("model completion parser guard", function()
  local function with_missing_parser(callback)
    local original = vim.treesitter.get_parser
    vim.treesitter.get_parser = function()
      return nil
    end

    local ok, result = pcall(callback)
    vim.treesitter.get_parser = original
    assert.is_true(ok)
    return result
  end

  it("returns nil when the php parser is unavailable", function()
    local result = with_missing_parser(function()
      return resolver.resolve_model_at_cursor(0, "")
    end)

    assert.is_nil(result)
  end)

  it("returns nil when get_parser raises for the php parser", function()
    local original = vim.treesitter.get_parser
    vim.treesitter.get_parser = function()
      error("no parser for 'php' language")
    end

    local ok, result = pcall(resolver.resolve_model_at_cursor, 0, "")

    vim.treesitter.get_parser = original
    assert.is_true(ok)
    assert.is_nil(result)
  end)

  it("returns no completion items when the php parser is unavailable", function()
    local items = with_missing_parser(function()
      return model_completion.complete({ bufnr = 0, before = "" }, {})
    end)

    assert.same({}, items)
  end)
end)
