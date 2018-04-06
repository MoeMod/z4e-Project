#if defined _z4e_mainmenu_included
  #endinput
#endif
#define _z4e_mainmenu_included

enum
{
    Z4E_MAINMENU_INVALID = -1,
    Z4E_MAINMENU_IGNORED = 0,
    Z4E_MAINMENU_FORBIDDEN,
    Z4E_MAINMENU_HIDDEN
};

native z4e_mainmenu_show(id)
native z4e_mainmenu_item_count()
native z4e_mainmenu_item_get_name(iItemID, szOut[], iLen)
native z4e_mainmenu_item_get_id(const szItemName[])

native z4e_mainmenu_item_register(szItemName[])

forward z4e_fw_mainmenu_select_pre(id, iItem)
forward z4e_fw_mainmenu_select_post(id, iItem)
