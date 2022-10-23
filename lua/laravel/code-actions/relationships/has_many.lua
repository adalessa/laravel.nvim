local template =[[

    /**
     * @return HasMany<%s>
     */
    public function %s(): HasMany
    {
        return $this->hasMany(%s::class);
    }]]

---insert the has many relation
---@param class laravel.class
---@param model string
---@param name string
return function(class, model, name)
    class:add_use("Illuminate\\Database\\Eloquent\\Relations\\HasMany")
    class:add_method(
        string.format(template, model, name, model)
    )
end
