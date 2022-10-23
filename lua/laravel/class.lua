local parsers = require("nvim-treesitter.parsers")

vim.treesitter.set_query(
	"php",
	"php_class_information",
	[[
        (namespace_definition (namespace_name) @class_namespace)
        (namespace_use_declaration
            (namespace_use_clause (qualified_name (name) @class_use_class))
        ) @class_use_namespace

        (class_declaration (name) @class_name)

        (base_clause (name) @class_base)

        (class_interface_clause (name) @class_interface)

        (class_declaration
          (declaration_list
              (use_declaration (name) @class_trait)
          )
        )
    ]]
)

---@class laravel.class
---@field bufnr integer
---@field name string
---@field namespace string
---@field namesaces_uses string[]
---@field class_uses string[]
---@field extended_class string|nil
---@field implemented_classes string[]
---@field traits string[]
---@field insert_use_position integer
local Class = {
    bufnr = 0,
	name = "",
	namespace = "",
	namesaces_uses = {},
	class_uses = {},
	extended_class = nil,
	implemented_classes = {},
	traits = {},
    insert_use_position = 0,
}

---creates a new class
---@param bufnr integer
---@return laravel.class
function Class:new(bufnr)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    self.bufnr = bufnr
    self:_load()

    return o
end

function Class:_load()
	local query = vim.treesitter.get_query("php", "php_class_information")

    local bufnr = self.bufnr

	local parser = parsers.get_parser(bufnr)
    -- extrange without calling this like this have an error
    parser:parse()
	local tree = unpack(parser:parse())

    local last_namespace_row = 0
    local namespace_row = 0

	for id, node in query:iter_captures(tree:root(), bufnr) do
		if query.captures[id] == "class_name" then
			self.name = vim.treesitter.get_node_text(node, bufnr)
		elseif query.captures[id] == "class_namespace" then
			self.namespace = vim.treesitter.get_node_text(node, bufnr)
            namespace_row = node:start()
		elseif query.captures[id] == "class_use_namespace" then
			table.insert(self.namesaces_uses or {}, vim.treesitter.get_node_text(node, bufnr))
            last_namespace_row = node:start()
		elseif query.captures[id] == "class_use_class" then
			table.insert(self.class_uses or {}, vim.treesitter.get_node_text(node, bufnr))
		elseif query.captures[id] == "class_base" then
			self.extended_class = vim.treesitter.get_node_text(node, bufnr)
		elseif query.captures[id] == "class_interface" then
			table.insert(self.implemented_classes or {}, vim.treesitter.get_node_text(node, bufnr))
		elseif query.captures[id] == "class_trait" then
			table.insert(self.traits or {}, vim.treesitter.get_node_text(node, bufnr))
		end
	end

    if last_namespace_row ~= 0 then
        self.insert_use_position = last_namespace_row + 1
    else
        self.insert_use_position = namespace_row + 1
    end
end

---checks if a class name is already being use
---@param target string
---@return boolean
function Class:has_class_use(target)
    for _, use in pairs(self.class_uses) do
        if use == target then
            return true
        end
    end

    return false
end

---checks if a class name is already being use
---@param target string
---@return boolean
function Class:has_fqn_use(target)
    for _, use in pairs(self.namesaces_uses) do
        if string.format("use %s;", target) == use then
            return true
        end
    end

    return false
end

---Insert into the class the use
---@param fqn string
function Class:add_use(fqn)
    if self:has_fqn_use(fqn) then
        return
    end
    vim.api.nvim_buf_set_lines(
        self.bufnr,
        self.insert_use_position,
        self.insert_use_position,
        false,
        { string.format("use %s;", fqn) }
    )

    --- since the file changed better to reload it
    self:_load()
end

---adds a method at the end
---@param method string
function Class:add_method(method)
    vim.api.nvim_buf_set_lines(0, -2, -2, false, vim.split(method, "\n"))

    self:_load()
end

return Class
