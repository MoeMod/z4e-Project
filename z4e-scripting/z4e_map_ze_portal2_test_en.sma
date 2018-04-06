#include < amxmodx >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < hamsandwich >
#include < dhudmessage >
#include < z4e_alarm >
#include < z4e_team >

#define PLUGIN_NAME	"[Z4E] Map: ze_portal2_test_en"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

new const MAP_SOUND[][] = {
	"ze_portal_test/here we go.wav",
	"ze_portal_test/i'm different.wav",
	"ze_portal_test/the door's malfunctioning.wav",
	"ze_portal_test/Very good.wav",
	"ze_portal_test/Escape.wav"
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "ambient_generic", "HamF_AmbientGeneric_Use")
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	new szMap[19];
	get_mapname(szMap, 18)
	if(!equali(szMap, "ze_portal2_test_en"))
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
	/*
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}*/
	
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_button"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
}

public SpawnPrint()
{
	client_print(0, print_chat, "Console: ** ze_portal2_test_en ** Plugin By Xiaobaibai **")
	z4e_alarm_insert(_, "** 地图: 光圈科学 ** 文本: 小白白 **", "难度：***", "", { 50,250,50 }, 2.0);
	
	for(new id=0;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		if(z4e_team_get(id) != Z4E_TEAM_HUMAN)
			continue;
		
		set_pev(id, pev_health, 255.0);
	}
}

public HamF_AmbientGeneric_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[64];
	pev(this, pev_message, szMessage, 63);
	
	if(equal(szMessage, MAP_SOUND[0]))
	{
		z4e_alarm_insert(_, "GLaDOS: 金属球，我在机房都可以听到你的怪叫", "", "", { 250,250,50 }, 2.0);
		z4e_alarm_insert(_, "Wheatley: Oh，黑喂狗~", "", "", { 50,250,50 }, 1.0);
		z4e_alarm_push(_, "提示：路在脚下喔", "", "", { 250,50,50 }, 2.0);
	}
	else if(equal(szMessage, MAP_SOUND[1]))
	{
		z4e_alarm_insert(_, "炮塔：我可与众不同", "", "", { 250,250,250 }, 2.0);
		z4e_alarm_insert(_, "炮塔: 喵喵喵？", "", "", { 250,250,250 }, 1.0);
		z4e_alarm_insert(_, "炮塔: 有人陪我玩吗？", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szMessage, MAP_SOUND[2]))
	{
		z4e_alarm_timertip(17, "玻璃爆破中……")
		z4e_alarm_insert(_, "GlaDOS：什么也不准碰", "", "", { 250,250,250 }, 2.0);
		z4e_alarm_insert(_, "GlaDOS：我马上就回来", "", "", { 250,250,250 }, 2.0);
		z4e_alarm_insert(_, "GlaDOS：我猜小白白已经把它修好了", "", "", { 250,250,250 }, 2.0);
		z4e_alarm_insert(_, "GlaDOS: 现在门可以用了", "", "", { 250,250,250 }, 1.0);
		z4e_alarm_insert(_, "GlaDOS: 那你们很棒棒哦", "", "", { 250,250,50 }, 1.0);
	}
	else if(equal(szMessage, MAP_SOUND[3]))
	{
		z4e_alarm_timertip(35, "电梯启动中……");
		z4e_alarm_insert(_, "GlaDOS：非常感谢你们之中某人做了微小的工作", "", "", { 250,250,250 }, 3.0);
		z4e_alarm_insert(_, "GlaDOS：很好，你们的团队合作非常默契", "", "", { 250,250,250 }, 3.0);
	}
	else if(equal(szMessage, MAP_SOUND[4]))
	{
		z4e_alarm_insert(_, "GlaDOS：你们赢了。滚吧~", "", "", { 250,250,250 }, 3.0);
		z4e_alarm_insert(_, "GlaDOS：23333", "", "", { 250,250,250 }, 2.0);
	}
	
	//client_print(0, print_chat, "触发ambient_generic实体%d , 内容%s", this, szMessage);
}

public HamF_GameText_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[64];
	pev(this, pev_message, szMessage, 63);
	
	client_print(0, print_chat, "** Console : %s **", szMessage)
	
	//client_print(0, print_chat, "触发game_text实体%d , 内容%s", this, szMessage);
}