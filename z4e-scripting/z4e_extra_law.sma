#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include <z4e_bits>
#include <z4e_team>
#include <z4e_gameplay>
#include <z4e_extra>
#include <z4e_knockback>

#define PLUGIN "[Z4E] Extra: C4"
#define VERSION "2.0"
#define AUTHOR "Xiaobaibai"

#define CSW_WEAPON CSW_C4
#define weapon_classname "weapon_c4"
#define OLD_W_MODEL "models/w_backpack.mdl"
#define WEAPON_SECRETCODE 2524423

#define WEAPON_ANIMEXT "knife"
#define WEAPON_HUD "weapon_c4"

#define C4_CLASSNAME "z4e_lawrocket"
#define C4_DAMAGE 2000.0
#define C4_DAMAGE2 2000.0
#define C4_RADIUS 285.0

new const WEAPON_MODELS[][] = 
{
    "models/z4e/v_law.mdl",
    "models/z4e/p_law.mdl",
    "models/z4e/w_law.mdl",
    "models/z4e/lawrocket.mdl",
    "sprites/fexplo.spr",
    "sprites/eexplo.spr"
}
new const WEAPON_SOUND[][] = 
{
    "weapons/law_fire.wav",
    "weapons/law_explode.wav"
}

new const WEAPON_SPRITES[][] =
{
    "sound/weapons/law_bounce.wav",
    "sound/weapons/law_discard.wav",
    "sound/weapons/law_draw.wav",
    "sound/weapons/law_travel.wav"
    
}

enum
{
    ANIM_IDLE = 0,
    ANIM_DRAW,
    ANIM_SHOOT,
    ANIM_DISCARD,
    
}


// 来自 player.h
enum
{
    PLAYER_IDLE,
    PLAYER_WALK,
    PLAYER_JUMP,
    PLAYER_SUPERJUMP,
    PLAYER_DIE,
    PLAYER_ATTACK1,
    PLAYER_ATTACK2,
    PLAYER_FLINCH,
    PLAYER_LARGE_FLINCH,
    PLAYER_RELOAD,
    PLAYER_HOLDBOMB
}

enum
{
    BULLET_NONE = 0,
    BULLET_PLAYER_9MM,
    BULLET_PLAYER_MP5,
    BULLET_PLAYER_357,
    BULLET_PLAYER_BUCKSHOT,
    BULLET_PLAYER_CROWBAR,

    BULLET_MONSTER_9MM,
    BULLET_MONSTER_MP5,
    BULLET_MONSTER_12MM,

    BULLET_PLAYER_45ACP,
    BULLET_PLAYER_338MAG,
    BULLET_PLAYER_762MM,
    BULLET_PLAYER_556MM,
    BULLET_PLAYER_50AE,
    BULLET_PLAYER_57MM,
    BULLET_PLAYER_357SIG
}

// 来自 weapons.h
#define WPNSTATE_USP_SILENCED (1<<0)
#define WPNSTATE_GLOCK18_BURST_MODE (1<<1)
#define WPNSTATE_M4A1_SILENCED (1<<2)
#define WPNSTATE_ELITE_LEFT (1<<3)
#define WPNSTATE_FAMAS_BURST_MODE (1<<4)
#define WPNSTATE_SHIELD_DRAWN (1<<5)

#define LOUD_GUN_VOLUME 1000
#define NORMAL_GUN_VOLUME 600
#define QUIET_GUN_VOLUME 200

#define BRIGHT_GUN_FLASH 512
#define NORMAL_GUN_FLASH 256
#define DIM_GUN_FLASH 128

#define BIG_EXPLOSION_VOLUME 2048
#define NORMAL_EXPLOSION_VOLUME 1024
#define SMALL_EXPLOSION_VOLUME 512

#define WEAPON_ACTIVITY_VOLUME 64

// FROM cdll_dll.h
#define MAX_WEAPONS 32
#define MAX_WEAPON_SLOTS 5
#define MAX_ITEM_TYPES 6
#define MAX_ITEMS 4


