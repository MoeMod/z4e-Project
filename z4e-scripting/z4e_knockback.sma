#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>
#include <z4e_api>
#include <z4e_team>
#include <z4e_gameplay>

#define PLUGIN "[Z4E] Knockback"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define PDATA_SAFE 2
#define OFFSET_LINUX 5
stock m_flVelocityModifier = 108

// Knockback
enum _:MAX_KNOCKBACK_TYPE(<<=1)
{
    Z4E_KNOCKBACK_NONE = 0,
    Z4E_KNOCKBACK_IGNOREABILITY = 1,
    Z4E_KNOCKBACK_IGNORERETURN,
    Z4E_KNOCKBACK_IGNORECHECK,
    Z4E_KNOCKBACK_DRAWANIM,
    Z4E_KNOCKBACK_INSIDE,
}
new Float:cfg_flWeaponKnockback[][5] = 
{
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // ---
    {85.0,100.0,100.0,80.0,0.8},    // P228
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // ---
    {3000.0,500.0,1200.0,800.0,0.3},    // SCOUT
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // ---
    {700.0,450.0,600.0,450.0,0.4},    // XM1014
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // ---
    {250.0,200.0,250.0,90.0,0.7},    // MAC10
    {350.0,250.0,300.0,100.0,0.6},    // AUG
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // ---
    {85.0,100.0,100.0,80.0,0.8},    // ELITE
    {85.0,100.0,100.0,80.0,0.8},    // FIVESEVEN
    {250.0,200.0,250.0,90.0,0.7},    // UMP45
    {450.0,400.0,400.0,200.0,0.5},    // SG550
    {350.0,250.0,300.0,100.0,0.6},    // GALIL
    {350.0,250.0,300.0,100.0,0.6},    // FAMAS
    {85.0,100.0,100.0,80.0,0.8},    // USP
    {85.0,100.0,100.0,80.0,0.8},    // GLOCK18
    {5000.0,500.0,1200.0,800.0,0.3},    // AWP
    {250.0,200.0,250.0,90.0,0.7},    // MP5NAVY
    {350.0,250.0,300.0,100.0,0.6},    // M249
    {1800.0,480.0,900.0,600.0,0.3},    // M3
    {350.0,250.0,300.0,100.0,0.6},    // M4A1
    {250.0,200.0,250.0,90.0,0.7},    // TMP
    {400.0,400.0,400.0,200.0,0.5},    // G3SG1
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // ---
    {350.0,250.0,350.0,100.0,0.6},    // DEAGLE
    {350.0,250.0,300.0,100.0,0.6},    // SG552
    {350.0,250.0,200.0,100.0,0.6},    // AK47
    {-1.0,-1.0,-1.0,-1.0,-1.0},    // [KNIFE]
    {250.0,200.0,250.0,90.0,0.7}        // P90
}

enum _:TOTAL_FORWARDS
{
    FW_KNOCKBACK_PRE,
    FW_KNOCKBACK_POST,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

new Float:g_vecLastVelocity[33][3]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
    
    g_iForwards[FW_KNOCKBACK_PRE] = CreateMultiForward("z4e_fw_knockback_set_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT, FP_FLOAT, FP_FLOAT, FP_FLOAT, FP_FLOAT, FP_CELL)
    g_iForwards[FW_KNOCKBACK_POST] = CreateMultiForward("z4e_fw_knockback_set_post", ET_IGNORE, FP_CELL, FP_CELL, FP_FLOAT, FP_FLOAT, FP_FLOAT, FP_FLOAT, FP_FLOAT, FP_CELL)
}

public plugin_natives()
{
    register_native("z4e_knockback_set", "Native_SetKnockBack", 1)
}

public Native_SetKnockBack(id, iAttacker, Float:flGround, Float:flAir, Float:flFly, Float:flDuck, Float:flVelocityModifier, bitsType)
{
    return KnockBack_Set(id, iAttacker, flGround, flAir, flFly, flDuck, flVelocityModifier, bitsType)
}

public z4e_fw_api_bot_registerham(id)
{
    RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
    RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage_Post", 1)
}

public fw_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
    if(is_user_alive(iVictim))
        pev(iVictim, pev_velocity, g_vecLastVelocity[iVictim])
        
    return HAM_IGNORED
}

