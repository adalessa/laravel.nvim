local M = {}

function M.gen_from_artisan(commands)
  local string_names = vim
    .iter(commands)
    :map(function(command)
      return command.name
    end)
    :totable()

  local command_hash = {}
  for _, command in ipairs(commands) do
    command_hash[command.name] = command
  end

  return string_names, command_hash
end

function M.gen_from_commands(commands)
  local string_names = vim
    .iter(commands)
    :map(function(command)
      return command.display
    end)
    :totable()

  local command_hash = {}
  for _, command in ipairs(commands) do
    command_hash[command.display] = command
  end

  return string_names, command_hash
end

function M.gen_from_history(history)
  local string_names = vim
    .iter(history)
    :map(function(command)
      return command.name
    end)
    :totable()

  local history_hash = {}
  for _, command in ipairs(history) do
    history_hash[command.name] = command
  end

  return string_names, history_hash
end

function M.gen_from_related(relations)
  local string_names = vim
    .iter(relations)
    :map(function(relation)
      return relation.class .. " " .. relation.type .. " " .. relation.extra_information
    end)
    :totable()

  local relation_hash = {}
  for _, relation in ipairs(relations) do
    relation_hash[relation.class .. " " .. relation.type .. " " .. relation.extra_information] = relation
  end

  return string_names, relation_hash
end

function M.gen_from_routes(routes)
  local string_names = vim
    .iter(routes)
    :map(function(route)
      return route.uri .. " " .. (route.name or "")
    end)
    :totable()

  local route_hash = {}
  for _, route in ipairs(routes) do
    route_hash[route.uri .. " " .. (route.name or "")] = route
  end

  return string_names, route_hash
end

return M
