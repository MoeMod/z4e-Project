#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < z4e_alarm >
#include < z4e_team >

#define PLUGIN_NAME	"[Z4E] Map: ze_axn_minecraft_b2"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "multi_manager", "HamF_MultiManager_Use")
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_axn_minecraft_b2"))
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
	z4e_alarm_insert(_, "** 地图: 我的世界I ** 文本: 小白白 **", "难度：*", "", { 250,250,250 }, 2.0);
}

public HamF_MultiManager_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[64];
	pev(this, pev_message, szMessage, 63);
	
	new szTargetName[31];
	pev(this, pev_targetname, szTargetName, 31);
	
	if(equal(szTargetName, "escape"))
	{
		z4e_alarm_timertip(10, "最后逃跑…… ");
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
	
	
	if(equal(szTargetName, "texto0"))
	{
		z4e_alarm_timertip(10, "1号大门爆破中…… ");
	}
	else if(equal(szTargetName, "text1"))
	{
		z4e_alarm_timertip(8, "2号大门爆破中…… ");
	}
}