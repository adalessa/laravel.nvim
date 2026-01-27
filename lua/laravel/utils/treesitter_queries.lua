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
  "php_class",
  [[
      (namespace_definition (namespace_name) @namespace)
      (namespace_use_clause) @use
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

vim.treesitter.query.set(
  "json",
  "composer_dependencies",
  [[
    (pair
        key: (string
            (string_content) @key (#match? @key "require|require-dev")
        )
        value: (object
            (pair
                key: (string (string_content) @depen)
            )
        )
    )
  ]]
)
