#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include <z4e_alarm>
#include <z4e_team>
#include <z4e_zombie>
#include <z4e_gameplay>
#include <z4e_freeze>
#include <z4e_bits>

#define PLUGIN "[Z4E] Map: ze_vip"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TASK_MAP 10086

new g_bRoundEnd

enum
{
	Z4E_ALARMTYPE_ZOMBIEWIN = 2000,
	Z4E_ALARMTYPE_HUMANWIN,
	Z4E_ALARMTYPE_ROUNDDRAW
}

// offset
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	OrpheuRegisterHook(OrpheuGetFunction("PM_Move"), "OnPM_Move");
	
	RegisterHam(Ham_TakeDamage, "func_breakable", "HamF_FuncBreakable_TakeDamage");
	
	fm_remove_entity_name("info_player_deathmatch");
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_vip")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
}

public HamF_FuncBreakable_TakeDamage(this, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!pev_valid(this))
		return HAM_IGNORED;
	new Float:flHealth;
	pev(this, pev_health, flHealth);
	if(flHealth >= 300.0)
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public OrpheuHookReturn:OnPM_Move(OrpheuStruct:ppmove, server)
{
	static id; id = OrpheuGetStructMember(ppmove, "player_index") + 1
	if(BitsIsPlayer(id))
	{
		if(BitsGet(z4e_gameplay_bits_get_status(), Z4E_GAMESTATUS_GAMESTARTED) && !BitsGet(z4e_gameplay_bits_get_status(), Z4E_GAMESTATUS_INFECTIONSTART))
			return OrpheuSupercede;
	}
	return OrpheuIgnored;
}

public plugin_cfg()
{
	z4e_fw_gameplay_round_new();
}

public z4e_fw_zombie_originate_post(id, iZombieCount)
{
	z4e_fw_team_spawn_post(id)
	z4e_freeze_set(id, 0.1, 0);
}

public z4e_fw_team_spawn_post(id)
{
	new const Float:vecMins[3] = { -3711.0, -3727.0, 661.0};
	new const Float:vecMaxs[3] = { -2693.0, -2161.0, 670.0};
	if(z4e_team_get_user_zombie(id))
	{
		RandomSpawn(id, vecMins, vecMaxs);
	}
}

public z4e_fw_gameplay_round_new()
{
	remove_task(TASK_MAP);
	set_task(1.0, "Task_Timer", TASK_MAP)
	
	g_bRoundEnd = 0;
	
	z4e_alarm_push(_, "** 地图: VIP逃生 ** 插件：小白白 **", "难度：***", "", { 250,250,50 }, 2.0);
	z4e_alarm_push(_, "** 本地图将会有一半的玩家变成僵尸 **", "", "", { 250,250,50 }, 2.0);
	z4e_alarm_push(_, "** 请大家做好战斗准备 **", "", "", { 250,250,50 }, 2.0);
}

public z4e_fw_gameplay_plague_pre()
{
	new bitsRemaining = z4e_team_bits_get_alive()
	new iZombieNum = BitsCount(bitsRemaining) / 2
	
	for(new i = 0; i < iZombieNum; i++)
	{
		new iRandom = BitsGetRandom(bitsRemaining)
		iRandom = !iRandom ? 32:iRandom
		
		z4e_zombie_originate(iRandom, iZombieNum)
		BitsUnSet(bitsRemaining, iRandom)
	}
	
	new bitsGameStatus = z4e_gameplay_bits_get_status();
	BitsSet(bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART);
	z4e_gameplay_bits_set_status(bitsGameStatus);
	
	return PLUGIN_HANDLED;
}

public Task_Timer()
{
	
	new const Float:vecEscapeMins[3] = {-1088.0, -575.0, 0.0};
	new const Float:vecEscapeMaxs[3] = {256.0, 320.0, 512.0};
	
	new Float:vecOrigin[3];
	for(new id=1;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		pev(id, pev_origin, vecOrigin);
		if(CheckPointIn(vecOrigin, vecEscapeMins, vecEscapeMaxs))
		{
			if(z4e_team_get_user_zombie(id))
			{
				z4e_alarm_push(Z4E_ALARMTYPE_ZOMBIEWIN, "逃生失败...", "", "", { 250,50,50 }, 6.0);
				new bitsGameStatus = z4e_gameplay_bits_get_status();
				BitsSet(bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED);
				z4e_gameplay_bits_set_status(bitsGameStatus);
				return;
			}
			
			if(!g_bRoundEnd)
			{
				z4e_alarm_timertip(7, "最终逃跑…… ");
				set_task(7.0, "Task_Kill", TASK_MAP);
				g_bRoundEnd = 1;
				break;
			}
		}
	}
	
	set_task(1.0, "Task_Timer", TASK_MAP)
}

public Task_Kill()
{
	new const Float:vecEscapeMins[3] = {-1088.0, -575.0, 0.0};
	new const Float:vecEscapeMaxs[3] = {256.0, 320.0, 512.0};
	
	new Float:vecOrigin[3];
	for(new id=1;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		pev(id, pev_origin, vecOrigin);
		if(!CheckPointIn(vecOrigin, vecEscapeMins, vecEscapeMaxs))
			user_kill(id);
	}
	
	
}

stock CheckPointIn(const Float:vecOrigin[3], const Float:vecMins[3], const Float:vecMaxs[3])
{
	if(vecOrigin[0] < vecMins[0] || vecOrigin[0] > vecMaxs[0])
		return 0;
	if(vecOrigin[1] < vecMins[1] || vecOrigin[1] > vecMaxs[1])
		return 0;
	if(vecOrigin[2] < vecMins[2] || vecOrigin[2] > vecMaxs[2])
		return 0;
	return 1;
}

stock RandomSpawn(id, const Float:vecMins[3], const Float:vecMaxs[3])
{
	static Float:vecOrigin[3];
	do
	{
		RandomVector(vecMins, vecMaxs, vecOrigin);
	}
	while(!is_hull_vacant(vecOrigin, HULL_HUMAN));
	set_pev(id, pev_origin, vecOrigin);
}

stock RandomVector(const Float:vecMins[3], const Float:vecMaxs[3], Float:vecOut[3])
{
	for(new i=0;i<3;i++) vecOut[i] = random_float(vecMins[i], vecMaxs[i])
}

stock is_hull_vacant(Float:Origin[3], hull)
{
	engfunc(EngFunc_TraceHull, Origin, Origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true
	
	return false
}