local ngx = ngx

local _M = {}

function _M.rewrite()
  local ua = ngx.var.http_user_agent
  ngx_log(ngx.NOTICE, string_format("helll"))
  if ua == "hello" then
    ngx.req.set_header("x-hello-world", "1")
  end
end

