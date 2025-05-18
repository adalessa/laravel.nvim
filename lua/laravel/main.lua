local app = require("laravel").app

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local function get_command_names(command)
  if type(command.command) == "string" then
    return { command.command }
  elseif type(command.commands) == "table" then
    return command.commands
  end
  return command:commands()
end

local details_popup = Popup({
  border = {
    style = "rounded",
    text = {
      top = "Laravel commands",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:LaravelHelp",
  },
})

local entry_popup = Input({
  focusable = true,
  border = {
    style = "rounded",
    text = {
      top = "Laravel",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:LaravelPrompt",
  },
}, {
  prompt = "> ",
  on_submit = function(value)
    dd(value)
  end,
  on_change = function(value)
    vim.schedule(function()
      if not details_popup.bufnr then
        return
      end

      local args = vim.split(value, " ")
      local commands = vim
        .iter(app("user_commands"))
        :filter(function(item)
          return vim.iter(get_command_names(item)):any(function(name)
            return vim.startswith(name, args[1])
          end)
        end)
        :totable()

      local values = {}

      if #commands == 1 then
        local subs = {}
        local command = commands[1]
        if type(command.subCommands) == "table" then
          subs = vim
            .iter(command.subCommands)
            :filter(function(subcommand)
              return vim.startswith(subcommand, args[2])
            end)
            :totable()
        else
          subs = command:complete(args[2] or "", value)
        end

        values = vim
          .iter(subs)
          :map(function(sub)
            return get_command_names(command)[1] .. " " .. sub
          end)
          :totable()
      else
        values = vim.iter(commands):map(get_command_names):flatten():totable()
      end

      vim.api.nvim_buf_set_lines(details_popup.bufnr, 0, -1, true, values)
    end)
  end,
})

local boxes = {
  Layout.Box(entry_popup, { size = 3 }), -- 3 because of borders to be 1 row
  Layout.Box(details_popup, { grow = 1 }),
}

local layout = Layout({
  position = "50%",
  size = {
    width = "80%",
    height = "90%",
  },
  relative = "editor",
}, Layout.Box(boxes, { dir = "col" }))

entry_popup:on(event.BufLeave, function()
  layout:unmount()
end)

layout:mount()

vim.defer_fn(function()
  vim.api.nvim_command("startinsert!")
end, 20)
