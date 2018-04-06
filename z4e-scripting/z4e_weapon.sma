#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>
#include <z4e_mainmenu>
#include <z4e_team>

#define PLUGIN "[Z4E] Weapon"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

enum _:MAX_WEAPON_SLOT
{
	WEAPON_SLOT_PRIMARY,
	WEAPON_SLOT_SECONDARY,
	WEAPON_SLOT_MELEE,
	WEAPON_SLOT_GRENADE,
}
enum _:MAX_WEAPON_TYPE
{
	WEAPON_TYPE_INSIDE,
	WEAPON_TYPE_UNLOCK,
	WEAPON_TYPE_EXTRA,
	WEAPON_TYPE_BONUS,
}
new const cfg_szTextBuyWeapon[] = "选择你的武器"
new const cfg_szSlotName[MAX_WEAPON_SLOT][] = { "主武器", "副武器", "近身武器", "投掷武器" }
new const cfg_szTypeName[MAX_WEAPON_TYPE][] = { "『普通』", "『高級』", "『特殊』", "『福利』" }
new const cfg_szTextBuyNow[] = "购买所选武器!"

new const cfg_bitsWeaponInside[MAX_WEAPON_SLOT] = { 
	(1<<CSW_AUG)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_MP5NAVY)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90), 
	(1<<CSW_P228)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_DEAGLE), 
	(1<<CSW_KNIFE),
	(1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE)
}

new const MAXBPAMMO[] = { -1, 104, -1, 180, 1, 64, 1, 200, 180, 1, 200, 200, 200, 180, 180, 180, 200, 200,
			60, 200, 200, 64, 180, 200, 180, 2, 70, 180, 180, -1, 200 }
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }
new const WEAPONNAMES[][] = { "[NULL]", "P228手枪", "[NULL]", "SCOUT鸟狙", "烈焰燃烧弹", "XM1014连发散弹枪", "[C4]", "MAC-10冲锋枪", "AUG步枪",
			"零度冰冻弹", "ELITE双持手枪", "57式手枪 ", "UMP45冲锋枪", "SG550連狙", "GALIL半自动步枪", "FAMAS步枪",
			"USP.45消音手枪", "GLIOCK18三连发手枪", "AWP麦格农狙击步枪", "MP5冲锋枪", "M249轻机枪",
			"M3单发散弹枪", "M4A1卡宾枪", "TMP冲锋枪", "G3SG1连狙", "疾风力场弹", "沙漠之鹰",
			"SG-552突击步枪", "AK-47步枪", "小刀", "P90 RUSH B冲锋枪" }
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

// Forwards
enum _:TOTAL_FORWARDS
{
	FW_WEAPON_GET_UNLOCK = 0,
	FW_WEAPON_REMOVE,
	FW_WEAPON_REFILL,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

// OffSet
#define PDATA_SAFE 2
#define OFFSET_LINUX_WEAPONS 4
#define OFFSET_LINUX 5
#define OFFSET_WEAPONTYPE 43
#define OFFSET_WEAPONOWNER 41
#define OFFSET_CSMENUCODE 205
#define OFFSET_HE_AMMO 388

// Tasks
#define TASK_BOT_BUY 2200

new g_iMenuWeaponType[33][MAX_WEAPON_SLOT], g_iMenuWeaponItem[33][MAX_WEAPON_SLOT]
new g_bitsWeaponUnlock[MAX_WEAPON_SLOT], g_bitsWeaponUnlockFree[MAX_WEAPON_SLOT], g_szWeaponUnlockName[MAX_WEAPON_SLOT][32][32], g_iWeaponUnlockCost[MAX_WEAPON_SLOT][32]
new g_bitsUsingCustomKnife, g_bitsUnlocked[33][MAX_WEAPON_SLOT]
new g_bitsCanBuyWeapon

// Safety Cache
new g_bitsConnected, g_bitsIsAlive, g_bHamBotRegister
#define IsConnected(%1) (BitsIsPlayer(%1) && BitsGet(g_bitsConnected, %1))
#define IsAlive(%1) (BitsIsPlayer(%1) && BitsGet(g_bitsIsAlive, %1))

new g_iMenuItem

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1)
	
	g_iForwards[FW_WEAPON_GET_UNLOCK] = CreateMultiForward("z4h_fw_weapon_get_unlock", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_iForwards[FW_WEAPON_REMOVE] = CreateMultiForward("z4h_fw_weapon_remove", ET_IGNORE, FP_CELL, FP_CELL)
	g_iForwards[FW_WEAPON_REFILL] = CreateMultiForward("z4h_fw_weapon_refill", ET_IGNORE, FP_CELL, FP_CELL)
	g_iMenuItem = z4e_mainmenu_item_register("武器购买菜单")
}

