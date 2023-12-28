# Ideas

## To implement
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
- [X] replace anonymous function from mapping with dedicated functions to have descriptions
- [X] using the get_type in completion is dangerus. better to replace it with ide-helper
- [X] recipes for ide-helper models and eloquent
- [X] implement watch
- [X] implement alternate file for livewire components `:A`
- [X] extend api .sync and .async with better respons object. maybe create a new object with method for example `.successful()` and `.failed()`
- [ ] rework environment
- [ ] re-write the readme and translate (not forget fd as dependency) move all info from readme to doc

## Environment
How I want the environment

I have environments, resolver and executables
In environment only have `executables`
I need to get from the configuration per project the executables

I want it to be set on the configuration

So do I need the resolver ?
Is not clear ?
I already have the `environment` term so it's hard to tink into ahother

So I have diferent environments
Executables not found should use try to look for it
```lua
local environments = {
    local = {
        executables = {
            artisan = {"php", "artisan"},
            composer = {"composer"},
            npm = {"npm"},
        }
    }
}
```
