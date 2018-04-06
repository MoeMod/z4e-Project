#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_mainmenu>
#include <z4e_ammopacks>

#define PLUGIN "[Z4E] Extra Item"
#define VERSION "2.0"
#define AUTHOR "Xiaobaibai"

// OffSet
#define PDATA_SAFE 2
stock m_iMenu = 205 // int

enum _:TOTAL_FORWARDS
{
    FW_EXTRA_SELECT_PRE = 0,
    FW_EXTRA_SELECT_POST
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

enum
{
    Z4E_EXTRA_INVALID = -1,
    Z4E_EXTRA_IGNORED = 0,
    Z4E_EXTRA_FORBIDDEN,
    Z4E_EXTRA_HIDDEN
};

#define MAX_ITEM_COUNT 32
new g_iItemCount, g_szItemName[MAX_ITEM_COUNT][64], g_iItemCost[MAX_ITEM_COUNT]

new g_iMenuItem

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    g_iForwards[FW_EXTRA_SELECT_PRE] = CreateMultiForward("z4e_fw_extra_select_pre", ET_CONTINUE, FP_CELL, FP_CELL)
    g_iForwards[FW_EXTRA_SELECT_POST] = CreateMultiForward("z4e_fw_extra_select_post", ET_IGNORE, FP_CELL, FP_CELL)
    
    g_iMenuItem = z4e_mainmenu_item_register("特殊道具商店")
}

public plugin_natives()
{
    register_native("z4e_extra_show", "Native_MenuShow", 1)
    register_native("z4e_extra_item_count", "Native_MenuItemCount", 1)
    register_native("z4e_extra_item_get_name", "Native_MenuItemGetName", 1)
    register_native("z4e_extra_item_get_id", "Native_MenuItemGetID", 1)
    register_native("z4e_extra_item_register", "Native_MenuItemRegister", 1)
}

public z4e_fw_mainmenu_select_pre(id, iItem)
{
    if(iItem != g_iMenuItem)
        return Z4E_MAINMENU_IGNORED
    if(!g_iItemCount)
        return Z4E_MAINMENU_FORBIDDEN
    return Z4E_MAINMENU_IGNORED
}

public z4e_fw_mainmenu_select_post(id, iItem)
{
    if(iItem != g_iMenuItem)
        return Z4E_MAINMENU_IGNORED
    Show_ExtraMenu(id)
    return Z4E_MAINMENU_IGNORED
}

public Show_ExtraMenu(id)
{
    static szMenuName[128]
    formatex(szMenuName, sizeof(szMenuName), "\特殊道具商店")
    new iMenu = menu_create(szMenuName, "Handle_ExtraMenu")
    static szMenuItem[70], iData[2]

    for(new i;i < g_iItemCount;i++)
    {
        ExecuteForward(g_iForwards[FW_EXTRA_SELECT_PRE], g_iForwardResult, id, i)
        if(g_iForwardResult == Z4E_EXTRA_HIDDEN)
            continue;
        
        if(g_iForwardResult == Z4E_EXTRA_FORBIDDEN || z4e_ammopacks_get(id) < g_iItemCost[i])
            format(szMenuItem, sizeof(szMenuItem), "\d%s \y%i$", g_szItemName[i], g_iItemCost[i])
        else
            format(szMenuItem, sizeof(szMenuItem), "\w%s \y%i$", g_szItemName[i], g_iItemCost[i])
            
        iData[0] = i
        menu_additem(iMenu, szMenuItem, iData)
            
    }
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, m_iMenu, 0)
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
    menu_display(id, iMenu)
}

public Handle_ExtraMenu(id, iMenu, iItem)
{
    if(iItem == MENU_EXIT)
    {
        menu_destroy(iMenu)
        return PLUGIN_HANDLED
    }
    
    new szName[64], iData[5], iItemAccess, iItemCallback
    menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
    
    new iItemID = iData[0]
    ExecuteForward(g_iForwards[FW_EXTRA_SELECT_PRE], g_iForwardResult, id, iItemID)
    if(g_iForwardResult == Z4E_EXTRA_FORBIDDEN)
    {
        Show_ExtraMenu(id)
        menu_destroy(iMenu)
        return PLUGIN_CONTINUE
    }
    else if(z4e_ammopacks_get(id) < g_iItemCost[iItemID])
    {
        z4e_ammopacks_flash(id)
    }
    else
    {
        z4e_ammopacks_set(id, - g_iItemCost[iItemID])
        ExecuteForward(g_iForwards[FW_EXTRA_SELECT_POST], g_iForwardResult, id, iItemID)
    }
    menu_destroy(iMenu)
    return PLUGIN_CONTINUE
}

public Native_MenuShow(id)
{
    if(!is_user_connected(id))
        return 0
    Show_ExtraMenu(id)
    return 1
}

public Native_MenuItemCount()
{
    return g_iItemCount
}

public Native_MenuItemGetName(iItemID, szOut[], iLen)
{
    param_convert(2)
    if(iItemID < 0|| iItemID > g_iItemCount)
        return 0
    copy(szOut, iLen, g_szItemName[iItemID])
    return g_iItemCount
}

public Native_MenuItemGetID(szItemName[])
{
    param_convert(1)
    for(new i=0;i<g_iItemCount;i++)
    {
        if(equal(g_szItemName[i], szItemName))
            return i
    }
    return -1
}

public Native_MenuItemRegister(szItemName[], iCost)
{
    param_convert(1)
    if(g_iItemCount == MAX_ITEM_COUNT)
        return -1
    copy(g_szItemName[g_iItemCount], 63, szItemName)
    g_iItemCost[g_iItemCount] = iCost
    g_iItemCount ++
    return g_iItemCount -1
}