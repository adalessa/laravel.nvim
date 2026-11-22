local nio = require("nio")
local a = nio.tests

local function fake_completion(overrides)
  return vim.tbl_extend("force", {
    is_enabled = function()
      return true
    end,
    from_blink = function(ctx)
      return {
        bufnr = ctx.bufnr,
        filetype = "php",
        line = ctx.line,
        before = ctx.line:sub(1, ctx.cursor[2]),
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

local function context()
  return {
    bufnr = 1,
    line = "return view('welcome')",
    cursor = { 1, 15 },
  }
end

describe("blink.cmp completion source", function()
  it("is enabled only when the dispatcher says so for the current filetype", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.bo[bufnr].filetype = "blade"

    local seen
    local source = require("laravel.extensions.completion.blink").new({
      completion = fake_completion({
        is_enabled = function(filetype)
          seen = filetype
          return true
        end,
      }),
    })

    assert.is_true(source:enabled())
    assert.same("blade", seen)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("uses the shared trigger characters", function()
    local source = require("laravel.extensions.completion.blink").new({
      completion = fake_completion({
        trigger_characters = function()
          return { "'", '"', "(" }
        end,
      }),
    })

    assert.same({ "'", '"', "(" }, source:get_trigger_characters())
  end)

  a.it("returns blink-shaped completions from the dispatcher", function()
    local resolved
    local source = require("laravel.extensions.completion.blink").new({
      completion = fake_completion({
        resolve = function(ctx)
          resolved = ctx
          return { { label = "welcome", insertText = "welcome" } }
        end,
      }),
    })

    local responses = {}
    source:get_completions(context(), function(response)
      table.insert(responses, response)
    end)
    nio.sleep(0)

    assert.same(1, #responses)
    assert.same({ { label = "welcome", insertText = "welcome" } }, responses[1].items)
    assert.is_false(responses[1].is_incomplete_backward)
    assert.is_false(responses[1].is_incomplete_forward)
    assert.same("return view('we", resolved.before)
  end)

  a.it("answers immediately for unsupported filetypes and never dispatches", function()
    local dispatched = false
    local source = require("laravel.extensions.completion.blink").new({
      completion = fake_completion({
        is_enabled = function()
          return false
        end,
        resolve = function()
          dispatched = true
          return { { label = "should not appear" } }
        end,
      }),
    })

    local responses = {}
    source:get_completions(context(), function(response)
      table.insert(responses, response)
    end)
    nio.sleep(0)

    assert.same(1, #responses)
    assert.same({}, responses[1].items)
    assert.is_false(dispatched)
  end)

  a.it("does not call back after the request is cancelled", function()
    local source = require("laravel.extensions.completion.blink").new({
      completion = fake_completion({
        resolve = function()
          nio.sleep(5)
          return { { label = "late" } }
        end,
      }),
    })

    local responses = {}
    local cancel = source:get_completions(context(), function(response)
      table.insert(responses, response)
    end)
    cancel()
    nio.sleep(10)

    assert.same(0, #responses)
  end)

  a.it("answers once with no items when the dispatcher raises", function()
    local source = require("laravel.extensions.completion.blink").new({
      completion = fake_completion({
        resolve = function()
          error("boom")
        end,
      }),
    })

    local responses = {}
    source:get_completions(context(), function(response)
      table.insert(responses, response)
    end)
    nio.sleep(0)

    assert.same(1, #responses)
    assert.same({}, responses[1].items)
  end)
end)
