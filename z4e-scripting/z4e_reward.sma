
#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>
#include <z4e_api>
#include <z4e_team>
#include <z4e_gameplay>
#include <z4e_ammopacks>
//#include <x_item>

#define PLUGIN "[x][Z4E] Reward"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// OffSet
#define PDATA_SAFE 2
#define OFFSET_LINUX 5
#define OFFSET_CSTEAMS 114
#define OFFSET_CSDEATHS 444

new g_iScore[33], Float:g_flDamageToEffect[33], g_iEffectCount[33];
new g_MsgScoreInfo
new gmsgZ4E_DamageStar

// Bonus System
new Float:g_flNextBonusCheck[33]
new g_iBonusCount[33]
new g_iBonusPerSec[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Player_PostThink, "player", "fw_Player_PostThink")
	RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_Player_TakeDamage_Post", 1)
	RegisterHam(Ham_TakeDamage, "info_target", "fw_Boss_TakeDamage_Post", 1)
	
	g_MsgScoreInfo = get_user_msgid("ScoreInfo")
	gmsgZ4E_DamageStar = engfunc(EngFunc_RegUserMsg, "DamageStar", -1);
	server_print("gmsgZ4E_DamageStar=%d", gmsgZ4E_DamageStar);
}

public z4e_fw_api_bot_registerham(id)
{
	RegisterHamFromEntity(Ham_Player_PostThink, id, "fw_Player_PostThink")
	RegisterHamFromEntity(Ham_Killed, id, "fw_Killed_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_Player_TakeDamage_Post", 1)
}

public fw_Player_PostThink(id)
{
	Bonus_Check(id)
}

public fw_Killed_Post(iVictim, iAttacker)
{
	if(!is_user_connected(iAttacker) || !is_user_connected(iVictim))
		return
	if(z4e_team_get_user_zombie(iAttacker) && !z4e_team_get_user_zombie(iVictim))
	{
		switch(BitsCount(z4e_team_bits_get_connected()))
		{
			case 4..10: g_iScore[iAttacker] += random_num(2100, 2800)
			case 11..20: g_iScore[iAttacker] += random_num(1400, 2100)
			case 21..32: g_iScore[iAttacker] += random_num(700, 1400)
		}
		UpdateFrags(iAttacker, iVictim, 1, 0, 1)
		Bonus_Give(iAttacker, 300)
	}
	else if(!z4e_team_get_user_zombie(iAttacker) && z4e_team_get_user_zombie(iVictim))
	{
		switch(BitsCount(z4e_team_bits_get_connected()))
		{
			case 4..10: g_iScore[iAttacker] += random_num(700, 2100)
			case 11..20: g_iScore[iAttacker] += random_num(1400, 3500)
			case 21..32: g_iScore[iAttacker] += random_num(2800, 4900)
		}
		UpdateFrags(iAttacker, iVictim, 2, 0, 1)
		Bonus_Give(iAttacker, 300)
	}
}

public fw_Player_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (iVictim == iAttacker || !is_user_connected(iAttacker) || !is_user_connected(iVictim))
		return;
	if(z4e_team_get(iAttacker) == z4e_team_get(iVictim))
		return;
	switch(BitsCount(z4e_team_bits_get_connected()))
	{
		case 4..10: g_iScore[iAttacker] += floatround(floatmin(1000.0, flDamage) * 0.1)
		case 11..20: g_iScore[iAttacker] += floatround(floatmin(1000.0, flDamage) * 0.3)
		case 21..32: g_iScore[iAttacker] += floatround(floatmin(1000.0, flDamage) * 0.4)
	}
	
	g_flDamageToEffect[iAttacker] += flDamage;
	new iEffectCount = floatround(g_flDamageToEffect[iAttacker] / 100.0, floatround_floor)	
	if (iEffectCount)
	{
		g_flDamageToEffect[iAttacker] -= 100.0 * iEffectCount
		g_iEffectCount[iAttacker]+=iEffectCount;
		if(g_iEffectCount[iAttacker]>=10)
		{
			g_iEffectCount[iAttacker] %= 10;
			Bonus_Give(iAttacker, 100);
			UpdateFrags(iAttacker, iVictim, 1, 0, 1);
		}
		SendEffect(iAttacker, iEffectCount, 0);
	}
}

public fw_Boss_TakeDamage_Post(iEntity, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (!pev_valid(iEntity))
		return;
	if (!is_user_connected(iAttacker))
		return;
	new szClassname[32]
	pev(iEntity, pev_classname, szClassname, 31)
	if(!equal(szClassname, "z4e_boss"))
		return;
	switch(BitsCount(z4e_team_bits_get_connected()))
	{
		case 4..10: g_iScore[iAttacker] += floatround(floatmin(1000.0, flDamage) * 0.15)
		case 11..20: g_iScore[iAttacker] += floatround(floatmin(1000.0, flDamage) * 0.25)
		case 21..32: g_iScore[iAttacker] += floatround(floatmin(1000.0, flDamage) * 0.5)
	}
	
	g_flDamageToEffect[iAttacker] += flDamage;
	new iEffectCount = floatround(g_flDamageToEffect[iAttacker] / 100.0, floatround_floor)	
	if (iEffectCount)
	{
		g_flDamageToEffect[iAttacker] -= 100.0 * iEffectCount
		g_iEffectCount[iAttacker]+=iEffectCount;
		if(g_iEffectCount[iAttacker]>=10)
		{
			Bonus_Give(iAttacker, 100);
			g_iEffectCount[iAttacker] %= 10;
			UpdateFrags(iAttacker, 0, 1, 0, 1);
		}
		SendEffect(iAttacker, iEffectCount, 1);
	}
}

