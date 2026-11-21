local deps = dofile("tests/support/deps.lua")

describe("test dependency resolution", function()
  local root

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")
  end)

  after_each(function()
    vim.fn.delete(root, "rf")
  end)

  local function plugin(base, name)
    vim.fn.mkdir(base .. "/" .. name, "p")
  end

  it("prefers LARAVEL_TEST_DEPS", function()
    local env_dir = root .. "/env"
    local repo_dir = root .. "/repo/.tests/deps"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(env_dir, name)
      plugin(repo_dir, name)
    end

    local resolved, missing = deps.resolve({
      env = { LARAVEL_TEST_DEPS = env_dir },
      repo_root = root .. "/repo",
      data_dir = root .. "/data/lazy",
    })

    assert.equals(env_dir .. "/plenary.nvim", resolved["plenary.nvim"])
    assert.same({}, missing)
  end)

  it("falls back to .tests/deps", function()
    local repo_dir = root .. "/repo/.tests/deps"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(repo_dir, name)
    end

    local resolved, missing = deps.resolve({
      env = {},
      repo_root = root .. "/repo",
      data_dir = root .. "/data/lazy",
    })

    assert.equals(repo_dir .. "/nui.nvim", resolved["nui.nvim"])
    assert.same({}, missing)
  end)

  it("falls back to the lazy stdpath", function()
    local data_dir = root .. "/data/lazy"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(data_dir, name)
    end

    local resolved, missing = deps.resolve({
      env = {},
      repo_root = root .. "/repo",
      data_dir = data_dir,
    })

    assert.equals(data_dir .. "/nvim-nio", resolved["nvim-nio"])
    assert.same({}, missing)
  end)

  it("reports missing plugins instead of silently continuing", function()
    local _, missing = deps.resolve({
      env = {},
      repo_root = root .. "/repo",
      data_dir = root .. "/data/lazy",
    })

    assert.same({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }, missing)
  end)

  it("does not depend on the current working directory", function()
    local repo = root .. "/repo"
    local repo_dir = repo .. "/.tests/deps"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(repo_dir, name)
    end
    local original = vim.fn.getcwd()
    vim.cmd("cd " .. vim.fn.fnameescape(root))

    local resolved = deps.resolve({
      env = {},
      repo_root = repo,
      data_dir = root .. "/data/lazy",
    })
    vim.cmd("cd " .. vim.fn.fnameescape(original))

    assert.equals(repo_dir .. "/plenary.nvim", resolved["plenary.nvim"])
  end)
end)