stock WEAPONS_CLASSNAME[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
            "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
            "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
            "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
            "weapon_ak47", "weapon_knife", "weapon_p90"
}
stock WEAPONS_SLOT[] = { -1, 1, -1, 0, 3, 0, 4, 0, 0, 3, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0, 2, 0 }
stock WEAPONS_AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
            1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7
}
stock WEAPONS_NUMBERINSLOT[] = { -1, 3, -1, 9, 1, 12, 3, 13,
            14, 3, 5, 6, 15, 16,
            17, 18, 4, 2, 2, 7, 4,
            5, 6, 11, 3, 2, 1, 10,
            1, 1, 8
}
#define WEAPONS_FLAGS_GRENADE 24
#define WEAPONS_FLAGS_GENERIC 0
stock WEAPONS_ANIMEXT[][] = { "", "onehanded", "", "rifle", "grenade", "dualpistols", "c4", "onehanded", "carbine", "grenade", "dualpistols", "onehanded", "carbine",
            "rifle", "ak47", "carbine", "onehanded", "onehanded", "rifle", "mp5", "m249", "shotgun",
            "rifle", "onehanded", "mp5", "grenade", "onehanded", "mp5", "ak47", "knife", "carbine" 
}
stock WEAPONS_WMODEL[][] = { "", "models/w_p228.mdl", "", "models/w_scout.mdl", "models/w_hegrenade.mdl", "models/w_xm1014.mdl", "models/w_c4.mdl", "models/w_mac10.mdl", "models/w_aug.mdl", "models/w_smokegrenade.mdl", "models/w_elite.mdl", "models/w_fiveseven.mdl", "models/w_ump45.mdl",
            "models/w_sg550.mdl", "models/w_galil.mdl", "models/w_famas.mdl", "models/w_usp.mdl", "models/w_glock18.mdl", "models/w_awp.mdl", "models/w_mp5.mdl", "models/w_m249.mdl", "models/w_m3.mdl",
            "models/w_m4a1.mdl", "models/w_tmp.mdl", "models/w_g3sg1.mdl", "models/w_flashbang.mdl", "models/w_m3.mdl", "models/w_deagle.mdl", "models/w_ak47.mdl", "models/w_knife.mdl", "models/w_p90.mdl" 
}
stock WEAPONS_MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
            30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 
}

// offset
#define PDATA_SAFE 2
#define OFFSET_LINUX_WEAPONS 4
#define OFFSET_LINUX 5

#define OFFSET_AWM_AMMO 377 
#define OFFSET_SCOUT_AMMO 378
#define OFFSET_PARA_AMMO 379
#define OFFSET_FAMAS_AMMO 380
#define OFFSET_M3_AMMO 381
#define OFFSET_USP_AMMO 382
#define OFFSET_FIVESEVEN_AMMO 383
#define OFFSET_DEAGLE_AMMO 384
#define OFFSET_P228_AMMO 385
#define OFFSET_GLOCK_AMMO 386
#define OFFSET_FLASH_AMMO 387
#define OFFSET_HE_AMMO 388
#define OFFSET_SMOKE_AMMO 389
#define OFFSET_C4_AMMO 390
stock OFFSET_BPAMMO_WEAPON[] = { -1, OFFSET_P228_AMMO, -1, OFFSET_SCOUT_AMMO, OFFSET_HE_AMMO, OFFSET_M3_AMMO, OFFSET_C4_AMMO, OFFSET_USP_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SMOKE_AMMO, OFFSET_GLOCK_AMMO, OFFSET_FIVESEVEN_AMMO, OFFSET_USP_AMMO,
            OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO, OFFSET_USP_AMMO, OFFSET_GLOCK_AMMO, OFFSET_AWM_AMMO, OFFSET_GLOCK_AMMO, OFFSET_PARA_AMMO, OFFSET_M3_AMMO,
            OFFSET_FAMAS_AMMO, OFFSET_GLOCK_AMMO, OFFSET_SCOUT_AMMO, OFFSET_FLASH_AMMO, OFFSET_DEAGLE_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SCOUT_AMMO, -1, OFFSET_FIVESEVEN_AMMO }

