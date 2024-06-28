local log = {
    LOG_LEVEL_VERBOSE = 0,
    LOG_LEVEL_DEBUG = 10,
    LOG_LEVEL_INFO = 20,
    LOG_LEVEL_WARNING = 30,
    LOG_LEVEL_ERROR = 40,
    LOG_LEVEL_CRITICAL = 50,

    path = nil,
    log = nil,
    level = nil
}

local function log_level_to_string(level)
    if level == log.LOG_LEVEL_VERBOSE then
        return 'VERBOSE '
    elseif level == log.LOG_LEVEL_DEBUG then
        return 'DEBUG   '
    elseif level == log.LOG_LEVEL_INFO then
        return 'INFO    '
    elseif level == log.LOG_LEVEL_WARNING then
        return 'WARNING '
    elseif level == log.LOG_LEVEL_ERROR then
        return 'ERROR   '
    elseif level == log.LOG_LEVEL_CRITICAL then
        return 'CRITICAL'
    end
    return 'UNKNOWN '
end

function log.create(opts)
    self.path = opts['path']
    self.level = opts['level']

    if self.path == nil then
        error('Cannot initialize Log object - no path provided')
    end

    if self.level == nil then
        self.level = self.LOG_LEVEL_INFO
    end

    self.log = io.open(self.path, 'a+')
end

function log:close()
    if self.log == nil then
        return
    end

    self.log:close()
    self.setup_done = false
end

function log:_write(content)
    if self.log == nil then
        error('Log object used before being initialized!')
    end

    self.log:write(content)
    self.log:flush()
end

function log:_log(message, level)
    -- to prevent this getting silenced by log_level check, it's checked here and in _write
    if self.log == nil then
        error('Log object used before being initialized!')
    end

    if level < self.level then
        return
    end

    local current_time = os.date('%Y-%m-%d %H:%M:%S')
    self:_write(current_time .. ' [' .. log_level_to_string(self.level) .. '] ' .. message)
end

function log:verbose(message)
    self:_log(message, self.LOG_LEVEL_VERBOSE)
end

function log:debug(message)
    self:_log(message, self.LOG_LEVEL_DEBUG)
end

function log:info(message)
    self:_log(message, self.LOG_LEVEL_INFO)
end

function log:warning(message)
    self:_log(message, self.LOG_LEVEL_WARNING)
end

function log:error(message)
    self:_log(message, self.LOG_LEVEL_ERROR)
end

function log:critical(message)
    self:_log(message, self.LOG_LEVEL_CRITICAL)
end

function log:set_log_level(new_level)
    self.level = new_level
end

return log
