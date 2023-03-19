# Laravel.nvim

Currently in Alpha state. Any collaboration, issue reported is appreciated.

Plugin for Neovim to enhance the development experience of Laravel projects

Quick executing of artisan commands

The plugin relies in Treesitter for php run so don't forget `TSInstall php`

# Installation
Lazy
```lua
return {
  "adalessa/laravel.nvim",
  dependencies = {
    "rcarriga/nvim-notify",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "Sail", "Artisan", "Composer", "Npm", "Laravel" },
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
    ask_for_args = true,
    register_user_commands = true,
    route_info = true,
    default_runner = "buffer",
    commands_runner = {
        ["dump-server"] = "terminal",
        ["db"] = "terminal",
        ["tinker"] = "terminal",
    },
    resources = {
        cast = "app/Casts",
        channel = "app/Broadcasting",
        command = "app/Console/Commands",
        component = "app/View/Components",
        controller = "app/Http/Controllers",
        event = "app/Events",
        exception = "app/Exceptions",
        factory = function(name)
            return string.format("database/factories/%sFactory.php", name), nil
        end,
        job = "app/Jobs",
        listener = "app/Listeners",
        mail = "app/Mail",
        middleware = "app/Http/Middleware",
        migration = function(name)
            local resp, ret, stderr = require("laravel.runners").sync({ "fd", name .. ".php" })
            if ret == 1 then
                return "", stderr
            end

            return resp[1], nil
        end,
        model = "app/Models",
        notification = "app/Notifications",
        observer = "app/Observers",
        policy = "app/Policies",
        provider = "app/Providers",
        request = "app/Http/Requests",
        resource = "app/Http/Resources",
        rule = "app/Rules",
        scope = "app/Models/Scopes",
        seeder = "database/seeders",
        test = "tests/Feature",
    },
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
