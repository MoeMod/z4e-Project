#include <amxmodx>
#include <fakemeta>

// Thanks to ZP5.0
#define PLUGIN "[Z4E] Human Ammo"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// Weapon IDs for ammo types
new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
            CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 };

// From fakemeta_util.inc
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

/*  
new const OFFSET_BPAMMO_AMMOTYPE[] = { 0, OFFSET_AWM_AMMO, OFFSET_SCOUT_AMMO, OFFSET_PARA_AMMO, OFFSET_FAMAS_AMMO, OFFSET_M3_AMMO, OFFSET_USP_AMMO, OFFSET_FIVESEVEN_AMMO, OFFSET_DEAGLE_AMMO,
            OFFSET_P228_AMMO, OFFSET_GLOCK_AMMO, OFFSET_FLASH_AMMO, OFFSET_HE_AMMO, OFFSET_SMOKE_AMMO, OFFSET_C4_AMMO };
            
// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20,
            10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50 };
*/

// Max BP ammo for weapons
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
            30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 };
            
new const OFFSET_BPAMMO_WEAPON[] = { 0, OFFSET_P228_AMMO, 0, OFFSET_SCOUT_AMMO, OFFSET_HE_AMMO, OFFSET_M3_AMMO, OFFSET_C4_AMMO, OFFSET_USP_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SMOKE_AMMO, OFFSET_GLOCK_AMMO, OFFSET_FIVESEVEN_AMMO, OFFSET_USP_AMMO,
            OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO, OFFSET_USP_AMMO, OFFSET_GLOCK_AMMO, OFFSET_AWM_AMMO, OFFSET_GLOCK_AMMO, OFFSET_PARA_AMMO, OFFSET_M3_AMMO,
            OFFSET_FAMAS_AMMO, OFFSET_GLOCK_AMMO, OFFSET_SCOUT_AMMO, OFFSET_FLASH_AMMO, OFFSET_DEAGLE_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SCOUT_AMMO, 0, OFFSET_FIVESEVEN_AMMO };
new const WEAPON_AMMOID[] = { 0, 9, 0, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6,
            4, 4, 4, 6, 10, 1, 10, 3, 5,
            4, 10, 2, 11, 8, 4, 2, 0, 7 };

new gmsgAmmoX;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    gmsgAmmoX = get_user_msgid("AmmoX");
    register_message(gmsgAmmoX, "Message_AmmoX");
    register_message(get_user_msgid("CurWeapon"), "Message_CurWeapon");
}

// BP Ammo update
public Message_AmmoX(msg_id, msg_dest, id)
{
    
    // Not alive
    if (!is_user_alive(id))
        return PLUGIN_CONTINUE;
    
    // Get ammo type
    new iAmmoType = get_msg_arg_int(1);
    
    // Unknown ammo type
    if (iAmmoType >= sizeof AMMOWEAPON)
        return PLUGIN_CONTINUE;
    
    // Get weapon's id
    new iWeapon = AMMOWEAPON[iAmmoType];
    
    // Primary and secondary only
    if (MAXBPAMMO[iWeapon] <= 2)
        return PLUGIN_CONTINUE;

    return PLUGIN_HANDLED;
}

// Current Weapon info
public Message_CurWeapon(msg_id, msg_dest, id)
{
    // Not alive or not human
    if (!is_user_alive(id))
        return;
    
    // Not an active weapon
    if (get_msg_arg_int(1) != 1)
        return;
    
    // Get weapon's id
    new iWeapon = get_msg_arg_int(2)
    
    // Primary and secondary only
    if (MAXBPAMMO[iWeapon] <= 2)
        return;

    new iClip = get_msg_arg_int(3)
    
	// NOT emessage here so that it won't trigger Message_AmmoX hook
    message_begin(MSG_ONE, gmsgAmmoX, _, id);
    write_byte(WEAPON_AMMOID[iWeapon]);
    write_byte(iClip);
    message_end();
    
	// Remove clip ammo hud
    set_msg_arg_int(3, get_msg_argtype(3), -1);
	
	// Unlimited bpammo
    set_pdata_int(id, OFFSET_BPAMMO_WEAPON[iWeapon], MAXBPAMMO[iWeapon]);
}
