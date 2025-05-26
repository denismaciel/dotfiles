local M = {}

local function execute_curl(url, method, headers, data)
    local cmd = { 'curl', '-s', '-X', method }

    if headers then
        for _, header in ipairs(headers) do
            table.insert(cmd, '-H')
            table.insert(cmd, '"' .. header .. '"')
        end
    end

    local temp_file = nil
    if data then
        temp_file = os.tmpname()
        local file = io.open(temp_file, 'w')
        file:write(data)
        file:close()

        table.insert(cmd, '-d')
        table.insert(cmd, '@' .. temp_file)
    end

    table.insert(cmd, url)

    local handle = io.popen(table.concat(cmd, ' '))
    local result = handle:read('*a')
    handle:close()

    if temp_file then
        os.remove(temp_file)
    end

    return result
end

local function parse_json_simple(json_str)
    local result = {}

    local access_token = json_str:match('"accessJwt":"([^"]+)"')
    if access_token then
        result.accessJwt = access_token
    end

    local did = json_str:match('"did":"([^"]+)"')
    if did then
        result.did = did
    end

    local error_msg = json_str:match('"error":"([^"]+)"')
    if error_msg then
        result.error = error_msg
    end

    return result
end

function M.create_session(identifier, password)
    local url = 'https://bsky.social/xrpc/com.atproto.server.createSession'
    local safe_password = password:gsub('"', '\\"')
    local data = string.format(
        '{"identifier":"%s","password":"%s"}',
        identifier,
        safe_password
    )
    local headers = { 'Content-Type: application/json; charset=utf-8' }

    local response = execute_curl(url, 'POST', headers, data)
    local parsed = parse_json_simple(response)

    if parsed.error then
        return nil, 'Authentication failed: ' .. parsed.error
    end

    if not parsed.accessJwt or not parsed.did then
        return nil, 'Invalid response from server'
    end

    return {
        access_token = parsed.accessJwt,
        did = parsed.did,
    }
end

function M.create_post(session, text)
    if not session or not session.access_token or not session.did then
        return nil, 'Invalid session'
    end

    local timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    local url = 'https://bsky.social/xrpc/com.atproto.repo.createRecord'

    local escaped_text = text:gsub('"', '\\"')
    local data = string.format(
        [[{
        "repo": "%s",
        "collection": "app.bsky.feed.post",
        "record": {
            "$type": "app.bsky.feed.post",
            "text": "%s",
            "createdAt": "%s"
        }
    }]],
        session.did,
        escaped_text,
        timestamp
    )

    local headers = {
        'Content-Type: application/json',
        'Authorization: Bearer ' .. session.access_token,
    }

    local response = execute_curl(url, 'POST', headers, data)
    local parsed = parse_json_simple(response)

    if parsed.error then
        return nil, 'Post creation failed: ' .. parsed.error
    end

    return true, 'Post created successfully'
end

function M.post(identifier, password, text)
    local session, err = M.create_session(identifier, password)
    if not session then
        return nil, err
    end

    return M.create_post(session, text)
end

function M.post_from_neovim()
    local identifier = os.getenv('BLUESKY_IDENTIFIER')
    local password = os.getenv('BLUESKY_PASSWORD')

    if not identifier or not password then
        vim.notify(
            'Error: BLUESKY_IDENTIFIER and BLUESKY_PASSWORD environment variables must be set',
            vim.log.levels.ERROR
        )
        return
    end

    local input = vim.fn.input('Post to Bluesky: ')
    if input == '' then
        return
    end

    local success, message = M.post(identifier, password, input)
    if success then
        vim.notify(message, vim.log.levels.INFO)
    else
        vim.notify('Error: ' .. message, vim.log.levels.ERROR)
    end
end

if arg and arg[0] and arg[0]:match('bluesky%.lua$') then
    if #arg < 1 then
        print('Usage: lua bluesky.lua <text>')
        print(
            'Set BLUESKY_IDENTIFIER and BLUESKY_PASSWORD environment variables'
        )
        os.exit(1)
    end

    local identifier = os.getenv('BLUESKY_IDENTIFIER')
    local password = os.getenv('BLUESKY_PASSWORD')
    local text = arg[1]

    if not identifier or not password then
        print(
            'Error: BLUESKY_IDENTIFIER and BLUESKY_PASSWORD environment variables must be set'
        )
        os.exit(1)
    end

    local success, message = M.post(identifier, password, text)
    if success then
        print(message)
    else
        print('Error: ' .. message)
        os.exit(1)
    end
end

return M
