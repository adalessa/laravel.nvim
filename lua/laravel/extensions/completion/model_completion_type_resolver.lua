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

---@param method_node TSNode
---@param before string
local function get_param_position(method_node, before)
  local param_pos = nil
  local _, method_end = method_node:end_()
  local params_str = before:sub(method_end + 1)

  local _, count = params_str:find("%(")

  if count then
    local param_substr = params_str:sub(count + 1)
    if param_substr == "" then
      return 0
    end
    local commas = vim.fn.split(param_substr, ",")
    param_pos = #commas - 1
  end

  return param_pos
end

---@return {model: string, method: string, param_position: integer}|nil
local function resolve_by_ts(bufnr, before)
  vim.treesitter.get_parser(bufnr, "php"):parse()
  local node = vim.treesitter.get_node()

  while node do
    if node:type() == "scoped_call_expression" then
      local param_pos = nil
      -- get the number of , before the first ( after the method node
      local method_node = node:named_child(1)
      local model_node = node:named_child(0)
      if not method_node or not model_node then
        return nil
      end

      return {
        model = vim.treesitter.get_node_text(model_node, bufnr),
        method = vim.treesitter.get_node_text(method_node, bufnr),
        param_position = get_param_position(method_node, before),
      }
    elseif node:type() == "member_call_expression" then
      local member_node = node:named_child(0)
      local method_node = node:named_child(1)
      if not method_node or not member_node then
        return nil
      end
      if member_node:type() == "variable_name" then
        local definition_node = getVariableDefinition(member_node, bufnr)
        if not definition_node then
          return nil
        end

        return {
          model = vim.treesitter.get_node_text(definition_node, bufnr),
          method = vim.treesitter.get_node_text(method_node, bufnr),
          param_position = get_param_position(method_node, before),
        }
      end
      if member_node:type() == "scoped_call_expression" then
        local model_node = member_node:named_child(0)
        if not model_node then
          return nil
        end

        return {
          model = vim.treesitter.get_node_text(model_node, bufnr),
          method = vim.treesitter.get_node_text(method_node, bufnr),
          param_position = get_param_position(method_node, before),
        }
      end
    end
    node = node:parent()
  end

  return nil
end

---@param bufnr integer
---@param before string
---@return {model: string, method: string, param_position: integer}|nil
local function resolve_by_text(bufnr, before, cursor_line)
  local text = before
  local pieces = {}
  local i = 1
  while true do
    -- Look for ->methodName( from the rightmost position
    local last_scoped = text:find("->[%w_]+%s*%(")
    local last_static = text:find("[%w_\\]+::[%w_]+%s*%(")
    if last_scoped and (not last_static or last_scoped > last_static) then
      local _, _, method = text:find("->([%w_]+)%s*%(?$")
      if not method then
        -- Try any ->methodName(
        local s, e, m = text:find("->([%w_]+)%s*%(")
        method = m
        if not method then
          break
        end
      end
      table.insert(pieces, 1, {type = "scoped", method = method})
      -- Remove up to and including '->method('
      text = text:gsub("->" .. method .. "%s*%(", "", 1)
    elseif last_static then
      local _, _, class, method = text:find("([%w_\\]+)::([%w_]+)%s*%(?$")
      if not class or not method then
        -- Try matching from the left
        local s, e, c, m = text:find("([%w_\\]+)::([%w_]+)%s*%(")
        class, method = c, m
        if not class or not method then
          break
        end
      end
      table.insert(pieces, 1, {type = "static", class = class, method = method})
      -- Remove up to and including 'Class::method('
      text = text:gsub(class .. "::" .. method .. "%s*%(", "", 1)
      break -- leftmost static call found, stop
    else
      break
    end
  end
  if #pieces > 0 then
    -- Rightmost method is the last piece
    local last_piece = pieces[#pieces]
    local first_piece = pieces[1]
    local model = nil
    if first_piece.type == "static" then
      model = first_piece.class
    end
    for j=#pieces,1,-1 do
      if pieces[j].type == "static" then
        model = pieces[j].class
        break
      end
    end
    local method = last_piece.method
    -- Calculate param_position: count commas after the last opening paren and before the unmatched end
    local _, last_paren = before:find("%(", 1, true)
    local params = ""
    if last_paren then
      params = before:sub(last_paren + 1)
    end
    local param_position
    if params == "" then
      param_position = 0
    else
      local n = 0
      for _ in params:gmatch(",") do n = n + 1 end
      param_position = n
    end
    -- If model is still nil and text is a $var->method( pattern, try to resolve from prior buffer lines
    if not model and type(cursor_line) == 'number' then
      local var = nil
      local match_var = before:match("%$(%w+)%-%>%w+%s*%(")
      if match_var then
        var = match_var
        -- Look upwards for assignment
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, cursor_line-1, false)
        for i = #lines,1,-1 do
          local line = lines[i]
          local class = line:match("%$"..var.."%s*=%s*([%w_\\]+)::[%w_]+%s*%(")
          if class then
            model = class
            break
          end
        end
      end
    end
    return {
      model = model,
      method = method,
      param_position = param_position
    }
  end
  return nil
end



---@return {model: string, method: string, param_position: integer}|nil
function M.resolve_model_at_cursor(bufnr, cursor_before_line)
  vim.treesitter.get_parser(bufnr, "php"):parse()
  local node = vim.treesitter.get_node()

  if not node then
    return nil
  end

  if node:type() == "ERROR" then
    -- Try to get current cursor line if available (for resolve_by_text model rescue)
    local cur_line = nil
    local ok, row = pcall(function()
      local pos = vim.api.nvim_win_get_cursor(0)
      return pos[1]
    end)
    if ok and type(row) == "number" then
      cur_line = row
    end
    return resolve_by_text(bufnr, cursor_before_line, cur_line)
  end

  return resolve_by_ts(bufnr, cursor_before_line)
end

return M
