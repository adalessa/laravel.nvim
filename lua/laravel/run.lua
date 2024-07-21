local Popup = require("nui.popup")
local Split = require("nui.split")

local app = require("laravel.app")

local ui_builders = {
  split = Split,
  popup = Popup,
}

local make_rules = { "%[(.-)%]", "CLASS:%s+(.-)\n" }

---@param text string
---@return string|nil
local function find_class(text)
  text = text:gsub("\r", "")
  for _, rule in ipairs(make_rules) do
    local matche
    matche = text:gmatch(rule)()
    if matche then
      return matche
    end
  end

  return nil
end

---@param name string
---@param args string[]
---@param opts table|nil
return function(name, args, opts)
  opts = opts or {}
  local executable = app("env"):get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
    return
  end

  local cmd = vim.fn.extend(executable, args)

  local command_option = app("options"):get().commands_options[args[1]] or {}

  opts = vim.tbl_extend("force", command_option, opts)

  local selected_ui = opts.ui or app("options"):get().ui.default

  local instance = ui_builders[selected_ui](opts.nui_opts or app("options"):get().ui.nui_opts[selected_ui])

  instance:mount()

  -- This returns thhe job id
  local jobId = vim.fn.termopen(table.concat(cmd, " "))

  local prefix = "make"
  if name == "artisan" and args[1]:sub(1, #prefix) == prefix or args[1] == "livewire:make" then
    instance:on("TermClose", function()
      local lines = vim.api.nvim_buf_get_lines(instance.bufnr, 0, -1, false)
      local class = find_class(vim.fn.join(lines, "\r"))
      if class ~= nil and class ~= "" then
        instance:unmount()
        -- without this will not be open
        vim.schedule(function()
          vim.cmd("e " .. class)
        end)
        return
      end
    end)
  end

  app('history'):add(jobId, name, args, opts)

  vim.cmd("startinsert")
end
