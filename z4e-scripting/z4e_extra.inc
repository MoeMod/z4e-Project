#if defined _z4e_extra_included
  #endinput
#endif
#define _z4e_extra_included

enum
{
    Z4E_EXTRA_INVALID = -1,
    Z4E_EXTRA_IGNORED = 0,
    Z4E_EXTRA_FORBIDDEN,
    Z4E_EXTRA_HIDDEN
};

native z4e_extra_show(id)
native z4e_extra_item_count()
native z4e_extra_item_get_name(iItemID, szOut[], iLen)
native z4e_extra_item_get_id(const szItemName[])

native z4e_extra_item_register(szItemName[], iCost)

forward z4e_fw_extra_select_pre(id, iItem)
forward z4e_fw_extra_select_post(id, iItem)