// CBaseMonster
stock m_flNextAttack = 83 // float
stock m_iHideHUD = 361 // int
// CBasePlayer
stock m_iLastZoom = 109 // int
stock m_bResumeZoom = 440 // bool
stock m_iWeaponVolume = 239 // int
stock m_iWeaponFlash = 241 // int
stock m_iFOV = 363 // int
stock m_szAnimExtention = 492 // char [32]
stock m_bShieldDrawn = 2002 // bool
// CBasePlayerItem
stock m_pPlayer = 41 // CBasePlayer *
stock m_pNext = 42 // CBasePlayerItem *
stock m_iId = 43 // int
// CBasePlayerWeapon
stock m_flNextPrimaryAttack = 46 // float
stock m_flNextSecondaryAttack = 47 // float
stock m_flTimeWeaponIdle = 48 // float
stock m_iClip = 51 // int
stock m_fInReload = 54 // int
stock m_fMaxSpeed = 58 // float
stock m_bDelayFire = 236 // bool
stock m_flAccuracy = 62 // float
stock m_iShotsFired = 64 // int
stock m_iWeaponState = 74 // int
stock m_flDecreaseShotsFired = 76 // float
// CWeaponBox
stock m_rgpPlayerItems2[] = { 34, 35, 36, 37, 38, 39 } // CBasePlayerItem *

new g_iItemID
new g_bitsHasWeapon, g_bitsCanShoot
new g_iSprSmoke, g_iSprTrail, g_iSprExplo, g_iSprExplo2

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)    
    register_forward(FM_SetModel, "fw_SetModel")
    //register_forward(FM_ClientCommand, "fw_ClientCommand")
    
    RegisterHam(Ham_Touch, "info_target", "HamF_C4_Touch")
    RegisterHam(Ham_Think, "info_target", "HamF_C4_Think")
    RegisterHam(Ham_Touch, "weaponbox", "HamF_WeaponBox_Touch")
    
    RegisterHam(Ham_Item_AddToPlayer, weapon_classname, "HamF_Item_AddToPlayer_Post", 1)
    RegisterHam(Ham_Item_PostFrame, weapon_classname, "HamF_Item_PostFrame")
    RegisterHam(Ham_Weapon_Reload, weapon_classname, "HamF_Weapon_Reload")
    RegisterHam(Ham_Item_Deploy, weapon_classname, "HamF_Item_Deploy")
    RegisterHam(Ham_Weapon_PrimaryAttack, weapon_classname, "HamF_Weapon_PrimaryAttack")
    RegisterHam(Ham_Weapon_WeaponIdle, weapon_classname, "HamF_Weapon_WeaponIdle")
    RegisterHam(Ham_Item_Holster, weapon_classname, "HamF_Item_Holster")
    RegisterHam(Ham_CS_Item_GetMaxSpeed, weapon_classname, "HamF_CS_Item_GetMaxSpeed")
    
    // HUD的txt名设定一号
    //register_clcmd(WEAPON_HUD, "Hook_Weapon")
    g_iItemID = z4e_extra_item_register("LAW反坦克火箭炮", 1500)
}

public plugin_precache()
{
    
    new i 
    for(i = 0; i < sizeof(WEAPON_MODELS); i++)
        engfunc(EngFunc_PrecacheModel, WEAPON_MODELS[i])
    for(i = 0; i < sizeof(WEAPON_SOUND); i++)
        engfunc(EngFunc_PrecacheSound, WEAPON_SOUND[i])
    for(i = 0; i < sizeof(WEAPON_SPRITES); i++)
    {
        engfunc(EngFunc_PrecacheGeneric, WEAPON_SPRITES[i])
    }
    g_iSprSmoke = engfunc(EngFunc_PrecacheModel, "sprites/black_smoke3.spr")
    g_iSprTrail = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
    g_iSprExplo = engfunc(EngFunc_PrecacheModel, WEAPON_MODELS[4])
    g_iSprExplo2 = engfunc(EngFunc_PrecacheModel, WEAPON_MODELS[5])
    
}