public SendEffect(id, n, iType)
{
	//client_print(id, print_chat, "SendEffect()");
	
	engfunc(EngFunc_MessageBegin, MSG_ONE, gmsgZ4E_DamageStar, Float:{0.0,0.0,0.0}, id);
	write_byte(n)
	write_byte(iType)
	write_byte(0)
	message_end()
}

public UpdateFrags(iAttacker, iVictim, iFrags, iDeaths, bUpdate)
{
	if(is_user_connected(iAttacker) && is_user_connected(iVictim) && fm_get_user_team(iAttacker) != fm_get_user_team(iVictim))
	{
		if((pev(iAttacker, pev_frags) + iFrags) < 0)
			return
	}
	
	if(is_user_connected(iAttacker))
	{
		// Set iAttacker iFrags
		set_pev(iAttacker, pev_frags, float(pev(iAttacker, pev_frags) + iFrags))
		
		// Update with iAttacker and iVictim info
		if(bUpdate)
		{
			message_begin(MSG_BROADCAST, g_MsgScoreInfo)
			write_byte(iAttacker) // id
			write_short(pev(iAttacker, pev_frags)) // iFrags
			write_short(fm_get_user_deaths(iAttacker)) // iDeaths
			write_short(0) // class?
			write_short(int:fm_get_user_team(iAttacker)) // team
			message_end()
		}
	}
	
	if(is_user_connected(iVictim))
	{
		// Set iVictim iDeaths
		fm_cs_set_user_deaths(iVictim, fm_get_user_deaths(iVictim) + iDeaths)
		
		// Update with iAttacker and iVictim info
		if(bUpdate)
		{
			message_begin(MSG_BROADCAST, g_MsgScoreInfo)
			write_byte(iVictim) // id
			write_short(pev(iVictim, pev_frags)) // iFrags
			write_short(fm_get_user_deaths(iVictim)) // iDeaths
			write_short(0) // class?
			write_short(int:fm_get_user_team(iVictim)) // team
			message_end()
		}
	}
}

public z4e_fw_gameplay_roundend_post(iWinTeam)
{
	
	static iRewardCoin , szMessage[256]
	for(new id = 1;id < 33; id++)
	{
		if(!is_user_connected(id))
			continue;
			
		if(z4e_team_get(id) == iWinTeam && BitsCount(z4e_team_bits_get_connected()) > 4)
		{
			if(iWinTeam==Z4E_TEAM_HUMAN && is_user_alive(id))
			{
				//g_iScore[id] += 7000
				g_iScore[id] += min((g_iBonusCount[id] / 60) * 1400, 7000)
				Bonus_Give(id, 1400)
				UpdateFrags(id, 0, 7, 0, 1)
			}
			else
			{
				//g_iScore[id] += 1000
				g_iScore[id] += min((g_iBonusCount[id] / 60) * 200, 1000)
				Bonus_Give(id, 200)
				UpdateFrags(id, 0, 1, 0, 1)
			}
		}
		
		g_iBonusCount[id] = 0;
			
		iRewardCoin = floatround(g_iScore[id] / 1400.0 * 12.0)
		g_iScore[id] = 0
		if(iRewardCoin <= 0)
			continue;
		//x_item_set(id, "tz_coin", x_item_get(id, "tz_coin") + iRewardCoin)
		//format(szMessage, 255, "^x04[Thanatos] ^x01根据你的战绩，系统奖励^x03%i^x01个死神币(12倍活动奖励)。", iRewardCoin)
		//client_color(id, id, szMessage)
		
	}
}

public client_color(playerid, colorid, msg[])
{
	message_begin(playerid?MSG_ONE:MSG_ALL,get_user_msgid("SayText"),_,playerid) 
	write_byte(colorid)
	write_string(msg)
	message_end()
}

Bonus_Give(id, iAmount)
{
	g_iBonusPerSec[id] += iAmount
	g_flNextBonusCheck[id] = get_gametime() + 0.2
}

Bonus_Check(id)
{
	static Float:flCurTime; flCurTime = get_gametime()
	if(flCurTime < g_flNextBonusCheck[id])
		return
	
	if(g_iBonusPerSec[id])
		z4e_ammopacks_set(id, g_iBonusPerSec[id])
	g_iBonusPerSec[id] = 0
	g_iBonusCount[id]++;
	
	g_flNextBonusCheck[id] = flCurTime + 1.0
}

stock CsTeams:fm_get_user_team(id)
{
	if (pev_valid(id) != PDATA_SAFE)
		return CsTeams:-1;
	return CsTeams:get_pdata_int(id, OFFSET_CSTEAMS);
}

stock fm_get_user_deaths(index)
{
	if (pev_valid(index) != PDATA_SAFE)
		return -1;
	return get_pdata_int(index, OFFSET_CSDEATHS);
}
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}