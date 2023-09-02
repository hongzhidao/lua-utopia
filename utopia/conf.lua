local _M = {};

local CONF = {
    NUMBER = 1,
    STRING = 2,
    ARRAY = 3,
    OBJECT = 4,
};


local function conf_vldt_object(obj, members)
    for name, value in pairs(obj) do
        local member = members[name];
        if (member == nil) then
            return "unknown " .. name;
        end

        if (member.validator) then
            local err = member.validator(value);
            if (err) then
                return err;
            end
        end
    end

    return nil;
end


local function conf_vldt_deny(value)
    for _, ip in ipairs(value) do
        local cidr = ngx.cidr_parse(ip);
        if (not cidr) then
            return string.format("cidr_parse('%s') failed", ip);
        end
    end
end


local root_members = {
    deny = {
        type = CONF.ARRAY,
        validator = conf_vldt_deny,
    },
    uri = {
        type = CONF.STRING,
    },
};


function _M.validate(value)
    local err = conf_vldt_object(value, root_members);
    if (err) then
        return false, err;
    end

    return true;
end

return _M;
