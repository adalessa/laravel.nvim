local nio = require("nio")

---@class laravel.services.eloquent_helper
local M = {}

-- ------------------------
-- Utilities
-- ------------------------

local function indent(str, level)
  level = level or 1
  return string.rep("    ", level) .. str
end

local function write_file(path, lines)
  local file = nio.file.open(path, "w")

  file.write(table.concat(lines, "\n"))
end

-- ------------------------
-- Config / paths (replace)
-- ------------------------

local function internal_vendor_path(filename)
  return "vendor/" .. filename
end

-- ------------------------
-- Types helpers
-- ------------------------

local function model_builder_type(class_name)
  return "\\Illuminate\\Database\\Eloquent\\Builder<" .. class_name .. ">|" .. class_name
end

-- ------------------------
-- Builder return type logic
-- ------------------------

local function get_builder_return_type(method, class_name)
  if method.return_type == nil then
    return "mixed"
  end

  if method.return_type == "never" then
    return "void"
  end

  if method.name == "when" or method.name == "unless" then
    return "mixed"
  end

  if method.return_type == "static" or method.return_type == "self" then
    return model_builder_type(class_name)
  end

  local returns_single_model = (
    method.name == "sole"
    or method.name == "find"
    or method.name == "first"
    or method.name == "firstOrFail"
  )

  local rt = method.return_type
  rt = rt:gsub("%$this", model_builder_type(class_name))
  rt = rt:gsub("\\TReturn", "mixed")
  rt = rt:gsub("TReturn", "mixed")
  rt = rt:gsub("\\TValue", returns_single_model and class_name or "mixed")
  rt = rt:gsub("TValue", returns_single_model and class_name or "mixed")
  rt = rt:gsub("object", returns_single_model and class_name or "mixed")

  if rt:find("mixed") then
    return "mixed"
  end

  return rt
end

-- ------------------------
-- Attribute types
-- ------------------------

local cast_mapping = {
  array = { "json", "encrypted:json", "encrypted:array" },
  int = { "timestamp" },
  mixed = { "attribute", "accessor", "encrypted" },
  object = { "encrypted:object" },
  string = { "hashed" },
  float = { "^decimal:%d+$" },
  ["\\Illuminate\\Support\\Carbon"] = { "date", "datetime" },
  ["\\Carbon\\CarbonImmutable"] = { "immutable_date", "immutable_datetime" },
  ["\\Illuminate\\Support\\Collection"] = { "encrypted:collection" },
}

local type_mapping = {
  bool = { "^boolean", "^tinyint" },
  float = { "real", "money", "double precision", "^double", "^decimal", "^numeric" },
  int = { "^serial", "^int", "^integer", "^bigint", "^smallint" },
  resource = { "bytea" },
  string = {
    "uuid", "json", "text", "varchar", "char", "timestamp", "date", "time"
  },
}

local function find_in_mapping(mapping, value)
  if not value then return nil end

  for new_type, matches in pairs(mapping) do
    for _, match in ipairs(matches) do
      if match:sub(1,1) == "^" then
        if value:match(match) then
          return new_type
        end
      elseif value == match then
        return new_type
      end
    end
  end

  return nil
end

local function get_actual_type(cast, db_type)
  local final =
    find_in_mapping(cast_mapping, cast)
    or (cast and cast:match("([^:]+)"))
    or find_in_mapping(type_mapping, db_type)
    or "mixed"

  if final:find("\\") and not final:match("^\\") then
    return "\\" .. final
  end

  return final
end

-- ------------------------
-- Attribute blocks
-- ------------------------

local function get_attribute_blocks(attr, class_name)
  local blocks = {}

  local prop_type =
    (attr.cast == "accessor" or attr.cast == "attribute")
    and "@property-read"
    or "@property"

  if not attr.documented then
    local t = get_actual_type(attr.cast, attr.type)
    if attr.nullable and t ~= "mixed" then
      t = t .. "|null"
    end
    table.insert(blocks, prop_type .. " " .. t .. " $" .. attr.name)
  end

  if attr.cast ~= "accessor" and attr.cast ~= "attribute" then
    table.insert(
      blocks,
      "@method static "
        .. model_builder_type(class_name)
        .. " where"
        .. attr.title_case
        .. "($value)"
    )
  end

  return blocks
end

