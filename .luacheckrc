-- Rerun tests only if their modification time changed.
cache = true

std = luajit
codes = true

self = false

-- Glorious list of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
  "212", -- Unused argument, In the case of callback function, _arg_name is easier to understand than _, so this option is set to off.
  -- Pre-existing baseline debt. Remove these categories incrementally as
  -- the coverage phases touch each file; they are not enforced yet.
  "211", -- Unused variable
  "213", -- Unused loop variable
  "311", -- Value assigned to variable is unused
  "411", -- Variable was previously defined
  "421", -- Shadowing a local variable
  "431", -- Shadowing an upvalue
  "432", -- Shadowing an upvalue argument
  "433", -- Shadowing an upvalue loop variable
  "631", -- Line length is enforced by stylua
}

globals = {
  "vim",
  "Laravel",
  "describe",
  "it",
  "before_each",
  "after_each",
  "assert",
  "A",
  "LoadStub",
  "CreateApiMock",
}

-- Global objects defined by the C code or optional plugins
read_globals = {
  "Snacks",
}