public client_putinserver(id)
{
	BitsSet(g_bitsConnected, id)
	BitsUnSet(g_bitsIsAlive, id)
	if(!g_bHamBotRegister && is_user_bot(id))
	{
		g_bHamBotRegister = 1
		set_task(0.1, "Do_Register_HamBot", id)
	}
}

public Do_Register_HamBot(id)
{
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
	RegisterHamFromEntity(Ham_Spawn, id, "fw_Spawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_Killed_Post", 1)
}

public client_connect(id)
{
	Weapon_Reset(id)
}

public client_disconnect(id)
{
	BitsUnSet(g_bitsConnected, id)
	BitsUnSet(g_bitsIsAlive, id)
}

public fw_Spawn_Post(id)
{
	if(!is_user_alive(id))
		return
		
	BitsSet(g_bitsIsAlive, id)
}

public fw_Killed_Post(id)
{
	BitsUnSet(g_bitsIsAlive, id)
}

public z4e_fw_mainmenu_select_post(id, iItem)
{
	if(iItem != g_iMenuItem)
		return Z4E_MAINMENU_IGNORED
	Show_BuyMenu(id)
	return Z4E_MAINMENU_IGNORED
}

public fw_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDirection[3], pTr, bitsDamageType)
{
	if(!is_user_connected(iAttacker))
		return HAM_IGNORED
	
	if(z4e_team_get(iAttacker) != Z4E_TEAM_HUMAN)
		return HAM_IGNORED
		
	if(!BitsGet(g_bitsUsingCustomKnife, iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE)
	{
		flDamage *= 5.0
	}

	SetHamParamFloat(3, flDamage)
	return HAM_IGNORED
}

public z4e_fw_team_set_post(id, iTeam)
{
	if(!is_user_alive(id))
		return;
	if(iTeam != Z4E_TEAM_HUMAN)
	{
		BitsUnSet(g_bitsCanBuyWeapon, id)
		return;
	}
	
	if(is_user_bot(id))
	{
		remove_task(id + TASK_BOT_BUY)
		set_task(random_float(0.5, 3.0), "Task_Bot_SelectRandom", id + TASK_BOT_BUY)
	}
	else
	{
		BitsSet(g_bitsCanBuyWeapon, id)
		Show_BuyMenu(id)
	}
}

public Show_BuyMenu(id)
{
	static szMenuName[32]
	formatex(szMenuName, sizeof(szMenuName), cfg_szTextBuyWeapon)
	new iMenu = menu_create(szMenuName, "Handle_BuyMenu")
	static szMenuItem[128], iData[2], szWeaponName[32]

	for(new iSlot = 0; iSlot < MAX_WEAPON_SLOT; iSlot++)
	{
		switch(g_iMenuWeaponType[id][iSlot])
		{
			case WEAPON_TYPE_INSIDE: copy(szWeaponName, 31, WEAPONNAMES[g_iMenuWeaponItem[id][iSlot]])
			case WEAPON_TYPE_UNLOCK: copy(szWeaponName, 31, g_szWeaponUnlockName[iSlot][g_iMenuWeaponItem[id][iSlot]])
		}
		
		if(iSlot == WEAPON_SLOT_GRENADE && get_user_flags(id) & ADMIN_LEVEL_C)
		{
			format(szMenuItem, sizeof(szMenuItem), "\y%s\w^t^t%s \r(x2)", cfg_szSlotName[iSlot], szWeaponName)
		}
		else
		{
			format(szMenuItem, sizeof(szMenuItem), "\y%s\w^t^t%s", cfg_szSlotName[iSlot], szWeaponName)
		}
		
		
		iData[0] = iSlot
		menu_additem(iMenu, szMenuItem, iData)
	}
	
	if(is_user_alive(id) && BitsGet(g_bitsCanBuyWeapon, id))
	{
		format(szMenuItem, sizeof(szMenuItem), "\w%s", cfg_szTextBuyNow)
		iData[0] = -2
		menu_additem(iMenu, szMenuItem, iData)
	}
	if(pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0)
	menu_display(id, iMenu)
}

public Handle_BuyMenu(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED;
	}
	
	new szName[64], iData[5], iItemAccess, iItemCallback
	menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
	new iSelected = iData[0]
	if(iSelected == -2 && IsAlive(id) && BitsGet(g_bitsCanBuyWeapon, id))
	{
		for(new iSlot = 0; iSlot < MAX_WEAPON_SLOT; iSlot++)
		{
			Weapon_Select(id, g_iMenuWeaponType[id][iSlot], iSlot, g_iMenuWeaponItem[id][iSlot])
		}
		BitsUnSet(g_bitsCanBuyWeapon, id)
	}
	else if(0 <= iSelected < MAX_WEAPON_SLOT)
	{
		Show_SlotMenu(id, iSelected)
	}
	else
		Show_BuyMenu(id)
	
	menu_destroy(iMenu)
	return PLUGIN_HANDLED;
}