public z4e_fw_extra_select_pre(id, iItem)
{
    if(iItem != g_iItemID)
        return Z4E_EXTRA_IGNORED
    if(!is_user_alive(id) || z4e_team_get_user_zombie(id))
        return Z4E_EXTRA_FORBIDDEN
    return Z4E_EXTRA_IGNORED
}

public z4e_fw_extra_select_post(id, iItem)
{
    if(iItem != g_iItemID)
        return Z4E_EXTRA_IGNORED
        
    drop_weapons(id, 5)
            
    BitsSet(g_bitsHasWeapon, id)
    fm_give_item(id, weapon_classname)
    BitsSet(g_bitsCanShoot, id)

    UpdateAmmo(id)
    return Z4E_EXTRA_IGNORED
}

public z4e_fw_team_set_act(id, iTeam)
{
    if(BitsGet(g_bitsHasWeapon, id))
    {
        BitsUnSet(g_bitsHasWeapon, id)
        UpdateWeaponList(id)
        
        BitsUnSet(g_bitsCanShoot, id)
        
        new pEntity
        while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", C4_CLASSNAME))))
        {
            if(pev(pEntity, pev_owner) != id)
                continue;
            fm_remove_entity(pEntity)
        }
    }
}

public Hook_Weapon(id)
{
    client_cmd(id, weapon_classname)
    return PLUGIN_HANDLED
}

public z4e_fw_gameplay_round_new()
{
    fm_remove_entity_name(C4_CLASSNAME)
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
    if(!is_user_alive(id) || !is_user_connected(id))
        return FMRES_IGNORED    
    if(get_user_weapon(id) == CSW_WEAPON && BitsGet(g_bitsHasWeapon, id))
        set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
    
    return FMRES_HANDLED
}

public fw_SetModel(iEntity, szModel[])
{
    if(!pev_valid(iEntity))
        return FMRES_IGNORED
    
    static szClassname[32]
    pev(iEntity, pev_classname, szClassname, sizeof(szClassname))
    
    if(!equal(szClassname, "weaponbox"))
        return FMRES_IGNORED
    
    new id = pev(iEntity, pev_owner)
    
    if(equal(szModel, OLD_W_MODEL))
    {
        new pItem = fm_find_ent_by_owner(-1, weapon_classname, iEntity)
        
        if(!pev_valid(pItem))
            return FMRES_IGNORED;
        
        if(BitsGet(g_bitsHasWeapon, id))
        {
            // W模型
            set_pev(pItem, pev_iuser1, !!BitsGet(g_bitsCanShoot, id))
            BitsUnSet(g_bitsCanShoot, id)
            set_pev(pItem, pev_impulse, WEAPON_SECRETCODE)
            engfunc(EngFunc_SetModel, iEntity, WEAPON_MODELS[2])
            BitsUnSet(g_bitsHasWeapon, id)
            UpdateWeaponList(id)
            return FMRES_SUPERCEDE
        }
    }

    return FMRES_IGNORED;
}

