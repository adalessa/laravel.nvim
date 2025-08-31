local mcp = {}

function mcp:boot()
  local status, _ = pcall(require, "mcphub")
  if not status then
    return
  end
  require("laravel.extensions.mcp.artisan_tool")
  require("laravel.extensions.mcp.composer_tool")
end

return mcp
