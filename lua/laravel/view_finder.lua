local viewService = require "laravel.services.view_service"
local run = require "laravel.run"

local M = {}

-- Should be use from blades to find where is being use
function M.go_to_usage()
  viewService:usage(vim.uri_to_fname(vim.uri_from_bufnr(vim.api.nvim_get_current_buf())), function(usages)
    if #usages == 0 then
      vim.notify("No usage of this view found", vim.log.levels.WARN)
    elseif #usages == 1 then
      vim.cmd("edit " .. usages[1].file)
    else
      vim.ui.select(
        vim.fn.sort(vim.tbl_map(function(item)
          return item.file
        end, usages)),
        { prompt = "File: " },
        function(value)
          if not value then
            return
          end
          vim.cmd("edit " .. value)
        end
      )
    end
  end, function(errMessage)
    vim.notify(errMessage, vim.log.levels.ERROR, {})
  end)
end

-- should be use in files to find the views
function M.go_to_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    error("Could not retrive syntax tree", vim.log.levels.ERROR)
  end

  local query = vim.treesitter.query.get("php", "laravel_views")

  if not query then
    error("Could not get treesitter query", vim.log.levels.ERROR)
  end

  local founds = {}
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      local view = vim.treesitter.get_node_text(node, bufnr):gsub("'", "")
      founds[view] = true
    end
  end

  founds = vim.tbl_keys(founds)

  if #founds == 0 then
    vim.notify("No usage of this view found", vim.log.levels.WARN)
    return
  end

  ---@param viewName string
  local open = function(viewName)
    viewService:find(viewName, function(view)
      vim.cmd("edit " .. view.path)
    end, function(errMessage)
      if errMessage == "view not found" then
        if vim.fn.confirm("View " .. viewName .. " does not exists, Should create it?", "&Yes\n&No") == 1 then
          run("artisan", { "make:view", viewName })
        end
      end
    end)
  end

  if #founds > 1 then
    vim.ui.select(vim.fn.sort(founds), { prompt = "Which view:" }, function(selected)
      if not selected then
        return
      end
      open(selected)
    end)
    return
  end
  open(founds[1])
end

function M.auto()
  local ft = vim.o.filetype
  if ft == "php" then
    return M.go_to_definition()
  elseif ft == "blade" then
    return M.go_to_usage()
  end
end

return M