public Show_SlotMenu(id, iSlot)
{
	static szMenuName[64]
	format(szMenuName, sizeof(szMenuName) - 1, "%s - %s", cfg_szTextBuyWeapon, cfg_szSlotName[iSlot])
	new iMenu = menu_create(szMenuName, "Handle_SlotMenu")
	static szMenuItem[128], iData[5], bitsRemaining
	
	// Unlocked
	bitsRemaining = g_bitsWeaponUnlock[iSlot] & g_bitsUnlocked[id][iSlot]
	while(bitsRemaining)
	{
		static iItem; iItem = BitsGetFirst(bitsRemaining)
		formatex(szMenuItem, sizeof(szMenuItem), "\y%s \w%s", cfg_szTypeName[WEAPON_TYPE_UNLOCK], g_szWeaponUnlockName[iSlot][iItem])
		iData[0] = iSlot + 1
		iData[1] = WEAPON_TYPE_UNLOCK + 1
		iData[2] = iItem + 1
		menu_additem(iMenu, szMenuItem, iData)
		BitsUnSet(bitsRemaining, iItem)
	}
	
	// Inside
	bitsRemaining = cfg_bitsWeaponInside[iSlot]
	while(bitsRemaining)
	{
		static iWeapon; iWeapon = BitsGetRandom(bitsRemaining)
		
		if(iSlot == WEAPON_SLOT_GRENADE && get_user_flags(id) & ADMIN_LEVEL_C)
		{
			formatex(szMenuItem, sizeof(szMenuItem), "\y%s \w%s \r(x2)", cfg_szTypeName[WEAPON_TYPE_INSIDE], WEAPONNAMES[iWeapon])
		}
		else
		{
			formatex(szMenuItem, sizeof(szMenuItem), "\y%s \w%s", cfg_szTypeName[WEAPON_TYPE_INSIDE], WEAPONNAMES[iWeapon])
		}
		iData[0] = iSlot + 1
		iData[1] = WEAPON_TYPE_INSIDE + 1
		iData[2] = iWeapon + 1
		menu_additem(iMenu, szMenuItem, iData)
		BitsUnSet(bitsRemaining, iWeapon)
	}
	
	// Not Unlocked
	bitsRemaining = g_bitsWeaponUnlock[iSlot] & ~g_bitsUnlocked[id][iSlot]
	while(bitsRemaining)
	{
		static iItem; iItem = BitsGetFirst(bitsRemaining)/*
		if(g_iAmmoPacks[id] < g_iWeaponUnlockCost[iSlot][iItem])
			formatex(szMenuItem, sizeof(szMenuItem), "\y%s \d%s \r(%i$)", cfg_szTypeName[WEAPON_TYPE_UNLOCK], g_szWeaponUnlockName[iSlot][iItem], g_iWeaponUnlockCost[iSlot][iItem])
		else
			*/
		formatex(szMenuItem, sizeof(szMenuItem), "\y%s \w%s \y(%i$)", cfg_szTypeName[WEAPON_TYPE_UNLOCK], g_szWeaponUnlockName[iSlot][iItem], g_iWeaponUnlockCost[iSlot][iItem])
		iData[0] = iSlot + 1
		iData[1] = WEAPON_TYPE_UNLOCK + 1
		iData[2] = iItem + 1
		menu_additem(iMenu, szMenuItem, iData)
		BitsUnSet(bitsRemaining, iItem)
	}
	if(pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0)
	menu_display(id, iMenu)
}

