local ngx = ngx

local _M = {}

-- function _M.rewrite()
--   ngx.log(ngx.NOTICE, "rewrite =====================")
-- end



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
    metric_response_sizes = prometheus:histogram(
        "nginx_http_response_size_bytes", "Size of HTTP responses", {"host"},
        {10,100,1000,10000,100000,1000000})
    metric_bytes = prometheus:counter("nginx_http_request_size_bytes",
        "Total size of incoming requests", {"host"})
    metric_requests_per_second = prometheus:counter(
        "requests_per_second_total", "Number of HTTP requests per second", {"host"})
    metric_active_connections = prometheus:gauge(
        "active_connections", "Number of active HTTP connections", {"host"})
    metric_open_connections = prometheus:counter(
        "open_connections_total", "Total number of HTTP connections opened", {"host"})
    metric_closed_connections = prometheus:counter(
        "closed_connections_total", "Total number of HTTP connections closed", {"host"})

end

function _M:log()
    local host = ngx.var.http_host or "unknown"
    local domain = string.match(host, "^([^%.]+)%.") or "unknown"
    metric_requests:inc(1, {domain, ngx.var.status})
    metric_latency:observe(tonumber(ngx.var.request_time), {domain})
    metric_bytes:inc(tonumber(ngx.var.request_length), {domain})
    metric_requests_per_second:inc(1, {domain})

end

return _M
