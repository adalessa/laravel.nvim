local telescope_provider = {}

function telescope_provider:register(app)
  app():register_many({
    artisan_picker = "laravel.telescope.pickers.artisan",
    routes_picker = "laravel.telescope.pickers.routes",
    make_picker = "laravel.telescope.pickers.make",
  })
end

function telescope_provider:boot(app)
end

return telescope_provider
