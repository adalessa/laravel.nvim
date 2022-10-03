local lib = require("neotest.lib")
local async = require("neotest.async")
local logger = require("neotest.logging")
local utils = require("laravel.neotest.utils")

local sail = require("laravel.sail")

---@class neotest.Adapter
---@field name string
local NeotestAdapter = { name = "neotest-laravel-phpunit" }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
NeotestAdapter.root = lib.files.match_root_pattern("composer.json", "phpunit.xml")

---@async
---@param file_path string
---@return boolean
function NeotestAdapter.is_test_file(file_path)
    if string.match(file_path, "vendor/") or not string.match(file_path, "tests/") then
        return false
    end
    return vim.endswith(file_path, "Test.php")
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapter.discover_positions(file_path)
    local query = [[
    ((class_declaration
      name: (name) @namespace.name (#match? @namespace.name "Test")
    )) @namespace.definition

    ((method_declaration
      (name) @test.name (#match? @test.name "test")
    )) @test.definition

    (((comment) @test_comment (#match? @test_comment "\\@test") .
      (method_declaration
        (name) @test.name
      ) @test.definition
    ))
  ]]

    return lib.treesitter.parse_positions(file_path, query, {
        position_id = utils.make_test_id,
    })
end

---@return string|table
local function get_phpunit_cmd()
    if Laravel.properties.uses_sail then
        return { "vendor/bin/sail", "phpunit" }
    end

    if vim.fn.filereadable("vendor/bin/phpunit") then
        return "vendor/bin/phpunit"
    end

    return "phpunit"
end

local path_mapping = {}

if Laravel.properties.uses_sail then
    path_mapping = { ["/var/www/html"] = vim.fn.getcwd() }
end

---get's the relative file from the absolute
---@param filename string
---@return string
local function get_test_path(filename)
    for remote_path, local_path in pairs(path_mapping) do
        if string.sub(filename, 1, string.len(local_path)) == local_path then
            filename = remote_path .. string.sub(filename, string.len(local_path) + 1)
            break
        end
    end

    return filename
end

local function convert_paths(results)
    local converted_results = {}
    for test, result in pairs(results) do
        for remote_path, local_path in pairs(path_mapping) do
            converted_results[string.gsub(test, remote_path, local_path)] = result
        end
    end

    return converted_results
end

---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function NeotestAdapter.build_spec(args)
    local position = args.tree:data()
    local results_path = async.fn.tempname()

    local binary = get_phpunit_cmd()

    local command = vim.tbl_flatten({
        binary,
        position.name ~= "tests" and get_test_path(position.path),
        "--log-junit=" .. results_path,
    })

    if position.type == "test" then
        local script_args = vim.tbl_flatten({
            "--filter",
            position.name,
        })

        command = vim.tbl_flatten({
            command,
            script_args,
        })
    end

    return {
        command = command,
        context = {
            results_path = results_path,
        },
    }
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return neotest.Result[]
function NeotestAdapter.results(test, result, tree)
    local output_file = test.context.results_path

    if Laravel.properties.uses_sail then
        -- need to copy the file
        sail.exec(string.format("cp laravel.test:%s %s", output_file, output_file))
    end

    local ok, data = pcall(lib.files.read, output_file)
    if not ok then
        logger.error("No test output file found:", output_file)
        return {}
    end

    local ok, parsed_data = pcall(lib.xml.parse, data)
    if not ok then
        logger.error("Failed to parse test output:", output_file)
        return {}
    end

    local ok, results = pcall(utils.get_test_results, parsed_data, output_file)
    if not ok then
        logger.error("Could not get test results", output_file)
        return {}
    end

    return convert_paths(results)
end

local is_callable = function(obj)
    return type(obj) == "function" or (type(obj) == "table" and obj.__call)
end

setmetatable(NeotestAdapter, {
    __call = function(_, opts)
        if is_callable(opts.phpunit_cmd) then
            get_phpunit_cmd = opts.phpunit_cmd
        elseif opts.phpunit_cmd then
            get_phpunit_cmd = function()
                return opts.phpunit_cmd
            end
        end

        if is_callable(opts.path_mapping) then
            path_mapping = opts.path_mapping()
        end

        return NeotestAdapter
    end,
})

return NeotestAdapter
