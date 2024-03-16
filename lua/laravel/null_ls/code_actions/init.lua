local null_ls = require "null-ls"

local M = {}

M.name = "Laravel_CodeAction"

function M.setup()
  null_ls.deregister(M.name)
  null_ls.register {
    name = M.name,
    method = null_ls.methods.CODE_ACTION,
    filetypes = { "php" },
    generator = {
      fn = function(context)
        local fname = vim.uri_to_fname(context.lsp_params.textDocument.uri)
        local className = vim.fs.basename(fname):match "(.+)%..+"

        local actions = {
          {
            title = "Make",
            action = function()
              require("telescope").extensions.laravel.make()
            end,
          },
        }

        for dir in vim.fs.parents(fname) do
          if vim.fs.basename(dir) == "Models" then
            table.insert(actions, {
              title = "Related",
              action = function()
                require("telescope").extensions.laravel.related { class = className }
              end,
            })
            table.insert(actions, {
              title = "Show DB Info",
              action = function()
                require "laravel.run"("artisan", { "model:show", className }, {})
              end,
            })
            break
          end
        end

        -- check view diagnostic
        local pos = context.lsp_params.range.start
        for _, diag in pairs(vim.diagnostic.get(context.bufnr)) do
          if
            diag.lnum == pos.line
            and pos.character > diag.col
            and pos.character < diag.end_col
            and diag.source == "laravel.nvim"
          then
            table.insert(actions, {
              title = "Create view",
              action = function()
                require "laravel.run"("artisan", { "make:view", diag.user_data.view })
              end,
            })
          end
        end

        -- check pending migrations
        local response = require("laravel.api").sync("artisan", { "migrate:status", "--pending" })
        if response:content()[2] ~= "   INFO  No pending migrations.  " then
          table.insert(actions, {
            title = "Run Pending migrations",
            action = function()
              require "laravel.run"("artisan", { "migrate" })
            end,
          })
        end

        return actions
      end,
    },
  }
end

return M
