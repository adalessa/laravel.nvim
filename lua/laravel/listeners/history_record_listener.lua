return {
  event = require("laravel.events.command_run_event"),
  handle = function(data, app)
    app("history"):add(data.job_id, data.cmd, data.args, data.options)
  end,
}
