
local ngx = ngx

local _M = {}

function _M:init_worker()
    ngx.log(ngx.NOTICE, "init_worker =====================")
    prometheus = require("plugins/prometheus/main").init("prometheus_metrics",{sync_interval=0.4})

    metric_requests = prometheus:counter("requests_total",
    "Number of HTTP requests", {"host", "status", "pod"})

    metric_latency = prometheus:histogram("request_duration_seconds",
        "HTTP request latency", {"host", "pod"},
        {0.08, 0.089991, 0.1, 0.2, 0.75, 1, 1.5, 3.123232001, 5, 15, 120, 350.5, 1500, 75000, 1500000})

    metric_connections = prometheus:gauge("connections",
        "Number of HTTP connections", {"state", "pod"})

    metric_response_sizes = prometheus:histogram("response_sizes",
        "Size of HTTP responses", {"host", "pod"},
        {100, 200, 500, 1000, 1500, 2000, 3000, 5000, 7500, 10000, 20000, 50000, 75000, 100000, 200000, 500000})

    metric_bytes = prometheus:counter("bytes_total",
        "Number of bytes sent and received", {"host", "direction", "pod"})

    metric_requests_per_second = prometheus:counter("requests_per_second",
        "Number of HTTP requests per second", {"host", "pod"})

    metric_requests_by_ip = prometheus:counter("requests_total_by_ip",
        "Number of HTTP requests by IP address", {"host", "status", "ip", "pod"})

end

function _M:log()
    local host = ngx.var.http_host or "unknown"
    local domain = string.match(host, "^([^%.]+)%.") or "unknown"
    local ip = ngx.var.remote_addr
    local pod_name = os.getenv("HOSTNAME") or "unknown"
    metric_requests:inc(1, {pod_name, domain, ngx.var.status})
    metric_requests_by_ip:inc(1, {pod_name, domain, ngx.var.status, ip})
    metric_latency:observe(tonumber(ngx.var.request_time), {pod_name, domain})
    metric_response_sizes:observe(tonumber(ngx.var.bytes_sent), {pod_name, domain})
    metric_bytes:inc(tonumber(ngx.var.bytes_sent), {pod_name, domain, "sent"})
    metric_bytes:inc(tonumber(ngx.var.bytes_received), {pod_name, domain, "received"})
    metric_requests_per_second:inc(1, {pod_name, domain})
    local req_per_sec = 1 / tonumber(ngx.var.request_time)
    
end

return _M