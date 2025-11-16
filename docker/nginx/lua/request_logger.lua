-- Request Logger with Metrics Tracking
-- Logs requests and updates metrics for Prometheus

local _M = {}

function _M.log_request()
    local metrics = require("metrics")
    
    -- Track the request in metrics
    metrics.track_request()
    
    -- Get request details
    local request_time = ngx.var.request_time
    local status = ngx.status
    local uri = ngx.var.uri
    local method = ngx.var.request_method
    
    -- Store in shared dictionary for debugging
    local stats = ngx.shared.request_stats
    local key = string.format("%s:%s", method, uri)
    local count = stats:get(key) or 0
    stats:set(key, count + 1)
    
    -- Log to error log for debugging (can be disabled in production)
    if status >= 500 then
        ngx.log(ngx.ERR, string.format(
            "5xx Error: %s %s - Status: %d, Time: %s",
            method, uri, status, request_time
        ))
    end
end

return _M
