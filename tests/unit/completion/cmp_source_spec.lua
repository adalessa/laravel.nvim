local nio = require("nio")
local a = nio.tests

local function fake_completion(overrides)
  return vim.tbl_extend("force", {
    is_enabled = function()
      return true
    end,
    from_cmp = function(params)
      return {
        bufnr = params.context.bufnr,
        filetype = params.context.filetype,
        line = params.context.cursor_line,
        before = params.context.cursor_before_line,
      }
    end,
    resolve = function()
      return {}
    end,
    trigger_characters = function()
      return {}
    end,
  }, overrides or {})
end

local function params()
  return {
    context = {
      bufnr = 1,
      filetype = "php",
      cursor_line = "return view('welcome')",
      cursor_before_line = "return view('we",
    },
  }
end

describe("nvim-cmp completion source", function()
  it("receives the dispatcher when the container factory constructs it", function()
    local factory = require("laravel.core.factory")
    local source = factory.create({}, "laravel.extensions.completion.source")(nil)

    assert.is_true(source.completion ~= source)
    assert.is_function(source.completion.is_enabled)
  end)

  it("uses the shared trigger characters", function()
    local source = require("laravel.extensions.completion.source").new(fake_completion({
      trigger_characters = function()
        return { "'", '"' }
      end,
    }))

    assert.same({ "'", '"' }, source:get_trigger_characters())
  end)

  a.it("returns the dispatcher items to nvim-cmp", function()
    local resolved
    local source = require("laravel.extensions.completion.source").new(fake_completion({
      resolve = function(ctx)
        resolved = ctx
        return { { label = "welcome", insertText = "welcome" } }
      end,
    }))

    local responses = {}
    source:complete(params(), function(response)
      table.insert(responses, response)
    end)
    nio.sleep(0)

    assert.same(1, #responses)
    assert.same({ { label = "welcome", insertText = "welcome" } }, responses[1].items)
    assert.is_false(responses[1].isIncomplete)
    assert.same("return view('we", resolved.before)
  end)

  a.it("answers immediately for unsupported filetypes and never dispatches", function()
    local dispatched = false
    local source = require("laravel.extensions.completion.source").new(fake_completion({
      is_enabled = function()
        return false
      end,
      resolve = function()
        dispatched = true
        return { { label = "should not appear" } }
      end,
    }))

    local responses = {}
    source:complete(params(), function(response)
      table.insert(responses, response)
    end)
    nio.sleep(0)

    assert.same(1, #responses)
    assert.same({}, responses[1].items)
    assert.is_false(dispatched)
  end)

  a.it("answers once with no items when the dispatcher raises", function()
    local source = require("laravel.extensions.completion.source").new(fake_completion({
      resolve = function()
        error("boom")
      end,
    }))

    local responses = {}
    source:complete(params(), function(response)
      table.insert(responses, response)
    end)
    nio.sleep(0)

    assert.same(1, #responses)
    assert.same({}, responses[1].items)
  end)
end)
