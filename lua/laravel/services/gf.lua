local Class = require("laravel.utils.class")

---@class laravel.services.gf
local gf = Class()

---@return false|TSNode, string|nil
function gf:cursorOnResource()
  local node = vim.treesitter.get_node()
  if not node then
    return false
  end

  if node:type() ~= "string_content" then
    return false
  end

  local parent = node:parent()
  while parent ~= nil do
    if parent:type() == "function_call_expression" or parent:type() == "scoped_call_expression" then
      break
    end

    parent = parent:parent()
  end

  if not parent then
    return false
  end

  if parent:type() == "function_call_expression" then
    local func_node = parent:child(0)
    if not func_node then
      return false
    end

    local func_name = vim.treesitter.get_node_text(func_node, 0, {})

    if vim.tbl_contains({ "route", "view", "config", "env", "inertia" }, func_name) then
      return node, func_name
    end

    return false
  end

  if parent:type() == "scoped_call_expression" then
    local scope_node = parent:named_child(0)
    local func_node = parent:named_child(1)
    if not scope_node or not func_node then
      return false
    end

    local scope_name = vim.treesitter.get_node_text(scope_node, 0, {})
    local func_name = vim.treesitter.get_node_text(func_node, 0, {})

    if scope_name == "Inertia" and func_name == "render" then
      return node, "inertia"
    end

    return false
  end

  return false
end

return gf
