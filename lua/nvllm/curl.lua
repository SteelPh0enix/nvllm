-- see https://neovim.io/doc/user/lua.html#vim.system()
-- for details about values returned by this module's functions

local utils = require('nvllm.utils')
local logger = require('nvllm.logger')

local Curl = {
    executable = 'curl',
    id = nil,
    default_headers = {},
    default_timeout = 10000,
    logger = nil,
}
Curl.__index = Curl

local function convert_http_headers_to_curl_arguments(headers)
    if headers == nil then
        return {}
    end

    local parsed_headers = {}
    for _, header in ipairs(headers) do
        parsed_headers[#parsed_headers + 1] = '--header'
        parsed_headers[#parsed_headers + 1] = '"' .. header .. '"'
    end
    return parsed_headers
end

function Curl:_log_error(msg)
    self.logger:error('<' .. self.id .. '> ' .. msg)
end

function Curl:_log_warning(msg)
    self.logger:warning('<' .. self.id .. '> ' .. msg)
end

function Curl:_log_verbose(msg)
    self.logger:verbose('<' .. self.id .. '> ' .. msg)
end

function Curl:_log_debug(msg)
    self.logger:debug('<' .. self.id .. '> ' .. msg)
end

function Curl:_get_curl_args()
    local headers = convert_http_headers_to_curl_arguments(self.default_headers)
    return utils.concat_tables({ self.executable }, headers)
end

function Curl:_call_curl_async(args, on_exit_handler)
    local curl_args = utils.concat_tables(self:_get_curl_args(), args)
    self:_log_debug('calling async ' .. table.concat(curl_args, ' '))
    local result = vim.system(utils.concat_tables(curl_args, args), { text = true }, on_exit_handler)
    self.logger:debug('result: ' .. utils.stringify_table(result))
    return result
end

function Curl:_call_curl(args, timeout)
    if timeout == nil then
        timeout = self.default_timeout
    end

    local curl_args = utils.concat_tables(self:_get_curl_args(), args)
    self:_log_debug('calling ' .. table.concat(curl_args, ' '))
    local result = vim.system(curl_args, { text = true, timeout = timeout }):wait()
    self.logger:debug('result: ' .. utils.stringify_table(result))
    return result
end

function Curl:get(url, headers, timeout)
    if url == nil then
        self:_log_error('cannot perform GET, url is nil')
        error('cannot perform GET, url is nil')
    end

    self:_log_verbose('performing GET to ' .. url)
    local headers_args = convert_http_headers_to_curl_arguments(headers)
    local curl_args = utils.concat_tables({ '--request', 'GET', '--url', url }, headers_args)
    return self:_call_curl(curl_args, timeout)
end

function Curl:async_get(url, headers, on_exit_handler)
    if url == nil then
        self:_log_error('cannot perform async GET, url is nil')
        error('cannot perform async GET, url is nil')
    end

    self:_log_verbose('performing async GET to ' .. url)
    local headers_args = convert_http_headers_to_curl_arguments(headers)
    local curl_args = utils.concat_tables({ '--request', 'GET', '--url', url }, headers_args)
    return self:_call_curl_async(curl_args, on_exit_handler)
end

function Curl:post(url, data, headers, timeout)
    if url == nil then
        self:_log_error('cannot perform POST, url is nil')
        error('cannot perform POST, url is nil')
    end

    if data == nil then
        self:_log_warning('performing POST to ' .. url .. ', but data is nil!')
        data = ''
    end

    self:_log_verbose('performing POST to ' .. url .. ' with payload ' .. data)
    local headers_args = convert_http_headers_to_curl_arguments(headers)
    local curl_base_args = utils.concat_tables({ '--request', 'POST', '--url', url }, headers_args)
    local curl_args = utils.concat_tables(curl_base_args, { '--data', '\'' .. data .. '\'' })
    return self:_call_curl(curl_args, timeout)
end

function Curl:async_post(url, data, headers, on_exit_handler)
    if url == nil then
        self:_log_error('cannot perform async POST, url is nil')
        error('cannot perform async POST, url is nil')
    end

    if data == nil then
        self:_log_warning('performing async POST to ' .. url .. ', but data is nil!')
        data = ''
    end

    self:_log_verbose('performing async POST to ' .. url .. ' with payload ' .. data)
    local headers_args = convert_http_headers_to_curl_arguments(headers)
    local curl_base_args = utils.concat_tables({ '--request', 'POST', '--url', url }, headers_args)
    local curl_args = utils.concat_tables(curl_base_args, { '--data', '\'' .. data .. '\'' })
    return self:_call_curl_async(curl_args, on_exit_handler)
end

function Curl.new()
    local self = setmetatable({}, Curl)
    return self
end

function Curl:setup(opts)
    if opts == nil then
        opts = {}
    end

    if self.id ~= nil then
        error('curl module setup has already been done!')
    end

    for k, v in pairs(opts) do
        if k == 'executable' then
            self.executable = v
        end
        if k == 'default_headers' then
            self.default_headers = v
        end
        if k == 'default_timeout' then
            self.default_timeout = v
        end
        if k == 'log_path' then
            self.logger = logger.new()
            self.logger:setup({
                path = v,
                level = opts['log_level'],
            })
        end
    end

    self.id = utils.random_id(8)
    self:_log_verbose('curl.lua initialized with ID ' .. self.id)
end

return Curl
