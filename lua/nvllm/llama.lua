local logger = require('nvllm.logger')
local utils = require('nvllm.utils')
local curl = require('nvllm.curl')

local Llama = {
    curl = nil,
    llm_server_url = nil,
    logger = nil,
}
Llama.__index = Llama

function Llama:_get_endpoint(path)
    self.logger:debug('making endpoint for ' .. path)
    if path:sub(1, 1) ~= '/' then
        self.logger:debug('path not starting with /, prefixing...')
        path = '/' .. path
    end

    local final_path = self.llm_server_url .. path
    self.logger:debug('final path: ' .. final_path)
    return final_path
end

function Llama.new()
    local self = setmetatable({}, Llama)
    return self
end

function Llama:setup(opts)
    -- duplicated from init.lua but w/e
    local default_opts = {
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

    if opts == nil then
        opts = {}
    else
        opts = utils.merge_tables(opts, default_opts)
    end

    self.logger = logger.new()
    self.logger:setup({
        path = opts.log_path,
        level = opts.log_level
    })

    self.logger:info('llama API setup started')
    self.logger:verbose('llama API wrapper configuration: ' .. utils.stringify_table(opts))

    if opts.server_url:sub(-1) == '/' then
        self.logger:warning('server_url should not end with a slash!')
        opts.server_url = opts.server_url:sub(1, -2)
    end

    opts.curl['default_header'] = { 'Content-Type: application/json' }
    self.curl = curl.new()
    self.curl:setup(opts.curl)

    self.server_url = opts.server_url
    self.logger:info("llama API wrapper initialized, using API @ " .. self.server_url)
end

return Llama
