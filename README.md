# Laravel.nvim
Plugin for Neovim to enhance the development experience of Laravel projects

Quick executing of artisan commands, list and navigate to routes. Information about the routes.
Robust API to allow you to run any command in the way that you need.

# Preview
![](./images/telescope_commands.png)
![](./images/telescope_routes.png)
![](./images/route_info.png)

# Requirements
Treesitter, LSP Server (I recommend phpactor)

# Installation
Lazy
```lua
return {
  "adalessa/laravel.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
  keys = {
    { "<leader>la", ":Laravel artisan<cr>" },
    { "<leader>lr", ":Laravel routes<cr>" },
    {
      "<leader>lt",
      function()
        require("laravel").app.sendToTinker()
      end,
      mode = "v",
      desc = "Laravel Application Routes",
    },
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

# Route Info
I want to have more information in the controller, I want to have the route information directly in the controller so I build route info, this will show the
![](./images/route_info.png)
This also will show error if a route is defined but the method is not defined
![](./images/missing_method.png)

> Note: using lazy is likely that you will not see at first since the plugin will not load until you call one of the commands, after that it is just picked up

## Lua API
As developer I want to enable other to extend this plugin to cover all your needs. For this I tried to have a good API.

To run artisan commands you can execute
```lua
require('laravel.artisan').run({'your-command'})
```
That is great but what about how to get the results not all commands behave in the same way.
Currently there are several runners:

| Runner   | Description                                                                                                                                              |
| -------- | ----------------------------------------------------------------                                                                                         |
| terminal | Opens a new terminal in neovim with the command, this is usefull for commands that require interaction like tinker                                       |
| buffer   | This opens an split and shows the results in a new buffer. This uses the `vim.fn.jobstart` to run the command                                            |
| sync     | This is more for api since the result of the command will be directly return to work with                                                                |
| async    | Similar to `sync` but it takes a callback and will call it once the data is loaded, usefull for long process and to not block the editor                 |
| persist  | One thing with buffers is that are temprary once you close the buffer the job is terminated, for some process you don't want that like, npm dev or other |
| watch    | This is usefull for commands that needs to be retrigger one files are modifed, like queues restart, or tests                                             |


So you can run commands like
```lua
require('laravel.artisan').run({'your-command'}, 'persist')
```
Each runner returns different values since it have different behave.

| Runner   | Output                 |
| --       | --                     |
| terminal | {buff, term_id}        |
| buffer   | {buff, job}            |
| sync     | {out, exit_code, err } |
| async    | {}                     |
| persist  | {buff, job}            |
| watch    | {buff, job}            |


These runners are available for the following commands
- artisan
- composer
- sail
- npm
- yarn

This is to provide the option to you to build what ever you need for you development experience.

The commands have a default runner configure that you can customize
```lua
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
```


## Send to Tinker
Working with laravel tinker is a great tool so after thinking how can improve my flow with it I decide that selecting lines and have them send to tinker it was a good idea
So that is exactly what I did with the function `require("laravel").app.sendToTinker()` which will grab the selected lines and send them to the open tinker or open a new one if is not already.
If you copy my keybindings from lazy or you can assign to your like is great.



### Improve your flow.
Is normal that working with a project you have several things that you would like to start automatically.
Lets say for example that you would like to have two windows, one with the test running with every change of file and other with the dump server
we can write this
```lua
local function start()
  vim.cmd "vsplit new"
  local top = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(0)
  vim.api.nvim_win_set_width(0, vim.fn.round(width * 2 / 3))
  vim.cmd "split new"
  local bot = vim.api.nvim_get_current_win()

  local test_run = require("laravel.artisan").run({ "test" }, "watch", { open = false })
  local dump_run = require("laravel.artisan").run({ "dump-server" }, "persist", { open = false })

  vim.api.nvim_win_set_buf(top, test_run.buff)
  vim.api.nvim_win_set_buf(bot, dump_run.buff)
end
```
The function will create an split, and resize it, split again and with these 2 windows will call the commands that want. Since in this case we want to set the position our self we send the option to not open.
After that we only need to set the buffer from the commands into the windows and ready.


Other example to just run everything
```lua
vim.api.nvim_create_user_command("StartMyApp", function ()
  require('laravel.artisan').run({"serve"})
  require('laravel.artisan').run({"queue:restart"})
  require('laravel.artisan').run({"queue:listen"})
  require('laravel.yarn').run({"dev"}, "persist")
end, {})
```
This will create your own command and when run will just call everyone of the commands, and split the windows as it needs and you resize when you want. Remember the `open = false` is an option to not have it display and run in the background.

# Self promotion
I am Ariel I am a developer and also content creator (mostly in Spanish) if you would like to show some love leave a start into the plugin and subscribe to my [Youtube](https://youtube.com/@Alpha_Dev) if you want to show even more love you can support becoming a member on Youtube. But just leaving a like or letting me know that you like and enjoy the plugin is appreciated.


# Collaboration
I am open to review pr if you have ideas or ways to improve the plugin would be great.
