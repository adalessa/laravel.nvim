return [[
// PHP Tinker custom eval template for laravel.nvim
// Auto-generated. Do not edit manually.
//
// TODO: Add more type-checks below for Query Builder, Collection, etc.
// For now: If last value is Eloquent Model, print as array; else use var_dump.

error_reporting(E_ERROR | E_PARSE);

$__tinker_started_at = microtime(true);

require_once __DIR__ . '/../autoload.php';

try {
    $app = require_once __DIR__ . '/../../bootstrap/app.php';
    $app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
}
catch (Throwable $e) {
    echo "Tinker Initialization Error: ".$e->getMessage();
    exit(2);
}

// --- Custom dump handler outside closure (for use/import support) ---
if (!function_exists('nvim_dump')) {
    function nvim_dump($val) {
        // All headers colorized with ANSI codes for Neovim/terminal
        if ($val instanceof Illuminate\Database\Eloquent\Model) {
          Laravel\Prompts\info('Model: '.$val::class);
          Laravel\Prompts\table(
              headers: ['Attribute', 'Value'],
              rows: collect($val->getAttributes())
                  ->map(fn ($value, $key) => [$key, (string) $value])
                  ->values()
                  ->all()
          );
        } else if ($val instanceof Illuminate\Database\Eloquent\Builder) {
          $driver = $val->getConnection()->getDriverName();
          $bindings = $val->getBindings();

          if ($driver === 'sqlite') {
              $explain = Illuminate\Support\Facades\DB::select('EXPLAIN QUERY PLAN '.$val->toSql(), $bindings)[0]->detail ?? 'N/A';
          } else {
              $explain = json_encode($val->explain()->toArray(), JSON_PRETTY_PRINT);
          }

          Laravel\Prompts\info("Query:");
          Laravel\Prompts\warning($val->toRawSql());

          Laravel\Prompts\info("Bindings:");
          Laravel\Prompts\table(
              headers: ['Values'],
              rows: array_map(fn ($value) => [$value], $bindings)
          );

          Laravel\Prompts\info("Connection Driver:");
          Laravel\Prompts\warning($driver);

          Laravel\Prompts\info("Explain:");
          Laravel\Prompts\warning($explain);
        } else {
            dump($val);
        }
    }
}
// ---------------------------------------------------------------

__NVIM_LARAVEL_OUTPUT__

$__tinker_time = (microtime(true) - $__tinker_started_at) * 1000;
echo "\n__tinker_info:".json_encode([
    'time' => $__tinker_time,
    'memory' => memory_get_peak_usage() / 1024 / 1024
]);
]]
