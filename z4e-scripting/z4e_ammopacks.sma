#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <z4e_bits>

#define PLUGIN "[Z4E] Ammopacks"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define OFFSET_STATIONARY 362 

new g_iAmmoPacks[33]

new g_MsgMoney

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    g_MsgMoney = get_user_msgid("Money")
    register_message(g_MsgMoney, "Message_Money")
}

public plugin_natives()
{
    register_native("z4e_ammopacks_get", "Native_Ammopacks_Get", 1)
    register_native("z4e_ammopacks_set", "Native_Ammopacks_Set", 1)
    register_native("z4e_ammopacks_flash", "Native_Ammopacks_Flash", 1)
}

public client_putinserver(id)
{
    g_iAmmoPacks[id] = get_cvar_num("mp_startmoney")
}

public client_disconnect(id)
{
    g_iAmmoPacks[id] = 0
}

public Native_Ammopacks_Get(id)
{
    if(!is_user_connected(id))
        return 0
    return g_iAmmoPacks[id];
}

public Native_Ammopacks_Set(id, iAmount)
{
    if(!is_user_connected(id))
        return 0
    Ammopacks_Set(id, iAmount)
    return 1
}

public Native_Ammopacks_Flash(id, iTimes)
{
    if(!is_user_connected(id))
        return 0
    Ammopacks_Flash(id, iTimes)
    return 1
}

public Message_Money(msg_id, msg_dest, id)
{
    if(!is_user_connected(id))
        return;
    set_msg_arg_int(1, get_msg_argtype(1), g_iAmmoPacks[id]);
}


Ammopacks_Set(id, iAmount)
{
    g_iAmmoPacks[id] += iAmount
    g_iAmmoPacks[id] = max(0, g_iAmmoPacks[id])
    message_begin(MSG_ONE_UNRELIABLE, g_MsgMoney, _, id)
    write_long(g_iAmmoPacks[id]) // Money amount
    write_byte(1) // Flag
    message_end()
}

Ammopacks_Flash(id, iTimes = 2)
{
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BlinkAcct"), _, id)
    write_byte(iTimes) // BlinkAmt
    message_end()
}