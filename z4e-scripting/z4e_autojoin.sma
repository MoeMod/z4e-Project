#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include <z4e_bits>
#include <z4e_mainmenu>
#include <z4e_team>
#include <z4e_gameplay>

#define PLUGIN "[Z4E] Auto Join"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TEAM_SELECT_VGUI_MENU_ID 2

new g_iAutoJoin[33]
new g_iMenuItem

new g_MsgShowMenu, g_MsgVGUIMenu

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	OrpheuRegisterHook(OrpheuGetFunction("TeamFull", "CHalfLifeMultiplay"), "OnTeamFull");
	
	g_MsgShowMenu = get_user_msgid("ShowMenu")
	g_MsgVGUIMenu = get_user_msgid("VGUIMenu")
	
	register_message(g_MsgShowMenu, "Message_ShowMenu")
	register_message(g_MsgVGUIMenu, "Message_VGUIMenu")
	
	g_iMenuItem = z4e_mainmenu_item_register("成为观察者")
}

public OrpheuHookReturn:OnTeamFull(this, team_id)
{
	OrpheuSetReturn(false);
	return OrpheuSupercede;
}

public z4e_fw_mainmenu_select_pre(id, iItem)
{
	if(iItem != g_iMenuItem)
		return Z4E_MAINMENU_IGNORED
	if(BitsGet(z4e_gameplay_bits_get_status(), Z4E_GAMESTATUS_INFECTIONSTART))
		return Z4E_MAINMENU_FORBIDDEN
	return Z4E_MAINMENU_IGNORED
}

public z4e_fw_mainmenu_select_post(id, iItem)
{
	if(iItem != g_iMenuItem)
		return Z4E_MAINMENU_IGNORED
	
	if(z4e_team_get(id) == Z4E_TEAM_SPECTATOR)
	{
		z4e_team_set(id, Z4E_TEAM_HUMAN)
	}
	else
	{
		if(is_user_alive(id))
			dllfunc(DLLFunc_ClientKill, id)
		z4e_team_set(id, Z4E_TEAM_SPECTATOR)
	}
	
	return Z4E_MAINMENU_IGNORED
}

public Message_ShowMenu(msg_id, msg_dest, id)
{
	static szBuffer[24]
	get_msg_arg_string(4, szBuffer, charsmax(szBuffer))
	
	if(!strcmp(szBuffer, "#Team_Select") || !strcmp(szBuffer, "#Team_Select_Spect") || !strcmp(szBuffer, "#IG_Team_Select") || !strcmp(szBuffer, "#IG_Team_Select_Spect"))
	{
		g_iAutoJoin[id] = 2
		return PLUGIN_HANDLED
	}
	
	if(!strcmp(szBuffer, "#Terrorist_Select") || !strcmp(szBuffer, "#CT_Select"))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public Message_VGUIMenu(msg_id, msg_dest, id)
{
	static szBuffer[24]
	get_msg_arg_string(4, szBuffer, charsmax(szBuffer))
	
	if(get_msg_arg_int(1) == TEAM_SELECT_VGUI_MENU_ID)
	{
		g_iAutoJoin[id] = 2
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public fw_PlayerPreThink(id)
{
	if(!g_iAutoJoin[id])
		return FMRES_IGNORED
	
	if(g_iAutoJoin[id] == 2) 
	{
		force_team_join(id, "5", "")
	}
	else
	{
		force_team_join(id, "5", "5")
	}

	g_iAutoJoin[id] --
	return FMRES_IGNORED
}

stock force_team_join(id, const team[] = "5", const class[] = "0") 
{
	if (class[0] == '0') {
		engclient_cmd(id, "jointeam", team)
		return
	}

	new iBlockShowMenu = get_msg_block(g_MsgShowMenu)
	new iBlockVGUIMenu = get_msg_block(g_MsgVGUIMenu)
	set_msg_block(g_MsgShowMenu, BLOCK_SET)
	set_msg_block(g_MsgVGUIMenu, BLOCK_SET)
	if(team[0])
		engclient_cmd(id, "jointeam", team)
	if(class[0])
		engclient_cmd(id, "joinclass", class)
	set_msg_block(g_MsgShowMenu, iBlockShowMenu)
	set_msg_block(g_MsgVGUIMenu, iBlockVGUIMenu)
}