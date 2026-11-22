local eloquent_helper = require("laravel.services.eloquent_helper")

local function build(builder_methods)
  local lines = eloquent_helper.build_eloquent_docblocks({
    {
      class = "App\\Models\\User",
      attributes = {},
      scopes = {},
      relations = {},
    },
  }, builder_methods)

  return table.concat(lines, "\n")
end

local function assert_has_block(docblock, expected)
  assert.truthy(
    docblock:find(expected, 1, true),
    string.format("expected docblock to contain:\n%s\n\ngot:\n%s", expected, docblock)
  )
end

describe("eloquent docblocks", function()
  it("renders builder methods using the return field from the template", function()
    local docblock = build({
      {
        name = "where",
        parameters = { "$column", "$operator = null", "$value = null", "$boolean = 'and'" },
        ["return"] = "$this",
      },
      {
        name = "get",
        parameters = { "$columns = []" },
        ["return"] = "\\Illuminate\\Support\\Collection<int, \\stdClass>",
      },
      {
        name = "count",
        parameters = { "$columns = []" },
        ["return"] = "int<0, max>",
      },
    })

    assert_has_block(
      docblock,
      " * @method static \\Illuminate\\Database\\Eloquent\\Builder<User>|User where($column, $operator = null, $value = null, $boolean = 'and')"
    )
    assert_has_block(
      docblock,
      " * @method static \\Illuminate\\Support\\Collection<int, \\stdClass> get($columns = [])"
    )
    assert_has_block(docblock, " * @method static int<0, max> count($columns = [])")
  end)

  it("keeps variadic parameter markers", function()
    local docblock = build({
      {
        name = "merge",
        parameters = { "string $prefix", "string ...$values" },
        ["return"] = "$this",
      },
    })

    assert_has_block(docblock, "merge(string $prefix, string ...$values)")
  end)

  it("normalizes special builder return types", function()
    local docblock = build({
      { name = "delete", parameters = {}, ["return"] = "never" },
      { name = "query", parameters = {} },
      { name = "exists", parameters = {}, ["return"] = "static" },
      { name = "find", parameters = { "$id", "$columns = []" }, ["return"] = "object" },
    })

    assert_has_block(docblock, " * @method static void delete()")
    assert_has_block(docblock, " * @method static mixed query()")
    assert_has_block(docblock, " * @method static \\Illuminate\\Database\\Eloquent\\Builder<User>|User exists()")
    assert_has_block(docblock, " * @method static User find($id, $columns = [])")
  end)
end)
