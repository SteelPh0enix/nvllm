local utils = require('nvllm.utils')
local logger = require('nvllm.logger')
local llama = require('nvllm.llama')

local NVLLM = {
    llama = nil,
    logger = nil,
    current_status = 'uninitialized'
}

local function nvim_write(text)
    if type(text) == 'string' then
        local text_table = {}
        for line in text:gmatch('[^\r\n]+') do
            table.insert(text_table, line)
        end
        text = text_table
    end

    vim.api.nvim_put(text, 'c', true, true)
end

function NVLLM:server_health()
    self.logger:verbose('querying server for health...')
end

function NVLLM:status()
    return 'NVLLM: ' .. self.current_status
end

function NVLLM:setup(opts)
    local default_opts = {
        log_path = utils.get_plugin_logs_dir('nvllm') .. '/nvllm.log',
        log_level = logger.LOG_LEVEL_WARNING,
        llama = {
            server_url = 'http://localhost:8080',
            log_path = utils.get_plugin_logs_dir('nvllm') .. '/nvllm.llama.log',
            log_level = logger.LOG_LEVEL_WARNING,
            curl = {
                executable = 'curl',
                timeout = 10000,
                log_path = utils.get_plugin_logs_dir('nvllm') .. '/nvllm.llama.curl.log',
                log_level = logger.LOG_LEVEL_WARNING,
            }
        }
    }

    if opts == nil then
        opts = default_opts
    else
        opts = utils.merge_tables(opts, default_opts)
    end

    if self.llama ~= nil then
        error('nvllm module setup has already been done!')
    end

    self.logger = logger.new()
    self.logger:setup({
        path = opts.log_path,
        level = opts.log_level
    })

    self.logger:info('NVLLM setup started')
    self.logger:verbose('full configuration: ' .. utils.stringify_table(opts))

    self.llama = llama.new()
    self.llama:setup(opts.llama)

    vim.api.nvim_create_user_command('NVLLMCheckHealth', function(_)
        self:server_health()
    end, {
        nargs = 0,
    })

    self.logger:info('NVLLM initialized, API @ ' .. self.llama.server_url)
    self.current_status = 'initialized, API @ ' .. self.llama.server_url
end

return NVLLM
