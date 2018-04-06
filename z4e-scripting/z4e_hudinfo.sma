#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "[Z4E] HUD Info"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_message(get_user_msgid("Health"), "Message_Health")
}

public Message_Health(msg_id, msg_dest, id)
{
    if(!is_user_connected(id))
        return;
    static Float:flMaxHealth
    pev(id, pev_max_health, flMaxHealth)
    static Float:flHealth
    pev(id, pev_health, flHealth)
    if(flMaxHealth >= flHealth)
        set_msg_arg_int(1, get_msg_argtype(1), max(floatround(flHealth * 100.0 / flMaxHealth), 1))
}