public Handle_SlotMenu(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED;
	}
	new szName[64], iData[5], iItemAccess, iItemCallback
	menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
	
	
	static iSlot;iSlot = iData[0] - 1
	static iType;iType = iData[1] - 1
	static iItem;iItem = iData[2] - 1
	
	if((iType == WEAPON_TYPE_UNLOCK) && BitsGet(g_bitsWeaponUnlock[iSlot] & ~g_bitsUnlocked[id][iSlot], iItem))
	{
		/*
		if(g_iAmmoPacks[id] < g_iWeaponUnlockCost[iSlot][iItem])
		{
			Ammopacks_Flash(id)
			menu_destroy(iMenu)
			Show_SlotMenu(id, iSlot)
			return PLUGIN_CONTINUE
		}
		else
		{
			BitsSet(g_bitsUnlocked[id][iSlot], iItem)
			Ammopacks_Set(id, -g_iWeaponUnlockCost[iSlot][iItem])
		}*/
		BitsSet(g_bitsUnlocked[id][iSlot], iItem)
	}
	
	g_iMenuWeaponType[id][iSlot] = iType
	g_iMenuWeaponItem[id][iSlot] = iItem
	
	Show_BuyMenu(id)

	menu_destroy(iMenu)
	return PLUGIN_HANDLED;
}

public Task_Bot_SelectRandom(taskid)
{
	static id;id = taskid - TASK_BOT_BUY
	if(!IsAlive(id))
		return
	for(new iSlot = 0; iSlot < MAX_WEAPON_SLOT; iSlot++)
		if(g_bitsWeaponUnlock[iSlot])
			Weapon_Select(id, WEAPON_TYPE_UNLOCK, iSlot, BitsGetRandom(g_bitsWeaponUnlock[iSlot]))
		else if(cfg_bitsWeaponInside[iSlot])
			Weapon_Select(id, WEAPON_TYPE_INSIDE, iSlot, BitsGetRandom(cfg_bitsWeaponInside[iSlot]))
}

Weapon_Reset(id)
{
	for(new iSlot = 0; iSlot < MAX_WEAPON_SLOT; iSlot++)
	{
		g_iMenuWeaponType[id][iSlot] = WEAPON_TYPE_INSIDE
		g_iMenuWeaponItem[id][iSlot] = BitsGetRandom(cfg_bitsWeaponInside[iSlot])
		g_bitsUnlocked[id][iSlot] = g_bitsWeaponUnlockFree[iSlot]
	}
}

