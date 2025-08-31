local cache = require("laravel.services.cache")
local nio = require("nio")
local a = nio.tests

describe("Cache Service", function()
  local test_cache

  before_each(function()
    test_cache = cache:new()
  end)

  a.it("stores and retrieves a value", function()
    test_cache:put("key", "value")
    assert.are.equal(test_cache:get("key"), "value")
  end)

  a.it("returns default value when key does not exist", function()
    assert.are.equal(test_cache:get("nonexistent_key", "default"), "default")
  end)

  a.it("checks if a key exists", function()
    test_cache:put("key", "value")
    assert.is_true(test_cache:has("key"))
    assert.is_false(test_cache:has("nonexistent_key"))
  end)

  a.it("removes an item by key", function()
    test_cache:put("key", "value")
    test_cache:forget("key")
    assert.is_false(test_cache:has("key"))
  end)

  a.it("remembers and retrieves values using a callback", function()
    local value, err = test_cache:remember("key", 60, function()
      return "calculated_value"
    end)
    assert.are.equal(value, "calculated_value")
    assert.are.equal(test_cache:get("key"), "calculated_value")
    assert.is_nil(err)
  end)

  a.it("flushes all items", function()
    test_cache:put("key1", "value1")
    test_cache:put("key2", "value2")
    test_cache:flush()
    assert.is_false(test_cache:has("key1"))
    assert.is_false(test_cache:has("key2"))
  end)

  a.it("removes items by prefix", function()
    test_cache:put("prefix_key1", "value1")
    test_cache:put("prefix_key2", "value2")
    test_cache:put("other_key", "value3")

    test_cache:forgetByPrefix("prefix_")
    assert.is_false(test_cache:has("prefix_key1"))
    assert.is_false(test_cache:has("prefix_key2"))
    assert.is_true(test_cache:has("other_key"))
  end)
end)

