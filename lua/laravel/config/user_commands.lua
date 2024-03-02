return {
  artisan = {
    ["db:fresh"] = {
      cmd = { "migrate:fresh", "--seed" },
      desc = "Re-creates the db and seed's it",
    },
  },
  npm = {
    build = {
      cmd = { "run", "build" },
      desc = "Builds the javascript assets",
    },
    dev = {
      cmd = { "run", "dev" },
      desc = "Builds the javascript assets",
    },
  },
  composer = {
    autoload = {
      cmd = { "dump-autoload" },
      desc = "Dumps the composer autoload",
    },
  },
}
