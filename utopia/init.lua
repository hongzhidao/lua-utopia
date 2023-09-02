local _M = {};

local conf = require('utopia.conf');
local http = require('utopia.http');

local config = ngx.shared.config;
config:set('config_version', '0');
config:set('config_data', '{}');


local function json_response(r, resp)
    local json = ngx.json_encode(resp)
    r.set_header("Content-type", "application/json");
    r.echo(json);
end


function _M.config(r)
    if (r.method == 'GET') then
        local version = config:get('config_version');
        local data = config:get('config_data');

        json_response(r, {
            version = tonumber(version),
            data = data,
        });
        return;
    end

    if (r.method == 'POST') then
        if (not r.body) then
            json_response(r, {
                error = "Invalid request body"
            });
            return;
        end

        local value, err = ngx.json_decode(r.body);
        if (not value) then
            json_response(r, {
                error = "Invalid json",
                detail = err
            });
            return;
        end

        local valid, err = conf.validate(value);
        if (not valid) then
            json_response(r, {
                error = "Invalid json",
                detail = err
            });
            return;
        end

        local version = config:get('config_version');
        version = tonumber(version) + 1;

        config:set('config_version', tostring(version));
        config:set('config_data', r.body);

        json_response(r, {
            success = "Reconfiguration done"
        });
        return;
    end

    json_response(r, {
        error = "Invalid method",
    });
end


local config_version = 0;

function _M.timer()
    local version = config:get('config_version');
    version = tonumber(version);

    if (config_version ~= version) then
        print('reload config');
        config_version = version;

        local data = config:get('config_data');
        local value = ngx.json_decode(data);

        http.init_conf(value);
    end
end


function _M.http(r)
    http.handle(r);
end

return _M;
