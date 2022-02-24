-- tl_ops_balance
-- en : balance count state
-- zn : 路由次数统计
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_balance_count");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local cache_service = require("cache.tl_ops_cache"):new("tl-opsxxx");
local lock = require("lib.lock");
local shared = ngx.shared.tlopsbalance;

-- 控制细度 ，以周期为分割，仅用store持久
local count_name = "tl-ops-balance-count-" .. tl_ops_constant_balance.count.interval;
local cache_balance_count = require("cache.tl_ops_cache"):new(count_name);


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }

-- 需要提前定义，定时器访问不了
local tl_ops_balance_count_timer



---- 统计器加锁
local tl_ops_balance_count_lock = function()
	local ok, _ = shared:add(tl_ops_constant_balance.cache_key.lock, true, tl_ops_constant_balance.count.interval - 0.01)
	if not ok then
		if _ == "exists" then
			return nil
		end
		return nil
    end
	
	return true
end


---- 统计器 ： 持久化数据
local tl_ops_balance_count = function()
    if not tl_ops_balance_count_lock() then
        return
    end

    local service_list = nil
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str then
        -- use default
        service_list = tl_ops_constant_balance.service.list
    else
        service_list = cjson.decode(service_list_str);
    end
    

    for service_name, nodes in pairs(service_list) do
        for i = 1, #nodes do
            local node_id = i-1
            local cur_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_succ, service_name, node_id)
            local cur_count = shared:get(cur_count_key)
            if not cur_count then
                cur_count = 0
                shared:set(cur_count_key, cur_count)
            end

            -- push to list
            local success_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.balance_5min_success, service_name, node_id)
            local balance_5min_success = cache_balance_count:get001(success_key)
            if not balance_5min_success then
                balance_5min_success = {}
            else
                balance_5min_success = cjson.decode(balance_5min_success)
            end

            balance_5min_success[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
            local ok, _ = cache_balance_count:set001(success_key, cjson.encode(balance_5min_success))
            if not ok then
                tlog:err("balance success count async err ,success_key=",success_key,",cur_count=",cur_count,",err=",_)
            end

            -- rest cur_count
            local ok, _ = shared:set(cur_count_key, 0)
            if not ok then
                tlog:err("balance count reset err ,success_key=",success_key,",cur_count=",cur_count)
            end

            tlog:dbg("balance count async ok ,success_key=",success_key,",balance_5min_success=",balance_5min_success)
        end
    end
end



---- 统计balance次数周期为 5min
tl_ops_balance_count_timer = function(premature, args)
	if premature then
		return
    end

	local ok, _ = pcall(tl_ops_balance_count)
	if not ok then
		tlog:err("failed to pcall : " ,  _)
    end

	local ok, _ = ngx.timer.at(tl_ops_constant_balance.count.interval, tl_ops_balance_count_timer, args)
	if not ok then
		tlog:err("failed to create timer: " , _)
    end

end

---- 启动
function _M:tl_ops_balance_count_timer_start() 
	local ok, _ = ngx.timer.at(0, tl_ops_balance_count_timer, nil)
	if not ok then
		tlog:err("failed to run default args , create timer failed " ,_)
		return nil
    end
end


function _M:new()
	return setmetatable({}, mt)
end


return _M