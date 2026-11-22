local function load_extensions(paths)
  local original = vim.api.nvim_get_runtime_file
  vim.api.nvim_get_runtime_file = function()
    return paths
  end

  package.loaded["laravel.providers.extensions_provider"] = nil
  local ok, result = pcall(function()
    return require("laravel.providers.extensions_provider").extensions
  end)

  vim.api.nvim_get_runtime_file = original
  package.loaded["laravel.providers.extensions_provider"] = nil
  if not ok then
    error(result, 0)
  end

  return result
end

describe("extensions provider", function()
  it("discovers extensions from Windows-style runtime paths", function()
    local extensions = load_extensions({
      "C:\\Users\\dev\\AppData\\Local\\nvim-data\\lazy\\laravel.nvim\\lua\\laravel\\extensions\\tinker\\provider.lua",
    })

    assert.same({
      { module = "laravel.extensions.tinker.provider", name = "tinker" },
    }, extensions)
  end)

  it("discovers extensions from POSIX runtime paths", function()
    local extensions = load_extensions({
      "/home/dev/.local/share/nvim/lazy/laravel.nvim/lua/laravel/extensions/model_info/provider.lua",
    })

    assert.same({
      { module = "laravel.extensions.model_info.provider", name = "model_info" },
    }, extensions)
  end)
end)
