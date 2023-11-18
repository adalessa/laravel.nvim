local M = {}

local completions = {
  view = require "laravel.null_ls.completion.view",
  route = require "laravel.null_ls.completion.route",
}

local function get_function_node(param_node)
  local node = param_node
  while node ~= nil and node.type(node) ~= "function_call_expression" do
    node = node:parent()
  end

  return node
end

function M.setup()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    error "Completition requires null ls"
  end

  null_ls.deregister "Laravel"

  local laravel = {
    name = "Laravel",
    method = null_ls.methods.COMPLETION,
    filetypes = { "php" },
    generator = {
      fn = function(params, done)
        local api = require "laravel.api"

        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        if node.type(node) == "member_call_expression" then
          local object_node = node:child(0)
          local row, col = vim.treesitter.get_node_range(object_node)
          local param = vim.lsp.util.make_position_params()
          param.position.line = row
          param.position.character = col

          vim.lsp.buf_request(0, "textDocument/typeDefinition", param, function(error, result)
            if error then
              return
            end
            local bufnr = vim.uri_to_bufnr(result.uri)

            vim.fn.bufload(bufnr)

            local query = vim.treesitter.query.parse(
              "php",
              [[ (namespace_definition name: (namespace_name) @namespace)
              (class_declaration name: (name) @class) ]]
            )
            local tree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
            local class = ""
            for id, in_node, _ in query:iter_captures(tree, bufnr, tree:start(), tree:end_()) do
              if query.captures[id] == "class" then
                class = class .. "\\" .. vim.treesitter.get_node_text(in_node, bufnr)
              elseif query.captures[id] == "namespace" then
                class = vim.treesitter.get_node_text(in_node, bufnr) .. class
              end
            end
            if class == "" then
              return
            end

            local related_res = api.sync("artisan", { "model:show", class, "--json" })
            if related_res.exit_code ~= 0 then
              return
            end

            local model_info = vim.fn.json_decode(related_res.stdout[1])
            if not model_info then
              return
            end

            local candidates = {}
            for _, attr in pairs(model_info.attributes) do
              table.insert(candidates, {
                label = attr.name,
                insertText = attr.name,
                kind = vim.lsp.protocol.CompletionItemKind["Property"],
                documentation = string.format("Database property %s. Type: %s", attr.name, attr.type),
              })
            end
            done { { items = candidates, isIncomplete = false } }
          end)

          -- print(vim.inspect(param))
          -- local object = vim.treesitter.get_node_text(node:child(0), params.bufnr, {})
          -- print("memeber property")
          -- to add support for model fields
          -- get the node of the property
          return
        else
          local func_node = get_function_node(node)
          if not func_node then
            return
          end

          if func_node:child_count() > 0 then
            local node_text = vim.treesitter.get_node_text(func_node:child(0), params.bufnr, {})

            -- encapsed_string initial node it means is in double quotes
            -- string initial node it means single quotes
            -- arguments does not have quotes
            local have_quotes = node.type(node) == "encapsed_string" or node.type(node) == "string"
            local completion = completions[node_text]
            if not completion then
              return
            end
            completion(done, not have_quotes)
          end
        end
      end,
      async = true,
    },
  }

  null_ls.register(laravel)
end

return M
