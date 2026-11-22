local views_diagnostic = require("laravel.extensions.diagnostic.views"):new()

describe("views diagnostic", function()
  local log = {
    errors = {},
    error = function(self, message)
      table.insert(self.errors, message)
    end,
    debug = function() end,
  }

  before_each(function()
    log.errors = {}
  end)

  it("does nothing for an invalid buffer", function()
    local cut = views_diagnostic:new()
    cut.log = log
    cut.views_loader = {
      load = function()
        error("should not load views for an invalid buffer")
      end,
    }

    local ok = pcall(cut.handle, cut, 999999)

    assert.is_true(ok)
  end)

  it("does not raise when the php parser is unavailable", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local original = vim.treesitter.get_parser
    vim.treesitter.get_parser = function()
      error("no parser for 'php' language")
    end

    local cut = views_diagnostic:new()
    cut.log = log
    cut.views_loader = {
      load = function()
        return {}, nil
      end,
    }

    local ok = pcall(cut.handle, cut, bufnr)

    vim.treesitter.get_parser = original
    vim.api.nvim_buf_delete(bufnr, { force = true })

    assert.is_true(ok)
    assert.is_truthy(#log.errors > 0)
  end)
end)
