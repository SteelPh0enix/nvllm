local config = {}

local function setup(cfg)
    config = cfg
    vim.keymap.set('n', '<Leader>li', ':call NvllmRunInference()<CR>', { silent = true })
end

local function get_config()
    return config
end

return { setup = setup, get_config = get_config }
