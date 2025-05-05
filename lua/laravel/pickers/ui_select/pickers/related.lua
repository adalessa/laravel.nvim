local actions = require("laravel.pickers.common.actions")

---@class LaravelUISelectRelatedPicker
---@field class LaravelClassService
---@field api laravel.api
local related_picker = {}

local build_relation = function(info, relation_type)
  if next(info) == nil then
    return nil
  end
  if relation_type == "observers" and info["observer"][2] ~= nil then
    return {
      class = info["observer"][2],
      type = relation_type,
      extra_information = info["event"],
    }
  elseif relation_type == "relations" then
    return {
      class = info["related"],
      type = relation_type,
      extra_information = info["type"] .. " " .. info["name"],
    }
  elseif relation_type == "policy" then
    return {
      class = info[1],
      type = relation_type,
      extra_information = "",
    }
  end
  return nil
end

local types = { "observers", "relations", "policy" }

function related_picker:new(class, api)
  local instance = {
    class = class,
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related_picker:run(opts)
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()

  return self.class
    :get(bufnr)
    :thenCall(function(class)
      return self.api:send("artisan", { "model:show", class.fqn, "--json" })
    end)
    :thenCall(function(response)
      local model_info = response:json()

      local relations = {}
      for _, relation_type in ipairs(types) do
        if model_info[relation_type] and #model_info[relation_type] > 0 then
          if type(model_info[relation_type]) == "table" and model_info[relation_type][1] then
            for _, info in ipairs(model_info[relation_type]) do
              local relation = build_relation(info, relation_type)
              if relation ~= nil then
                table.insert(relations, relation)
              end
            end
          else
            local relation = build_relation({ model_info[relation_type] }, relation_type)
            if relation ~= nil then
              table.insert(relations, relation)
            end
          end
        end
      end

      vim.ui.select(relations, {
        prompt = "Related Files",
        format_item = function(relation)
          return relation.class .. " " .. relation.extra_information
        end,
        kind = "make",
      }, function(resource)
        if resource ~= nil then
          actions.open_relation(resource)
        end
      end)
    end)
end

return related_picker
