local args = _G.arg or {}

local function option(name)
  for index, value in ipairs(args) do
    if value == name then
      return args[index + 1]
    end
  end
end

local strict = false
for _, value in ipairs(args) do
  if value == "--strict" then
    strict = true
  end
end

local manifest_path = option("--manifest") or "tests/coverage_manifest.lua"
local tests_root = option("--tests-root") or "tests"

local function absolute(path)
  return vim.fn.fnamemodify(path, ":p")
end

local loaded, manifest = pcall(dofile, manifest_path)
if not loaded then
  io.stderr:write("coverage-check: cannot load manifest " .. manifest_path .. ": " .. tostring(manifest) .. "\n")
  os.exit(2)
end

if type(manifest) ~= "table" then
  io.stderr:write("coverage-check: manifest must return a table\n")
  os.exit(2)
end

local errors = {}
local listed = {}
local covered = 0
local pending = 0

for _, area in ipairs(manifest) do
  local name = area.name or "(unnamed)"
  local status = area.status
  local specs = area.specs or {}

  if status ~= "covered" and status ~= "pending" then
    table.insert(errors, ("%s: invalid status %q"):format(name, tostring(status)))
  elseif status == "covered" then
    covered = covered + 1
    if #specs == 0 then
      table.insert(errors, name .. ": covered area has no specs")
    end
  else
    pending = pending + 1
    if #specs > 0 then
      table.insert(errors, name .. ": pending area must not list specs")
    end
  end

  for _, spec in ipairs(specs) do
    local path = absolute(spec)
    listed[path] = true
    if vim.fn.filereadable(path) == 0 then
      table.insert(errors, ("%s: spec not found: %s"):format(name, spec))
    end
  end
end

local discovered = vim.fs.find(function(filename)
  return filename:match("_spec%.lua$") ~= nil
end, { path = tests_root, type = "file" })

for _, spec in ipairs(discovered) do
  local path = absolute(spec)
  if not listed[path] then
    table.insert(errors, "spec is not listed in the manifest: " .. vim.fn.fnamemodify(path, ":."))
  end
end

if strict and pending > 0 then
  table.insert(errors, ("%d feature areas are still pending (--strict)"):format(pending))
end

print(("coverage-check: %d covered, %d pending"):format(covered, pending))
for _, message in ipairs(errors) do
  io.stderr:write("coverage-check: " .. message .. "\n")
end

io.stdout:flush()
io.stderr:flush()
os.exit(#errors == 0 and 0 or 1)
