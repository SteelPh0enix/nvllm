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
        table_string = table_string .. k .. ': ' .. v .. ', '
    end
    return '{ ' .. table_string .. ' }'
end

return utils
