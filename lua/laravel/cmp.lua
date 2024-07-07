local app = require("laravel.app")

local source = {}

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  return app("env"):is_active()
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
  return "laravel"
end

function source:get_keyword_pattern()
  return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
  return { '"', "'" }
end

function source:complete(params, callback)
  local text = params.context.cursor_before_line

  -- FIX: add other ways to call the view not just view() View::make() Route::view()

  -- TODO: handle not just views - config - route
  -- add tests to check that

  -- only advance if the text contains the call to `view('`
  if text:match("view%([%'|%\"]") then
    app("views"):get(function(views)
      callback({
        items = views
            :map(function(view)
              return {
                label = string.format("%s (view)", view.name),
                insertText = view.name,
                kind = vim.lsp.protocol.CompletionItemKind["Value"],
                documentation = view.path,
              }
            end)
            :totable(),
        isIncomplete = false,
      })
    end)

    return
  end

  if text:match("config%([%'|%\"]") then
    app("configs"):get(function(configs)
      callback({
        items = configs
            :map(function(config)
              return {
                label = string.format("%s (config)", config),
                insertText = config,
                kind = vim.lsp.protocol.CompletionItemKind["Value"],
                documentation = config,
              }
            end)
            :totable(),
        isIncomplete = false,
      })
    end)

    return
  end

  callback({ items = {} })
end

return source
