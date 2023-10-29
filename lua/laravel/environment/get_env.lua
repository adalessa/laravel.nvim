return function(var)
  local envVal
  if vim.api.nvim_call_function("exists", { "*DotenvGet" }) == 1 then
    envVal = vim.api.nvim_call_function("DotenvGet", { var })
  else
    envVal = vim.api.nvim_call_function("eval", { "$" .. var })
  end

  if envVal == "" then
    return nil
  end

  return envVal
end
