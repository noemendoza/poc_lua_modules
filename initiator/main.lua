local ngx = ngx

local _M = {}

-- function _M.rewrite()
--   ngx.log(ngx.NOTICE, "rewrite =====================")
-- end


local prometheus = require("plugins/prometheus/main")

function _M:init_worker()
    ngx.log(ngx.NOTICE, "init_worker =====================")
    prometheus.init("prometheus_metrics",{sync_interval=0.4})
    metric_requests = prometheus:counter("requests_total", "Number of HTTP requests", {"host", "status"})
    metric_latency = prometheus:histogram("request_duration_seconds","HTTP request latency", {"host"},{0.08, 0.089991, 0.1, 0.2, 0.75, 1, 1.5, 3.123232001, 5, 15, 120, 350.5, 1500, 75000, 1500000})
    metric_connections = prometheus:gauge("connections","Number of HTTP connections", {"state"})
end

function _M:log()
    local host = ngx.var.http_host or "unknown"
    local domain = string.match(host, "^([^%.]+)%.") or "unknown"
    metric_requests:inc(1, {domain, ngx.var.status})
    metric_latency:observe(tonumber(ngx.var.request_time), {domain})
end

return _M