Weapon_Select(id, iType, iSlot, iItem)
{
	if(iSlot == WEAPON_SLOT_MELEE)
	{
		if(pev_valid(id) == PDATA_SAFE)
		{
			new iEntity = get_pdata_cbase(id, 367+3, 4)
			if(pev_valid(iEntity))
			{
				ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity)
				ExecuteHamB(Ham_RemovePlayerItem, id, iEntity)
				ExecuteHamB(Ham_Item_Kill, iEntity)
				set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<get_pdata_int(iEntity, 43, 4)))
			}
		}
		fm_give_item(id, "weapon_knife")
		if(iType != WEAPON_TYPE_INSIDE)
			BitsSet(g_bitsUsingCustomKnife, id)
	}
	else if(iSlot == WEAPON_SLOT_PRIMARY || iSlot == WEAPON_SLOT_SECONDARY)
		drop_weapons(id, iSlot + 1)
	Weapon_Remove(id, iSlot)
	
	if(iType == WEAPON_TYPE_INSIDE)
	{
		if(iSlot == WEAPON_SLOT_GRENADE)
		{
			new iAmmo = 1;
			if(get_user_flags(id) & ADMIN_LEVEL_C)
				iAmmo++;
			for(new i = 0;i < iAmmo; i++)
			{
				if(pev(id, pev_weapons) & (1<<iItem))
				{
					switch(iItem)
					{
						case CSW_FLASHBANG: ExecuteHamB(Ham_GiveAmmo, id, 1, "Flashbang", 10086); 
						case CSW_HEGRENADE: ExecuteHamB(Ham_GiveAmmo, id, 1, "HEGrenade", 10086); 
						case CSW_SMOKEGRENADE: ExecuteHamB(Ham_GiveAmmo, id, 1, "SmokeGrenade", 10086); 
					}
				}
				else
				{
					fm_give_item(id, WEAPONENTNAMES[iItem]);
				}
			}
			
		}
		else
		{
			fm_give_item(id, WEAPONENTNAMES[iItem])
		}
		
		
		//ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[iItem], AMMOTYPE[iItem], MAXBPAMMO[iItem])
	}
	else if(iType == WEAPON_TYPE_UNLOCK)
	{
		ExecuteForward(g_iForwards[FW_WEAPON_GET_UNLOCK], g_iForwardResult, id, iSlot, iItem)
	}
}

Weapon_Refill(id, iSlot = -998)
{
	if(iSlot < 0)
	{
		for(new i = 0; i < MAX_WEAPON_SLOT; i++)
			Weapon_Refill(id, i)
		return
	}
	
	if(iSlot == WEAPON_SLOT_GRENADE)
	{
		if(pev_valid(fm_get_user_weapon_entity(id, CSW_HEGRENADE)) != PDATA_SAFE)
			fm_give_item(id, "weapon_hegrenade")
	}
	else if(iSlot != WEAPON_SLOT_MELEE)
	{
		new bitsRemaining = cfg_bitsWeaponInside[iSlot]
		while(bitsRemaining)
		{
			static iWeapon; iWeapon = BitsGetFirst(bitsRemaining)
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[iWeapon] / 2, AMMOTYPE[iWeapon], MAXBPAMMO[iWeapon])
			BitsUnSet(bitsRemaining, iWeapon)
		}
	}
	ExecuteForward(g_iForwards[FW_WEAPON_REFILL], g_iForwardResult, id, iSlot)
}

Weapon_Remove(id, iSlot = -998)
{
	if(iSlot < 0)
	{
		for(new i = 0; i < MAX_WEAPON_SLOT; i++)
			Weapon_Remove(id, i)
	}
	else
	{
		BitsSet(g_bitsCanBuyWeapon, id)
		ExecuteForward(g_iForwards[FW_WEAPON_REMOVE], g_iForwardResult, id, iSlot)
	}
}

stock drop_weapons(iPlayer, Slot)
{
	new item = get_pdata_cbase(iPlayer, 367+Slot, 4)
	while(pev_valid(item))
	{
		static classname[24]
		pev(item, pev_classname, classname, charsmax(classname))
		engclient_cmd(iPlayer, "drop", classname)
		item = get_pdata_cbase(item, 42, 5)
	}
	set_pdata_cbase(iPlayer, 367, -1, 4)
}