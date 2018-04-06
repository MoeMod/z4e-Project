#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>
#include <z4e_mainmenu>
#include <z4e_team>

#define PLUGIN "[Z4E] Admin"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

enum _:MAX_ADMIN_ACT
{
    ADMIN_ACT_INFECT,
    ADMIN_ACT_SETHUMAN,
    ADMIN_ACT_KILL,
    ADMIN_ACT_RESPAWN,
}
new const cfg_szAdminAct[MAX_ADMIN_ACT][] = { 
    "变成僵尸",
    "恢复人类",
    "处死",
    "复活"
}

enum _:MAX_ADMIN_TARGET
{
    ADMIN_TARGET_ONE,
    ADMIN_TARGET_ALL,
    ADMIN_TARGET_HUMAN,
    ADMIN_TARGET_ALIVE,
    ADMIN_TARGET_RANDOM
}
new const cfg_szAdminTarget[MAX_ADMIN_TARGET][] = { 
    "指定一名玩家",
    "所有的玩家",
    "所有的人类",
    "所有活着的人",
    "随机抽一个人"
}

// OffSet
#define PDATA_SAFE 2
stock m_iMenu = 205

new g_bitsSelectedID[33]
new g_szName[33][32]
new g_iMenuItem

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    g_iMenuItem = z4e_mainmenu_item_register("管理员装逼菜单")
}

public z4e_fw_mainmenu_select_pre(id, iItem)
{
    if(iItem != g_iMenuItem)
        return Z4E_MAINMENU_IGNORED
    if(!is_user_admin(id))
        return Z4E_MAINMENU_FORBIDDEN
    return Z4E_MAINMENU_IGNORED
}

public z4e_fw_mainmenu_select_post(id, iItem)
{
    if(iItem != g_iMenuItem)
        return Z4E_MAINMENU_IGNORED
    
    Show_AdminTargetMenu(id)
    
    return Z4E_MAINMENU_IGNORED
}

public client_connect(id)
{
    g_bitsSelectedID[id] = 0
    get_user_name(id, g_szName[id], 31)
}

public Show_AdminTargetMenu(id)
{
    new bitsConnected = z4e_team_bits_get_connected()
    static szMenuName[64]
    formatex(szMenuName, sizeof(szMenuName), "选择你想管理的对象：[%i/%i]", BitsCount(g_bitsSelectedID[id]), BitsCount(bitsConnected))
    new iMenu = menu_create(szMenuName, "Handle_AdminTargetMenu")
    static szMenuItem[128], iData[2]

    for(new iItem = 0; iItem < MAX_ADMIN_TARGET; iItem++)
    {
        format(szMenuItem, sizeof(szMenuItem), "\w%s", cfg_szAdminTarget[iItem])
        
        iData[0] = iItem
        menu_additem(iMenu, szMenuItem, iData)
    }
    
    format(szMenuItem, sizeof(szMenuItem), "\y确认选择")
    iData[0] = -1
    menu_additem(iMenu, szMenuItem, iData)
    
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, m_iMenu, 0)
    
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
    menu_display(id, iMenu)
}

public Handle_AdminTargetMenu(id, iMenu, iItem)
{
    if(iItem == MENU_EXIT)
    {
        menu_destroy(iMenu)
        return PLUGIN_HANDLED
    }
    
    new szName[64], iData[2], iItemAccess, iItemCallback
    menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
    
    new iSelected = iData[0]
    new bitsConnected = z4e_team_bits_get_connected()
    new bitsIsAlive = z4e_team_bits_get_alive()
    new bitsIsZombie = z4e_team_bits_get_member(Z4E_TEAM_ZOMBIE)
    
    switch(iSelected)
    {
        case ADMIN_TARGET_ONE: {
            menu_destroy(iMenu)
            Show_AdminSelectOneMenu(id, 0)
            return PLUGIN_HANDLED
        }
        case ADMIN_TARGET_ALL: {
            if(g_bitsSelectedID[id] & bitsConnected == bitsConnected)
            {
                g_bitsSelectedID[id] = 0
                client_print(id, print_chat, "[Z4E] 取消选择所有玩家")
            }
            else
            {
                g_bitsSelectedID[id] = bitsConnected
                client_print(id, print_chat, "[Z4E] 成功选择所有玩家")
            }
        }
        case ADMIN_TARGET_HUMAN: {
            if(g_bitsSelectedID[id] & bitsConnected & ~bitsIsZombie == bitsConnected & ~bitsIsZombie)
            {
                g_bitsSelectedID[id] &= bitsConnected & bitsIsZombie
                client_print(id, print_chat, "[Z4E] 取消选择所有人类")
            }
            else
            {
                g_bitsSelectedID[id] |= bitsConnected & ~bitsIsZombie
                client_print(id, print_chat, "[Z4E] 成功选择所有人类")
            }
        }
        case ADMIN_TARGET_ALIVE: {
            if(g_bitsSelectedID[id] & bitsConnected & bitsIsAlive == bitsConnected & bitsIsAlive)
            {
                g_bitsSelectedID[id] &= bitsConnected & ~bitsIsAlive
                client_print(id, print_chat, "[Z4E] 取消选择所有存活玩家")
            }
            else
            {
                g_bitsSelectedID[id] |= bitsConnected & bitsIsAlive
                client_print(id, print_chat, "[Z4E] 成功选择所有存活玩家")
            }
        }
        case ADMIN_TARGET_RANDOM: {
            if(bitsConnected & ~g_bitsSelectedID[id])
            {
                new iRandom = BitsGetRandom(bitsConnected & ~g_bitsSelectedID[id])
                iRandom = !iRandom ? 32:iRandom
                BitsSet(g_bitsSelectedID[id], iRandom)
                client_print(id, print_chat, "[Z4E] 随机选择：<%s>", g_szName[iRandom])
            }
        }
        case -1:{
            menu_destroy(iMenu)
            Show_AdminActMenu(id)
            return PLUGIN_CONTINUE
        }
    }
    
    menu_destroy(iMenu)
    Show_AdminTargetMenu(id)
    return PLUGIN_CONTINUE
}

