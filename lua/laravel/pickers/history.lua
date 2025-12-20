local Class = require("laravel.utils.class")

local history_picker = Class({
  history_service = "laravel.services.history",
})

function history_picker:run(picker, opts)
  picker.run(opts, self.history_service:get())
end

return history_picker
