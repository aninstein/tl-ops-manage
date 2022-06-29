-- tl_ops_api 
-- en : get balance config
-- zn : 获取路由配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-balance");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local Router = function() 
   local code_str = cache:get(tl_ops_constant_balance.cache_key.options)
   if not code_str then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found options", _);
      return;
   end

   tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", cjson.decode(code_str));
end

return Router