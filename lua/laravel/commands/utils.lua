local M = {}

M.from_json = function(json)
  local cmds = {}

  if json == "" or json == nil or #json == 0 then
    return cmds
  end

  for _, cmd in ipairs(vim.fn.json_decode(json).commands) do
    if not cmd.hidden then
      table.insert(cmds, cmd)
    end
  end
  return cmds
end

return M
