describe("Composer user command", function()
  local spy = require('luassert.spy')

  local s = spy.new(function() end)
  package.loaded['laravel.run'] = s
  require('laravel.user_commands.composer').setup()

  it('require formats the parameter', function()
    vim.cmd [[Composer require laravel/folio]]
    assert.spy(s).was.called_with('composer', { "require", "laravel/folio" }, {})
  end)

  it('passes the arguments to the install', function()
    vim.cmd [[Composer install --options]]
    assert.spy(s).was.called_with('composer', { "install", "--options" }, {})
  end)
end)
