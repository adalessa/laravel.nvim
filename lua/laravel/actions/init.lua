---@class laravel.actions.action
---@field check async fun(self, bufnr: number): (boolean, string?)
---@field format async fun(self, bufnr: number): (string, string?)
---@field run async fun(self, bufnr: number)

return {
  "laravel.actions.go_to_migration",
  "laravel.actions.open_env",
  -- "laravel.actions.add_relation",
}
