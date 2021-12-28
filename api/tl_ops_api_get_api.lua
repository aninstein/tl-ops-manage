-- tl_ops_api 
-- en : get balance api config list
-- zn : 获取负载api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local cache = require("cache.tl_ops_cache"):new("tl-ops-api");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local rule, err_rule = cache:get(tl_ops_constant_balance.api.rule.cache_key);
if not rule or rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found rule", err_rule);
    return;
end

local list, err_list = cache:get(tl_ops_constant_balance.api.list.cache_key);
if not list or list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", err_list);
    return;
end

local res_data = {
    tl_ops_api_rule = rule, 
    tl_ops_api_list = cjson.decode(list)
}
tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);