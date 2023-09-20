local lsp_utils = require "laravel._lsp.utils"
local notify = require("laravel.notify")

---@param client table
---@param is_new_instance boolean
---@param full_class string
---@param method string|nil
---@return string|nil
local function go_to(client, is_new_instance, full_class, method)
  local class_parts = vim.split(full_class, "\\")
  local class = class_parts[#class_parts]

  local resp = client.request_sync("workspace/symbol", { query = class }, nil)

  local class_location = nil
  for _, location in pairs(resp.result) do
    if
      location.location
      and location.containerName .. "\\" .. location.name == full_class
      and vim.lsp.util._get_symbol_kind_name(location.kind) == "Class"
    then
      class_location = location
      break
    end
  end

  if class_location == nil then
    notify("Route Open", { msg = "Could not find class for : " .. full_class, level = "WARN" })
    if is_new_instance then
      vim.lsp.stop_client(client.id)
    end
    return
  end

  lsp_utils.open_filename(vim.uri_to_fname(class_location.location.uri))

  local params = vim.lsp.util.make_position_params(0)
  if is_new_instance then
    vim.lsp.buf_attach_client(0, client.id)
  end

  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(method_err, method_server_result, _, _)
    if method_err then
      notify(
        "Route Open",
        { msg = "Error when finding workspace symbols: " .. method_err.message, level = "WARN" }
      )
      if is_new_instance then
        vim.lsp.stop_client(client.id)
      end
      return
    end

    local method_locations = vim.lsp.util.symbols_to_items(method_server_result or {}, 0) or {}
    if vim.tbl_isempty(method_locations) then
      lsp_utils.notify(
        "Route open",
        { msg = string.format("empty response looking for method: %s", method or "__invoke"), level = "WARN" }
      )
      if is_new_instance then
        vim.lsp.stop_client(client.id)
      end
      return
    end

    local method_location = nil
    for _, value in ipairs(method_locations) do
      if value.text == string.format("[Method] %s", method or "__invoke") then
        method_location = value
        break
      end
    end

    if method_location == nil then
      if is_new_instance then
        vim.lsp.stop_client(client.id)
      end
      return
    end

    local row = method_location.lnum
    local col = method_location.col - 1

    if row and col then
      local ok, err_msg = pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
      if not ok then
        lsp_utils.notify("Route Open", { msg = "Erro setting row and col " .. err_msg, level = "WARN" })
      end
      vim.cmd "normal zt"
    end
    if is_new_instance then
      vim.lsp.stop_client(client.id)
    end
  end)
end

return {
  go_to = go_to,
}
