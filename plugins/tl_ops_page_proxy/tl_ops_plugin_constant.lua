local tl_ops_plugin_constant_page_proxy = {
    cache_key = {

    },
    export = {
        cache_key = {
            page_proxy = "tl_ops_plugins_export_page_proxy",
        },
        tlops_api = {
            get = "/tlops/page-proxy/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/page-proxy/manage/set",           -- 修改插件配置数据的接口
        },
        page_proxy = {
            zname = '页面代理插件',
            page = "",
            name = 'page_proxy',
            open = true,
            scope = "tl_ops_process_before_init_rewrite",
        },
        demo = {
            zname = '',         -- 插件中文名称
            page = "",          -- 插件配置页面
            name = '',          -- 插件名称
            open = true,        -- 插件是否开启
            scope = "",         -- 插件生命周期阶段
        }
    }
}

return tl_ops_plugin_constant_page_proxy;