#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>

#define PLUGIN "[Z4E] Main Menu"
#define VERSION "2.0"
#define AUTHOR "Xiaobaibai"

#define MOD_NAME "僵尸逃跑"

// OffSet
#define PDATA_SAFE 2
stock m_iMenu = 205

enum _:TOTAL_FORWARDS
{
    FW_MAINMENU_SELECT_PRE = 0,
    FW_MAINMENU_SELECT_POST
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

enum
{
    Z4E_MAINMENU_INVALID = -1,
    Z4E_MAINMENU_IGNORED = 0,
    Z4E_MAINMENU_FORBIDDEN,
    Z4E_MAINMENU_HIDDEN
};

new g_bitsMenuItem, g_szItemName[32][64]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_forward(FM_GetGameDescription, "fw_GetGameDescription")
    
    register_clcmd("chooseteam", "CMD_ChooseTeam")
    
    g_iForwards[FW_MAINMENU_SELECT_PRE] = CreateMultiForward("z4e_fw_mainmenu_select_pre", ET_CONTINUE, FP_CELL, FP_CELL)
    g_iForwards[FW_MAINMENU_SELECT_POST] = CreateMultiForward("z4e_fw_mainmenu_select_post", ET_IGNORE, FP_CELL, FP_CELL)
}

public plugin_natives()
{
    register_native("z4e_mainmenu_show", "Native_MenuShow", 1)
    register_native("z4e_mainmenu_item_count", "Native_MenuItemCount", 1)
    register_native("z4e_mainmenu_item_get_name", "Native_MenuItemGetName", 1)
    register_native("z4e_mainmenu_item_get_id", "Native_MenuItemGetID", 1)
    register_native("z4e_mainmenu_item_register", "Native_MenuItemRegister", 1)
}

public CMD_ChooseTeam(id)
{
    Show_MainMenu(id)
    return PLUGIN_HANDLED;
}

public fw_GetGameDescription()
{
    forward_return(FMV_STRING, MOD_NAME)
    
    return FMRES_SUPERCEDE;
}

public Show_MainMenu(id)
{
    static szMenuName[128]
    formatex(szMenuName, sizeof(szMenuName), "\r[CODENAME Z4E] \y%s^t%s^n^t^t^t\r作者:\w小白白^n^t^t^t\rQQ群:\w1326357", MOD_NAME, VERSION)
    new iMenu = menu_create(szMenuName, "Handle_MainMenu")
    static szMenuItem[70], iData[2]

    new bitsRemaining = g_bitsMenuItem
    while(bitsRemaining)
    {
        static iItemID; iItemID = BitsGetFirst(bitsRemaining)
        
        ExecuteForward(g_iForwards[FW_MAINMENU_SELECT_PRE], g_iForwardResult, id, iItemID)
        if(g_iForwardResult == Z4E_MAINMENU_HIDDEN)
            continue;
        
        if(g_iForwardResult == Z4E_MAINMENU_FORBIDDEN)
            format(szMenuItem, sizeof(szMenuItem), "\d%s", g_szItemName[iItemID])
        else
            format(szMenuItem, sizeof(szMenuItem), "\w%s", g_szItemName[iItemID])
            
        iData[0] = iItemID
        menu_additem(iMenu, szMenuItem, iData)
            
        BitsUnSet(bitsRemaining, iItemID)
    }
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, m_iMenu, 0)
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
    menu_display(id, iMenu)
}

public Handle_MainMenu(id, iMenu, iItem)
{
    if(iItem == MENU_EXIT)
    {
        menu_destroy(iMenu)
        return PLUGIN_HANDLED
    }
    
    new szName[64], iData[5], iItemAccess, iItemCallback
    menu_item_getinfo(iMenu, iItem, iItemAccess, iData, charsmax(iData), szName, charsmax(szName), iItemCallback)
    
    new iItemID = iData[0]
    ExecuteForward(g_iForwards[FW_MAINMENU_SELECT_PRE], g_iForwardResult, id, iItemID)
    if(g_iForwardResult == Z4E_MAINMENU_IGNORED)
    {
        ExecuteForward(g_iForwards[FW_MAINMENU_SELECT_POST], g_iForwardResult, id, iItemID)
    }
    menu_destroy(iMenu)
    return PLUGIN_CONTINUE
}

public Native_MenuShow(id)
{
    if(!is_user_connected(id))
        return 0
    Show_MainMenu(id)
    return 1
}

public Native_MenuItemCount()
{
    return BitsCount(g_bitsMenuItem)
}

public Native_MenuItemGetName(iItemID, szOut[], iLen)
{
    param_convert(2)
    if(!BitsGet(g_bitsMenuItem, iItemID))
        return 0
    copy(szOut, iLen, g_szItemName[iItemID])
    return BitsCount(g_bitsMenuItem)
}

public Native_MenuItemGetID(szItemName[])
{
    param_convert(1)
    new bitsRemaining = g_bitsMenuItem
    while(bitsRemaining)
    {
        static iItemID; iItemID = BitsGetFirst(bitsRemaining)
        if(equal(g_szItemName[iItemID], szItemName))
            return iItemID
        BitsUnSet(bitsRemaining, iItemID)
    }
    return -1
}

public Native_MenuItemRegister(szItemName[])
{
    param_convert(1)
    if(g_bitsMenuItem == ~0)
        return -1
    new iItemID = BitsGetFirst(~g_bitsMenuItem)
    copy(g_szItemName[iItemID], 63, szItemName)
    BitsSet(g_bitsMenuItem, iItemID)
    return iItemID
}