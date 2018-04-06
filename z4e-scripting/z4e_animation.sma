#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include <z4e_bits>
#include <z4e_offset>
#include <z4e_api>
#include <z4e_team>
#include <z4e_gameplay>

#define PLUGIN "[Z4E] Zombie Animation"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

enum _:PLAYER_ANIM
{
    PLAYER_IDLE = 0,
    PLAYER_WALK,
    PLAYER_JUMP,
    PLAYER_SUPERJUMP,
    PLAYER_DIE,
    PLAYER_ATTACK1,
    PLAYER_ATTACK2,
    PLAYER_FLINCH,
    PLAYER_LARGE_FLINCH,
    PLAYER_RELOAD,
    PLAYER_HOLDBOMB,
    PLAYER_CUSTOM
}

enum _:Activitys
{
    ACT_RESET = 0,
    ACT_IDLE,
    ACT_GUARD,
    ACT_WALK,
    ACT_RUN,
    ACT_FLY,
    ACT_SWIM,
    ACT_HOP,
    ACT_LEAP,
    ACT_FALL,
    ACT_LAND,
    ACT_STRAFE_LEFT,
    ACT_STRAFE_RIGHT,
    ACT_ROLL_LEFT,
    ACT_ROLL_RIGHT,
    ACT_TURN_LEFT,
    ACT_TURN_RIGHT,
    ACT_CROUCH,
    ACT_CROUCHIDLE,
    ACT_STAND,
    ACT_USE,
    ACT_SIGNAL1,
    ACT_SIGNAL2,
    ACT_SIGNAL3,
    ACT_TWITCH,
    ACT_COWER,
    ACT_SMALL_FLINCH,
    ACT_BIG_FLINCH,
    ACT_RANGE_ATTACK1,
    ACT_RANGE_ATTACK2,
    ACT_MELEE_ATTACK1,
    ACT_MELEE_ATTACK2,
    ACT_RELOAD,
    ACT_ARM,
    ACT_DISARM,
    ACT_EAT,
    ACT_DIESIMPLE,
    ACT_DIEBACKWARD,
    ACT_DIEFORWARD,
    ACT_DIEVIOLENT,
    ACT_BARNACLE_HIT,
    ACT_BARNACLE_PULL,
    ACT_BARNACLE_CHOMP,
    ACT_BARNACLE_CHEW,
    ACT_SLEEP,
    ACT_INSPECT_FLOOR,
    ACT_INSPECT_WALL,
    ACT_IDLE_ANGRY,
    ACT_WALK_HURT,
    ACT_RUN_HURT,
    ACT_HOVER,
    ACT_GLIDE,
    ACT_FLY_LEFT,
    ACT_FLY_RIGHT,
    ACT_DETECT_SCENT,
    ACT_SNIFF,
    ACT_BITE,
    ACT_THREAT_DISPLAY,
    ACT_FEAR_DISPLAY,
    ACT_EXCITED,
    ACT_SPECIAL_ATTACK1,
    ACT_SPECIAL_ATTACK2,
    ACT_COMBAT_IDLE,
    ACT_WALK_SCARED,
    ACT_RUN_SCARED,
    ACT_VICTORY_DANCE,
    ACT_DIE_HEADSHOT,
    ACT_DIE_CHESTSHOT,
    ACT_DIE_GUTSHOT,
    ACT_DIE_BACKSHOT,
    ACT_FLINCH_HEAD,
    ACT_FLINCH_CHEST,
    ACT_FLINCH_STOMACH,
    ACT_FLINCH_LEFTARM,
    ACT_FLINCH_RIGHTARM,
    ACT_FLINCH_LEFTLEG,
    ACT_FLINCH_RIGHTLEG,
    ACT_FLINCH,
    ACT_LARGE_FLINCH,
    ACT_HOLDBOMB,
    ACT_IDLE_FIDGET,
    ACT_IDLE_SCARED,
    ACT_IDLE_SCARED_FIDGET,
    ACT_FOLLOW_IDLE,
    ACT_FOLLOW_IDLE_FIDGET,
    ACT_FOLLOW_IDLE_SCARED,
    ACT_FOLLOW_IDLE_SCARED_FIDGET,
    ACT_CROUCH_IDLE,
    ACT_CROUCH_IDLE_FIDGET,
    ACT_CROUCH_IDLE_SCARED,
    ACT_CROUCH_IDLE_SCARED_FIDGET,
    ACT_CROUCH_WALK,
    ACT_CROUCH_WALK_SCARED,
    ACT_CROUCH_DIE,
    ACT_WALK_BACK,
    ACT_IDLE_SNEAKY,
    ACT_IDLE_SNEAKY_FIDGET,
    ACT_WALK_SNEAKY,
    ACT_WAVE,
    ACT_YES,
    ACT_NO,
    ACT_CUSTOM
}

