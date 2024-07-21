-- Should be able to have a class for each
-- and register in the bootstrap
-- each class should have two methos
-- aliases this mainly for art and artisan
-- complete should return the list available
-- other option is the action, important and the complete could be missing

local function subcommands()
  return vim.iter({
    "art",
    "artisan",
    "routes",
    "composer",
    "sail",
    "assets",
    "commands",
  })
end

vim.api.nvim_create_user_command("Laravel", function(args)
  local subcommand = args.fargs[1]
  if subcommand == "art" or subcommand == "artisan" then
    require("laravel").artisan()
  end
end, {
  nargs = "*",
  complete = function(argLead, cmdLine)
    local fCmdLine = vim.split(cmdLine, " ")
    if #fCmdLine <= 2 then
      return subcommands()
          :filter(function(subcommand)
            return vim.startswith(subcommand, argLead)
          end)
          :totable()
    elseif #fCmdLine == 3 then
        -- complete for the sub commands
        return {"next"}
    end

    return {}
  end,
})
