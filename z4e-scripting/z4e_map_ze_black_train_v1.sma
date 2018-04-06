#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < z4e_alarm >
#include < z4e_team >

#define PLUGIN_NAME	"[Z4E] Map: ze_black_train_v1"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_clcmd("goto", "CMD_Goto");
}

public CMD_Goto(id)
{
	set_pev(id, pev_origin, {1189.0, 2859.0, 0.0});
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_black_train_v1"))
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
	z4e_alarm_insert(_, "** 地图: 暗黑火车站 ** 文本: 小白白 **", "难度：***", "", { 250,250,250 }, 2.0);
}

public HamF_FuncButton_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	if(pev(this, pev_modelindex) == 27)
	{
		z4e_alarm_timertip(62, "火车启动中…… ");
	}
}

public HamF_GameText_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[64];
	pev(this, pev_message, szMessage, 63);
	
	new szTargetName[31];
	pev(this, pev_targetname, szTargetName, 31);
	
	client_print(0, print_chat, "** Console : %s **", szMessage)
	
	/*
	if(equal(szTargetName, "men1a"))
	{
		z4e_alarm_insert(_, "** 四号飞船准备离开 **", "", "", { 250,250,250 }, 2.0);
	}*/
	
}