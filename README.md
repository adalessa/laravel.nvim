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


## Composer

`install`, `update`, `require` and `remove` from the `:Composer` command

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


### Composer
```
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

