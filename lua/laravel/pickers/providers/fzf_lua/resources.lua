local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.providers.fzf_lua.format_entry").gen_from_artisan

local resources_picker = {}

function resources_picker.run(opts, resources)
  local resource_names, resource_table = format_entry(resources)
  fzf_exec(
    resource_names,
    vim.tbl_extend("force", {
      actions = {
        ["default"] = function(selected)
          local resource = resource_table[selected[1]]
          require("fzf-lua").files({ cwd = resource.path })
        end,
      },
      prompt = "Resources > ",
      preview = function(selected)
        local resource = resource_table[selected[1]]

        local command = "ls -1 " .. resource.path
        local handle = io.popen(command)

        if not handle then
          return ""
        end

        local output = handle:read("*a")
        handle:close()

        if not output then
          return ""
        end

        return vim.split(output, "\n")
      end,
      fzf_opts = {
        ["--preview-window"] = "nohidden,70%",
      },
    }, opts or {})
  )
end

return resources_picker
