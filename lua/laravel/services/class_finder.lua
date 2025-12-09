local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

local class_finder = Class({
  tinker = "laravel.services.tinker",
  path = "laravel.services.path",
})

---@param text string
---@return {file: string, line:number}, laravel.error
function class_finder:find(text)
  if not text or text == "" then
    return {}, Error:new("No class name provided")
  end

  local escaped_text = text:gsub("\\", "\\\\")

  local result, err = self.tinker:json(string.format(
    [[
    $text = "%s";
    if (str_contains($text, '@')) {
        [$class, $method] = explode('@', $text);
        $reflectionMethod = new ReflectionMethod($class, $method);
        echo json_encode([
            'file' => $reflectionMethod->getFileName(),
            'line' => $reflectionMethod->getStartLine(),
        ]);
    } else {
        $reflectionClass = new ReflectionClass($text);
        echo json_encode([
            'file' => $reflectionClass->getFileName(),
            'line' => $reflectionClass->getStartLine(),
        ]);
    }
  ]],
    escaped_text
  ))

  if err then
    return {}, err
  end
  if result.file then
    result.file = self.path:handle(vim.trim(result.file))
  end

  return result or {}, nil
end

return class_finder
