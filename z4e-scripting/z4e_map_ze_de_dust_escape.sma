
#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>
#include <z4e_alarm>
#include <z4e_gameplay>

#define PLUGIN "[Z4E] Map: ze_de_dust_escape"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

enum
{
	TS_AT_TOP,
	TS_AT_BOTTOM,
	TS_GOING_UP,
	TS_GOING_DOWN
}

new g_bitsMapRecord

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Use, "func_button", "fw_UseButton")
	RegisterHam(Ham_Use, "func_door", "fw_UseDoor")
	
	//register_clcmd("goto", "CMD_Goto")
}
/*
public CMD_Goto(id)
{
	set_pev(id, pev_origin, {-360.0,1185.0, -180.0})
}
*/
public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_de_dust_escape")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
}

public z4e_fw_gameplay_round_new()
{
	z4e_alarm_push(_, "** 地图: 沙漠遗迹I ** 文本: 小白白 **", "难度：***", "", { 50,250,50 }, 2.0);
	
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) == 62)
		{
			ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_TOP);
			
		}
		
	}
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_button"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
	
	g_bitsMapRecord = 0;
}

public fw_UseDoor(entity, caller, activator, use_type)
{
	if(!BitsGet(g_bitsMapRecord, 1) && pev(entity, pev_modelindex) == 64)
	{
		z4e_alarm_timertip(12, "小门开启中…… ");
		BitsSet(g_bitsMapRecord, 1)
	}
	else if(!BitsGet(g_bitsMapRecord, 4) && pev(entity, pev_modelindex) == 73)
	{
		z4e_alarm_timertip(6, "最终逃脱…… ");
		BitsSet(g_bitsMapRecord, 4)
	}
}

public fw_UseButton(entity, caller, activator, use_type)
{
	if(use_type == 2 && is_user_connected(caller))
	{
		if(!BitsGet(g_bitsMapRecord, 0) && pev(entity, pev_modelindex) == 63)
		{
			z4e_alarm_timertip(60, "大门开启中…… ");
			BitsSet(g_bitsMapRecord, 0)
		}
		else if(!BitsGet(g_bitsMapRecord, 3) && pev(entity, pev_modelindex) == 74)
		{
			z4e_alarm_timertip(60, "炸弹引爆中…… ");
			BitsSet(g_bitsMapRecord, 3)
		}
	}
}

