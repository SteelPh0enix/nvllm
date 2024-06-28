local utils = require('nvllm.utils')
local logger = require('nvllm.logger')
local curl = require('nvllm.curl')

local NVLLM = {
    curl = nil,
    llm_server_url = nil,
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

function NVLLM:_get_endpoint(path)
    self.logger:debug('making endpoint for ' .. path)
    if path:sub(1, 1) ~= '/' then
        self.logger:debug('path not starting with /, prefixing...')
        path = '/' .. path
    end

    local final_path = self.llm_server_url .. path
    self.logger:debug('final path: ' .. final_path)
    return final_path
end

function NVLLM:server_health()
    self.logger:verbose('querying server for health...')
    local query_json = self.curl:get(self:_get_endpoint('/health'))
    nvim_write(utils.stringify_table(query_json))
end

function NVLLM:status()
    return 'NVLLM: ' .. self.current_status
end

function NVLLM:setup(opts)
    local default_opts = {
        llm_server_url = 'http://localhost:8080',
        curl_executable = 'curl',
        curl_default_timeout = 10000,
        curl_log_path = './nvllm.curl.log',
        curl_log_level = logger.LOG_LEVEL_WARNING,
        log_path = './nvllm.log',
        log_level = logger.LOG_LEVEL_WARNING,
    }

    if opts == nil then
        opts = default_opts
    end

    opts = utils.merge_tables(opts, default_opts)

    if self.curl ~= nil then
        error('nvllm module setup has already been done!')
    end

    self.current_status = 'initializing...'

    self.logger = logger.new()
    self.logger:setup({
        path = opts.log_path,
        level = opts.log_level
    })

    self.logger:info('NVLLM setup started')

    if opts.llm_server_url:sub(-1) == '/' then
        self.logger:warning('llm_server_url should not end with a slash!')
        opts.llm_server_url = opts.llm_server_url:sub(1, -2)
    end

    self.logger:verbose('full configuration: ' .. utils.stringify_table(opts))

    self.curl = curl.new()
    self.curl:setup({
        curl_executable = opts.curl_executable,
        default_headers = { 'Content-Type: application/json' },
        default_timeout = opts.curl_default_timeout,
        log_path = opts.curl_log_path,
        log_level = opts.curl_log_level,
    })

    vim.api.nvim_create_user_command('NVLLMCheckHealth', function(_)
        self:server_health()
    end, {
        nargs = 0,
    })

    self.llm_server_url = opts.llm_server_url
    self.logger:info('NVLLM initialized, API @ ' .. self.llm_server_url)
    self.current_status = 'initialized, API @ ' .. self.llm_server_url
end

return NVLLM
