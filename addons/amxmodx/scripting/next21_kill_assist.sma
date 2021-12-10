#include <amxmodx>
#include <reapi>
#tryinclude <aes_v>

#define CONFIG_FILE					"adv_kill_assist.cfg"

#define NAMES_LENGTH				28
#define is_user_valid(%0)			(0 < %0 && %0 < g_iMaxPlayers)

#if AMXX_VERSION_NUM < 183
	#define client_disconnected client_disconnect
#endif

#if REAPI_VERSION < 52121
	#error This plugin supports ReAPI >=5.2.0.121
#endif

//#define DEBUG

enum
{
	ALGORITHM_CSSTATSX,
	ALGORITHM_ADVANCED
}

enum _:CVARS_DATA
{
	CVAR_FRAG,
	CVAR_MONEY,
	CVAR_EXP,
	CVAR_DAMAGE,
	CVAR_ALGORITHM
}

enum _:PLAYER_DATA
{
	DAMAGE_ON[33],
	Float:DAMAGE_ON_TIME[33],
	NAME[32]
}
new g_ePlayerData[33][PLAYER_DATA], g_pCvars[CVARS_DATA], g_iMaxPlayers, g_iMsgScoreInfo
new HookChain:g_pSV_WriteFullClientUpdate, HookChain:g_pCBasePlayer_Killed_Post, g_szDeathString[32], g_iAssistKiller
new g_pCvarAssistHp

public plugin_natives()
{
	set_native_filter("plugin_native_filter")
}

public plugin_native_filter(szNative[], iIndex, bool:bTrap)
{
	return PLUGIN_HANDLED
}

public plugin_init()
{
	register_plugin("Advanced Kill Assists", "1.3d", "Xelson")

	RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", true)
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Pre", false)
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "CBasePlayer_TakeDamage_Pre", false)
	DisableHookChain((g_pCBasePlayer_Killed_Post = RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true)))
	DisableHookChain((g_pSV_WriteFullClientUpdate = RegisterHookChain(RH_SV_WriteFullClientUpdate, "SV_WriteFullClientUpdate", false)))
	register_message(get_user_msgid("DeathMsg"), "Message_DeathMsg")

	#if defined DEBUG
		register_clcmd("assist", "ClCmd_Assist")
	#endif

	register_dictionary("next21_kill_assist.txt")

	g_pCvarAssistHp = get_cvar_pointer("csstats_sql_assisthp")
	g_iMsgScoreInfo = get_user_msgid("ScoreInfo")
	g_iMaxPlayers = get_maxplayers() + 1
}

public plugin_cfg()
{
	g_pCvars[CVAR_FRAG] = register_cvar("aka_frag", "1")
	g_pCvars[CVAR_MONEY] = register_cvar("aka_money", "100")
	g_pCvars[CVAR_EXP] = register_cvar("aka_exp", "0")
	g_pCvars[CVAR_DAMAGE] = register_cvar("aka_damage", "30.0")
	g_pCvars[CVAR_ALGORITHM] = register_cvar("aka_algorithm", "1")

	new szConfigFile[256]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	formatex(szConfigFile, charsmax(szConfigFile), "%s/%s", szConfigFile, CONFIG_FILE)
	server_cmd("exec ^"%s^"", szConfigFile)
}

public client_infochanged(id)
{
	get_user_info(id, "name", g_ePlayerData[id][NAME], charsmax(g_ePlayerData[][NAME]))
}

public client_disconnected(id)
{
	arrayset(g_ePlayerData[id][DAMAGE_ON], 0, sizeof g_ePlayerData[][DAMAGE_ON])
	for(new i = 1; i < g_iMaxPlayers; i++) g_ePlayerData[i][DAMAGE_ON][id] = 0
}

public CBasePlayer_Spawn_Post(id)
{
	arrayset(g_ePlayerData[id][DAMAGE_ON], 0, sizeof g_ePlayerData[][DAMAGE_ON])
	for(new i = 1; i < g_iMaxPlayers; i++) g_ePlayerData[i][DAMAGE_ON][id] = 0
}

public CBasePlayer_TakeDamage_Pre(iVictim, iWeapon, iAttacker, Float:fDamage)
{
	if(is_user_valid(iAttacker) && iVictim != iAttacker && rg_is_player_can_takedamage(iVictim, iAttacker))
	{
		if(get_pcvar_num(g_pCvars[CVAR_ALGORITHM]) == ALGORITHM_ADVANCED)
		{
			new Float:fHealth; get_entvar(iVictim, var_health, fHealth)
			if(fDamage > fHealth) fDamage = fHealth
		}
		g_ePlayerData[iAttacker][DAMAGE_ON][iVictim] += floatround(fDamage)
		g_ePlayerData[iAttacker][DAMAGE_ON_TIME][iVictim] = get_gametime()
	}
}

