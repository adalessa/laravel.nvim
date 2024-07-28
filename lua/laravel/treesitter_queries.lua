vim.treesitter.query.set(
  "php",
  "laravel_views",
  [[
      (function_call_expression
        (name) @function_name (#eq? @function_name "view")
        (arguments (argument (string) @view))
      )
      (member_call_expression
        (name) @member_name (#eq? @member_name "view")
        (arguments (argument (string) @view))
      )

      (scoped_call_expression
        scope: (name) @static (#eq? @static "Route")
        name: (name) @method (#eq? @method "view")
        arguments: (arguments (
          (argument) @route
          (argument (string) @view)
          ))
      )
    ]]
)

vim.treesitter.query.set(
  "php",
  "laravel_view_arguments",
  [[
      (scoped_call_expression
        scope: (name) @class
        name: (name) @method
        arguments: (arguments) @routeViewArguments (#eq? @method "view") (#eq? @class "Route")
      )
      (function_call_expression
        function: (name) @func
        arguments: (arguments) @viewFunctionArugments (#eq? @func "view")
      )
      (member_call_expression
        object: (function_call_expression
            function: (name) @function (#eq? @function "response")
          )
          name: (name) @method
          arguments: (arguments) @viewMethodArugments (#eq? @method "view")
      )
    ]]
)

vim.treesitter.query.set(
  "php",
  "laravel_route_argument",
  [[
      (function_call_expression
        function: (name) @function
        arguments: (arguments) @routeFunctionArugments (#eq? @function "route")
      )
    ]]
)

vim.treesitter.query.set(
  "php",
  "laravel_config_argument",
  [[
      (function_call_expression
        function: (name) @function
        arguments: (arguments) @configFunctionArugments (#eq? @function "config")
      )
    ]]
)

vim.treesitter.query.set(
  "php",
  "php_class",
  [[
      (namespace_definition (namespace_name) @namespace)
      (class_declaration (name) @class)
      (method_declaration
          (visibility_modifier) @method_visibility
          (name) @method_name
      )
      (property_declaration
        (visibility_modifier) @property_visibility
        (property_element
          (variable_name
            (name) @property_name
            )
        )
      )
    ]]
)
