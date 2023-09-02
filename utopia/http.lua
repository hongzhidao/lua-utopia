local _M = {};

local action = {};


local function http_access_handle(r)
    for _, cidr in pairs(action.deny_list) do
        if (r.match_cidr(cidr)) then
            r.exit(405);
        end
    end
end


function _M.handle(r)
    if (action.deny_list) then
        http_access_handle(r);
    end

    if (action.uri) then
        r.uri = action.uri;
    end

    if (action.set_headers) then
        for name, value in pairs(action.set_headers) do
            r.set_header(name, value);
        end
    end
end


function _M.init_conf(value)
    if (value.deny) then
        local deny_list = {};
        for _, addr in ipairs(value.deny) do
            local cidr = ngx.cidr_parse(addr);
            table.insert(deny_list, cidr);
        end
        action.deny_list = deny_list;
    end

    if (value.uri) then
        action.uri = value.uri;
    end

    if (value.set_headers) then
        action.set_headers = value.set_headers;
    end
end

return _M;
