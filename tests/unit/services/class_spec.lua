local class_service = require("laravel.services.class")

describe("class service parser guard", function()
  local function with_buffer(callback)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "<?php", "class Example {}" })

    local ok, result, err = pcall(callback, bufnr)

    vim.api.nvim_buf_delete(bufnr, { force = true })
    assert.is_true(ok)
    return result, err
  end

  local function with_parser(stub, callback)
    local original = vim.treesitter.get_parser
    vim.treesitter.get_parser = stub

    local ok, result, err = pcall(callback)
    vim.treesitter.get_parser = original

    assert.is_true(ok)
    return result, err
  end

  it("returns an error when the php parser raises", function()
    local result, err = with_buffer(function(bufnr)
      return with_parser(function()
        error("no parser for 'php' language")
      end, function()
        return class_service:get(bufnr)
      end)
    end)

    assert.same({}, result)
    assert.is_not_nil(err)
    assert.equals("Could not get the parser", err.message)
  end)

  it("returns an error when the buffer is invalid", function()
    local ok, result, err = pcall(class_service.get, class_service, 999999)

    assert.is_true(ok)
    assert.same({}, result)
    assert.is_not_nil(err)
  end)

  it("returns an error when views has no php parser", function()
    local result, err = with_buffer(function(bufnr)
      return with_parser(function()
        return nil
      end, function()
        return class_service:views(bufnr)
      end)
    end)

    assert.same({}, result)
    assert.is_not_nil(err)
    assert.equals("Could not get the parser", err.message)
  end)
end)
