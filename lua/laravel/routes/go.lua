local notify = require "laravel.notify"
local lsp = require "laravel._lsp"

return function(route)
  if route.action == "Closure" then
    if vim.tbl_contains(route.middlewares, "api") then
      vim.cmd "edit routes/api.php"
      vim.fn.search(route.uri:gsub("api", "") .. "")
    elseif vim.tbl_contains(route.middlewares, "web") then
      vim.cmd "edit routes/web.php"
      if route.uri == "/" then
        vim.fn.search "['\"]/['\"]"
      else
        vim.fn.search("/" .. route.uri)
      end
    else
      notify("Route", { msg = "Could not open the route location", level = "WARN" })
      return
    end

    vim.cmd "normal zt"
    return
  end

  local action = vim.fn.split(route.action, "@")
  lsp.go_to(action[1], action[2])
end
