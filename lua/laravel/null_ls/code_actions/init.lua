local M = {}

function M.setup()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    vim.notify(
      "Null ls feature is enable but null ls is not installed please install to have this feature enable",
      vim.log.levels.ERROR
    )
    return
  end

  null_ls.deregister "LaravelCodeAction"
  local laravel = {
    name = "LaravelCodeAction",
    method = null_ls.methods.CODE_ACTION,
    filetypes = { "php" },
    generator = {
      fn = function(context)
        local fname = vim.uri_to_fname(context.lsp_params.textDocument.uri)
        local className = vim.fs.basename(fname):match "(.+)%..+"

        return {
          {
            title = "Show Related",
            action = function()
              require("telescope").extensions.laravel.related { class = className }
            end,
          },
          {
            title = "Make Menu",
            action = function()
              require("telescope").extensions.laravel.make()
            end,
          },
          {
            title = "Show Model Info",
            action = function()
              require "laravel.run"("artisan", { "model:show", className }, {})
            end,
          },
        }
      end,
    },
  }

  null_ls.register(laravel)
end

return M
