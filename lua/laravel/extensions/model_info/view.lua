---@class LaravelModelInfoView
local model_info_view = {}

function model_info_view:get(model)
  local virt_lines = {
    { { "[", "comment" } },
    { { " Database: ", "comment" },  { model.database, "@enum" } },
    { { " Table: ", "comment" },     { model.table, "@enum" } },
    { { " Attributes: ", "comment" } },
  }

  for _, attribute in ipairs(model.attributes) do
    table.insert(virt_lines, {
      { "   " .. attribute.name,                                                     "@enum" },
      { " " .. (attribute.type or "null") .. (attribute.nullable and "|null" or ""), "comment" },
      attribute.cast and { " -> " .. attribute.cast, "@enum" } or nil,
    })
  end

  table.insert(virt_lines, { { "]", "comment" } })

  return {
    virt_lines = virt_lines,
    virt_lines_above = true,
  }
end

return model_info_view
