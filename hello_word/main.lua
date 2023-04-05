local ngx = ngx

local string_format = string.format
local ngx_log = ngx.log

local _M = {}

function _M.rewrite()
  local ua = ngx.var.http_user_agent
  ngx_log(ngx.NOTICE, string_format("User Agent passed: \"%s\"", ua))
  if ua == "hello" then
    ngx_log(ngx.NOTICE, string_format("User Agent matched 'hello'"))
    ngx.req.set_header("x-hello-world", "hello")
  else
    ngx_log(ngx.NOTICE, string_format("User Agent did not match any provided conditions error noe"))
    ngx.req.set_header("x-hello-world", "unknwon")
    -- ngx.say('not found')
    ngx.exit(ngx.HTTP_NOT_FOUND)
  end
end

return _M