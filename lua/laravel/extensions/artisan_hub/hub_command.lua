local NuiLine = require("nui.line")
local Popup = require("nui.popup")
local app = require("laravel.core.app")

local hub = {
  signature = "hub",
  description = "Artisan Hub",
}
---@type NuiPopup?
local instance = nil
local open = false

---@return NuiPopup
local function create()
  -- should look for config
  local cfg = app("laravel.core.config"):get()

  if not cfg.hub then
    cfg.hub = {
      {
        name = "About",
        key = "A",
        cmd = "artisan about",
        auto_start = true,
      },
      {
        name = "HTTP",
        key = "H",
        cmd = "artisan serve",
        auto_start = true,
      },
      {
        name = "Vite",
        key = "V",
        cmd = "npm run dev",
        auto_start = true,
      },
      {
        name = "Pail",
        key = "P",
        cmd = "artisan pail --timeout=0",
      },
      {
        name = "Queue",
        key = "Q",
        cmd = "artisan queue:listen --tries=1",
      },
      {
        name = "Logs",
        key = "L",
        cmd = "tail -f -n 100 storage/logs/laravel.log",
      },
    }
    app("laravel.core.config"):set(cfg)
  end

  local tabs = vim
    .iter(cfg.hub)
    :map(function(tab_cfg)
      return require("laravel.extensions.artisan_hub.command_tab"):new(tab_cfg)
    end)
    :totable()

  local title = NuiLine()
  vim
    .iter(tabs)
    :map(function(tab)
      local t = tab:getTitle()
      local l = NuiLine()
      l:append(t.text, "@function")
      l:append("(", "@comment")
      l:append(t.key, "@keyword")
      l:append(") ", "@comment")

      return l
    end)
    :each(function(tab_line)
      title:append(tab_line)
      title:append("  ")
    end)

  local help = NuiLine()

  for _, action in ipairs(tabs[1]:getActions()) do
    help:append(action.name, "@function")
    help:append("(", "@comment")
    help:append(action.key, "@keyword")
    help:append(") ", "@comment")
  end

  local p = Popup({
    enter = true,
    focusable = true,
    relative = "editor",
    border = {
      style = "rounded",
      text = {
        top = title,
        bottom = help,
      },
    },

    position = {
      row = "50%",
      col = "50%",
    },

    size = {
      width = "80%",
      height = "80%",
    },
    win_options = {
      number = false,
      relativenumber = false,
      winfixbuf = true,
    },
    bufnr = tabs[1]:getBufnr(),
  })

  vim.iter(tabs):each(function(tab)
    tab:map("n", "q", function()
      p:hide()
      open = false
    end)

    for _, action in ipairs(tab:getActions()) do
      tab:map("n", action.key, function()
        action.action()
        vim.api.nvim_set_option_value("winfixbuf", false, { win = p.winid })
        vim.api.nvim_win_set_buf(p.winid, tab:getBufnr())
        vim.api.nvim_set_option_value("winfixbuf", true, { win = p.winid })
      end)
    end
    for _, t in ipairs(tabs) do
      if tab:getTitle().text ~= t:getTitle().text then
        tab:map("n", t:getTitle().key, function()
          vim.api.nvim_set_option_value("winfixbuf", false, { win = p.winid })
          vim.api.nvim_win_set_buf(p.winid, t:getBufnr())
          vim.api.nvim_set_option_value("winfixbuf", true, { win = p.winid })
          p.bufnr = t:getBufnr()

          help = NuiLine()

          vim.iter(t:getActions()):each(function(action)
            help:append(action.name, "@function")
            help:append("(", "@comment")
            help:append(action.key, "@keyword")
            help:append(") ", "@comment")
          end)

          p.border:set_text("bottom", help, "center")
        end)
      end
    end

    tab:autostart()
  end)

  p.bufnr = tabs[1]:getBufnr()

  return p
end

function hub:handle()
  if not instance then
    instance = create()
    instance:mount()
    open = true
    return
  end
  if open then
    instance:hide()
    open = false
    return
  end

  instance:show()
  open = true
end

return hub
