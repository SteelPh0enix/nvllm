local utils = require('nvllm.utils')
local logger = require('nvllm.logger')
local curl = require('nvllm.curl')

local nvllm = {
    curl = nil,
    llm_server_url = nil,
    logger = nil,
}

function nvllm:setup(opts)
    local default_opts = {
        llm_server_url = 'http://localhost:8080/',
        curl_executable = 'curl',
        curl_default_timeout = 10000,
        curl_log_path = './nvllm.curl.log',
        curl_log_level = logger.LOG_LEVEL_INFO,
        log_path = './nvllm.log',
        log_level = logger.LOG_LEVEL_INFO,
    }

    if opts == nil then
        opts = default_opts
    end

    opts = utils.merge_tables(opts, default_opts)

    if self.curl ~= nil then
        error('nvllm module setup has already been done!')
    end

    self.logger = logger.new()
    self.logger:setup({
        path = opts.log_path,
        level = opts.log_level
    })
    self.logger:info('NVLLM setup started...')

    self.curl = curl.new()
    self.curl:setup({
        curl_executable = opts.curl_executable,
        default_headers = { ContentType = 'application/json' },
        default_timeout = opts.curl_default_timeout,
        log_path = opts.curl_log_path,
        log_level = opts.curl_log_level,
    })

    self.llm_server_url = opts.llm_server_url
    self.logger:info('NVLLM initialized!')
end

return nvllm
