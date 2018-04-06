
#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_alarm>
#include <z4e_gameplay>
#include <z4e_freeze>

#define PLUGIN "[Z4E] Map: ze_jurassicpark_v2"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TASK_MAP 10086

new g_bCarUsed

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Use, "func_button", "fw_UseButton")
	RegisterHam(Ham_Use, "func_tracktrain", "fw_UseTrackTrain")
	RegisterHam(Ham_Use, "ambient_generic", "HamF_AmbientGeneric_Use")
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_jurassicpark_v2")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
}

public z4e_fw_gameplay_round_new()
{
	remove_task(TASK_MAP)
	g_bCarUsed = 0
	z4e_alarm_push(_, "** 地图: 侏罗纪公园 ** 文本: 小白白 **", "难度：**", "", { 50,250,50 }, 2.0);
}

public HamF_AmbientGeneric_Use(this, caller, activator, use_type)
{
	if(!pev_valid(this))
		return;
	new szTargetName[32];
	pev(this, pev_targetname, szTargetName, 31);
	if(equal(szTargetName, "carsong"))
	{
		z4e_alarm_timertip(7, "别说了快上车！]")
	}
}

public fw_UseTrackTrain(entity, caller, activator, use_type)
{
	if(is_user_connected(caller) && !task_exists(TASK_MAP) && !g_bCarUsed)
	{
		z4e_alarm_timertip(20, "老司机开车中…… ")
		g_bCarUsed = 1
	}
}

public fw_UseButton(entity, caller, activator, use_type)
{
	if(use_type == 2 && is_user_connected(caller) && !task_exists(TASK_MAP))
	{
		if(pev(entity, pev_modelindex) == 90)
		{
			z4e_alarm_insert(_, "坚守阵地，等待救援！", "", "", { 250,50,50 }, 2.0)
			z4e_alarm_timertip(48, "等待救援…… ")
			set_task(48.0, "Task_Rescue", TASK_MAP)
		}
	}
}

public Task_Rescue()
{
	remove_task(TASK_MAP)
	z4e_alarm_timertip(19, "飞机启动…… ")
	set_task(19.0, "Task_Go", TASK_MAP)
}

public Task_Go()
{
	z4e_alarm_timertip(7, "逃生成功…… ")
}
