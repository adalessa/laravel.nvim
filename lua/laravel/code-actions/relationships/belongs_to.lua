local template = [[

    /**
     * @return BelongsTo<%s, %s>
     */
    public function %s(): BelongsTo
    {
        return $this->belongsTo(%s::class);
    }]]

---insert the belongs to relation
---@param class laravel.class
---@param model string
---@param name string
return function(class, model, name)
    class:add_use("Illuminate\\Database\\Eloquent\\Relations\\BelongsTo")
    class:add_method(
        string.format( template, model, class.name, name, model)
    )
end
