local template = require("laravel.php-templates.models")

describe("models template", function()
  it("embeds the builder signature helpers", function()
    assert.is_nil(template:find("__LARAVEL_NVIM_MODEL_SIGNATURES__", 1, true))
    assert.truthy(template:find("function laravel_nvim_builder_parameter", 1, true))
    assert.truthy(template:find("function laravel_nvim_builder_return_type", 1, true))
    assert.truthy(template:find("function laravel_nvim_docblock_tag_return", 1, true))
  end)

  it("is valid php", function()
    local file = vim.fn.tempname() .. ".php"
    vim.fn.writefile(vim.split("<?php\n" .. template, "\n"), file)

    local result = vim.system({ "php", "-l", file }, { text = true }):wait()
    vim.fn.delete(file)

    assert.equals(0, result.code, (result.stdout or "") .. (result.stderr or ""))
  end)
end)
