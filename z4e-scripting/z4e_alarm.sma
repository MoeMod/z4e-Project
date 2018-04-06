#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include <x_alarm>

#include <z4e_team>
#include <z4e_zombie>
#include <z4e_bits>

#define PLUGIN "[Z4E] Alarm"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

new const cfg_szTextAlarmTimer[] = "HUMAN^t%i^tVS^t%i^tZOMBIE" 

enum _:TOTAL_FORWARDS
{
	FW_ALARM_SHOW_PRE = 0,
	FW_ALARM_SHOW_POST
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_iForwards[FW_ALARM_SHOW_PRE] = CreateMultiForward("z4e_fw_alarm_show_pre", ET_CONTINUE, FP_CELL, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_FLOAT)
	g_iForwards[FW_ALARM_SHOW_POST] = CreateMultiForward("z4e_fw_alarm_show_post", ET_IGNORE, FP_CELL, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_FLOAT)
}

public plugin_natives()
{
	register_library("z4e_alarm")
	register_native("z4e_alarm_push", "Native_Push", 1)
	register_native("z4e_alarm_insert", "Native_Insert", 1)
	register_native("z4e_alarm_timertip", "Native_TimerTip", 1)
	register_native("z4e_alarm_kill", "Native_Kill", 1)
}

public Native_Push(iAlarmType, szTitle[], szSubTitle[], szSound[], iColor[], Float:flAlarmTime)
{
	param_convert(2)
	param_convert(3)
	param_convert(4)
	param_convert(5)
	return x_alarm_push(iAlarmType, szTitle, szSubTitle, szSound, iColor, flAlarmTime)
}

public Native_Insert(iAlarmType, szTitle[], szSubTitle[], szSound[], iColor[], Float:flAlarmTime)
{
	param_convert(2)
	param_convert(3)
	param_convert(4)
	param_convert(5)
	return x_alarm_insert(iAlarmType, szTitle, szSubTitle, szSound, iColor, flAlarmTime)
}

public Native_TimerTip(iTime, szText[])
{
	param_convert(2)
	return x_alarm_timertip(iTime, szText)
	
}

public Native_Kill(iKiller, iVictim, iAlarmType)
{
	return x_alarm_kill(iKiller, iVictim, iAlarmType)
}

public x_fw_alarm_show_pre(iType, szTitle[128], szSubTitle[128], szSound[128], iColor[3], Float:flAlarmTime)
{
	if(iType == X_ALARMTYPE_IDLE)
		format(szTitle,127, cfg_szTextAlarmTimer, z4e_team_count(Z4E_TEAM_HUMAN, 1), z4e_team_count(Z4E_TEAM_ZOMBIE, 1))
	
	ExecuteForward(g_iForwards[FW_ALARM_SHOW_PRE], g_iForwardResult, iType, PrepareArray(szTitle, 127, 1), PrepareArray(szSubTitle, 127, 1), PrepareArray(szSound, 127, 1), PrepareArray(iColor, 3, 1), flAlarmTime)
	return g_iForwardResult
}

public x_fw_alarm_show_post(iType, const szTitle[], const szSubTitle[], const szSound[], const iColor[], Float:flAlarmTime)
{
	ExecuteForward(g_iForwards[FW_ALARM_SHOW_POST], g_iForwardResult, iType, PrepareArray(szTitle, 127, 0), PrepareArray(szSubTitle, 127, 0), PrepareArray(szSound, 127, 0), PrepareArray(iColor, 3, 0), flAlarmTime)
	return g_iForwardResult
}