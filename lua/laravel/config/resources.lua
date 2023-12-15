-- each element represent a command that after execution should open a file
-- if the return is a string is use as directory to search file.
-- if the return is a function will call and expects the result to be an string
return {
  ["make:cast"] = "app/Casts",
  ["make:channel"] = "app/Broadcasting",
  ["make:command"] = "app/Console/Commands",
  ["make:component"] = "app/View/Components",
  ["make:controller"] = "app/Http/Controllers",
  ["make:event"] = "app/Events",
  ["make:exception"] = "app/Exceptions",
  ["make:factory"] = function(name)
    return string.format("database/factories/%sFactory.php", name)
  end,
  ["make:job"] = "app/Jobs",
  ["make:listener"] = "app/Listeners",
  ["make:mail"] = "app/Mail",
  ["make:middleware"] = "app/Http/Middleware",
  ["make:migration"] = function(name)
    return vim.fn.systemlist(string.format("fd %s.php", name))[1]
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
  ["make:view"] = function(name)
    return "resources/views/" .. name:gsub("%.", "/") .. ".blade.php"
  end,
}
