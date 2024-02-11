local commands = require "laravel.commands"
local run = require "laravel.run"

local function get_artisan_auto_complete(current_match, full_command)
  -- avoid getting autocomplete for when parameter is expected
  if (#vim.fn.split(full_command, " ") >= 2 and current_match == "") or #vim.fn.split(full_command, " ") >= 3 then
    return {}
  end

  if vim.tbl_isempty(commands.list) then
    if not commands.load() then
      return
    end
  end

  local complete_list = {}
  for _, command in ipairs(commands.list) do
    if current_match == "" or string.match(command.name, current_match) then
      table.insert(complete_list, command.name)
    end
  end

  return complete_list
end

return {
  setup = function()
    vim.api.nvim_create_user_command("Artisan", function(args)
      if args.args == "" then
        local ok, telescope = pcall(require, "telescope")
        if ok then
          return telescope.extensions.laravel.commands()
        end
      end

      return run("artisan", args.fargs)
    end, {
      nargs = "*",
      complete = get_artisan_auto_complete,
    })
  end,
}
