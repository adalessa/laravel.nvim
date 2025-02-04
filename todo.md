# Goal

Quiero poder usar gf o dejado para quien quiera para ir a la defincion del archivo
de view, Route::view, config & env

- [ ] Get node at cursor, and validate that is in string on one of the supported functions.
- [ ] get the needed information of the file
- [ ] for config and env should get to the line were defined.
- [ ] for config will be a bit hard, need to get the file name from the first part

## After MVP
- [ ] Env completion

## Low priority
- [ ] blink source to not depend on compat

need to use function get_node_at_cursor(winnr)
From that I need to get the parser, and get the termins

get_node_text({node}, {source}, {opts})
source can be the buf number
nvim_get_current_buf should be able to use it, or 0

Asi puedo sobreescribir el gf para usarlo
```lua
vim.keymap.set("n", "gf", function()
  if require("obsidian").util.cursor_on_markdown_link() then
    return "<cmd>ObsidianFollowLink<CR>"
  else
    return "gf"
  end
end, { noremap = false, expr = true })
```

```lua
require('laravel').app('util').gf_passthrough()
```

This can engloble it

also can have

```lua
require('laravel').app('util').hover_passthrough()
```
could try to do the hover if not fallback to the lspaction ? or ask for it.
mimic the same hover

could use `vim.lsp.util.make_floating_popup_options()`
that can be pass to
```
    Creates a table with sensible default options for a floating window. The
    table can be passed to |nvim_open_win()|.
```
`nvim_open_win({buffer}, {enter}, {config})`

create a buffer with just that and the common options.



Thinker how to set parser for filetype.
I want to set filetype thinker and map to PHP_ONLY parser


Model completion, cache model show info
Need to get current position, get the MODEL on parent.
also check the alias to see if it's a model



TODO I was able to reproduce the issue of laravel is not active, need to check when locale or lative, that composer and php are executalble.
I have the check but the environment looks like is still set, so need to debug more there

Improve the healthcheck and how to map using some check for cmp, blink and the provider.
The provider for picker can be auto to look for the plugins configured
