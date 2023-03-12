---@class CommandPreview
---@field lines table
---@field highlights table

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

local function coma(str)
	if #str > 0 then
		return ","
	end
	return " "
end

local function required(is_required)
	if is_required then
		return "<required>"
	end

	return ""
end

--- Generates the preview and highlight for a command
---@param command LaravelCommand
---@return CommandPreview
local generate = function(command)
	local lines = {}

	local highlights = {}

	-- description
	table.insert(lines, "Description:")
	table.insert(highlights, {
		"WarningMsg",
		#lines - 1,
		0,
		-1,
	})

	table.insert(lines, "\t" .. command.description)

	table.insert(lines, "")

	-- usage
	table.insert(lines, "Usage:")
	table.insert(highlights, {
		"WarningMsg",
		#lines - 1,
		0,
		-1,
	})

	table.insert(lines, "\t" .. vim.fn.join(command.usage, " "))

	table.insert(lines, "")
	-- arguments
	if tablelength(command.definition.arguments) > 0 then
		table.insert(lines, "Arguments:")
		table.insert(highlights, {
			"WarningMsg",
			#lines - 1,
			0,
			-1,
		})

		local max_argument = 0
		local max_required = 0
		local arguments = {}
		for _, argument in pairs(command.definition.arguments) do
			table.insert(arguments, {
				argument.name,
				required(argument.is_required),
				argument.description,
			})

			if #argument.name > max_argument then
				max_argument = #argument.name
			end
			if argument.is_required then
				max_required = 10
			end
		end

		for _, argument in pairs(arguments) do
			local argument_line = string.format(
				"\t%-" .. max_argument .. "s %-" .. max_required .. "s \t\t%s",
				argument[1],
				argument[2],
				argument[3]
			)
      table.insert(lines, argument_line)

			table.insert(highlights, {
				"String",
				#lines - 1,
				0,
				max_argument + 1,
			})

			table.insert(highlights, {
				"ErrorMsg",
				#lines - 1,
				max_argument + 1,
				max_argument + 1 + max_required + 1,
			})

		end
	end

	-- options
	table.insert(lines, "")

	if tablelength(command.definition.options) > 0 then
		table.insert(lines, "Options:")
		table.insert(highlights, {
			"WarningMsg",
			#lines - 1,
			0,
			-1,
		})

		local options = {}
		local max_shortcut = 0
		local max_name = 0
		for _, option in pairs(command.definition.options) do
			table.insert(options, {
				option.shortcut,
				option.name,
				option.description,
			})
			if #option.shortcut > max_shortcut then
				max_shortcut = #option.shortcut
			end
			if #option.name > max_name then
				max_name = #option.name
			end
		end

		for _, option in pairs(options) do
			local option_line = string.format(
				"\t%" .. max_shortcut .. "s%s %-" .. max_name .. "s\t\t%s",
				option[1],
				coma(option[1]),
				option[2],
				option[3]
			)
			table.insert(lines, option_line)
			table.insert(highlights, {
				"String",
				#lines - 1,
				0,
				max_shortcut + max_name + 4,
			})
		end
	end

	return {
		lines = lines,
		highlights = highlights,
	}
end

return {
	generate = generate,
}
