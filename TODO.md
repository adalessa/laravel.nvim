# Ideas

## To implement
```lua
- [X] implement api
- [X] implement ui
- [X] implements a command history
- [X] remove bind telescope
- [X] Fix error when route list breaks it slows the heck out of the editor
- [X] order of arguments running command from telescope
- [X] completion for none-ls view('<"">') get all *.balde.php files.
- [X] implement default args | implement as options on the command options
- [X] escape on required args cancel it
- [X] when calling make commands without arguments run it in a popup
- [X] fix bug with `fd` switch from `sync` to proper use
- [X] How to implement checkhealth
- [X] completion route
- [X] detect library use by model show (command -precheck- on picker)
- [X] completion for routes when broken not loading to many making slow the editor
- [X] change the way of versions are being poll
- [X] maybe command for make only where only list commands of make principal laravel ones and open in a popup or how to configure from the command pallete
- [X] completion detect or not quotes
- [X] completion for model fields
- [X] remove completion for models
- [ ] replace anonymous function from mapping with dedicated functions to have descriptions
- [ ] recipes for ide-helper models and eloquent
- [ ] using the get_type in completion is dangerus. better to replace it with ide-helper
- [ ] implement watch
- [ ] tinker interface
- [ ] virtual text info ???
- [ ] re-write the readme and translate (not forget fd as dependency) the counter does not work as I expect


Somethign like thinkerwell
read the buffer and send to tinker ??

```lua
local res = api.sync("artisan", {"tinker", "--execute", "$a = view('welcome'); dump($a)"})
```
since php does not car of breake lines I could do something like this
read the buffer

If I want colors needs to use jobstart I think
```lua
vim.fn.jobstart({ "php", "artisan", "tinker", "--execute", vim.fn.join(lines, "") }, {
    stdeout_buffered = true,
    on_stdout = function(_, data)
        vim.fn.chansend(chan, data)
    end,
    pty = true,
})
```

To have autocomplete need to have the file in the project folder.
or start the server for the specific buffer

`tinker.php` could be created on the root when starting the mode

delete it when it's done, or persist it.

create temporary buffer and use vim.lsp.buf_attach_client() to attach it to the current php actor client

should start the buffer with the first line `<?php`

so I can start with an interface of two windows.
each one a buffer
TinkerEditor -> attach it to current lsp server for php
TinkerOutput -> render the output per save

Autocommand for TinkerEditor to save and run the hole buffer content into the api sync command.

Action Start Tinker
Open side for output.
Create buffer or look for buffer of tinker
On Close Leave tinkerEditor buffer but close the output



Completion of model fields
- check that we are trying to complete property for variable.
- check that variable is of model (lsp)
- get model name
if for the variable use type definition can get the document for the variable.
can I get the name of it ?
should be in the location
What can I get from location ??
