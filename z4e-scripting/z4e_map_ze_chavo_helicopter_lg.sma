#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < z4e_alarm >
#include < z4e_gameplay >

#define PLUGIN_NAME	"[Z4E] Map: ze_chavo_helicopter_lg"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_cfg()
{
	Event_NewRound();
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_chavo_helicopter_lg"))
	{
		pause("a")
		return;
	}
}

public Event_NewRound()
{
	remove_task(TASK_ESCAPE)
	
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_tracktrain"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
	
	z4e_alarm_insert(_, "** 坚守阵地直到直升机到来！ **", "", "", { 250,250,250 }, 2.0);
	z4e_alarm_insert(_, "** 地图: 查沃小镇 ** 文本: 小白白 **", "难度：***", "", { 250,250,250 }, 2.0);
	
}

public z4e_fw_gameplay_plague_post()
{
	set_task(7.0, "Task_Print", TASK_ESCAPE)
}
// 240 105 80 40
public Task_Print()
{
	z4e_alarm_timertip(135, "救援直升机正在赶来……")
	set_task(135.0, "Task_HelicopterArrive", TASK_ESCAPE)
}

public Task_HelicopterArrive()
{
	z4e_alarm_timertip(25, "救援直升机起飞中……")
	set_task(25.0, "Task_HelicopterLeave", TASK_ESCAPE)
}

public Task_HelicopterLeave()
{
	z4e_alarm_timertip(40, "救援直升机已离开……")
}