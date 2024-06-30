local logger = require('nvllm.logger')
local utils = require('nvllm.utils')
local curl = require('nvllm.curl')
local json = require('nvllm.json')

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

    local final_path = self.server_url .. path
    self.logger:debug('final path: ' .. final_path)
    return final_path
end

function Llama:_verify_curl_result(result)
    if result.code ~= 0 then
        self.logger:error('curl returned non-zero exit code: ' .. result.code)
        return false
    end
    return true
end

function Llama:_get_json(path)
    local endpoint = self:_get_endpoint(path)
    self.logger:debug('GET: ' .. endpoint)
    local curl_result = self.curl:get(endpoint)

    if not self:_verify_curl_result(curl_result) then
        return nil
    end

    self.logger:debug('Response: ' .. curl_result.stdout)
    return json.decode(curl_result.stdout)
end

function Llama:_post_json(path, payload)
    local endpoint = self:_get_endpoint(path)
    self.logger:debug('POST: ' .. endpoint)
    local json_string = json.encode(payload)
    self.logger:debug('Payload: ' .. json_string)
    local curl_result = self.curl:post(endpoint, json_string)

    if not self:_verify_curl_result(curl_result) then
        return nil
    end

    self.logger:debug('Response: ' .. curl_result.stdout)
    return json.decode(curl_result.stdout)
end

function Llama:health()
    return self:_get_json('/health')
end

function Llama.new()
    local self = setmetatable({}, Llama)
    return self
end

function Llama:setup(opts)
    -- duplicated from init.lua
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

    opts.curl['default_headers'] = { 'Content-Type: application/json' }
    self.curl = curl.new()
    self.curl:setup(opts.curl)

    self.server_url = opts.server_url
    self.logger:info('llama API wrapper initialized, using API @ ' .. self.server_url)
end

return Llama