public Show_AdminSelectOneMenu(id, iPage)
{
    new bitsConnected = z4e_team_bits_get_connected()
    static szMenuName[64]
    formatex(szMenuName, sizeof(szMenuName), "选择你想管理的对象：[%i/%i]", BitsCount(g_bitsSelectedID[id]), BitsCount(bitsConnected))
    new iMenu = menu_create(szMenuName, "Handle_AdminSelectOneMenu")
    static szMenuItem[128], iData[2]

    new bitsRemaining
    bitsRemaining = bitsConnected
    while(bitsRemaining)
    {
        new iItem = BitsGetFirst(bitsRemaining)
        iItem = !iItem ? 32:iItem
        if(BitsGet(g_bitsSelectedID[id], iItem))
            format(szMenuItem, sizeof(szMenuItem), "\d%s", g_szName[iItem])
        else
            format(szMenuItem, sizeof(szMenuItem), "\w%s", g_szName[iItem])
        
        iData[0] = iItem
        menu_additem(iMenu, szMenuItem, iData)
        
        BitsUnSet(bitsRemaining, iItem)
    }
    
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, m_iMenu, 0)
    
    menu_setprop(iMenu, MPROP_EXITNAME, "确认选择")
    menu_display(id, iMenu, iPage)
}

public Handle_AdminSelectOneMenu(id, iMenu, iItem)
{
        
    new szName[64], iData[2], iItemAccess, iItemCallback
    menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
    
    new iSelected = iData[0]
    new iPage = iItem / 7
    
    if(iItem == MENU_EXIT)
    {
        menu_destroy(iMenu)
        Show_AdminTargetMenu(id)
        return PLUGIN_HANDLED
    }
    BitsSwitch(g_bitsSelectedID[id], iSelected)
    if(BitsGet(g_bitsSelectedID[id], iSelected))
        client_print(id, print_chat, "[Z4E] 成功选择：<%s>", szName)
    else    
        client_print(id, print_chat, "[Z4E] 取消选择：<%s>", szName)
    
    
    menu_destroy(iMenu)
    Show_AdminSelectOneMenu(id, iPage)
    return PLUGIN_CONTINUE
}

public Show_AdminActMenu(id)
{
    new bitsConnected = z4e_team_bits_get_connected()
    static szMenuName[64]
    formatex(szMenuName, sizeof(szMenuName), "对于那些玩家要：[%i/%i]", BitsCount(g_bitsSelectedID[id]), BitsCount(bitsConnected))
    new iMenu = menu_create(szMenuName, "Handle_AdminActMenu")
    static szMenuItem[128], iData[2]

    for(new iItem = 0; iItem < MAX_ADMIN_ACT; iItem++)
    {
        format(szMenuItem, sizeof(szMenuItem), "\w%s", cfg_szAdminAct[iItem])
        
        iData[0] = iItem
        menu_additem(iMenu, szMenuItem, iData)
    }
    
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, m_iMenu, 0)
    
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
    menu_display(id, iMenu)
    return PLUGIN_CONTINUE
}

public Handle_AdminActMenu(id, iMenu, iItem)
{
    if(iItem == MENU_EXIT)
    {
        menu_destroy(iMenu)
        return PLUGIN_HANDLED
    }
    
    new szName[64], iData[2], iItemAccess, iItemCallback
    menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
    
    new iSelected = iData[0]
    
    new bitsRemaining = g_bitsSelectedID[id]
    while(bitsRemaining)
    {
        new iTarget = BitsGetFirst(bitsRemaining)
        iTarget = !iTarget ? 32:iTarget
            
        switch(iSelected)
        {
            case ADMIN_ACT_INFECT: z4e_team_set(iTarget, Z4E_TEAM_ZOMBIE)
            case ADMIN_ACT_SETHUMAN: z4e_team_set(iTarget, Z4E_TEAM_HUMAN)
            case ADMIN_ACT_KILL: {
                if(is_user_alive(iTarget))
                    dllfunc(DLLFunc_ClientKill, iTarget);
            }
            case ADMIN_ACT_RESPAWN: {
                set_pev(iTarget, pev_deadflag, DEAD_RESPAWNABLE)
                ExecuteHamB(Ham_CS_RoundRespawn, iTarget)
            }
        }
        client_print(0, print_chat, "[Z4E] 管理员<%s>把玩家<%s>%s", g_szName[id], g_szName[iTarget], cfg_szAdminAct[iSelected])
        BitsUnSet(bitsRemaining, iTarget)
    }
    
    menu_destroy(iMenu)
    Show_AdminActMenu(id)
    return PLUGIN_CONTINUE
}