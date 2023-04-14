local ngx = ngx

local _M = {}

function _M.rewrite()
  local ua = ngx.var.http_user_agent
  ngx.log(ngx.NOTICE, string_format("rewrite ====================="))
end


return _M