public CBasePlayer_Killed_Pre(iVictim, iKiller)
{
	new iAssistant, iMaxDamage
	new Float:fDamageForAssist = get_pcvar_float(g_pCvars[CVAR_DAMAGE])

	switch(get_pcvar_num(g_pCvars[CVAR_ALGORITHM]))
	{
		case ALGORITHM_ADVANCED:
		{
			new iTotalDamage
			for(new id = 1; id < g_iMaxPlayers; id++)
			{
				if(is_user_connected(id))
				{
					if(id != iKiller && g_ePlayerData[id][DAMAGE_ON][iVictim] > 0)
					{
						if(g_ePlayerData[id][DAMAGE_ON][iVictim] > iMaxDamage)
						{
							iAssistant = id
							iMaxDamage = g_ePlayerData[id][DAMAGE_ON][iVictim]
						}
						else if(g_ePlayerData[id][DAMAGE_ON][iVictim] == iMaxDamage) 
							iAssistant = g_ePlayerData[id][DAMAGE_ON_TIME][iVictim] > g_ePlayerData[iAssistant][DAMAGE_ON_TIME][iVictim] ? id : iAssistant
					}
					iTotalDamage += g_ePlayerData[id][DAMAGE_ON][iVictim]
				}
			}
			if((float(iMaxDamage) / float(iTotalDamage)) * 100.0 < fDamageForAssist) iAssistant = 0
		}
		case ALGORITHM_CSSTATSX:
		{
			new iNeedDamage = g_pCvarAssistHp ? get_pcvar_num(g_pCvarAssistHp) : floatround(fDamageForAssist)
			for(new id = 1; id < g_iMaxPlayers; id++)
			{
				if(is_user_connected(id) && id != iKiller && g_ePlayerData[id][DAMAGE_ON][iVictim] > iMaxDamage)
				{
					if(g_ePlayerData[id][DAMAGE_ON][iVictim] > iNeedDamage)
					{
						iAssistant = id
						iMaxDamage = g_ePlayerData[id][DAMAGE_ON][iVictim]
					}
					else if(g_ePlayerData[id][DAMAGE_ON][iVictim] == iNeedDamage)
						iAssistant = g_ePlayerData[id][DAMAGE_ON_TIME][iVictim] > g_ePlayerData[iAssistant][DAMAGE_ON_TIME][iVictim] ? id : iAssistant
				}
			}
		}
	}

	if(!iAssistant || iKiller == iVictim) return HC_CONTINUE

	new szName[2][32], iLen[2], iExcess
	copy(szName[1], charsmax(szName[]), g_ePlayerData[iAssistant][NAME])
	iLen[1] = strlen(szName[1])

	EnableHookChain(g_pSV_WriteFullClientUpdate)
	
	static const szWorldName[] = "world"
	new bool:bIsAssistantConnected = bool:is_user_connected(iAssistant)

	if(!is_user_valid(iKiller))
	{
		if(bIsAssistantConnected)
		{
			iExcess = iLen[1] - NAMES_LENGTH - (sizeof szWorldName)
			if(iExcess > 0) strclip(szName[1], iExcess)
			formatex(g_szDeathString, charsmax(g_szDeathString), "%s + %s", szWorldName, szName[1])

			g_iAssistKiller = iAssistant
			rh_update_user_info(iAssistant)
		}
	}
	else if(is_user_connected(iKiller))
	{
		g_ePlayerData[iKiller][DAMAGE_ON][iVictim] = 0
		
		copy(szName[0], charsmax(szName[]), g_ePlayerData[iKiller][NAME])
		iLen[0] = strlen(szName[0])

		new iLenSum = (iLen[0] + iLen[1])
		iExcess = iLenSum - NAMES_LENGTH

		if(iExcess > 0)
		{
			new iLongest = iLen[0] > iLen[1] ? 0 : 1
			new iShortest = iLongest == 1 ? 0 : 1

			if(float(iExcess) / float(iLen[iLongest]) > 0.60)
			{
				new iNewLongest = floatround(float(iLen[iLongest]) / float(iLenSum) * float(iExcess))
				strclip(szName[iLongest], iNewLongest)
				strclip(szName[iShortest], iExcess - iNewLongest)
			}
			else strclip(szName[iLongest], iExcess)
		}
		formatex(g_szDeathString, charsmax(g_szDeathString), "%s + %s", szName[0], szName[1])

		g_iAssistKiller = iKiller
		rh_update_user_info(g_iAssistKiller)
	}
	if(bIsAssistantConnected)
	{   
		g_ePlayerData[iAssistant][DAMAGE_ON][iVictim] = 0

		new iAddMoney = get_pcvar_num(g_pCvars[CVAR_MONEY])
		new iAddExp = get_pcvar_num(g_pCvars[CVAR_EXP])

		if(iAddMoney > 0 || iAddExp > 0) 
		{
			if(iAddMoney > 0) rg_add_account(iAssistant, iAddMoney)
			#if defined aes_add_player_exp_f
				if(iAddExp > 0) aes_add_player_exp_f(iAssistant, float(iAddExp))
			#endif

			new szMessage[192], szMoney[16], szExp[16], szKillerName[32]
			formatex(szMessage, charsmax(szMessage), "%L", iAssistant, "AKA_MESSAGE")
			if(szMessage[0])
			{
				num_to_str(iAddMoney, szMoney, charsmax(szMoney))
				num_to_str(iAddExp, szExp, charsmax(szExp))
				if(is_user_valid(iKiller)) copy(szKillerName, charsmax(szKillerName), g_ePlayerData[iKiller][NAME])

				replace_all(szMessage, charsmax(szMessage), "[award]", szMoney)
				replace_all(szMessage, charsmax(szMessage), "[exp]", szExp)
				replace_all(szMessage, charsmax(szMessage), "[killer]", szKillerName)
				replace_all(szMessage, charsmax(szMessage), "[victim]", g_ePlayerData[iVictim][NAME])

				UTIL_SayText(iAssistant, szMessage)
			}
		}

		if(get_pcvar_num(g_pCvars[CVAR_FRAG]))
		{
			new Float:fNewFrags; get_entvar(iAssistant, var_frags, fNewFrags)
			fNewFrags++
			set_entvar(iAssistant, var_frags, fNewFrags)

			message_begin(MSG_ALL, g_iMsgScoreInfo)
			write_byte(iAssistant)
			write_short(floatround(fNewFrags))
			write_short(get_member(iAssistant, m_iDeaths))
			write_short(0)
			write_short(get_member(iAssistant, m_iTeam))
			message_end()
		}
	}
	
	DisableHookChain(g_pSV_WriteFullClientUpdate)
	if(g_iAssistKiller) EnableHookChain(g_pCBasePlayer_Killed_Post)

	return HC_CONTINUE
}

