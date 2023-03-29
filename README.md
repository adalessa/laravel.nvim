# Laravel.nvim

Currently in Alpha state. Any collaboration, issue reported is appreciated.

Plugin for Neovim to enhance the development experience of Laravel projects

Quick executing of artisan commands

The plugin relies in Treesitter for php run so don't forget `TSInstall php`

In order to be able to jump from the route to the class it depends on the LSP.

# Installation
Lazy
```lua
return {
  "adalessa/laravel.nvim",
  dependencies = {
    "rcarriga/nvim-notify",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
  keys = {
    { "<leader>la", ":Laravel artisan<cr>" },
    { "<leader>lr", ":Laravel routes<cr>" },
  },
  event = { "VeryLazy" },
  config = function()
    require("laravel").setup()
    require("telescope").load_extension "laravel"
  end,
}
```

For nicer notifications use `rcarriga/nvim-notify`
My lazy configuration for notify is
```lua
return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        -- this for transparency
        notify.setup({ background_colour = "#000000" })
        -- this overwrites the vim notify function
        vim.notify = notify.notify
    end
}
```

Default configuration
```lua
{
    split = {
        cmd = "vertical",
        width = 120,
    },
    bind_telescope = true,
    lsp_server = "phpactor",
    register_user_commands = true,
    route_info = true,
    default_runner = "buffer",
    commands_runner = {
        ["dump-server"] = "persist",
        ["db"] = "terminal",
        ["tinker"] = "terminal",
        ["queue:listen"] = "persist",
        ["serve"] = "persist",
        ["websockets"] = "persist",
        ["queue:restart"] = "watch",
    },
    resources = {
        ["make:cast"] = "app/Casts",
        ["make:channel"] = "app/Broadcasting",
        ["make:command"] = "app/Console/Commands",
        ["make:component"] = "app/View/Components",
        ["make:controller"] = "app/Http/Controllers",
        ["make:event"] = "app/Events",
        ["make:exception"] = "app/Exceptions",
        ["make:factory"] = function(name)
          return string.format("database/factories/%sFactory.php", name), nil
        end,
        ["make:job"] = "app/Jobs",
        ["make:listener"] = "app/Listeners",
        ["make:mail"] = "app/Mail",
        ["make:middleware"] = "app/Http/Middleware",
        ["make:migration"] = function(name)
          local result = require("laravel.runners").sync { "fd", name .. ".php" }
          if result.exit_code == 1 then
            return "", result.error
          end

          return result.out, nil
        end,
        ["make:model"] = "app/Models",
        ["make:notification"] = "app/Notifications",
        ["make:observer"] = "app/Observers",
        ["make:policy"] = "app/Policies",
        ["make:provider"] = "app/Providers",
        ["make:request"] = "app/Http/Requests",
        ["make:resource"] = "app/Http/Resources",
        ["make:rule"] = "app/Rules",
        ["make:scope"] = "app/Models/Scopes",
        ["make:seeder"] = "database/seeders",
        ["make:test"] = "tests/Feature",
    }
}
```


## Artisan
To run Artisan commands you can use `:Artisan` which will autocomplete with the available
artisan command as the terminal

Not sending any arguments will run the Telescope prompt

`:Artisan tinker` will open the terminal inside of Neovim, with tinker

Any other command will just run and output the result on a new split

## Sail
You can run `shell` as tinker will open a new terminal
`up`, `down`, `restart` will notify when starting and result will show as notification

## Composer
`install`, `update`, `require` and `remove` from the `:Composer` command

## Plugin specific
`Laravel cache:clear` purge the cache clears the cache for commands.
`Laravel commands` shows the list of artisan commands and executes it.
`Laravel routes` show the list of routes and goes to the implementation.
`Laravel test` runs the application tests
`Laravel test:watch` runs the application tests and keep monitoring the changes
