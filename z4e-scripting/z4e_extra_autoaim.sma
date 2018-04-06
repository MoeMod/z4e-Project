#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <orpheu>

#include <z4e_bits>
#include <z4e_zombie>
#include <z4e_team>
#include <z4e_extra>

#define PLUGIN "[Z4E] Extra: Autoaim"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// offset
#define PDATA_SAFE 2
#define OFFSET_LINUX_WEAPONS 4
#define OFFSET_LINUX 5
// CBasePlayerItem
stock m_pPlayer = 41 // CBasePlayer *
stock m_pNext = 42 // CBasePlayerItem *
stock m_iId = 43 // int

stock WEAPONS_CLASSNAME[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
            "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
            "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
            "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
            "weapon_ak47", "weapon_knife", "weapon_p90"
}

new const WEAPONS_CANAUTOAIM = (1<<CSW_P228)|(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_DEAGLE)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)


#define TASK_SKILLEND 12345

new g_iItemID
new g_bitsUsingSkill

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    OrpheuRegisterHook(OrpheuGetFunction("KickBack", "CBasePlayerWeapon"), "OnKickBack")
    for(new i;i<sizeof(WEAPONS_CLASSNAME);i++)
        if(WEAPONS_CLASSNAME[i][0])
            RegisterHam(Ham_Weapon_PrimaryAttack, WEAPONS_CLASSNAME[i], "HamF_Weapon_PrimaryAttack")
    
    g_iItemID = z4e_extra_item_register("辅助瞄准 (15s)", 300)
}

public z4e_fw_extra_select_pre(id, iItem)
{
    if(iItem != g_iItemID)
        return Z4E_EXTRA_IGNORED
    if(!is_user_alive(id) || z4e_team_get_user_zombie(id))
        return Z4E_EXTRA_FORBIDDEN
    if(BitsGet(g_bitsUsingSkill, id))
        return Z4E_EXTRA_FORBIDDEN
    return Z4E_EXTRA_IGNORED
}

public z4e_fw_extra_select_post(id, iItem)
{
    if(iItem != g_iItemID)
        return Z4E_EXTRA_IGNORED
        
    BitsSet(g_bitsUsingSkill, id)
    client_print(id, print_chat, "[Z4E] 技能激活：辅助瞄准")
    
    set_task(15.0, "Task_SkillEnd", TASK_SKILLEND+id)
    return Z4E_EXTRA_IGNORED
}

public Task_SkillEnd(taskid)
{
    new id = taskid - TASK_SKILLEND
    
    BitsUnSet(g_bitsUsingSkill, id)
    
    client_print(id, print_chat, "[Z4E] 技能结束：辅助瞄准")
}

public HamF_Weapon_PrimaryAttack(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsUsingSkill, id))
        return HAM_IGNORED
    new iCSW = get_pdata_int(this, m_iId, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(WEAPONS_CANAUTOAIM, iCSW))
        return HAM_IGNORED
        
    new Float:vecSrc[3], Float:vecEnd[3]
    new ptr = create_tr2()
    GetGunPosition(id, vecSrc)
    
    static Float:vecForward[3]
    global_get(glb_v_forward, vecForward)
    xs_vec_mul_scalar(vecForward, 2048.0, vecForward)
    xs_vec_add(vecSrc, vecForward, vecEnd)

    engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, ptr)

    new pEntity
    pEntity = get_tr2(ptr, TR_pHit)
    
    if (!is_user_alive(pEntity))
    {
        engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, id, ptr)
        pEntity = get_tr2(ptr, TR_pHit)
        if (!is_user_alive(pEntity))
        {
            engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HUMAN, id, ptr)
            pEntity = get_tr2(ptr, TR_pHit)
            if (!is_user_alive(pEntity))
            {
                engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_LARGE, id, ptr)
                pEntity = get_tr2(ptr, TR_pHit)
            }
        }
    }
    
    if(is_user_alive(pEntity))
    {
        new Float:vecDelta[3]
        new Float:vecAngles[3]
        //pev(pEntity, pev_origin, vecEnd)
        //vecEnd[2] += 17.0
        engfunc(EngFunc_GetBonePosition, pEntity, 8, vecEnd, vecAngles)
        xs_vec_sub(vecEnd, vecSrc, vecDelta)
        vector_to_angle(vecDelta, vecDelta)
        vecDelta[0] *= -1.0
        set_pev(id, pev_angles, vecDelta)
        set_pev(id, pev_v_angle, vecDelta)
        set_pev(id, pev_fixangle, 1)
    }
    free_tr2(ptr)
    
    return HAM_IGNORED
}

stock GetGunPosition(id, Float:vecOut[3])
{
    new Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
    new Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
    xs_vec_add(vecOrigin, vecViewOfs, vecOut)
}

public OrpheuHookReturn:OnKickBack(this, Float:up_base, Float:lateral_base, Float:up_modifier, Float:lateral_modifier, Float:up_max, Float:lateral_max, direction_change)
{
    if(!pev_valid(this))
        return OrpheuIgnored
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsUsingSkill, id))
        return OrpheuIgnored
    return OrpheuSupercede
}
