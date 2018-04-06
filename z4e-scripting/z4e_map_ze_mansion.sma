#include < amxmodx >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < hamsandwich >
#include < dhudmessage >
#include < z4e_alarm >

#define PLUGIN_NAME	"[ZE]Map: ze_mansion"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

new const MAP_MESSAGE[][] = {
	"Defend until the gate opens!",
	"Run!",
	"Wait for the detonation!",
	"Go go go!",
	"Fight until the barrier breaks!",
	"Escape on the train!",
	"Bombing sequence initiated..."
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	new szMap[11];
	get_mapname(szMap, 10)
	if(!equali(szMap, "ze_mansion"))
	{
		pause("a")
		return;
	}
}

public Event_NewRound()
{
	remove_task(TASK_ESCAPE)
	set_task(2.0, "SpawnPrint", TASK_ESCAPE)
	
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_tracktrain"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
		//client_print(0, print_chat, "火车%d 已刷新", pEntity)
	}
}

public SpawnPrint()
{
	client_print(0, print_chat, "Console: ** ze_mansion ** Plugin By Xiaobaibai **")
	z4e_alarm_insert(_, "** 地图: 僵尸公馆 ** 文本: 小白白 **", "难度：***", "", { 50,250,50 }, 2.0);
}

public HamF_GameText_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[32];
	pev(this, pev_message, szMessage, 31);
	
	if(equal(szMessage, MAP_MESSAGE[0]))
	{
		z4e_alarm_insert(_, "大门开启中，拼死抵抗！", "", "", { 250,50,50 }, 2.0);
		z4e_alarm_timertip(14, "公馆大门开启中……");
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[0]);
	}
	else if(equal(szMessage, MAP_MESSAGE[1]))
	{
		z4e_alarm_insert(_, "大门已开启，迅速撤退！", "", "", { 250,50,50 }, 2.0);
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[1]);
	}
	if(equal(szMessage, MAP_MESSAGE[2]))
	{
		z4e_alarm_insert(_, "请等待炸弹引爆……", "", "", { 250,50,50 }, 2.0);
		z4e_alarm_timertip(14, "炸弹引爆中……");
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[2]);
	}
	else if(equal(szMessage, MAP_MESSAGE[3]))
	{
		z4e_alarm_insert(_, "冲 冲 冲！", "", "", { 250,50,50 }, 2.0);
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[3]);
	}
	if(equal(szMessage, MAP_MESSAGE[4]))
	{
		z4e_alarm_insert(_, "路障即将打开，请注意防守", "", "", { 250,50,50 }, 2.0);
		z4e_alarm_timertip(18, "路障开启中……");
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[4]);
	}
	else if(equal(szMessage, MAP_MESSAGE[5]))
	{
		z4e_alarm_insert(_, "迅速跳上火车！", "", "", { 250,50,50 }, 2.0);
		z4e_alarm_timertip(30, "逃跑成功……");
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[5]);
	}
	else if(equal(szMessage, MAP_MESSAGE[6]))
	{
		z4e_alarm_insert(_, "炸弹正在引爆！", "", "", { 250,50,50 }, 2.0);
		client_print(0, print_chat, "Console: ** %s **", MAP_MESSAGE[6]);
	}
	
	//client_print(0, print_chat, "触发trigger_once实体%d , 内容%s", this, szMessage);
}