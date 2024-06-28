local utils = require('nvllm.utils')
local logger = require('nvllm.logger')

local curl = {
    curl_executable = 'curl',
    setup_done = false,
    default_headers = {},
    default_timeout = 10000,
    logger = nil,
}

local function parse_http_headers_to_curl_arguments(headers)
    if headers == nil then
        return {}
    end

    local parsed_headers = {}
    for k, v in pairs(headers) do
        parsed_headers[#parsed_headers + 1] = '--header "' .. k .. ': ' .. v .. '"'
    end
    return parsed_headers
end

function curl:_get_curl_args()
    local headers = parse_http_headers_to_curl_arguments(self.default_headers)
    return utils.concat_tables({ self.curl_executable }, headers)
end

function curl:_call_curl_async(args, on_exit_handler)
    return vim.system(utils.concat_tables(self:_get_curl_args(), args), { text = true }, on_exit_handler)
end

function curl:_call_curl(args, timeout)
    if timeout == nil then
        timeout = self.default_timeout
    end

    return vim.system(utils.concat_tables(self:_get_curl_args(), args), { text = true, timeout = timeout }):wait()
end

function curl:get(url, headers, timeout)
    local headers_args = parse_http_headers_to_curl_arguments(headers)
    local curl_args = utils.concat_tables({ '--request GET', '--url ' .. url }, headers_args)
    return self:_call_curl(curl_args, timeout)
end

function curl:async_get(url, headers, on_exit_handler)
    local headers_args = parse_http_headers_to_curl_arguments(headers)
    local curl_args = utils.concat_tables({ '--request GET', '--url ' .. url }, headers_args)
    return self:_call_curl_async(curl_args, on_exit_handler)
end

function curl:post(url, data, headers, timeout)
    local headers_args = parse_http_headers_to_curl_arguments(headers)
    local curl_base_args = utils.concat_tables({ '--request POST', '--url ' .. url }, headers_args)
    local curl_args = utils.concat_tables(curl_base_args, { '--data \'' .. data .. '\'' })
    return self:_call_curl(curl_args, timeout)
end

function curl:async_post(url, data, headers, on_exit_handler)
    local headers_args = parse_http_headers_to_curl_arguments(headers)
    local curl_base_args = utils.concat_tables({ '--request POST', '--url ' .. url }, headers_args)
    local curl_args = utils.concat_tables(curl_base_args, { '--data \'' .. data .. '\'' })
    return self:_call_curl_async(curl_args, on_exit_handler)
end

function curl:setup(opts)
    if not opts then
        opts = {}
    end

    if self.setup_done then
        error('curl module setup has already been done!')
    end

    for k, v in pairs(opts) do
        if k == 'curl_executable' then
            self.curl_executable = v
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
                level = opts["log_level"],
            })
        end
    end

    self.setup_done = true
end

return curl