public HamF_WeaponBox_Touch(iEntity, pHit)
{
    if(!pev_valid(iEntity))
        return HAM_IGNORED;
    if(!(pev(iEntity, pev_flags) & FL_ONGROUND))
        return HAM_IGNORED;
    if(!is_user_alive(pHit))
        return HAM_IGNORED;
    for (new i = 0; i < MAX_ITEM_TYPES; i++)
    {
        new pItem = get_pdata_cbase(iEntity, m_rgpPlayerItems2[i])
        if (pev_valid(pItem))
        {
            while (pev_valid(pItem))
            {
                new szClassname[32]
                pev(pItem, pev_classname, szClassname, 31)
                if (equal(szClassname, "weapon_c4"))
                {
                    if(pev(pItem, pev_impulse) == WEAPON_SECRETCODE)
                    {
                        if(pev(pHit, pev_weapons) & (1<<CSW_C4))
                        {
                            return HAM_IGNORED;
                        }
                        else
                        {
                            if(ExecuteHamB(Ham_AddPlayerItem, pHit, pItem))
                            {
                                ExecuteHamB(Ham_Item_AttachToPlayer, pItem, pHit)
                            }
                        }
                        emit_sound(pHit, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
                        set_pdata_cbase(iEntity, m_rgpPlayerItems2[i], get_pdata_cbase(pItem, m_pNext))
                        return HAM_SUPERCEDE;
                    }
                }
                pItem = get_pdata_cbase(pItem, m_pNext)
            }
        }
    }
    return HAM_IGNORED;
}

public fw_ClientCommand(id)
{
    if(!is_user_alive(id))
        return FMRES_IGNORED    
    if(get_user_weapon(id) != CSW_WEAPON || !BitsGet(g_bitsHasWeapon, id))    
        return FMRES_IGNORED
    
    static szCommand[24]
    read_argv(0, szCommand, charsmax(szCommand))
    
    if(equal(szCommand, "drop"))
    {
        client_print(id, print_center, "无法丢弃该武器。")
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}

public HamF_Item_AddToPlayer_Post(this, id)
{
    if(!pev_valid(this))
        return HAM_IGNORED
        
    if(pev(this, pev_impulse) == WEAPON_SECRETCODE)
    {
        BitsSet(g_bitsHasWeapon, id)
        if(pev(this, pev_iuser1))
            BitsSet(g_bitsCanShoot, id)
        set_pev(this, pev_iuser1, 0)
        set_pev(this, pev_impulse, 0)
        UpdateWeaponList(id)
        UpdateAmmo(id)
    }        
    
    return HAM_HANDLED    
}

public HamF_Item_Deploy(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED;
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
    
    // 命中初始值
    set_pdata_float(this, m_flAccuracy, 0.2, OFFSET_LINUX_WEAPONS)
    set_pdata_bool(id, m_bShieldDrawn, false)
    set_pdata_float(this, m_fMaxSpeed, 250.0, OFFSET_LINUX_WEAPONS)
    // VP模型 掏出时间（0.75） 掏出动作 第三人称动作
    OrpheuCall(OrpheuGetFunction("DefaultDeploy", "CBasePlayerWeapon"), this, WEAPON_MODELS[0], WEAPON_MODELS[1], ANIM_DRAW, WEAPON_ANIMEXT, 0)
    
    set_pdata_float(this, m_flNextPrimaryAttack, 1.5)
    set_pdata_float(this, m_flTimeWeaponIdle, 3.0)
    set_pdata_int(this, m_iShotsFired, 1, OFFSET_LINUX_WEAPONS)
    
    UpdateAmmo(id)
    return HAM_SUPERCEDE;
}

public HamF_Item_PostFrame(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
        
    if(!BitsGet(g_bitsCanShoot, id))
    {
        if(get_pdata_int(this, m_iShotsFired, OFFSET_LINUX_WEAPONS))
        {
            UTIL_SendWeaponAnim(id, ANIM_DISCARD)
            set_pdata_int(this, m_iShotsFired, 0, OFFSET_LINUX_WEAPONS)
            set_pdata_float(this, m_flNextPrimaryAttack, 1.0, OFFSET_LINUX_WEAPONS)
            set_pdata_float(this, m_flTimeWeaponIdle, 1.7, OFFSET_LINUX_WEAPONS)
            return HAM_SUPERCEDE
        }
    }
    
    return HAM_IGNORED
}

public HamF_Weapon_Reload(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED;
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
        
    return HAM_SUPERCEDE;
}

public HamF_Weapon_PrimaryAttack(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
        
    Create_Grenade(this)
    
    return HAM_SUPERCEDE
}

public HamF_Weapon_WeaponIdle(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
    
    if(get_pdata_float(this, m_flTimeWeaponIdle, OFFSET_LINUX_WEAPONS) > 0.1) 
        return HAM_SUPERCEDE
        
    ExecuteHamB(Ham_Weapon_ResetEmptySound, this);
    //OrpheuCall(OrpheuGetFunctionFromEntity(id, "GetAutoaimVector", "CBasePlayer"), id, AUTOAIM_10DEGREES)
    
    UTIL_SendWeaponAnim(id, ANIM_IDLE)
    set_pdata_float(this, m_flTimeWeaponIdle, 20.0, OFFSET_LINUX_WEAPONS)
    
    if(!BitsGet(g_bitsCanShoot, id))
    {
        BitsUnSet(g_bitsHasWeapon, id)
        UpdateWeaponList(id)
        set_pdata_int(id, OFFSET_C4_AMMO, 0)
        ExecuteHamB(Ham_Item_Holster, this, 0)
        client_cmd(id, "lastinv")
    }
    return HAM_IGNORED
}

public HamF_Item_Holster(this, skiplocal)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
    return HAM_SUPERCEDE
}

stock GetGunPosition(id, Float:vecOut[3])
{
    new Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
    new Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
    xs_vec_add(vecOrigin, vecViewOfs, vecOut)
}

public Create_Grenade(this)
{
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    
    if (!BitsGet(g_bitsCanShoot, id))
    {
        //ExecuteHam(Ham_Weapon_PlayEmptySound, this);
        set_pdata_float(this, m_flNextPrimaryAttack, 0.2)
        return;
    }
    BitsUnSet(g_bitsCanShoot, id);
    UpdateAmmo(id)
    
    set_pdata_int(this, m_iShotsFired, 1, OFFSET_LINUX_WEAPONS)
    
    set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH));
    OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
    
    UTIL_SendWeaponAnim(id, ANIM_SHOOT)
    
    new iEntity; iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
    if(!pev_valid(iEntity)) return
    
    new Float:vecPunchangle[3]
    pev(id, pev_punchangle, vecPunchangle)
    vecPunchangle[0] -= random_float(0.55, 1.0)
    vecPunchangle[1] -= random_float(-0.65, 0.95)
    set_pev(id, pev_punchangle, vecPunchangle)
    
    new Float:vecOrigin[3], Float:vecVelocity[3], Float:vecTargetOrigin[3]
    GetGunPosition(id, vecOrigin)
    
    new Float:vecAngles[3]; pev(id, pev_v_angle, vecAngles)
    vecAngles[0] = 360.0 - vecAngles[0]
    
    fm_get_aim_origin(id, vecTargetOrigin)
    xs_vec_sub(vecTargetOrigin, vecOrigin, vecVelocity)
    xs_vec_normalize(vecVelocity, vecVelocity)
    xs_vec_mul_scalar(vecVelocity, 1000.0, vecVelocity)
    //vecVelocity[2] += 135.0
    
    set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
    set_pev(iEntity, pev_solid, SOLID_BBOX)
    set_pev(iEntity, pev_classname, C4_CLASSNAME)
    set_pev(iEntity, pev_owner, id)
    set_pev(iEntity, pev_gravity, 0.001)
    
    engfunc(EngFunc_SetModel, iEntity, WEAPON_MODELS[3])
    
    set_pev(iEntity, pev_sequence, 0)
    set_pev(iEntity, pev_framerate, 10)
    
    engfunc(EngFunc_SetSize, iEntity, {-1.0, -1.0, -1.0}, {1.0, 1.0, 1.0})
    engfunc(EngFunc_SetOrigin, iEntity, vecOrigin)
    set_pev(iEntity, pev_velocity, vecVelocity)
    set_pev(iEntity, pev_angles, vecAngles)
    
    set_pdata_int(id, m_iWeaponVolume, NORMAL_GUN_VOLUME);
    set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH);
    
    set_pdata_float(this, m_flNextPrimaryAttack, 1.0)
    set_pdata_float(this, m_flTimeWeaponIdle, 2.0)
    set_pdata_float(id, m_flNextAttack, 1.0)
    
    set_pev(iEntity, pev_nextthink, get_gametime() + random_float(0.2,0.3))
    
    engfunc(EngFunc_EmitSound, iEntity, CHAN_WEAPON, WEAPON_SOUND[0], 0.8, ATTN_NORM, 0, PITCH_NORM)
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_BEAMFOLLOW)
    write_short(iEntity) // entity
    write_short(g_iSprTrail) // sprite
    write_byte(15)  // life
    write_byte(4)  // width
    write_byte(200) // r
    write_byte(200);  // g
    write_byte(200);  // b
    write_byte(200); // brightness
    message_end();
    
    message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, id)
    write_short((1<<12) * 5) // amplitude
    write_short((1<<12) * 2) // duration
    write_short((1<<12) * 5) // frequency
    message_end()
    
    vecPunchangle[0] -= random_float(12.0, 20.0) * 0.75
    vecPunchangle[1] -= random_float(-5.3, 5.3)
    set_pev(id, pev_punchangle, vecPunchangle)
}

