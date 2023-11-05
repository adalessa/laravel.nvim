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
      },
    },
  },
}
