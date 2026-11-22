return {
  {
    name = "dto",
    status = "covered",
    specs = { "tests/unit/api_response_spec.lua" },
  },
  {
    name = "cache",
    status = "covered",
    specs = { "tests/unit/services/cache_spec.lua" },
  },
  {
    name = "utils",
    status = "covered",
    specs = {
      "tests/unit/utils/buffer_spec.lua",
      "tests/unit/utils/error_spec.lua",
    },
  },
  {
    name = "services",
    status = "covered",
    specs = {
      "tests/unit/services/api_spec.lua",
      "tests/unit/services/command_generator_spec.lua",
      "tests/unit/services/code_spec.lua",
      "tests/unit/services/class_spec.lua",
      "tests/unit/services/status_spec.lua",
    },
  },
  {
    name = "loaders",
    status = "covered",
    specs = {
      "tests/unit/loaders/artisan_loader_spec.lua",
      "tests/unit/loaders/routes_loader_spec.lua",
      "tests/unit/loaders/user_commands_loader_spec.lua",
    },
  },
  {
    name = "completion",
    status = "covered",
    specs = {
      "tests/unit/completion/model_completion_identification_spec.lua",
      "tests/unit/completion/parser_guard_spec.lua",
    },
  },
  {
    name = "test-tooling",
    status = "covered",
    specs = { "tests/unit/support/deps_spec.lua" },
  },
  {
    name = "extensions-provider",
    status = "covered",
    specs = { "tests/unit/providers/extensions_provider_spec.lua" },
  },
  {
    name = "model-docblocks",
    status = "covered",
    specs = {
      "tests/unit/services/eloquent_helper_spec.lua",
      "tests/integration/php-templates/models_signatures_spec.lua",
      "tests/integration/php-templates/models_spec.lua",
    },
  },
  { name = "bootstrap", status = "pending", specs = {} },
  { name = "container-factory", status = "pending", specs = {} },
  {
    name = "options-env",
    status = "covered",
    specs = { "tests/unit/core/env_spec.lua" },
  },
  { name = "events", status = "pending", specs = {} },
  { name = "core-services", status = "pending", specs = {} },
  { name = "commands", status = "pending", specs = {} },
  {
    name = "extensions-completion",
    status = "covered",
    specs = {
      "tests/unit/completion/dispatcher_spec.lua",
      "tests/unit/completion/providers_spec.lua",
      "tests/unit/completion/cmp_source_spec.lua",
      "tests/unit/completion/blink_source_spec.lua",
      "tests/unit/completion/provider_spec.lua",
      "tests/component/completion/inertia_provider_spec.lua",
    },
  },
  { name = "model-info", status = "pending", specs = {} },
  { name = "route-info", status = "pending", specs = {} },
  {
    name = "diagnostics",
    status = "covered",
    specs = { "tests/unit/extensions/diagnostic/views_spec.lua" },
  },
  { name = "composer-info", status = "pending", specs = {} },
  { name = "tinker", status = "pending", specs = {} },
  { name = "command-center", status = "pending", specs = {} },
  {
    name = "artisan-hub",
    status = "covered",
    specs = { "tests/unit/extensions/artisan_hub/hub_command_spec.lua" },
  },
  { name = "pickers", status = "pending", specs = {} },
  { name = "health", status = "covered", specs = { "tests/unit/core/health_spec.lua" } },
  { name = "e2e", status = "pending", specs = {} },
}
