local template =[[

    /**
     * @return HasOne<%s>
     */
    public function %s(): HasOne
    {
        return $this->hasOne(%s::class);
    }]]

---insert the has one relation
---@param class laravel.class
---@param model string
---@param name string
return function(class, model, name)
    class:add_use("Illuminate\\Database\\Eloquent\\Relations\\HasOne")
    class:add_method(
        string.format(template, model, name, model)
    )
end
