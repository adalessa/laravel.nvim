Examples of what I want

Think in the laravel way

```lua
app():bootstrap()
```

```lua
local app = require('app')

app('commands'):get()
app('routes'):get()
app('views'):get()
app('config'):get()
app('cache'):get('commands')
app('cache'):get('routes')
```

General parts

```lua
local api
local run
```

Do I have 2 levels ?
Low Level
api
    Takes cares of running commands sync and async
    This is usefull for the plugin and extensions

Hi Level
    Commaands to run like artisan lists, commands and routes

This high levels will need to interact with the application
So there is were app starts.


setup
    - setup autocommands
    - setup user commands
    - setup tinker filetype

ftplugin
    - special keymaps for each filetype (fg)
    - autocommands

expose features from lua api.
expose features in just `Laravel` commands dont add to many

`Laravel`
    - artisan (art)
    - routes
    - composer
    - sail
    - assets
    - commands

`extensions`
    - route info
    - completion with cmp
    - code action without null-ls
