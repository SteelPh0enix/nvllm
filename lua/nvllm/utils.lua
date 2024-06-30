local utils = {}

function utils.concat_tables(a, b)
    -- returns a + b
    local result = {}

    for _, v in ipairs(a) do
        table.insert(result, v)
    end

    for _, v in ipairs(b) do
        table.insert(result, v)
    end

    return result
end

function utils.merge_tables(a, b)
    -- returns a + (b - a)
    local result = {}

    for k, v in pairs(a) do
        result[k] = v
    end

    for k, v in pairs(b) do
        if result[k] == nil then
            result[k] = v
        end

        if type(result[k]) == 'table' and type(v) == 'table' then
            result[k] = utils.merge_tables(result[k], v)
        end
    end

    return result
end

function utils.random_id(length, character_set)
    -- return a random id of defined length
    -- id consists of lowercase ascii letters if not provided via character_set
    if character_set == nil then
        character_set = 'qwertyuiopasdfghjklzxcvbnm'
    end

    local id = ''
    for _ = 1, length do
        local index = math.random(#character_set)
        id = id .. character_set:sub(index, index)
    end

    return id
end

function utils.stringify_table(table)
    if table == nil then
        table = {}
    end

    local table_string = ''
    for k, v in pairs(table) do
        if v == nil then
            v = '[nil]'
        end
        if type(v) == 'table' then
            v = utils.stringify_table(v)
        end
        table_string = table_string .. k .. ': ' .. v .. ', '
    end
    return '{ ' .. table_string .. ' }'
end

function utils.get_plugin_logs_dir(plugin_name, makedirs)
    if plugin_name == nil then
        error('missing plugin name')
    end

    if makedirs == nil then
        makedirs = true
    end

    local nvim_log_path = os.getenv('NVIM_LOG_FILE')
    if nvim_log_path == nil then
        error('cannot read NVIM_LOG_FILE env var!')
    end

    local last_slash_index = string.find(nvim_log_path, '/[^/]*$')
    local logs_dir = nvim_log_path:sub(1, last_slash_index) .. plugin_name

    if makedirs and not vim.loop.fs_stat(logs_dir) then
        vim.fn.mkdir(logs_dir, 'p')
    end

    return logs_dir
end

return utils
