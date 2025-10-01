return {
  event = require("laravel.events.command_run_event"),
  handle = function(data, app)
    if vim.tbl_contains({ "composer", "artisan" }, data.cmd) then
      Laravel("cache"):flush()
      app("log"):info("CacheInvalidationListener: cache clear.")
    end
  end,
}
