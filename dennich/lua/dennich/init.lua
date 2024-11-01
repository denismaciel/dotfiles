local M = {}

M.sum = function(a, b)
    return a + b
end

M.is_url = function(text)
    if text == nil then
        return false
    end
    local url_pattern = '^https?://[%w-_%.%?%.:/%+=&;,@]+$'
    return string.match(text, url_pattern) ~= nil
end

return M
