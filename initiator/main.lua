local ngx = ngx

local _M = {}

function _M.init_worker()
    ngx.log(ngx.NOTICE, "init_worker ------------------------") 
end

function _M.rewrite()
    ngx.log(ngx.NOTICE, "rewrite ------------------------") 
end

function _M.log()
    ngx.log(ngx.NOTICE, "LOG  ------------------------")") 
end
