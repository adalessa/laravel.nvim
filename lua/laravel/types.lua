---@class laravel.dto.class
---@field fqn string
---@field class string
---@field namespace string
---@field position laravel.dto.position
---@field methods table<string, laravel.dto.method>
---@field properties table<string, laravel.dto.property>

---@class laravel.dto.method
---@field fqn string
---@field name string
---@field visibility "public" | "protected" | "private"
---@field position laravel.dto.position

---@class laravel.dto.property
---@field name string
---@field visibility "public" | "protected" | "private"
---@field position laravel.dto.position

---@class laravel.dto.position
---@field start laravel.dto.pos
---@field end_ laravel.dto.pos

---@class laravel.dto.pos
---@field row number
---@field col number

---@class laravel.dto.models_response
---@field models table<string, laravel.dto.model>
---@field builderMethods laravel.dto.builder_method[]

---@class laravel.dto.model
---@field table string
---@field class string
---@field database string
---@field uri string
---@field attributes laravel.dto.model_attribute[]
---@field relations table<string, laravel.dto.model_relation>
---@field scopes table<string, laravel.dto.model_scope>
---@field events table<string, laravel.dto.model_event>
---@field observers table<string, laravel.dto.model_observer>

---@class laravel.dto.model_attribute
---@field name string
---@field type string
---@field cast string
---@field title_case string
---@field nullable boolean
---@field unique boolean
---@field increments boolean
---@field fillable boolean
---@field hidden boolean
---@field documented boolean

---@class laravel.dto.model_relation

---@class laravel.dto.model_scope

---@class laravel.dto.model_event

---@class laravel.dto.model_observer

---@class laravel.dto.builder_method
---@field name string
---@field parameters string[]
---@field return string

---@class laravel.dto.model_response
---@field model laravel.dto.model
---@field class laravel.dto.class

---@class laravel.dto.paths_response
---@field app string
---@field base string
---@field config string
---@field public string
---@field resources string
---@field storage string
---@field views string
