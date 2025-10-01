---@class NuiOptions
---@field enter boolean
---@field relative string
---@field position string|table
---@field size string|table
---@field buf_options table
---@field win_options table

---@class LaravelOptionsUINui
---@field split NuiOptions
---@field popup NuiOptions

---@class LaravelOptionsUI
---@field default string
---@field nui_opts LaravelOptionsUINui
return {
  default = "split",
  nui_opts = {
    split = {
      enter = true,
      relative = "editor",
      position = "right",
      size = "33%",
      buf_options = {},
      win_options = {
        number = false,
        relativenumber = false,
      },
    },
    popup = {
      enter = true,
      focusable = true,
      relative = "editor",
      border = {
        style = "rounded",
      },
      position = {
        row = "20%",
        col = "50%",
      },
      size = {
        width = "28%",
        height = "35%",
      },
      buf_options = {},
      win_options = {
        number = false,
        relativenumber = false,
        winhighlight = "Normal:LaravelPopUpNormal,FloatBorder:LaravelPopUpFloatBorder",
      },
    },
  },
}