public SV_WriteFullClientUpdate(id, pBuffer)
{
	if(id == g_iAssistKiller)
		set_key_value(pBuffer, "name", g_szDeathString)
}

public Message_DeathMsg()
{
	new iWorld = get_msg_arg_int(1)
	if(iWorld == 0 && g_iAssistKiller)
		set_msg_arg_int(1, ARG_BYTE, g_iAssistKiller)
}

public CBasePlayer_Killed_Post(iVictim, iKiller)
{
	DisableHookChain(g_pCBasePlayer_Killed_Post)

	new iAssistKiller = g_iAssistKiller; g_iAssistKiller = 0
	rh_update_user_info(iAssistKiller)
}

strclip(szString[], iClip, szEnding[] = "..")
{
	new iLen = strlen(szString) - 1 - strlen(szEnding) - iClip
	format(szString[iLen], iLen, szEnding)
}

UTIL_SayText(id, const szMessage[], any:...)
{
	new szBuffer[190];
	static iMsgSayText
	if(!iMsgSayText) iMsgSayText = get_user_msgid("SayText")
	if(numargs() > 2) vformat(szBuffer, charsmax(szBuffer), szMessage, 3);
	else copy(szBuffer, charsmax(szBuffer), szMessage);
	while(replace(szBuffer, charsmax(szBuffer), "!y", "^1")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!t", "^3")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!g", "^4")) {}
	switch(id)
	{
		case 0:
		{
			for(new i = 1; i < g_iMaxPlayers; i++)
			{
				if(!is_user_connected(i)) continue
				message_begin(MSG_ONE_UNRELIABLE, iMsgSayText, .player = i)
				write_byte(i);
				write_string(szBuffer);
				message_end();
			}
		}
		default:
		{
			message_begin(MSG_ONE_UNRELIABLE, iMsgSayText, .player = id)
			write_byte(id);
			write_string(szBuffer);
			message_end();
		}
	}
	return 0
}

#if defined DEBUG
#include <hamsandwich>
public ClCmd_Assist()
{
	new id[4], szArg[64]
	for(new i; i < 4; i++)
	{
		read_argv(i + 1, szArg, charsmax(szArg))
		id[i] = str_to_num(szArg)
	}
	g_ePlayerData[id[1]][DAMAGE_ON][id[2]] = id[3] ? id[3] : 100
	ExecuteHamB(Ham_Killed, id[2], id[0], 0)
	ExecuteHamB(Ham_CS_RoundRespawn, id[2])
}
#endif