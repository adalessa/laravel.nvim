local M = {}

local function format_command_text(command)
  local parts = vim.split(command, ":")
  local cmd = table.remove(parts, #parts)

  local out = {}
  for _, part in ipairs(parts) do
    table.insert(out, { part, "@enum" })
    table.insert(out, { ":", "@string" })
  end
  table.insert(out, { cmd, "@keyword" })

  return out
end

M.command = function(item, _)
  return format_command_text(item.value.name)
end

M.composer_command = function(item, _)
  return format_command_text(item.value.name)
end

M.user_command = function(item, _)
  return {
    { string.format("[%s]", item.value.executable), "@string" },
    { " ", "@string" },
    { item.value.name, "@keyword" },
  }
end

M.history = function(item, _)
  return {
    { item.value.name, "@keyword" },
    { " ", "@string" },
    { table.concat(item.value.args, " "), "@string" },
  }
end

M.related = function(item, _)
  return {
    { item.value.class, "@string" },
    { " ", "@string" },
    { item.value.type, "@keyword" },
    { " ", "@string" },
    { item.value.extra_information or "", "@string" },
  }
end

M.route = function(item, _)
  return {
    { vim.iter(item.value.methods):join("|"), "@string" },
    { " ", "@string" },
    { item.value.name, "@keyword" },
    { " ", "@string" },
    { item.value.uri, "@string" },
  }
end

return M
