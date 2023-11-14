return {
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
    local files = vim.fn.systemlist(string.format("fd %s.php", name))

    return files[1], nil
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
