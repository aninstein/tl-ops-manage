-- tl_ops_test_get_export
-- en : get export test config
-- zn : 获取test插件配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-test");
local constant                  = require("plugins.tl_ops_test.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function()
    
    local str, _ = cache:get(constant.export.cache_key.test);
    if not str or str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found test", _);
        return;
    end

    local res_data = {}
    res_data[constant.export.cache_key.test] = cjson.decode(str)
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router