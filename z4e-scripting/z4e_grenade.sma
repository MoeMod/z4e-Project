#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_team>
#include <z4e_knockback>
#include <z4e_freeze>
#include <z4e_burn>

#define PLUGIN "[Z4E] Grenade"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// Custom Grenade
const PEV_NADETYPE = pev_flTimeStepSound
enum _:MAX_NADE_TYPE(+=1111)
{
	NADE_TYPE_NONE = 0,
	NADE_TYPE_HEGRENADE,
	NADE_TYPE_FLASHBANG,
	NADE_TYPE_SMOKEGRENADE,
	NADE_TYPE_ZOMBIEBOMB,
	NADE_TYPE_ZOMBIEBOMB2,
}
//#define NADE_FLASHBANG_RADIUS 420.0
//#define NADE_FLASHBANG_KNOCKBACK 700.0
//#define NADE_FLASHBANG_KNOCKHIGH 0.4

#define NADE_FLASHBANG_RADIUS 420.0
#define NADE_FLASHBANG_KNOCKBACKA 8000.0
#define NADE_FLASHBANG_KNOCKBACKB 3000.0
#define NADE_FLASHBANG_KNOCKBACKC 2500.0
#define NADE_FLASHBANG_KNOCKBACKD 4000.0
#define NADE_FLASHBANG_KNOCKBACKE 1.0
new const SOUND_FB_EXP[] = "metalarena/acc_up.wav"

#define NADE_HEGRENADE_RADIUS 420.0
new const SOUND_HE_EXP[] = "zombie_plague/grenade_explode.wav"

#define NADE_SMOKEGRENADE_RADIUS 420.0
new const SOUND_SG_EXP[] = "warcraft3/impalehit.wav"

new const FIRE_MODEL[] = "sprites/z4e/flame.spr"

new g_iSprFire, g_iSprShockWave

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_SetModel, "fw_SetModel")
	
	RegisterHam(Ham_Think, "grenade", "HamF_Grenade_Think")
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, SOUND_FB_EXP)
	engfunc(EngFunc_PrecacheSound, SOUND_HE_EXP)
	engfunc(EngFunc_PrecacheSound, SOUND_SG_EXP)
	
	g_iSprFire = precache_model(FIRE_MODEL)
	g_iSprShockWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
}

public fw_SetModel(iEntity, const szModel[])
{
	// We don't care
	if (strlen(szModel) < 8)
		return FMRES_IGNORED
		
	// Narrow down our matches a bit
	if (szModel[7] != 'w' || szModel[8] != '_')
		return FMRES_IGNORED
	
	// Get damage time of grenade
	static Float:flDmgTime
	pev(iEntity, pev_dmgtime, flDmgTime)
	
	if (szModel[9] == 'h' && szModel[10] == 'e' && szModel[11] == 'g')
	{
		if(flDmgTime != 0.0)
		{
			set_pev(iEntity, PEV_NADETYPE, NADE_TYPE_HEGRENADE)
			return FMRES_IGNORED
		}
	}
	else if (szModel[9] == 'f' && szModel[10] == 'l' && szModel[11] == 'a')
	{
		if(flDmgTime != 0.0)
		{
			set_pev(iEntity, PEV_NADETYPE, NADE_TYPE_FLASHBANG)
			return FMRES_IGNORED
		}
	}
	else if (szModel[9] == 's' && szModel[10] == 'm' && szModel[11] == 'o')
	{
		if(flDmgTime != 0.0)
		{
			set_pev(iEntity, PEV_NADETYPE, NADE_TYPE_SMOKEGRENADE)
			return FMRES_IGNORED
		}
	}
	return FMRES_IGNORED
}

// Ham Grenade Think Forward
public HamF_Grenade_Think(iEntity)
{
	// Invalid entity
	if (!pev_valid(iEntity)) 
		return HAM_IGNORED;
	
	// Get damage time of grenade
	static iType; iType = pev(iEntity, PEV_NADETYPE)
	static Float:flDmgTime; pev(iEntity, pev_dmgtime, flDmgTime)
	
	// Check if it's time to go off
	if (get_gametime() > flDmgTime)
	{
		// Check if it's one of our custom nades
		switch (iType)
		{
			case NADE_TYPE_HEGRENADE: // HE Grenade: No need
			{
				CustomGrenade_HE_Explode(iEntity)
				return HAM_SUPERCEDE;
			}
			case NADE_TYPE_FLASHBANG: // FlashBang: Kickback
			{
				CustomGrenade_FB_Explode(iEntity)
				return HAM_SUPERCEDE;
			}
			case NADE_TYPE_SMOKEGRENADE: // Smoke Grenade: No need
			{
				CustomGrenade_SG_Explode(iEntity)
				return HAM_SUPERCEDE;
			}
		}
	}
		
	return HAM_IGNORED;
}