public HamF_C4_Touch(iEntity, pHit)
{
    if(!pev_valid(iEntity))
        return HAM_IGNORED;
        
    static szClassname[32]
    pev(iEntity, pev_classname, szClassname, sizeof(szClassname))
    
    if(!equal(szClassname, C4_CLASSNAME))
        return HAM_IGNORED;
        
    if(pev_valid(pev(iEntity, pev_iuser4)))
        return HAM_SUPERCEDE;
        
    set_pev(iEntity, pev_iuser4, pHit)
        
    Make_Explosion(iEntity)
    
    return HAM_SUPERCEDE;
}

public HamF_C4_Think(iEntity)
{
    if(!pev_valid(iEntity))
        return HAM_IGNORED;
        
    static szClassname[32]
    pev(iEntity, pev_classname, szClassname, sizeof(szClassname))
    
    if(!equal(szClassname, C4_CLASSNAME))
        return HAM_IGNORED;
        
    new Float:vecOrigin[3]
    pev(iEntity, pev_origin, vecOrigin)
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
    write_byte(TE_SMOKE) // TE id
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2] - 20.0)
    write_short(g_iSprSmoke) // sprite
    write_byte(random_num(15, 20)) // scale
    write_byte(random_num(10, 20)) // framerate
    message_end()
    
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
    write_byte(TE_DLIGHT) // TE id
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2])
    write_byte(15) // radius
    write_byte(255) // red
    write_byte(255) // green
    write_byte(100) // blue
    write_byte(6) // life
    write_byte(10) // decay rate
    message_end()
        
    set_pev(iEntity, pev_nextthink, get_gametime() + random_float(0.2,0.3))
    return HAM_SUPERCEDE;
}

