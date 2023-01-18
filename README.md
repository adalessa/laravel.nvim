# Laravel.nvim

Currently in Alpha state. Any collaboration, issue reported is appreciated.

Plugin for neovim to enhance the developement experience of laravel projects

Quick executing of artisan commands

The plugin relys in treesitter for php run so dont forget `TSInstall php`

# Installation
Lazy
```lua
{
    "adalessa/laravel.nvim",
    dependencies = {
        "rcarriga/nvim-notify",
        "nvim-telescope/telescope.nvim",
    },
    cmd = {"Sail", "Artisan", "Composer"},
    keys = {
        {"<leader>pa", ":Artisan<cr>"},
    },
    config = function()
        require("laravel").setup()
        require("telescope").load_extension("laravel")
    end
}
```

Default config
```lua
{
    split = split,
    bind_telescope = true,
    ask_for_args = true,
    register_user_commands = true,
    route_info = true,
    default_runner = "buffer",
    artisan_command_runner = {
        ["dump-server"] = "terminal",
        ["db"] = "terminal",
        ["tinker"] = "terminal",
    },
    resource_directory_map = {
        cast = "app/Casts",
        channel = "app/Broadcasting",
        command = "app/Console/Commands",
        component = "app/View/Components",
        controller = "app/Http/Controllers",
        event = "app/Events",
        exception = "app/Exceptions",
        factory = "database/factories",
        job = "app/Jobs",
        listener = "app/Listeners",
        mail = "app/Mail",
        middleware = "app/Http/Middleware",
        migration = "database/migrations",
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

`:Artisan tinker` will open the terminal inside of neovim, with tinker

Any other command will just run and output the result on a new split

## Sail
You can run `shell` as tinker will open a new terminal
`up`, `down`, `restart` will notify when starting and result will show as notification


## Composer
`install`, `update`, `require` and `remove` from the `:Composer` command

## Plugin especific
`LaravelCleanArtisanCache` clears the cache for commands

## API
written in lua it offers a cool api

### Artisan
```lua
require("laravel.artisan").tinker() -- drops you in a terminal of tinker
require("laravel.artisan").run(cmd) -- command with args as string
require("laravel.artisan").make(resource, name, args) -- this will create and open the new resource
require("laravel.artisan").list() -- list the commands, is more internal but you can use it
require("laravel.artisan").help(cmd) -- return the help for a command
```

### Sail
```lua
require("laravel.sail").shell() -- drops you in a terminal of the container
require("laravel.sail").run(cmd) -- command with args as string
require("laravel.sail").up() -- start sail with the -d flag
require("laravel.sail").down()
require("laravel.sail").restart()
```


### Composer
```lua
require("laravel.composer").install()
require("laravel.composer").update(package)
require("laravel.composer").remove(package)
require("laravel.composer").require(package)
```

## Null-ls Integration
[Null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) is a cool tool that provides
a way to seamesly integrat tools with neovim as an lsp.
I choose to create my own actions so you can easy reach to other functions without needing to add an
extra command since this is just actions on the code.

```lua
local laravel_actions = require("laravel.code-actions")
local sources = {
    ...
    laravel_actions.relationships,
    ...
}

require("null-ls").setup({
    sources = sources,
})
```
of course you can add more sources there are amaizing ones.
then you can call the `vim.lsp.buf.code_action` to have it
here is my keybinding
```lua
vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, {})
```

The relationships action only works for classes on the `App\Models` namespace
In the future will customize it

