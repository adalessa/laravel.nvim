local app = require("laravel.core.app")
local TermCommand = require("laravel.term_command")
local PtyCommand = require("laravel.pty_command")

local hub = {
  signature = "hub",
  description = "Artisan Hub",
}

local win = nil

local commands = {}

local current_tab = ""

local function get_keys()
  return vim.tbl_map(function(cmd)
    return cmd.name
  end, commands)
end
local function get_title()
  return vim.tbl_map(function(key)
    if key == current_tab then
      return { (" [%s] "):format(key), "keyword" }
    end
    return { (" %s "):format(key), "Comment" }
  end, get_keys())
end

local function getByName(name)
  return vim.iter(commands):find(function(cmd)
    return cmd.name == name
  end)
end
local function add_keymaps()
  local keys = get_keys()
  for i, key in ipairs(keys) do
    local item = getByName(key)
    vim.keymap.set("n", "q", function()
      if win then
        vim.api.nvim_win_hide(win)
      end
    end, { buffer = item.command.bufnr })

    vim.keymap.set("n", "a", function()
      vim.ui.input({ prompt = "Name: " }, function(name)
        if not name or name == "" then
          return
        end
        -- being able from a command to add to hub

        vim.ui.input({ prompt = "Enter command: " }, function(input)
          if not input or input == "" then
            return
          end

          hub:add(name, input)
        end)
      end)
    end, { buffer = item.command.bufnr })

    vim.keymap.set("n", "d", function()
      for i, cmd in ipairs(commands) do
        if cmd.name == current_tab then
          table.remove(commands, i)
          cmd.command:stop()

          current_tab = get_keys()[1]
          if win then
            vim.api.nvim_win_set_buf(win, getByName(current_tab).command.bufnr)
            vim.api.nvim_win_set_config(win, { title = get_title() })
          end
          add_keymaps()
        end
      end
    end, { buffer = item.command.bufnr })

    local next_key = keys[i + 1] or keys[1]
    local prev_key = keys[i - 1] or keys[#keys]

    vim.keymap.set("n", "<Tab>", function()
      if win then
        vim.api.nvim_win_set_buf(win, getByName(next_key).command.bufnr)
        current_tab = next_key
        vim.api.nvim_win_set_config(win, { title = get_title() })
      end
    end, { buffer = item.command.bufnr })

    vim.keymap.set("n", "<S-Tab>", function()
      if win then
        vim.api.nvim_win_set_buf(win, getByName(prev_key).command.bufnr)
        current_tab = prev_key
        vim.api.nvim_win_set_config(win, { title = get_title() })
      end
    end, { buffer = item.command.bufnr })
  end
end

function hub:_init()
  if vim.tbl_isempty(commands) then
    commands = app("laravel.extensions.artisan_hub.commands")
  end

  for _, command in ipairs(commands) do
    if not command.command then
      local cmd = app("laravel.services.command_generator"):generate(command.cmd)

      if command.callback then
        command.command = PtyCommand:new(cmd):addCallback(command.callback)
      else
        command.command = TermCommand:new(cmd)
      end
    end
  end

  vim.tbl_map(function(cmd)
    if not cmd.command:isRunning() then
      cmd.command:execute()
    end
  end, commands)

  if current_tab == "" then
    current_tab = get_keys()[1]
  end
end

function hub:handle()
  self:_init()
  local current = getByName(current_tab)

  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor(ui.width * 0.8)
  local height = math.floor(ui.height * 0.8)

  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  win = vim.api.nvim_open_win(current.command.bufnr, true, {
    title = get_title(),
    title_pos = "center",
    border = "rounded",
    height = height,
    width = width,
    footer = "q: Close | a: Add | d: Delete | <Tab>: Next Tab | <S-Tab>: Previous Tab",
    footer_pos = "center",
    relative = "editor",
    row = row,
    col = col,
  })

  vim.api.nvim_set_option_value("number", false, { win = win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = win })
  add_keymaps()
end

function hub:add(name, cmd)
  self:_init()
  local new_cmd = app("laravel.services.command_generator"):generate(cmd)
  if not new_cmd then
    vim.notify("Command not found: " .. cmd, vim.log.levels.ERROR)
    return
  end

  local new_command = TermCommand:new(new_cmd)
  table.insert(commands, {
    name = name,
    cmd = cmd,
    command = new_command,
  })
  new_command:execute()

  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_buf(win, new_command.bufnr)
    current_tab = name
    vim.api.nvim_win_set_config(win, { title = get_title() })
    vim.api.nvim_set_current_win(win)
  end

  add_keymaps()
end

return hub