public Make_Explosion(iEnt)
{
    static id; id = pev(iEnt, pev_owner)
    static Float:vecOrigin[3]; pev(iEnt, pev_origin, vecOrigin)
    static Float:vecVelocity[3]; pev(iEnt, pev_velocity, vecVelocity)
    
    message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
    write_byte(TE_EXPLOSION)
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2] + 20.0)
    write_short(g_iSprExplo)    // sprite index
    write_byte(35)    // scale in 0.1's
    write_byte(30)    // framerate
    write_byte(0)    // flags
    message_end()
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_EXPLOSION)
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2] + 20.0)
    write_short(g_iSprExplo2)
    write_byte(50)
    write_byte(23)
    write_byte(0)
    message_end()
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_WORLDDECAL)
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2])
    write_byte(engfunc(EngFunc_DecalIndex, "{scorch1"))
    message_end()
    
    emit_sound(iEnt, CHAN_WEAPON, WEAPON_SOUND[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
    
    if(pev_valid(pev(iEnt, pev_iuser4)))
        ExecuteHamB(Ham_TakeDamage, pev(iEnt, pev_iuser4), iEnt, id, C4_DAMAGE, DMG_BULLET)
    
    if(!z4e_team_get_user_zombie(id))
    {
        new pEntity = -1, Float:flAdjustedDamage
        while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, C4_RADIUS)) && pev_valid(pEntity))
        {
            if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
                continue;
            static Float:vecOrigin2[3]; pev(pEntity, pev_origin, vecOrigin2)
            static Float:vecDelta[3]; xs_vec_sub(vecOrigin2, vecOrigin, vecDelta)
            flAdjustedDamage = C4_DAMAGE2
            flAdjustedDamage *= 1.0 - (vector_length(vecDelta) / C4_RADIUS);

            if (flAdjustedDamage < 0.0)
                flAdjustedDamage = 0.0
            if(is_user_alive(pEntity))
            {
				if(!z4e_team_get_user_zombie(pEntity))
					continue;
                set_pdata_int(pEntity, 75, HIT_CHEST);
            }
                
            ExecuteHamB(Ham_TakeDamage, pEntity, id, id, flAdjustedDamage, DMG_BULLET)
            if(is_user_alive(pEntity) && z4e_team_get_user_zombie(pEntity))
                z4e_knockback_set(pEntity, id, 3000.0, 1600.0, 1200.0, 800.0, 0.8, Z4E_KNOCKBACK_IGNORECHECK|Z4E_KNOCKBACK_IGNOREABILITY|Z4E_KNOCKBACK_DRAWANIM)
                
            message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, id)
            write_short((1<<12) * 10) // amplitude
            write_short((1<<12) * 6) // duration
            write_short((1<<12) * 10) // frequency
            message_end()
        }
    }
    if(pev_valid(iEnt))
        engfunc(EngFunc_RemoveEntity, iEnt)
}

