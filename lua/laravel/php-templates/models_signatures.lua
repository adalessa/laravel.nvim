return [[
/**
 * Render a parameter default value as a PHPDoc expression.
 */
function laravel_nvim_parameter_default(\ReflectionParameter $param): string
{
    if ($param->isDefaultValueConstant()) {
        return '\\' . $param->getDefaultValueConstantName();
    }

    $value = $param->getDefaultValue();

    return match (true) {
        is_null($value) => 'null',
        is_scalar($value) => var_export($value, true),
        is_array($value) => '[]',
        is_object($value) => 'new \\' . get_class($value),
        default => 'null',
    };
}

/**
 * Build the PHPDoc parameter declaration for a reflected method parameter.
 */
function laravel_nvim_builder_parameter(\ReflectionParameter $param): string
{
    $types = match ($param->getType()) {
        null => [],
        default => method_exists($param->getType(), 'getTypes') ? $param->getType()->getTypes() : [$param->getType()],
    };

    $type = implode('|', array_map(fn($type) => $type->getName(), array_filter($types)));

    $default = $param->isDefaultValueAvailable() ? ' = ' . laravel_nvim_parameter_default($param) : '';
    $declaration = ($param->isVariadic() ? '...' : '') . '$' . $param->getName();

    return trim($type . ' ' . $declaration . $default);
}

/**
 * Read the type from a docblock @return tag, ignoring any description.
 * Returns null when the tag is absent.
 */
function laravel_nvim_docblock_tag_return(array $tags): ?string
{
    if (!isset($tags[0])) {
        return null;
    }

    $tag = $tags[0];

    if (method_exists($tag, 'getType') && $tag->getType() !== null) {
        return (string) $tag->getType();
    }

    return (string) $tag;
}

/**
 * Extract the return type expression from a docblock. Nested generic and
 * array-shape types such as "Collection<int, \stdClass>" and "int<0, max>"
 * are kept intact, while a trailing description is ignored.
 */
function laravel_nvim_docblock_return_type(string $docComment): ?string
{
    if (!preg_match('/@return[ \t]+([^\r\n]+)/', $docComment, $matches)) {
        return null;
    }

    $rest = trim($matches[1]);
    $depth = 0;
    $type = '';

    for ($i = 0, $length = strlen($rest); $i < $length; $i++) {
        $char = $rest[$i];

        if ($depth === 0 && ctype_space($char)) {
            break;
        }

        if (str_contains('<({[', $char)) {
            $depth++;
        } elseif (str_contains('>)}]', $char)) {
            $depth--;
        }

        $type .= $char;
    }

    return $type === '' ? null : $type;
}

/**
 * Resolve the builder return type, falling back to the @return tag because most
 * builder methods only declare the return type in the docblock.
 */
function laravel_nvim_builder_return_type(\ReflectionMethod $method): ?string
{
    $return = $method->getReturnType();

    if ($return !== null) {
        return $return->getName();
    }

    return laravel_nvim_docblock_return_type((string) $method->getDocComment());
}
]]
