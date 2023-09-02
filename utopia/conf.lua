local _M = {};

local CONF = {
    NUMBER = 1,
    STRING = 2,
    ARRAY = 3,
    OBJECT = 4,
};


local function check_type(member, value)
    local types = {"number", "string", "array", "object"};

    local expected = types[member.type];
    local tvalue = type(value);

    if (tvalue == "table") then
        if (value[1]) then
            tvalue = "array";
        else
            tvalue = "object";
        end
    end

    if (tvalue ~= expected) then
        return "expected " .. expected .. " but " .. tvalue;
    end
end


local function conf_vldt_object(obj, members)
    for name, value in pairs(obj) do
        local member = members[name];

        if (member == nil) then
            return "unknown " .. name;
        end

        local err = check_type(member, value);
        if (err) then
            return err;
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


local function conf_vldt_set_headers(value)
    for key, val in pairs(value) do
        if (type(val) ~= "string") then
            return "set header value must be a string";
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
    set_headers = {
        type = CONF.OBJECT,
        validator = conf_vldt_set_headers,
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
