local tinker_provider = {}

function tinker_provider:register(app) end

function tinker_provider:boot(app)
  vim.filetype.add({ extension = { tinker = "php" } })

  local group = vim.api.nvim_create_augroup("tinker", {})

  local Split = require("nui.split")
  -- TODO allow to change this by configuration
  local split = Split({
    enter = false,
    relative = "editor",
    position = "right",
    size = "40%",
    buf_options = {},
    win_options = {
      number = false,
      relativenumber = false,
    },
  })

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*.tinker",
    group = group,
    callback = function(ev)
      local bufnr = ev.buf

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)

      if lines[1] ~= "<?php" then
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "<?php" })
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    pattern = "*.tinker",
    group = group,
    callback = function()
      split:unmount()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = "*.tinker",
    group = group,
    callback = function(ev)
      local bufnr = ev.buf

      local lines = vim.api.nvim_buf_get_lines(bufnr, 1, -1, false)

      -- filter empty lines
      lines = vim.tbl_filter(function(raw_line)
        local line = raw_line:gsub("^%s*(.-)%s*$", "%1")
        return line ~= ""
            and line:sub(1, 2) ~= "//"
            and line:sub(1, 2) ~= "/*"
            and line:sub(1, 2) ~= "*/"
            and line:sub(1, 1) ~= "*"
            and line:sub(1, 1) ~= "#"
      end, lines)

      if #lines == 0 then
        return
      end

      if not split.mounted then
        split:mount()
      end

      -- dont dump the last line if it's not a statement
      -- FIX: there is a bug when the last line is a multi line statement
      -- should use more treesitter to get the last element and get the last statement
      if
          lines[#lines] ~= "}"
          and lines[#lines]:sub(1, 4) ~= "dump"
          and lines[#lines]:sub(1, 8) ~= "var_dump"
          and lines[#lines]:sub(1, 4) ~= "echo"
      then
        lines[#lines] = string.format("dump(%s);", lines[#lines]:sub(1, -2))
      end

      -- add closing comment but ramdonly once every 10
      -- if math.random(1, 10) == 1 then
      --   table.insert(lines, "echo '\n\nDone by Alpha Developer';")
      -- end

      local cmd = app("api"):generate_command("artisan", { "tinker", "--execute", table.concat(lines, "\n") })

      -- clean the output
      local channel_id = vim.api.nvim_open_term(split.bufnr, {})
      vim.fn.jobstart(cmd, {
        stdeout_buffered = true,
        on_stdout = function(_, data)
          data = vim.tbl_map(function(line)
            if line:find("vendor/psy/psysh/src") then
              local sub = line:gsub("vendor/psy/psysh/src.*$", "")
              return sub:sub(1, -14)
            end
            return line
          end, data)

          vim.fn.chansend(channel_id, data)
        end,
        on_exit = function()
          if split then
            vim.api.nvim_win_set_cursor(split.winid, { 1, 1 })
          end
        end,
        pty = true,
      })
    end,
  })
end

return tinker_provider