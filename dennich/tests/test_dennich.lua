local T = MiniTest.new_set()

T['works'] = function()
    local x = 1 + 1
    MiniTest.expect.equality(x, 2)
end

-- URL validation tests with parametrization
T['test is url'] = MiniTest.new_set({
    parametrize = {
        -- Valid URLs - Should return true
        { 'https://example.com', true, 'simple https URL' },
        { 'http://example.com', true, 'simple http URL' },
        { 'https://example.com/path/to/resource', true, 'URL with path' },
        {
            'https://example.com/search?q=test&page=1',
            true,
            'URL with query parameters',
        },
        { 'https://localhost:8080/api', true, 'URL with port' },
        { 'https://my_site.example.com', true, 'URL with underscore' },
        { 'https://my-site.example.com', true, 'URL with hyphen' },
        {
            'https://www.westlifeimobiliaria.com/imovel/21122132',
            true,
            'westlife URL',
        },

        -- Invalid URLs - Should return false
        {
            'example.com',
            false,
            'URL without protocol',
        },
        { 'ftp://example.com', false, 'non-http protocol' },
        { 'https://', false, 'incomplete URL' },
        { 'https://example.com/path with space', false, 'URL with space' },
        { '', false, 'empty string' },
        -- { nil, false, 'nil value' },
        {
            'https://example.com/<script>',
            false,
            'URL with invalid characters',
        },
    },
})

T['test is url']['validates urls'] = function(input, expected, description)
    MiniTest.expect.equality(require('dennich').is_url(input), expected)
end

return T
