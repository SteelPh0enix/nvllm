local Logger = {
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
Logger.__index = Logger

local function log_level_to_string(level)
    if level == Logger.LOG_LEVEL_VERBOSE then
        return 'VERBOSE '
    elseif level == Logger.LOG_LEVEL_DEBUG then
        return 'DEBUG   '
    elseif level == Logger.LOG_LEVEL_INFO then
        return 'INFO    '
    elseif level == Logger.LOG_LEVEL_WARNING then
        return 'WARNING '
    elseif level == Logger.LOG_LEVEL_ERROR then
        return 'ERROR   '
    elseif level == Logger.LOG_LEVEL_CRITICAL then
        return 'CRITICAL'
    end
    return 'UNKNOWN '
end

function Logger.new()
    local self = setmetatable({}, Logger)
    return self
end

function Logger:setup(opts)
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

function Logger:close()
    if self.log == nil then
        return
    end

    self.log:close()
    self.setup_done = false
end

function Logger:_write(content)
    if self.log == nil then
        error('Log object used before being initialized!')
    end

    self.log:write(content)
    self.log:flush()
end

function Logger:_log(message, level)
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

function Logger:verbose(message)
    self:_log(message, self.LOG_LEVEL_VERBOSE)
end

function Logger:debug(message)
    self:_log(message, self.LOG_LEVEL_DEBUG)
end

function Logger:info(message)
    self:_log(message, self.LOG_LEVEL_INFO)
end

function Logger:warning(message)
    self:_log(message, self.LOG_LEVEL_WARNING)
end

function Logger:error(message)
    self:_log(message, self.LOG_LEVEL_ERROR)
end

function Logger:critical(message)
    self:_log(message, self.LOG_LEVEL_CRITICAL)
end

function Logger:set_log_level(new_level)
    self.level = new_level
end

return Logger
