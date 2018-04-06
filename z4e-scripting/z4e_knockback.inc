#if defined _z4e_knockback_included
  #endinput
#endif
#define _z4e_knockback_included

enum _:MAX_KNOCKBACK_TYPE(<<=1)
{
    Z4E_KNOCKBACK_NONE = 0,
    Z4E_KNOCKBACK_IGNOREABILITY = 1,
    Z4E_KNOCKBACK_IGNORERETURN,
    Z4E_KNOCKBACK_IGNORECHECK,
    Z4E_KNOCKBACK_DRAWANIM,
    Z4E_KNOCKBACK_INSIDE,
}
native z4e_knockback_set(id, iAttacker, Float:flGround = -1.0, Float:flAir = -1.0, Float:flFly = -1.0, Float:flDuck = -1.0, Float:flVelocityModifier = -1.0, bitsType);
forward z4e_fw_knockback_set_pre(id, iAttacker, Float:flGround, Float:flAir, Float:flFly, Float:flDuck, Float:flVelocityModifier, bitsType);
forward z4e_fw_knockback_set_post(id, iAttacker, Float:flGround, Float:flAir, Float:flFly, Float:flDuck, Float:flVelocityModifier, bitsType);