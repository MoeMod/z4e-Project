#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include <z4e_bits>
#include <z4e_team>
#include <z4e_api>

#define PLUGIN "[Z4E] Human"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// OffSet
#define PDATA_SAFE 2
stock m_iKevlar = 112

new const HUMAN_MODEL[][] = { "arctic", "gign", "gsg9", "guerilla", "leet", "sas", "terror", "urban", "vip" }

// Human & Morale
#define HUMAN_HEALTH 100.0
#define HUMAN_ARMOR 100.0
#define HUMAN_GRAVITY 1.0

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    OrpheuRegisterHook(OrpheuGetFunction("GiveDefaultItems", "CBasePlayer"), "OnGiveDefaultItems")
}

public plugin_precache()
{
    new i, szBuffer[64]
    
    for(i = 0; i < sizeof(HUMAN_MODEL); i++) 
    {
        format(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", HUMAN_MODEL[i], HUMAN_MODEL[i])
        engfunc(EngFunc_PrecacheModel, szBuffer); 
    }
}

public OrpheuHookReturn:OnGiveDefaultItems(id)
{
    return OrpheuSupercede
}

public z4e_fw_team_set_post(id, iTeam)
{
    if(iTeam != Z4E_TEAM_HUMAN || !is_user_alive(id))
        return;
    
    HumanME(id)
}

public z4e_fw_team_spawn_post(id)
{
    if(z4e_team_get(id) == Z4E_TEAM_HUMAN)
    {
        HumanME(id)
    }
    return PLUGIN_CONTINUE
}

HumanME(id)
{
    set_pev(id, pev_max_health, HUMAN_HEALTH)
    set_pev(id, pev_health, HUMAN_HEALTH)
    set_pev(id, pev_gravity, HUMAN_GRAVITY)
        
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, m_iKevlar, 1);
        
    z4e_api_set_player_model(id, HUMAN_MODEL[random_num(0, sizeof(HUMAN_MODEL) - 1)])
    fm_set_user_armor(id, floatround(HUMAN_ARMOR))
    
    z4e_api_reset_player_maxspeed(id)
    
    // Start Weapon
    fm_strip_user_weapons(id)
    fm_give_item(id, "weapon_knife")
    fm_give_item(id, "weapon_usp")
    ExecuteHamB(Ham_GiveAmmo, id, 12, "45acp", 254)
    ExecuteHamB(Ham_GiveAmmo, id, 12, "45acp", 254)
    
    // Turn Off the FlashLight
    if (pev(id, pev_effects) & EF_DIMLIGHT) set_pev(id, pev_impulse, 100)
    else set_pev(id, pev_impulse, 0)
    
    // Bug Fix
    fm_set_user_rendering(id)
    client_cmd(id, "-duck")
}