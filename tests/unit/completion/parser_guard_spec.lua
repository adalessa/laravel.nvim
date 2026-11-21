local resolver = require("laravel.extensions.completion.model_completion_type_resolver")

describe("model completion parser guard", function()
  it("returns nil when the php parser is unavailable", function()
    local original = vim.treesitter.get_parser
    vim.treesitter.get_parser = function()
      return nil
    end

    local ok, result = pcall(resolver.resolve_model_at_cursor, 0, "")

    vim.treesitter.get_parser = original
    assert.is_true(ok)
    assert.is_nil(result)
  end)
end)