-- ------------------------
-- Relations
-- ------------------------

local function get_relation_blocks(rel)
  local many = {
    BelongsToMany = true,
    HasMany = true,
    HasManyThrough = true,
    MorphMany = true,
    MorphToMany = true,
  }

  if many[rel.type] then
    return {
      "@property-read \\Illuminate\\Database\\Eloquent\\Collection<int, \\"
        .. rel.related
        .. "> $"
        .. rel.name,
      "@property-read int|null $" .. rel.name .. "_count",
    }
  end

  return {
    "@property-read \\" .. rel.related .. " $" .. rel.name,
  }
end

-- ------------------------
-- Scopes
-- ------------------------

local function get_scope_block(model, scope, class_name)
  local params = {}

  for i = 2, #scope.parameters do
    local p = scope.parameters[i]
    local part =
      (p.type or "")
      .. (p.is_variadic and " ..." or " ")
      .. (p.is_by_ref and "&" or "")
      .. "$" .. p.name
      .. (p.default and (" = " .. p.default) or "")
    table.insert(params, part)
  end

  return "@method static "
    .. model_builder_type(class_name)
    .. " "
    .. scope.name
    .. "(" .. table.concat(params, ", ") .. ")"
    .. " {@see " .. model.class .. "::" .. scope.method .. "()}"
end

-- ------------------------
-- Main block builder
-- ------------------------

local function get_blocks(model, class_name, builder_methods)
  local blocks = {}

  for _, attr in ipairs(model.attributes or {}) do
    for _, b in ipairs(get_attribute_blocks(attr, class_name)) do
      table.insert(blocks, " * " .. b)
    end
  end

  for _, method in ipairs({ "newModelQuery", "newQuery", "query" }) do
    table.insert(
      blocks,
      " * @method static "
        .. model_builder_type(class_name)
        .. " " .. method .. "()"
    )
  end

  for _, scope in ipairs(model.scopes or {}) do
    table.insert(blocks, " * " .. get_scope_block(model, scope, class_name))
  end

  for _, rel in ipairs(model.relations or {}) do
    for _, b in ipairs(get_relation_blocks(rel)) do
      table.insert(blocks, " * " .. b)
    end
  end

  for _, method in ipairs(builder_methods or {}) do
    table.insert(
      blocks,
      " * @method static "
        .. get_builder_return_type(method, class_name)
        .. " "
        .. method.name
        .. "(" .. table.concat(method.parameters or {}, ", ") .. ")"
    )
  end

  return blocks
end

-- ------------------------
-- Class docblock
-- ------------------------

local function class_to_docblock(block)
  local lines = {
    "/**",
    " * " .. block.namespace .. "\\" .. block.class_name,
    " *",
  }

  for _, b in ipairs(block.blocks) do
    table.insert(lines, b)
  end

  table.insert(lines, " * @mixin \\Illuminate\\Database\\Query\\Builder")
  table.insert(lines, " */")
  table.insert(
    lines,
    "class "
      .. block.class_name
      .. " extends "
      .. (block.extends or "\\Illuminate\\Database\\Eloquent\\Model")
  )
  table.insert(lines, "{")
  table.insert(lines, indent("//"))
  table.insert(lines, "}")

  for i, l in ipairs(lines) do
    lines[i] = indent(l)
  end

  return table.concat(lines, "\n")
end

-- ------------------------
-- Entry point
-- ------------------------

function M.write_eloquent_docblocks(models, builder_methods)
  local namespaces = {}

  for _, model in pairs(models) do
    local parts = vim.split(model.class, "\\")
    local class_name = table.remove(parts)
    local namespace = table.concat(parts, "\\")

    namespaces[namespace] = namespaces[namespace] or {}

    table.insert(namespaces[namespace], {
      namespace = namespace,
      class_name = class_name,
      blocks = get_blocks(model, class_name, builder_methods),
      extends = model.extends,
    })
  end

  local output = { "<?php" }

  for namespace, blocks in pairs(namespaces) do
    table.insert(output, "")
    table.insert(output, "namespace " .. namespace .. " {")

    for _, block in ipairs(blocks) do
      table.insert(output, "")
      table.insert(output, class_to_docblock(block))
    end

    table.insert(output, "}")
  end

  write_file(
    internal_vendor_path("_model_helpers.php"),
    output
  )
end

return M
