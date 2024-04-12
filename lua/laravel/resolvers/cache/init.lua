local cache_decorator = require 'laravel.resolvers.cache.decorator'

return {
  routes = {
    ---@param onSuccess fun(routes: Route[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(
      onSuccess,
      onFailure
    )
      return cache_decorator(
        require 'laravel.resolvers.routes_resolver',
        'routes',
        onSuccess,
        onFailure
      )
    end
  },
  commands = {
    ---@param onSuccess fun(commands: Command[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(
      onSuccess,
      onFailure
    )
      return cache_decorator(
        require 'laravel.resolvers.commands_resolver',
        'commands',
        onSuccess,
        onFailure
      )
    end
  },
  views = {
    ---@param onSuccess fun(views: View[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(
      onSuccess,
      onFailure
    )
      return cache_decorator(
        require 'laravel.resolvers.views_resolver',
        'views',
        onSuccess,
        onFailure
      )
    end
  },
  configs = {
    ---@param onSuccess fun(configs: string[])|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(
      onSuccess,
      onFailure
    )
      return cache_decorator(
        require 'laravel.resolvers.configs_resolver',
        'configs',
        onSuccess,
        onFailure
      )
    end
  },
  paths = {
    ---@param resource string
    ---@param onSuccess fun(path: string)|nil
    ---@param onFailure fun(errorMessage: string)|nil
    resolve = function(
      resource,
      onSuccess,
      onFailure
    )
      return cache_decorator(
        require 'laravel.resolvers.resource_path_resolver',
        'paths_' .. resource,
        onSuccess,
        onFailure
      )
    end
  },
}
