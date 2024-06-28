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

return utils
