local function split_string(input)
  local group, command = input:match("([^:]+):([^:]+)")
  if not group then
    command = input
  end
  return group, command
end

local M = {}

local function format_command_text(command)
  local group, cmd = split_string(command)
  local out = {}
  if group then
    table.insert(out, { group, "@string" })
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
    { item.value.class_name, "@string" },
    { item.value.type, "@keyword" },
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
