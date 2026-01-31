local M = {}

local function getVariableDefinition(variableNode, bufnr)
  local varName = vim.treesitter.get_node_text(variableNode, bufnr)

  -- Helper: find the closest enclosing scope node
  local function find_scope(node)
    while node do
      local t = node:type()
      if
        t == "function_definition"
        or t == "method_declaration"
        or t == "closure_expression"
        or t == "anonymous_function"
      then
        return node
      end
      if t == "program" then
        return node -- file/global scope
      end
      node = node:parent()
    end
    return nil
  end

  local scope = find_scope(variableNode)
  if not scope then
    return nil
  end

  if scope:type() == "anonymous_function" then
    scope = scope:named_child(1)
  end

  -- Find all prior statements in current scope node
  -- Get all children of scope, find index of variableNode, iterate all earlier siblings
  local scope_children = {}
  for i = 0, scope:named_child_count() - 1 do
    table.insert(scope_children, scope:named_child(i))
  end

  -- Find the usage node's index in scope_children
  local usage_idx = nil
  for i, child in ipairs(scope_children) do
    if child == variableNode then
      usage_idx = i
      break
    end
  end

  if not usage_idx then
    -- This may occur if node is nested more deeply (such as part of an expression)
    usage_idx = #scope_children + 1 -- search all
  end

  -- Search all prior children
  for i = usage_idx - 1, 1, -1 do
    local sibling = scope_children[i]
    if sibling and sibling:type() == "expression_statement" then
      local expr = sibling:named_child(0)
      if expr and expr:type() == "assignment_expression" then
        local left = expr:named_child(0)
        if left and vim.treesitter.get_node_text(left, bufnr) == varName then
          local right = expr:named_child(1)
          if right then
            -- Recursively resolve, but only within current scope
            if right:type() == "variable_name" then
              return getVariableDefinition(right, bufnr)
            elseif right:type() == "scoped_call_expression" then
              return right:named_child(0)
            end
          end
        end
      end
    end
  end

  -- if not found and scope name contains the suffix scope should get the class name
  local scope_name = vim.treesitter.get_node_text(scope, bufnr)
  if scope_name:find("scope") then
    local class_node = scope:parent()
    while class_node do
      if class_node:type() == "class_declaration" then
        local class_name_node = class_node:field("name")[1]
        if class_name_node then
          return class_name_node
        end
      end
      class_node = class_node:parent()
    end
    if not class_node then
      return nil
    end

    return class_node:named_child(0)
  end

  return nil
end

local function getNode(bufnr)
  vim.treesitter.get_parser(bufnr, "php"):parse()
  local node = vim.treesitter.get_node()

  while node do
    if node:type() == "scoped_call_expression" then
      return node:named_child(0)
    elseif node:type() == "member_call_expression" then
      local variable = getVariableDefinition(node:named_child(0), bufnr)

      return variable
    end
    node = node:parent()
  end

  return nil
end

function M.resolve_model_at_cursor(bufnr)
  local node = getNode(bufnr)
  if not node then
    return nil
  end

  return vim.treesitter.get_node_text(node, bufnr)
end

return M