CustomGrenade_FB_Explode(iEntity)
{
	emit_sound(iEntity, CHAN_BODY, SOUND_FB_EXP, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static Float:vecOrigin[3]; pev(iEntity, pev_origin, vecOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + NADE_FLASHBANG_RADIUS)
	write_short(g_iSprShockWave)
	write_byte(0) // Start Frame
	write_byte(20) // Framerate
	write_byte(4) // Live Time
	write_byte(10) // Width
	write_byte(10) // Noise
	write_byte(0) // R
	write_byte(255) // G
	write_byte(255) // B
	write_byte(255) // Bright
	write_byte(9) // Speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + NADE_FLASHBANG_RADIUS)
	write_short(g_iSprShockWave)
	write_byte(0) // Start Frame
	write_byte(10) // Framerate
	write_byte(4) // Live Time
	write_byte(10) // Width
	write_byte(20) // Noise
	write_byte(0) // R
	write_byte(255) // G
	write_byte(0) // B
	write_byte(150) // Bright
	write_byte(9) // Speed
	message_end() 
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, NADE_FLASHBANG_RADIUS)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		z4e_knockback_set(pEntity, iEntity, NADE_FLASHBANG_KNOCKBACKA, NADE_FLASHBANG_KNOCKBACKB, NADE_FLASHBANG_KNOCKBACKC, NADE_FLASHBANG_KNOCKBACKD, NADE_FLASHBANG_KNOCKBACKE, Z4E_KNOCKBACK_IGNORERETURN|Z4E_KNOCKBACK_IGNORECHECK|Z4E_KNOCKBACK_IGNOREABILITY|Z4E_KNOCKBACK_DRAWANIM)
	}
	fm_remove_entity(iEntity)
}

CustomGrenade_HE_Explode(iEntity)
{
	emit_sound(iEntity, CHAN_BODY, SOUND_HE_EXP, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static Float:vecOrigin[3]; pev(iEntity, pev_origin, vecOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_FIREFIELD) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, vecOrigin[1]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, vecOrigin[2]-10.0)
	write_short(675) //radius
	write_short(g_iSprFire) // sprite
	write_byte(random_num(20, 50)) // count
	write_byte(TEFIRE_FLAG_SOMEFLOAT|TEFIRE_FLAG_LOOP|TEFIRE_FLAG_PLANAR|32) // flags
	write_byte(15) // duration (in seconds) * 10
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + NADE_HEGRENADE_RADIUS)
	write_short(g_iSprShockWave)
	write_byte(0) // Start Frame
	write_byte(10) // Framerate
	write_byte(4) // Live Time
	write_byte(10) // Width
	write_byte(20) // Noise
	write_byte(255) // R
	write_byte(0) // G
	write_byte(0) // B
	write_byte(150) // Bright
	write_byte(9) // Speed
	message_end() 
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, NADE_HEGRENADE_RADIUS)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		z4e_burn_set(pEntity, 3.0, 1);
	}
	fm_remove_entity(iEntity)
}

CustomGrenade_SG_Explode(iEntity)
{
	emit_sound(iEntity, CHAN_BODY, SOUND_SG_EXP, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static Float:vecOrigin[3]; pev(iEntity, pev_origin, vecOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + NADE_HEGRENADE_RADIUS)
	write_short(g_iSprShockWave)
	write_byte(0) // Start Frame
	write_byte(20) // Framerate
	write_byte(4) // Live Time
	write_byte(10) // Width
	write_byte(10) // Noise
	write_byte(0) // R
	write_byte(255) // G
	write_byte(255) // B
	write_byte(255) // Bright
	write_byte(9) // Speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + NADE_HEGRENADE_RADIUS)
	write_short(g_iSprShockWave)
	write_byte(0) // Start Frame
	write_byte(10) // Framerate
	write_byte(4) // Live Time
	write_byte(10) // Width
	write_byte(20) // Noise
	write_byte(0) // R
	write_byte(0) // G
	write_byte(255) // B
	write_byte(150) // Bright
	write_byte(9) // Speed
	message_end() 
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, NADE_SMOKEGRENADE_RADIUS)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		z4e_freeze_set(pEntity, 2.0, 1);
	}
	fm_remove_entity(iEntity)
}