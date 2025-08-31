local M = {}

function M:validate()
  local plenary_ok, _ = pcall(require, "plenary")
  local nio_ok, _ = pcall(require, "nio")
  local nui_ok, _ = pcall(require, "nui.popup")

  if not plenary_ok or not nio_ok or not nui_ok then
    local errors = {}
    if not plenary_ok then
      table.insert(errors, "Plenary is required for Laravel, please install it")
    end
    if not nio_ok then
      table.insert(errors, "Nio is required for Laravel, please install it")
    end
    if not nui_ok then
      table.insert(errors, "Nui is required for Laravel, please install it")
    end

    error(table.concat(errors, "\n"))
  end
end

return M
