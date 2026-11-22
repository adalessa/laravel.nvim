local signatures = require("laravel.php-templates.models_signatures")

local function run_php(fixture)
  local file = vim.fn.tempname() .. ".php"
  vim.fn.writefile(vim.split("<?php\n" .. signatures .. "\n" .. fixture, "\n"), file)

  local result = vim.system({ "php", file }, { text = true }):wait()
  vim.fn.delete(file)

  assert.equals(0, result.code, result.stderr or "")
  assert.is_not_nil(result.stdout)

  return vim.json.decode(result.stdout)
end

describe("builder signature helpers", function()
  it("keeps nested @return types intact", function()
    local result = run_php([==[
class ReturnTypeFixture
{
    /** @return \Illuminate\Support\Collection<int, \stdClass> */
    public function generic() {}

    /** @return int<0, max> */
    public function range() {}

    /** @return array{\DateTimeInterface, \DateTimeInterface} */
    public function shape() {}

    /** @return bool Whether the query was executed */
    public function described() {}

    /** @return $this */
    public function fluent() {}

    /** @return static */
    public function fluentStatic() {}

    /**
     * @return
     *     \DateTimeInterface
     */
    public function emptyReturn() {}

    public function noDocblock() {}
}

$reflection = new ReflectionClass(ReturnTypeFixture::class);

$result = [];
foreach (['generic', 'range', 'shape', 'described', 'fluent', 'fluentStatic', 'emptyReturn', 'noDocblock'] as $method) {
    $result[$method] = laravel_nvim_builder_return_type($reflection->getMethod($method));
}

echo json_encode($result, JSON_THROW_ON_ERROR);
]==])

    assert.same({
      generic = "\\Illuminate\\Support\\Collection<int, \\stdClass>",
      range = "int<0, max>",
      shape = "array{\\DateTimeInterface, \\DateTimeInterface}",
      described = "bool",
      fluent = "$this",
      fluentStatic = "static",
      emptyReturn = vim.NIL,
      noDocblock = vim.NIL,
    }, result)
  end)

  it("renders parameter defaults and variadic markers", function()
    local result = run_php([==[
class ParameterFixture
{
    public function where($column, $operator = null, $value = null, $boolean = 'and') {}

    public function variadic(string $prefix, string ...$values) {}

    public function defaults(int $limit = 10, float $ratio = 1.5, bool $flag = true, array $columns = ['*'], string $label = "it's") {}
}

$reflection = new ReflectionClass(ParameterFixture::class);

$result = [];
foreach (['where', 'variadic', 'defaults'] as $method) {
    $result[$method] = array_map(
        'laravel_nvim_builder_parameter',
        $reflection->getMethod($method)->getParameters()
    );
}

echo json_encode($result, JSON_THROW_ON_ERROR);
]==])

    assert.same({
      where = { "$column", "$operator = null", "$value = null", "$boolean = 'and'" },
      variadic = { "string $prefix", "string ...$values" },
      defaults = {
        "int $limit = 10",
        "float $ratio = 1.5",
        "bool $flag = true",
        "array $columns = []",
        "string $label = 'it\\'s'",
      },
    }, result)
  end)

  it("reads the type from a docblock @return tag", function()
    local result = run_php([==[
class TagWithTypeStub
{
    public function getType()
    {
        return new class {
            public function __toString(): string
            {
                return 'bool';
            }
        };
    }

    public function __toString(): string
    {
        return 'bool Whether the query was executed';
    }
}

echo json_encode([
    'present' => laravel_nvim_docblock_tag_return(['$this']),
    'missing' => laravel_nvim_docblock_tag_return([]),
    'typed' => laravel_nvim_docblock_tag_return([new TagWithTypeStub()]),
], JSON_THROW_ON_ERROR);
]==])

    assert.same({ present = "$this", missing = vim.NIL, typed = "bool" }, result)
  end)
end)
