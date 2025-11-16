-- Prometheus Metrics Exporter for Nginx
-- Tracks requests, errors, and performance metrics

local _M = {}

-- Initialize metrics storage
local function init_metrics()
    local metrics = ngx.shared.prometheus_metrics
    if not metrics:get("total_requests") then
        metrics:set("total_requests", 0)
        metrics:set("total_5xx", 0)
        metrics:set("total_4xx", 0)
        metrics:set("total_2xx", 0)
        metrics:set("total_3xx", 0)
    end
end

-- Increment counter
local function increment_counter(key)
    local metrics = ngx.shared.prometheus_metrics
    local value = metrics:get(key) or 0
    metrics:set(key, value + 1)
end

-- Export metrics in Prometheus format
function _M.export_metrics()
    init_metrics()
    
    local metrics = ngx.shared.prometheus_metrics
    
    local total_requests = metrics:get("total_requests") or 0
    local total_5xx = metrics:get("total_5xx") or 0
    local total_4xx = metrics:get("total_4xx") or 0
    local total_2xx = metrics:get("total_2xx") or 0
    local total_3xx = metrics:get("total_3xx") or 0
    
    local output = string.format([[
# HELP nginx_http_requests_total Total number of HTTP requests
# TYPE nginx_http_requests_total counter
nginx_http_requests_total %d

# HELP nginx_http_requests_5xx Total number of 5xx HTTP responses
# TYPE nginx_http_requests_5xx counter
nginx_http_requests_5xx %d

# HELP nginx_http_requests_4xx Total number of 4xx HTTP responses
# TYPE nginx_http_requests_4xx counter
nginx_http_requests_4xx %d

# HELP nginx_http_requests_2xx Total number of 2xx HTTP responses
# TYPE nginx_http_requests_2xx counter
nginx_http_requests_2xx %d

# HELP nginx_http_requests_3xx Total number of 3xx HTTP responses
# TYPE nginx_http_requests_3xx counter
nginx_http_requests_3xx %d
]], total_requests, total_5xx, total_4xx, total_2xx, total_3xx)
    
    ngx.header.content_type = "text/plain"
    ngx.say(output)
end

-- Track request
function _M.track_request()
    init_metrics()
    increment_counter("total_requests")
    
    local status = ngx.status
    if status >= 500 then
        increment_counter("total_5xx")
    elseif status >= 400 then
        increment_counter("total_4xx")
    elseif status >= 300 then
        increment_counter("total_3xx")
    elseif status >= 200 then
        increment_counter("total_2xx")
    end
end

return _M
