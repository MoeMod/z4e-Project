#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < z4e_alarm >
#include < z4e_team >

#define PLUGIN_NAME	"[Z4E] Map: ze_ice4cap_lg"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "func_tracktrain", "HamF_FuncTrackTrain_Use")
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	new szMap[19];
	get_mapname(szMap, 18)
	if(!equali(szMap, "ze_ice4cap_lg"))
	{
		pause("a")
		return;
	}
}

public Event_NewRound()
{
	remove_task(TASK_ESCAPE)
	set_task(2.0, "SpawnPrint", TASK_ESCAPE)
}

public SpawnPrint()
{
	z4e_alarm_insert(_, "** 提示：按 E 可赛艇 **", "", "", { 50,250,50 }, 2.0);
	z4e_alarm_insert(_, "** 地图: 破冰行动 ** 文本: 小白白 **", "难度：未定义", "", { 250,250,250 }, 2.0);
}

public HamF_FuncTrackTrain_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	if(pev(this, pev_modelindex) == 11)
	{
		z4e_alarm_push(_, "一号赛艇已出发", "", "", { 250,250,250 }, 2.0);
	}
	else if(pev(this, pev_modelindex) == 19)
	{
		z4e_alarm_push(_, "二号赛艇已出发", "", "", { 250,250,250 }, 2.0);
	}
	else if(pev(this, pev_modelindex) == 18)
	{
		z4e_alarm_push(_, "缆车已出发", "", "", { 250,250,250 }, 2.0);
	}
	else if(pev(this, pev_modelindex) == 63)
	{
		z4e_alarm_timertip(25, "最终逃跑…… ");
	}
}

public HamF_FuncButton_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	if(pev(this, pev_modelindex) == 31)
	{
		z4e_alarm_timertip(30, "阿帕奇直升机加油中…… ");
	}
}