enum _:HITGROUP
{
    HITGROUP_GENERIC = 0,
    HITGROUP_HEAD,
    HITGROUP_CHEST,
    HITGROUP_STOMACH,
    HITGROUP_LEFTARM,
    HITGROUP_RIGHTARM,
    HITGROUP_LEFTLEG,
    HITGROUP_RIGHTLEG,
    HITGROUP_SHIELD    
}

enum _:ThrowDirection
{
    THROW_NONE,
    THROW_FORWARD,
    THROW_BACKWARD,
    THROW_HITVEL,
    THROW_BOMB,
    THROW_GRENADE,
    THROW_HITVEL_MINUS_AIRVEL
}

new GaitSequence[33], Float:RecordTiime[33], Float:PlayTime[33], Sequence[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    OrpheuRegisterHook(OrpheuGetFunction("SetAnimation", "CBasePlayer"), "OnSetAnimation");
}

public OrpheuHookReturn:OnSetAnimation(id, playerAnim)
{
    if(GaitSequence[id] >= 0 && pev(id, pev_deadflag) == DEAD_NO)
    {
        if(get_gametime() > RecordTiime[id] + PlayTime[id]) 
            GaitSequence[id] = -1;
        set_pev(id, pev_sequence, Sequence[id])
        set_pev(id, pev_gaitsequence, GaitSequence[id])
        return OrpheuSupercede;
    }
    
    new animDesired;
    new Float:speed;
    new szAnim[64];
    new hopSeq, leapSeq;
    
    if (!pev(id, pev_modelindex))
        return OrpheuSupercede;
    if ((playerAnim == PLAYER_FLINCH || playerAnim == PLAYER_LARGE_FLINCH) && get_pdata_bool(id, m_bOwnsShield) == true)
        return OrpheuSupercede;
    
    new Float:flHealth; pev(id, pev_health, flHealth)
    if(!(playerAnim == PLAYER_FLINCH || playerAnim == PLAYER_LARGE_FLINCH || get_gametime() > get_pdata_float(id, m_flFlinchTime) || flHealth <= 0.0))
        return OrpheuSupercede;
    
    new Float:vecVelocity[3]; 
    pev(id, pev_velocity, vecVelocity); 
    vecVelocity[2] = 0.0;
    speed = xs_vec_len(vecVelocity)
        
    if (pev(id, pev_flags) & FL_FROZEN)
    {
        speed = 0.0;
        playerAnim = PLAYER_IDLE;
    }
    
    hopSeq = LookupActivity(id, ACT_HOP);
    leapSeq = LookupActivity(id, ACT_LEAP);
    
    new Activity = get_pdata_int(id, m_Activity)
    new IdealActivity = get_pdata_int(id, m_IdealActivity)
    
    switch (playerAnim)
    {
        case PLAYER_CUSTOM:
        {
            if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
                IdealActivity = Activity;
            else
                IdealActivity = ACT_CUSTOM;
        }
        case PLAYER_JUMP:
        {
            if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
                IdealActivity = Activity;
            else
                IdealActivity = ACT_HOP;
        }
        case PLAYER_SUPERJUMP:
        {
            if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
                IdealActivity = Activity;
            else
                IdealActivity = ACT_LEAP;
        }
        case PLAYER_DIE:
        {
            IdealActivity = ACT_DIESIMPLE;
            DeathSound(id);
        }
        case PLAYER_ATTACK1:
        {
            if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
                IdealActivity = Activity;
            else
                IdealActivity = ACT_RANGE_ATTACK1;
        }
        case PLAYER_ATTACK2:
        {
            if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
                IdealActivity = Activity;
            else
                IdealActivity = ACT_RANGE_ATTACK2;
        }
        case PLAYER_RELOAD:
        {
            if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
                IdealActivity = Activity;
            else
                IdealActivity = ACT_RELOAD;
        }
        case PLAYER_IDLE:
        {
            if ((pev(id, pev_flags) &  FL_ONGROUND) || (Activity != ACT_HOP && Activity != ACT_LEAP))
            {
                if (pev(id, pev_waterlevel) <= 1)
                    IdealActivity = ACT_WALK;
                else if (speed == 0.0)
                    IdealActivity = ACT_HOVER;
                else
                    IdealActivity = ACT_SWIM;
                    
            }
            else
                IdealActivity = Activity;
        }
        case PLAYER_WALK:
        {
            if ((pev(id, pev_flags) &  FL_ONGROUND) || (Activity != ACT_HOP && Activity != ACT_LEAP))
            {
                if (pev(id, pev_waterlevel) <= 1)
                    IdealActivity = ACT_WALK;
                else if (speed == 0.0)
                    IdealActivity = ACT_HOVER;
                else
                    IdealActivity = ACT_SWIM;
                    
            }
            else
                IdealActivity = Activity;
        }
        case PLAYER_HOLDBOMB: 
            IdealActivity = ACT_HOLDBOMB;
        case PLAYER_FLINCH: 
            IdealActivity = ACT_FLINCH;
        case PLAYER_LARGE_FLINCH: 
            IdealActivity = ACT_LARGE_FLINCH;
    }
    set_pdata_int(id, m_IdealActivity, IdealActivity);
    
    switch(IdealActivity)
    {
        case ACT_CUSTOM:
        {
            RecordTiime[id] = get_gametime();
            animDesired = Sequence[id];
            if (animDesired == -1)
                animDesired = 0;
            set_pev(id, pev_sequence, animDesired);
            set_pev(id, pev_frame, 0.0);
            ResetSequenceInfo(id)
            Activity = IdealActivity;
        }
        case ACT_HOP:
        {
            if(Activity == IdealActivity)
                return OrpheuSupercede;
                
            if(Activity == ACT_CUSTOM)
            {
                animDesired = Sequence[id];
            }
            else
            {
                if (Activity == ACT_RANGE_ATTACK1)
                    copy(szAnim, 64, "ref_shoot_");
                else if (Activity == ACT_RANGE_ATTACK2)
                    copy(szAnim, 64, "ref_shoot2_");
                else if (Activity == ACT_RELOAD)
                    copy(szAnim, 64, "ref_reload_");
                else
                    copy(szAnim, 64, "ref_aim_");
                new szAnimExtention[32];
                get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                animDesired = LookupSequence(id, szAnim);
            }
            if (animDesired == -1)
                animDesired = 0;
            if (pev(id, pev_sequence) != animDesired || !get_pdata_bool(id, m_fSequenceLoops))
                set_pev(id, pev_frame, 0.0);
            if (!get_pdata_bool(id, m_fSequenceLoops))
                set_pev(id, pev_effects, pev(id, pev_effects) | EF_NOINTERP);
                
            set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_HOP));
            Activity = IdealActivity;
        }
        case ACT_LEAP:
        {
            if(Activity == IdealActivity)
                return OrpheuSupercede;
                
            if(Activity == ACT_CUSTOM)
            {
                animDesired = Sequence[id];
            }
            else
            {
                if (Activity == ACT_RANGE_ATTACK1)
                    copy(szAnim, 64, "ref_shoot_");
                else if (Activity == ACT_RANGE_ATTACK2)
                    copy(szAnim, 64, "ref_shoot2_");
                else if (Activity == ACT_RELOAD)
                    copy(szAnim, 64, "ref_reload_");
                else
                    copy(szAnim, 64, "ref_aim_");
                new szAnimExtention[32];
                get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                animDesired = LookupSequence(id, szAnim);
            }
            
            if (animDesired == -1)
                animDesired = 0;
            if (pev(id, pev_sequence) != animDesired || !get_pdata_bool(id, m_fSequenceLoops))
                set_pev(id, pev_frame, 0.0);
            if (!get_pdata_bool(id, m_fSequenceLoops))
                set_pev(id, pev_effects, pev(id, pev_effects) | EF_NOINTERP);
            
            set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_LEAP));
            Activity = IdealActivity;
        }
        case ACT_RANGE_ATTACK1:
        {
            set_pdata_float(id, m_flLastFired, get_gametime());
            if (pev(id, pev_flags) & FL_DUCKING)
                copy(szAnim, 64, "crouch_shoot_");
            else
                copy(szAnim, 64, "ref_shoot_");
            new szAnimExtention[32];
            get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
            format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
            animDesired = LookupSequence(id, szAnim);
            if (animDesired == -1)
                animDesired = 0;
            set_pev(id, pev_sequence, animDesired);
            set_pev(id, pev_frame, 0.0);
            ResetSequenceInfo(id);
            Activity = IdealActivity;
        }
        case ACT_RANGE_ATTACK2:
        {
            set_pdata_float(id, m_flLastFired, get_gametime());
            if (pev(id, pev_flags) & FL_DUCKING)
                copy(szAnim, 64, "crouch_shoot2_");
            else
                copy(szAnim, 64, "ref_shoot2_");
            new szAnimExtention[32];
            get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
            format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
            animDesired = LookupSequence(id, szAnim);
            if (animDesired == -1)
                animDesired = 0;
            set_pev(id, pev_sequence, animDesired);
            set_pev(id, pev_frame, 0.0);
            ResetSequenceInfo(id);
            Activity = IdealActivity;
        }
        case ACT_RELOAD:
        {
            if (pev(id, pev_flags) & FL_DUCKING)
                copy(szAnim, 64, "crouch_reload_");
            else
                copy(szAnim, 64, "ref_reload_");
            new szAnimExtention[32];
            get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
            format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
            animDesired = LookupSequence(id, szAnim);
            if (animDesired == -1)
                animDesired = 0;
                
            if (pev(id, pev_sequence) != animDesired || !get_pdata_bool(id, m_fSequenceLoops))
                set_pev(id, pev_frame, 0.0);
            if (!get_pdata_bool(id, m_fSequenceLoops))
                set_pev(id, pev_effects, pev(id, pev_effects) | EF_NOINTERP);

            Activity = IdealActivity;
        }
        case ACT_HOLDBOMB:
        {
            if (pev(id, pev_flags) & FL_DUCKING)
                copy(szAnim, 64, "crouch_aim_");
            else
                copy(szAnim, 64, "ref_aim_");
            new szAnimExtention[32];
            get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
            format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
            animDesired = LookupSequence(id, szAnim);
            if (animDesired == -1)
                animDesired = 0;
            
            Activity = IdealActivity;
        }
        case ACT_WALK:
        {
            new fSequenceFinished = get_pdata_int(id, m_fSequenceFinished);
            if ((Activity != ACT_CUSTOM || fSequenceFinished) && (m_Activity != ACT_RANGE_ATTACK1 || fSequenceFinished) && (Activity != ACT_RANGE_ATTACK2 || fSequenceFinished) && (Activity != ACT_FLINCH || fSequenceFinished) && (Activity != ACT_LARGE_FLINCH || fSequenceFinished) && (Activity != ACT_RELOAD || fSequenceFinished))
            {
                if (speed <= 135 || get_gametime() <= get_pdata_float(id, m_flLastFired) + 2.0 || get_gametime() <= RecordTiime[id] + PlayTime[id])
                {
                    if (pev(id, pev_flags) & FL_DUCKING)
                        copy(szAnim, 64, "crouch_aim_");
                    else
                        copy(szAnim, 64, "ref_aim_");
                    new szAnimExtention[32];
                    get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                    format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                    animDesired = LookupSequence(id, szAnim);
                    if (animDesired == -1)
                        animDesired = 0;
                        
                    Activity = ACT_WALK;
                }
                else
                {
                    copy(szAnim, 64, "run_");
                    new szAnimExtention[32];
                    get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                    format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                    animDesired = LookupSequence(id, szAnim);
                    if (animDesired == -1)
                    {
                        if(z4e_team_get_user_zombie(id))
                        {
                            if (pev(id, pev_flags) & FL_DUCKING)
                                copy(szAnim, 64, "crouch_aim_");
                            else
                                copy(szAnim, 64, "ref_aim_");
                            new szAnimExtention[32];
                            get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                            format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                            animDesired = LookupSequence(id, szAnim);
                        }
                        else
                            animDesired = LookupSequence(id, "run");
                        
                        if (animDesired == -1)
                            animDesired = 0;
                            
                        Activity = ACT_RUN;
                        set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_RUN));
                    }
                    else
                    {
                        Activity = ACT_RUN;
                        set_pev(id, pev_gaitsequence, animDesired);
                    }
                }
            }
            else
            {
                animDesired = pev(id, pev_sequence);
            }
            
            if(speed <= 135.0)
                set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_WALK));
            else
                set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_RUN));
        }
        case ACT_FLINCH:
        {
            Activity = IdealActivity;
            
            switch (get_pdata_int(id, m_LastHitGroup))
            {
                case HITGROUP_GENERIC:
                {
                    if (random_num(0, 1))
                        animDesired = LookupSequence(id, "gut_flinch");
                    else
                        animDesired = LookupSequence(id, "head_flinch");
                    
                }
                case HITGROUP_HEAD: animDesired = LookupSequence(id, "head_flinch");
                case HITGROUP_CHEST: animDesired = LookupSequence(id, "head_flinch");
                default: animDesired = LookupSequence(id, "gut_flinch");
            }
            
            if (animDesired == -1)
                animDesired = 0;
        }
        case ACT_LARGE_FLINCH:
        {
            Activity = IdealActivity;
            
            switch (get_pdata_int(id, m_LastHitGroup))
            {
                case HITGROUP_GENERIC:
                {
                    if (random_num(0, 1))
                        animDesired = LookupSequence(id, "gut_flinch");
                    else
                        animDesired = LookupSequence(id, "head_flinch");
                    
                }
                case HITGROUP_HEAD: animDesired = LookupSequence(id, "head_flinch");
                case HITGROUP_CHEST: animDesired = LookupSequence(id, "head_flinch");
                default: animDesired = LookupSequence(id, "gut_flinch");
            }
            
            if (animDesired == -1)
                animDesired = 0;
        }
        case ACT_DIESIMPLE:
        {
            if (Activity != IdealActivity)
            {
                Activity = IdealActivity;
                set_pdata_float(id, m_flDeathThrowTime, 0.0)
                set_pdata_int(id, m_iThrowDirection, THROW_NONE)
                
                switch (get_pdata_int(id, m_LastHitGroup))
                {
                    case HITGROUP_GENERIC:
                    {
                        switch(random_num(0,8))
                        {
                            case 0: 
                            {
                                animDesired = LookupActivity(id, ACT_DIE_HEADSHOT)
                                set_pdata_int(id, m_iThrowDirection, THROW_BACKWARD)
                            }
                            case 1: 
                            {
                                animDesired = LookupActivity(id, ACT_DIE_GUTSHOT)
                            }
                            case 2: 
                            {
                                animDesired = LookupActivity(id, ACT_DIE_BACKSHOT)
                                set_pdata_int(id, m_iThrowDirection, THROW_HITVEL)
                            }
                            case 3: 
                            {
                                animDesired = LookupActivity(id, ACT_DIESIMPLE)
                            }
                            case 4: 
                            {
                                animDesired = LookupActivity(id, ACT_DIEBACKWARD)
                                set_pdata_int(id, m_iThrowDirection, THROW_HITVEL)
                            }
                            case 5: 
                            {
                                animDesired = LookupActivity(id, ACT_DIEFORWARD)
                                set_pdata_int(id, m_iThrowDirection, THROW_FORWARD)
                            }
                            case 6: 
                            {
                                animDesired = LookupActivity(id, ACT_DIE_CHESTSHOT)
                            }
                            case 7: 
                            {
                                animDesired = LookupActivity(id, ACT_DIE_GUTSHOT)
                            }
                            case 8: 
                            {
                                animDesired = LookupActivity(id, ACT_DIE_HEADSHOT)
                            }
                            default: 
                            {
                                animDesired = LookupActivity(id, ACT_DIESIMPLE)
                            }
                        }
                    }
                    case HITGROUP_HEAD:
                    {
                        new iRandom = random_num(0,8)
                        set_pdata_bool(id, m_bHeadshotKilled, true)
                        if (get_pdata_bool(id, m_bHighDamage) == true)
                            iRandom++;
                            
                        switch(iRandom)
                        {
                            case 0: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_NONE)
                            }
                            case 1: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_BACKWARD)
                            }
                            case 2: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_BACKWARD)
                            }
                            case 3: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_FORWARD)
                            }
                            case 4: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_FORWARD)
                            }
                            case 5: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_HITVEL)
                            }
                            case 6: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_HITVEL)
                            }
                            case 7: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_NONE)
                            }
                            case 8: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_NONE)
                            }
                            default: 
                            {
                                set_pdata_int(id, m_iThrowDirection, THROW_NONE)
                            }
                        }
                        
                        animDesired = LookupActivity(id, ACT_DIE_HEADSHOT);
                    }
                    case HITGROUP_CHEST: 
                        animDesired = LookupActivity(id, ACT_DIE_CHESTSHOT);
                    case HITGROUP_STOMACH: 
                        animDesired = LookupActivity(id, ACT_DIE_GUTSHOT);
                    case HITGROUP_LEFTARM: 
                        animDesired = LookupSequence(id, "left");
                    case HITGROUP_RIGHTARM: 
                    {
                        set_pdata_int(id, m_iThrowDirection, random_num(0,1) ? THROW_HITVEL : THROW_HITVEL_MINUS_AIRVEL)
                        animDesired = LookupSequence(id, "right");
                    }
                    case HITGROUP_LEFTLEG: 
                        animDesired = LookupActivity(id, ACT_DIESIMPLE);
                    case HITGROUP_RIGHTLEG: 
                        animDesired = LookupActivity(id, ACT_DIESIMPLE);
                }
                
                if (pev(id, pev_flags) & FL_DUCKING)
                {
                    animDesired = LookupSequence(id, "crouch_die");
                    set_pdata_int(id, m_iThrowDirection, THROW_BACKWARD)
                }
                else
                {
                    if(get_pdata_bool(id, m_bKilledByBomb) == true || get_pdata_bool(id, m_bKilledByGrenade) == true)
                    {
                        new Float:vecVAngle[3]
                        pev(id, pev_v_angle, vecVAngle)
                        engfunc(EngFunc_MakeVectors, vecVAngle)
                        new Float:vecForward[3]
                        global_get(glb_v_forward, vecForward)
                        new Float:vecBlastVector[3]
                        vecBlastVector[0] = get_pdata_float(id, m_vBlastVector[0])
                        vecBlastVector[1] = get_pdata_float(id, m_vBlastVector[1])
                        vecBlastVector[2] = get_pdata_float(id, m_vBlastVector[2])
                        
                        if (xs_vec_dot(vecForward, vecBlastVector) > 0.0)
                        {
                            animDesired = LookupSequence(id, "left");
                        }
                        else if(random_num(0, 1))
                        {
                            animDesired = LookupSequence(id, "crouch_die");
                        }
                        else
                        {
                            animDesired = LookupActivity(id, ACT_DIE_HEADSHOT);
                        }
                        
                        if(get_pdata_bool(id, m_bKilledByBomb) == true)
                            set_pdata_int(id, m_iThrowDirection, THROW_BOMB)
                        else if(get_pdata_bool(id, m_bKilledByGrenade) == true)
                            set_pdata_int(id, m_iThrowDirection, THROW_GRENADE)
                    }
                }
                
                if (animDesired == -1)
                    animDesired = 0;
                if (pev(id, pev_sequence) != animDesired)
                {
                    set_pev(id, pev_gaitsequence, 0)
                    set_pev(id, pev_sequence, animDesired)
                    set_pev(id, pev_frame, 0.0)
                    ResetSequenceInfo(id);
                }
            }
            
            set_pdata_int(id, m_Activity, Activity)
            return OrpheuSupercede;
            
        }
        default:
        {
            if (Activity == IdealActivity)
                return OrpheuSupercede;
            Activity = IdealActivity
            if (pev(id, pev_sequence) != animDesired)
            {
                set_pev(id, pev_gaitsequence, 0)
                set_pev(id, pev_sequence, animDesired)
                set_pev(id, pev_frame, 0.0)
                ResetSequenceInfo(id);
            }
            
            set_pdata_int(id, m_Activity, Activity)
            return OrpheuSupercede;
        }
    }
    set_pdata_int(id, m_Activity, Activity)
    
    if(pev(id, pev_gaitsequence) != hopSeq && pev(id, pev_gaitsequence) != leapSeq)
    {
        if (pev(id, pev_flags) & FL_DUCKING)
        {
            if(speed)
            {
                set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_CROUCH))
            }
            else
            {
                set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_CROUCHIDLE))
            }
        }
        else if(speed > 135.0)
        {
            if (get_gametime() > get_pdata_float(id, m_flLastFired) + 2.0 && get_gametime() > RecordTiime[id] + PlayTime[id])
            {
                if (Activity != ACT_FLINCH && Activity != ACT_LARGE_FLINCH)
                {
                    copy(szAnim, 64, "run_")
                    new szAnimExtention[32];
                    get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                    format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                    animDesired = LookupSequence(id, szAnim);
                    
                    if (animDesired == -1)
                    {
                        if(z4e_team_get_user_zombie(id))
                        {
                            if (pev(id, pev_flags) & FL_DUCKING)
                                copy(szAnim, 64, "crouch_aim_");
                            else
                                copy(szAnim, 64, "ref_aim_");
                            new szAnimExtention[32];
                            get_pdata_string(id, m_szAnimExtention * 4, szAnimExtention, charsmax(szAnimExtention), false , 20);
                            format(szAnim, 64, "%s%s", szAnim, szAnimExtention);
                            animDesired = LookupSequence(id, szAnim);
                        }
                        else
                        {
                            animDesired = LookupSequence(id, "run");
                        }
                    }
                    else
                    {
                        set_pev(id, pev_gaitsequence, animDesired);
                    }
                    Activity = ACT_RUN;
                    set_pdata_int(id, m_Activity, Activity);
                }
            }
            set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_RUN))
        }
        else if(speed > 0.0)
        {
            set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_WALK))
        }
        else
        {
            set_pev(id, pev_gaitsequence, LookupActivity(id, ACT_IDLE))
        }
    }
    
    if(pev(id, pev_sequence)  == animDesired)
        return OrpheuSupercede
    set_pev(id, pev_sequence, animDesired)
    set_pev(id, pev_frame, 0.0)
    ResetSequenceInfo(id);
    
    return OrpheuSupercede;
}

public DeathSound(id)
{
    switch (random_num(1, 4))
    {
        case 1: emit_sound(id, CHAN_VOICE, "player/die1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
        case 2: emit_sound(id, CHAN_VOICE, "player/die2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
        case 3: emit_sound(id, CHAN_VOICE, "player/die3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
        case 4: emit_sound(id, CHAN_VOICE, "player/death6.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    }
}

stock LookupSequence(id, const szSequence[])
{
    return lookup_sequence(id, szSequence)
}

stock LookupActivity(id, iACT)
{
    static OrpheuFunction:pfnLookupActivity
    if(!pfnLookupActivity)
        pfnLookupActivity = OrpheuGetFunction("LookupActivity", "CBaseAnimating")
    return OrpheuCall(pfnLookupActivity, id, iACT);
}

stock ResetSequenceInfo(id)
{
    static OrpheuFunction:pfnResetSequenceInfo
    if(!pfnResetSequenceInfo)
    pfnResetSequenceInfo = OrpheuGetFunction("ResetSequenceInfo", "CBaseAnimating")
    return OrpheuCall(pfnResetSequenceInfo, id);
}