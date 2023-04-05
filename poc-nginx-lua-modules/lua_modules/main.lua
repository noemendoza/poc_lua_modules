local _M = {}

local https = require("ssl.https")
local json = require("dkjson")

function _M.verify(secret, response, remoteip)
	local post_data =
		"secret=" .. uhttpd.urlencode(secret) ..
		"&response=" .. uhttpd.urlencode(response) ..
		(remotip and "&remoteip=" .. uhttpd.urlencode(remoteip) or "")
	local body, code, headers, status = https.request("https://www.google.com/recaptcha/api/siteverify", post_data)
	if (code ~= 200) then return nil, code end
	local body_json, position, error = json.decode(body)
	if not body_json then return nil, error, position end
	if body_json.success then
		return true, body_json
	else
		return false, body_json['error-codes']
	end
end

return _M
