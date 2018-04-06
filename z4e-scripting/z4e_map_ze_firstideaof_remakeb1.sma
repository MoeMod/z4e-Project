#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < z4e_alarm >
#include < z4e_team >

#define PLUGIN_NAME	"[Z4E] Map: ze_firstideaof_remakeb1"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_firstideaof_remakeb1"))
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
	z4e_alarm_insert(_, "** 地图: 丛林军事基地 ** 文本: 小白白 **", "难度：**", "", { 50,250,50 }, 2.0);
}

public HamF_FuncButton_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szTarget[31];
	pev(this, pev_target, szTarget, 31);
	
	if(equal(szTarget, "masterescape") && !task_exists(TASK_ESCAPE))
	{
		z4e_alarm_timertip(10, "等待直升机起飞…… ");
		set_task(10.0, "Task_End", TASK_ESCAPE)
	}
	
}

public Task_End()
{
	z4e_alarm_timertip(30, "直升机运行中…… ");
	set_task(30.0, "Task_End", TASK_ESCAPE);
}

public Task_End2()
{
	z4e_alarm_timertip(233, "喵 ");
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
	
}