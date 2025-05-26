local function get_args(func)
  local args = {}
  for i = 1, debug.getinfo(func).nparams, 1 do
    table.insert(args, debug.getlocal(func, i))
  end
  return args
end

local M = {}

function M:create(app, moduleName)
  return function(arguments)
    local ok, module = pcall(require, moduleName)
    if not ok then
      error("Could not load module " .. moduleName)
    end

    local constructor = module.new

    if not constructor then
      return module
    end

    local injects = module._inject or {}

    local args = get_args(constructor)

    -- local params = vim.tbl_extend("force", arguments or {})
    local params = arguments or {}

    if #args > 1 then
      table.remove(args, 1)
      local module_args = {}
      for k, v in pairs(args) do
        if params[v] then
          module_args[k] = params[v]
        elseif injects[v] then
          module_args[k] = app:make(injects[v])
        else
          module_args[k] = app:make(v)
        end
      end

      return module:new(unpack(module_args))
    elseif not vim.tbl_isempty(injects) then
      local module_args = {}
      for _, v in pairs(injects) do
        if params[v] then
          table.insert(module_args, params[v])
        else
          table.insert(module_args, app:make(v))
        end
      end

      return module:new(unpack(module_args))
    end

    return module:new()
  end
end

function M:createConcrete(app, concrete)
  local concreteType = type(concrete)
  if concreteType == "string" then
    return M:create(app, concrete)
  elseif concreteType == "table" then
    return function()
      return concrete
    end
  elseif concreteType == "function" then
    return concrete
  else
    Snacks.debug.backtrace()
    error("Concrete should be a string, table or function " .. type(concrete) .. " given")
  end
end

return M