public HamF_CS_Item_GetMaxSpeed(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!BitsGet(g_bitsHasWeapon, id))
        return HAM_IGNORED
    SetHamReturnFloat(180.0)
    return HAM_HANDLED
}

UpdateWeaponList(id)
{
    message_begin(MSG_ONE, get_user_msgid("WeaponList"), .player = id)
    write_string(BitsGet(g_bitsHasWeapon, id) ? WEAPON_HUD : WEAPONS_CLASSNAME[CSW_WEAPON])
    write_byte(WEAPONS_AMMOID[CSW_WEAPON]) // PrimaryAmmoID
    write_byte(WEAPONS_MAXBPAMMO[CSW_WEAPON]) // PrimaryAmmoMaxAmount
    write_byte(-1) // SecondaryAmmoID
    write_byte(-1) // SecondaryAmmoMaxAmount
    write_byte(WEAPONS_SLOT[CSW_WEAPON]) // SlotID (0...N)
    write_byte(WEAPONS_NUMBERINSLOT[CSW_WEAPON]) // NumberInSlot (1...N)
    write_byte(CSW_WEAPON) // WeaponID
    write_byte(BitsGet(g_bitsHasWeapon, id) ? WEAPONS_FLAGS_GENERIC:WEAPONS_FLAGS_GRENADE) // Flags
    message_end()
}

UpdateAmmo(id)
{
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
    write_byte(14)
    write_byte(!!BitsGet(g_bitsCanShoot, id))
    message_end()
}

stock UTIL_SendWeaponAnim(pPlayer, iAnim, iBody = -1)
{
    set_pev(pPlayer, pev_weaponanim, iAnim);
    if(iBody < 0)
        iBody = pev(pPlayer, pev_body)
    message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, pPlayer);
    write_byte(iAnim);
    write_byte(iBody);
    message_end();
}
/*
stock set_pdata_bool(ent, charbased_offset, bool:value, intbase_linuxdiff = 5) 
{ 
    set_pdata_char(ent, charbased_offset, _:value, intbase_linuxdiff) 
}

stock set_pdata_char(ent, charbased_offset, value, intbase_linuxdiff = 5) 
{ 
    value &= 0xFF 
    new int_offset_value = get_pdata_int(ent, charbased_offset >> 2, intbase_linuxdiff) 
    new bit_decal = (charbased_offset & 3) << 3
    int_offset_value &= ~(0xFF<<bit_decal) // clear byte 
    int_offset_value |= value<<bit_decal 
    set_pdata_int(ent, charbased_offset >> 2, int_offset_value, intbase_linuxdiff) 
    return 1 
}
*/
stock drop_weapons(iPlayer, Slot)
{
    new item = get_pdata_cbase(iPlayer, 367+Slot, 4)
    while(item > 0)
    {
        static classname[24]
        pev(item, pev_classname, classname, charsmax(classname))
        engclient_cmd(iPlayer, "drop", classname)
        item = get_pdata_cbase(item, 42, 5)
    }
    set_pdata_cbase(iPlayer, 367, -1, 4)
}