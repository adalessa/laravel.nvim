local cache_decorator = require "laravel.resolvers.cache.decorator"

return {
  routes = {
    ---@param onSuccess fun(routes: Route[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(onSuccess, onFailure)
      return cache_decorator {
        decorated = require "laravel.resolvers.routes_resolver",
        key = "routes",
        onSuccess = onSuccess,
        onFailure = onFailure,
      }
    end,
  },
  commands = {
    ---@param onSuccess fun(commands: Command[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(onSuccess, onFailure)
      return cache_decorator {
        decorated = require "laravel.resolvers.commands_resolver",
        key = "commands",
        onSuccess = onSuccess,
        onFailure = onFailure,
      }
    end,
  },
  views = {
    ---@param onSuccess fun(views: View[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(onSuccess, onFailure)
      return cache_decorator {
        decorated = require "laravel.resolvers.views_resolver",
        key = "views",
        onSuccess = onSuccess,
        onFailure = onFailure,
      }
    end,
  },
  configs = {
    ---@param onSuccess fun(config: Config)|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(onSuccess, onFailure)
      return cache_decorator {
        decorated = require "laravel.resolvers.configs_resolver",
        key = "configs",
        onSuccess = onSuccess,
        onFailure = onFailure,
      }
    end,
  },
  paths = {
    ---@param resource string
    ---@param onSuccess fun(path: string)|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(resource, onSuccess, onFailure)
      return cache_decorator {
        decorated = require "laravel.resolvers.resource_path_resolver",
        key = "paths_" .. resource,
        onSuccess = onSuccess,
        onFailure = onFailure,
        args = { resource },
      }
    end,
  },
}
