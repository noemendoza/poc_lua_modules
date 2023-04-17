local ngx = ngx

local _M = {}

function _M:init_worker()
    ngx.log(ngx.NOTICE, "init_worker =====================")
    prometheus = require("plugins/prometheus/main").init("prometheus_metrics",{sync_interval=0.4})

    metric_requests = prometheus:counter("requests_total",
    "Number of HTTP requests", {"host", "status"})
    metric_latency = prometheus:histogram("request_duration_seconds",
        "HTTP request latency", {"host"},
        {0.08, 0.089991, 0.1, 0.2, 0.75, 1, 1.5, 3.123232001, 5, 15, 120, 350.5, 1500, 75000, 1500000})
    metric_connections = prometheus:gauge("connections",
        "Number of HTTP connections", {"state"})
    metric_response_sizes = prometheus:histogram("response_sizes",
        "Size of HTTP responses", {"host"},
        {100, 200, 500, 1000, 1500, 2000, 3000, 5000, 7500, 10000, 20000, 50000, 75000, 100000, 200000, 500000})
    metric_bytes = prometheus:counter("bytes_total",
        "Number of bytes sent and received", {"host", "direction"})
    metric_requests_per_second = prometheus:counter("requests_per_second",
        "Number of HTTP requests per second", {"host"})
    metric_errors = prometheus:counter("nginx_metric_errors_total", "Number of HTTP errors", {"host", "error_type"})

end

function _M:log()
    local host = ngx.var.http_host or "unknown"
    local domain = string.match(host, "^([^%.]+)%.") or "unknown"
    metric_requests:inc(1, {domain, ngx.var.status})
    metric_latency:observe(tonumber(ngx.var.request_time), {domain})
    metric_response_sizes:observe(tonumber(ngx.var.bytes_sent), {domain})
    metric_bytes:inc(tonumber(ngx.var.bytes_sent), {domain, "sent"})
    metric_bytes:inc(tonumber(ngx.var.bytes_received), {domain, "received"})
    metric_requests_per_second:inc(1, {domain})
    local req_per_sec = 1 / tonumber(ngx.var.request_time)
    metric_errors:inc(1, {domain, ngx.var.status})
    
end

return _M