public fw_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
    if (iVictim == iAttacker || !is_user_connected(iAttacker))
        return;
    
    set_pev(iVictim, pev_velocity, g_vecLastVelocity[iVictim])
    
    if(is_user_alive(iVictim) && (bitsDamageType & DMG_BULLET) && z4e_team_get_user_zombie(iVictim))
    {
        new iWeapon = get_user_weapon(iAttacker)
        KnockBack_Set(iVictim, iAttacker, cfg_flWeaponKnockback[iWeapon][0], cfg_flWeaponKnockback[iWeapon][1], cfg_flWeaponKnockback[iWeapon][2], cfg_flWeaponKnockback[iWeapon][3], cfg_flWeaponKnockback[iWeapon][4], Z4E_KNOCKBACK_INSIDE)
    }
}

KnockBack_Set(id, iAttacker, Float:flGround = -1.0, Float:flAir = -1.0, Float:flFly = -1.0, Float:flDuck = -1.0, Float:flVelocityModifier = -1.0, bitsType)
{
    ExecuteForward(g_iForwards[FW_KNOCKBACK_PRE], g_iForwardResult, id, iAttacker, flGround, flAir, flFly, flDuck, flVelocityModifier, bitsType)
    if(!(bitsType & Z4E_KNOCKBACK_IGNORERETURN) && g_iForwardResult >= 1)
        return false
    new bitsGameStatus = z4e_gameplay_bits_get_status()
    if(!(bitsType & Z4E_KNOCKBACK_IGNORECHECK) && (!BitsGet(bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED) || BitsGet(bitsGameStatus, Z4E_GAMESTATUS_GAMEENDED) || !BitsGet(bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART)))
        return false
        
    static Float:flKnockBack
    if(pev(id, pev_flags) & FL_ONGROUND)
    {
        if(pev(id, pev_flags) & FL_DUCKING)
            flKnockBack = flDuck
        else
            flKnockBack = flGround
    }
    else
    {
        static Float:vecVelocity[3]
        pev(id, pev_velocity, vecVelocity)
        vecVelocity[2] = 0.0
        if(xs_vec_len(vecVelocity) > 140.0)
            flKnockBack = flFly
        else
            flKnockBack = flAir
    }
    flKnockBack /= 2.0
    if(z4e_team_get_user_zombie(id) && !(bitsType & Z4E_KNOCKBACK_IGNOREABILITY))
        flKnockBack *= 2.0
    if((bitsType & Z4E_KNOCKBACK_DRAWANIM))
        Set_PlayerAnim(id, "hammer_flinch");
        
    
    if(flKnockBack > 0.0)
    {
        static Float:vecOriginVictim[3]; pev(id, pev_origin, vecOriginVictim)
        static Float:vecOriginAttacker[3]; pev(iAttacker, pev_origin, vecOriginAttacker)
        static Float:vecVelocity[3]; pev(id, pev_velocity, vecVelocity)
        
        static Float:vecDelta[3]
        xs_vec_sub(vecOriginVictim, vecOriginAttacker, vecDelta)
        vecDelta[2] = 0.0 
        xs_vec_normalize(vecDelta, vecDelta)
        xs_vec_mul_scalar(vecDelta, flKnockBack, vecDelta)
        xs_vec_add(vecVelocity, vecDelta, vecVelocity)
        
        set_pev(id, pev_velocity, vecVelocity)
    }
    if(flVelocityModifier > 0.0)
        set_pdata_float(id, m_flVelocityModifier, flVelocityModifier, OFFSET_LINUX)
    
    ExecuteForward(g_iForwards[FW_KNOCKBACK_POST], g_iForwardResult, id, iAttacker, flGround, flAir, flFly, flDuck, flVelocityModifier, bitsType)
    return true
}

stock Set_PlayerAnim(id, const AnimName[])
{
    if(!is_user_alive(id))
        return false
    new AnimNum, Float:FrameRate, Float:GroundSpeed, bool:Loops
    if ((AnimNum=lookup_sequence(id,AnimName,FrameRate,Loops,GroundSpeed))==-1)
        return false

    set_pev(id, pev_sequence, AnimNum)
    set_pev(id, pev_frame, 0.0)
    set_pev(id, pev_framerate, 1.0)
    set_pev(id, pev_animtime, get_gametime())

    set_pdata_int(id, 40, Loops, 4)
    set_pdata_int(id, 39, 0, 4)

    set_pdata_float(id, 36, FrameRate, 4)
    set_pdata_float(id, 37, GroundSpeed, 4)
    set_pdata_float(id, 38, get_gametime(), 4)

    set_pdata_int(id, 73, 28, 5)
    set_pdata_int(id, 74, 28, 5)
    set_pdata_float(id, 220, get_gametime(), 5)
    return true
}