return {
  artisan = {
    ["db:fresh"] = {
      cmd = { "migrate:fresh", "--seed" },
      desc = "Re-creates the db and seed's it",
    },
  },
}
