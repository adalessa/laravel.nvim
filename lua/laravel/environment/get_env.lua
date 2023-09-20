return function(var)
  local envVal
  if vim.fn.exists "*DotenvGet" == 1 then
    envVal = vim.fn.DotenvGet(var)
  else
    envVal = vim.fn.eval("$" .. var)
  end

  if envVal == "" then
    return nil
  end

  return envVal
end
