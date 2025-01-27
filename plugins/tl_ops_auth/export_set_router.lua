-- tl_ops_set_auth_export
-- en : set export auth config
-- zn : 更新auth插件配置管理
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-auth");
local constant                  = require("plugins.tl_ops_auth.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 

    local change = "success"

    local auth, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.export.cache_key.auth, 1);
    if auth then
        local res, _ = cache:set(constant.export.cache_key.auth, cjson.encode(auth));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set auth err ", _)
            return;
        end

        change = "auth"
    end
    
    local res_data = {}
    res_data[constant.export.cache_key.auth] = auth

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data)
 end
 
return Router
