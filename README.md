# Laravel.nvim

Currently in Alpha state. Any collaboration, issue reported is appreciated.

Plugin for neovim to enhance the developement experience of laravel projects

Quick executing of artisan commands

# Installation
Packer
```lua
use({"adalessa/laravel.nvim",
    requires = {
        { "nvim-lua/plenary.nvim" },
        { "rcarriga/nvim-notify" },
        { "nvim-telescope/telescope.nvim" },
    },
})
```

Set up
```lua
require("laravel").setup({
    split_cmd = "vertical",
    split_width = 120,
    bind_telescope = true,
    ask_for_args = true,
})

require("telescope").load_extension "laravel"
```



Default options for opening the split for terminal commands

## Artisan
To run Artisan commands you can use `:Artisan` which will autocomplete with the available
artisan command as the terminal

Not sending any arguments will run the Telescope prompt

`:Artisan tinker` will open the terminal inside of neovim, with tinker

Any other command will just run and output the result on a new split

## Sail

You can run `shell` as tinker will open a new terminal

`up`, `down`, `restart` will notify when starting and result will show as notification

## API
written in lua it offers a cool api

### Artisan
```
require("laravel.artisan").tinker() -- drops you in a terminal of tinker
require("laravel.artisan").run(cmd) -- command with args as string
require("laravel.artisan").make(resource, name, args) -- this will create and open the new resource
require("laravel.artisan").list() -- list the commands, is more internal but you can use it
require("laravel.artisan").help(cmd) -- return the help for a command
```

### Sail
```
require("laravel.sail").shell() -- drops you in a terminal of the container
require("laravel.sail").run(cmd) -- command with args as string
require("laravel.sail").up() -- start sail with the -d flag
require("laravel.sail").down()
require("laravel.sail").restart()
```
