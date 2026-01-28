local Buffer = require("laravel.utils.buffer")
local mock = require("luassert.mock")
local stub = require("luassert.stub")

describe("Buffer", function()
  it("returns true for current valid buffer", function()
    local api = mock(vim.api, true)
    api.nvim_get_current_buf.returns(1)
    api.nvim_buf_is_valid.returns(true)
    api.nvim_buf_is_loaded.returns(true)

    local bufwin_id = stub(vim.fn, "bufwinid")
    bufwin_id.returns(-1)

    assert.is.True(Buffer.is_valid_buffer())
    mock.revert(api)
    bufwin_id:revert()
  end)

  it("returns true for explicitly provided valid buffer", function()
    local api = mock(vim.api, true)
    api.nvim_buf_is_valid.returns(true)
    api.nvim_buf_is_loaded.returns(true)

    local bufwin_id = stub(vim.fn, "bufwinid")
    bufwin_id.returns(-1)

    assert.is.True(Buffer.is_valid_buffer(1))
    mock.revert(api)
    bufwin_id:revert()
  end)

  it("returns false for invalid buffer number", function()
    local api = mock(vim.api, true)
    api.nvim_buf_is_valid.returns(false)
    api.nvim_buf_is_loaded.returns(false)

    assert.is.False(Buffer.is_valid_buffer(100))
    mock.revert(api)
  end)

  it("returns false for unloaded buffer", function()
    local api = mock(vim.api, true)
    api.nvim_buf_is_valid.returns(true)
    api.nvim_buf_is_loaded.returns(false)

    assert.is.False(Buffer.is_valid_buffer(100))
    mock.revert(api)
  end)

  it("returns false for buffer in popup window", function()
    local api = mock(vim.api, true)
    api.nvim_buf_is_valid.returns(true)
    api.nvim_buf_is_loaded.returns(true)

    local bufwin_id = stub(vim.fn, "bufwinid")
    bufwin_id.returns(100)

    local win_gettype = stub(vim.fn, "win_gettype")
    win_gettype.returns("popup")

    assert.is.False(Buffer.is_valid_buffer(1))
    mock.revert(api)
    bufwin_id:revert()
    win_gettype:revert()
  end)

  it("returns false for buffer in preview window", function()
    local api = mock(vim.api, true)
    api.nvim_buf_is_valid.returns(true)
    api.nvim_buf_is_loaded.returns(true)

    local bufwin_id = stub(vim.fn, "bufwinid")
    bufwin_id.returns(100)

    local win_gettype = stub(vim.fn, "win_gettype")
    win_gettype.returns("preview")

    assert.is.False(Buffer.is_valid_buffer(1))
    mock.revert(api)
    bufwin_id:revert()
    win_gettype:revert()
  end)

  it("returns true for buffer in normal window", function()
    local api = mock(vim.api, true)
    api.nvim_buf_is_valid.returns(true)
    api.nvim_buf_is_loaded.returns(true)

    local bufwin_id = stub(vim.fn, "bufwinid")
    bufwin_id.returns(100)

    local win_gettype = stub(vim.fn, "win_gettype")
    win_gettype.returns("")

    assert.is.True(Buffer.is_valid_buffer(1))
    mock.revert(api)
    bufwin_id:revert()
    win_gettype:revert()
  end)
end)
