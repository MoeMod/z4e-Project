#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_alarm>
#include <z4e_gameplay>
#include <z4e_freeze>

#define PLUGIN "[Z4E] Map: ze_hospital_lg"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TASK_MAP 10086

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    RegisterHam(Ham_Use, "func_button", "fw_UseButton")
}

public plugin_precache()
{
    new szMap[32];
    get_mapname(szMap, 31)
    if(!equali(szMap, "ze_hospital_lg")) // equali比较字符串不区分大小写
    {
        pause("a")
        return;
    }
}

public z4e_fw_gameplay_round_new()
{
	z4e_alarm_insert(_, "** 地图: 生化医院 ** 文本: 小白白 **", "难度：**", "", { 250,250,250 }, 2.0);
    remove_task(TASK_MAP)
}

public fw_UseButton(entity, caller, activator, use_type)
{
    if(use_type == 2 && is_user_connected(caller) && !task_exists(TASK_MAP))
    {
        z4e_alarm_insert(_, "救援即将到达！", "", "", { 250,50,50 }, 2.0)
        z4e_alarm_timertip(20, "等待救援…… ")
        set_task(20.0, "Task_Rescue", TASK_MAP)
    }
}

public Task_Rescue()
{
    remove_task(TASK_MAP)
    z4e_alarm_insert(_, "快上飞机！", "", "", { 250,50,50 }, 2.0)
    z4e_alarm_timertip(15, "飞机启动中……")
    set_task(15.0, "Task_Go", TASK_MAP)
}

public Task_Go()
{
    z4e_alarm_timertip(18, "逃生成功…… ")
}
