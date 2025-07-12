---@class laravel.actions.action
---@field check async fun(self, bufnr: number): (boolean, laravel.error)
---@field format async fun(self, bufnr: number): (string, laravel.error)
---@field run fun(self, bufnr: number)

return {
  "laravel.actions.go_to_migration",
  "laravel.actions.open_env",
  -- "laravel.actions.add_relation",
}
