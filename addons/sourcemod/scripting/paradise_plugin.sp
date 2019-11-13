#include <sourcemod>
#include <emitsoundany>
#include <sdktools>	
#include <sdkhooks>
#include <cstrike>
#include <entity>
#include <smlib>
#include <dhooks>
//#include <sourcecomms>
#include <paradise-stocks>
#include <botmimic>

#undef REQUIRE_PLUGIN
#include <sourcebans>
#define REQUIRE_PLUGIN

#include "paradise/map.sp"
#include "paradise/vip.sp"
#include "paradise/zones.sp"
#include "paradise/mysql.sp"
#include "paradise/eve.sp"
#include "paradise/menu.sp"
#include "paradise/commands.sp"
#include "paradise/styles.sp"
#include "paradise/security.sp"
#include "paradise/bash.sp"
#include "paradise/settings.sp"

#pragma semicolon 1

enum TimerEnum
{
	Enabled,
	Float:StartTime,
	Float:EndTime,
	String:MapTime[64],
	bool:Bonus
}

new g_timers[MAXPLAYERS+1][TimerEnum];

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | <3",
    author = "Aexi0n",
    description = "Official Bhop Plugin for Paradise Servers",
    version = "5.0",
	url = ""
}

//-------------------
// Plugin Loading.. |
//-------------------
public OnPluginStart()
{
	AddCommandListener(HookPlayerChat, "say");
	AddCommandListener(HookPlayerChat, "say_team");
	AddCommandListener(Command_JoinTeam, "jointeam");
	
	LoadTranslations("common.phrases.txt");
	
	gh_AutoBhop = FindConVar("sv_autobunnyhopping");
	SetConVarBool(gh_AutoBhop, false);
	
	HookEvent("player_spawn", event_PlayerSpawn);
	HookEvent("player_jump", event_PlayerJump);
	HookEvent("player_death", event_PlayerDeath);
	HookEvent("cs_win_panel_match", event_MapEnd, EventHookMode_Pre);
	HookEvent("player_disconnect", event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_start", SetAllTalk, EventHookMode_Pre);
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	
	RegConsoleCmd("sm_style", sm_style, "Style Menu");
	RegConsoleCmd("sm_mapinfo", sm_mapinfo, "View Map Info");
	RegConsoleCmd("sm_minfo", sm_mapinfo, "View Map Info");
	RegConsoleCmd("sm_commands", sm_commands, "Command Overview Menu");
	RegConsoleCmd("sm_help", sm_commands, "Command Overview Menu");
	RegConsoleCmd("sm_profile", sm_profile, "sm_profile | sm_profile <PlayerName> - View Player Profile");
	RegConsoleCmd("sm_me", sm_profile, "sm_profile - View Player Profile");
	RegConsoleCmd("sm_wr", sm_wr, "World Records Menu");
	RegConsoleCmd("sm_worldrecord", sm_wr, "World Records Menu");
	RegConsoleCmd("sm_leaderboard", sm_leaderboard, "Paradise Leaderboard");
	RegConsoleCmd("sm_ranks", sm_leaderboard, "Paradise Leaderboard");
	RegConsoleCmd("sm_maptop", sm_maptop, "sm_maptop | sm_maptop <mapname> - View Top Records On Map");
	RegConsoleCmd("sm_mtop", sm_maptop, "sm_maptop | sm_maptop <mapname> - View Top Records On Map");
	RegConsoleCmd("sm_top", sm_top, "Style Rankings");
	RegConsoleCmd("sm_autotop", sm_autotop, "Auto Rankings");
	RegConsoleCmd("sm_topauto", sm_autotop, "Auto Rankings");
	RegConsoleCmd("sm_legittop", sm_legittop, "Legit Rankings");
	RegConsoleCmd("sm_toplegit", sm_legittop, "Legit Rankings");
	RegConsoleCmd("sm_freestyletop", sm_freestyletop, "Freestyle Rankings");
	RegConsoleCmd("sm_topfreestyle", sm_freestyletop, "Freestyle Rankings");
	RegConsoleCmd("sm_parkourtop", sm_parkourtop, "Parkour Rankings");
	RegConsoleCmd("sm_topparkour", sm_parkourtop, "Parkour Rankings");
	RegConsoleCmd("sm_halfsidewaystop", sm_halfsidewaystop, "Half-Sideways Rankings");
	RegConsoleCmd("sm_tophalfsideways", sm_halfsidewaystop, "Half-Sideways Rankings");
	RegConsoleCmd("sm_hswtop", sm_halfsidewaystop, "Half-Sideways Rankings");
	RegConsoleCmd("sm_tophsw", sm_halfsidewaystop, "Half-Sideways Rankings");
	RegConsoleCmd("sm_sidewaystop", sm_sidewaystop, "Sideways Rankings");
	RegConsoleCmd("sm_topsideways", sm_sidewaystop, "Sideways Rankings");
	RegConsoleCmd("sm_swtop", sm_sidewaystop, "Sideways Rankings");
	RegConsoleCmd("sm_topsw", sm_sidewaystop, "Sideways Rankings");
	RegConsoleCmd("sm_wonlytop", sm_wonlytop, "W-Only Rankings");
	RegConsoleCmd("sm_topwonly", sm_wonlytop, "W-Only Rankings");
	RegConsoleCmd("sm_autowr", sm_autowr, "Auto World Record on Current Map");
	RegConsoleCmd("sm_legitwr", sm_legitwr, "Legit World Record on Current Map");
	RegConsoleCmd("sm_freestylewr", sm_freestylewr, "Freestyle World Record on Current Map");
	RegConsoleCmd("sm_parkourwr", sm_parkourwr, "Parkour World Record on Current Map");
	RegConsoleCmd("sm_hswwr", sm_hswwr, "Half-Sideways World Record on Current Map");
	RegConsoleCmd("sm_swwr", sm_swwr, "Sideways World Record on Current Map");
	RegConsoleCmd("sm_wonlywr", sm_wonlywr, "W-Only World Record on Current Map");
	
	RegConsoleCmd("sm_rtv", sm_rtv, "Rock The Vote");
	RegConsoleCmd("sm_nominate", sm_nominate, "Nominate Map For Map Vote");
	RegConsoleCmd("sm_r", sm_r, "Respawn At Start of Map");
	RegConsoleCmd("sm_restart", sm_r, "Respawn At Start of Map");
	RegConsoleCmd("sm_b", sm_b, "Respawn At Start of Bonus");
	RegConsoleCmd("sm_bonus", sm_b, "Respawn At Start of Bonus");
	RegConsoleCmd("sm_auto", sm_auto, "Switch to Auto Style");
	RegConsoleCmd("sm_legit", sm_legit, "Switch to Legit Style");
	RegConsoleCmd("sm_freestyle", sm_freestyle, "Switch to Freestyle Style");
	RegConsoleCmd("sm_parkour", sm_parkour, "Switch to Parkour Style");
	RegConsoleCmd("sm_hsw", sm_hsw, "Switch to Half-Sideways Style");
	RegConsoleCmd("sm_halfsideways", sm_hsw, "Switch to Half-Sideways Style");
	RegConsoleCmd("sm_sideways", sm_sideways, "Switch to Sideways Style");
	RegConsoleCmd("sm_sw", sm_sideways, "Switch to Sideways Style");
	RegConsoleCmd("sm_wonly", sm_wonly, "Switch to W-Only Style");
	
	RegConsoleCmd("sm_spec", sm_spectate, "sm_spec <target> - Spectate a player");
	RegConsoleCmd("sm_spectate", sm_spectate, "sm_spectate <target> - Spectate a player");
	RegConsoleCmd("sm_hideweapons", sm_hideweapons, "Toggle Your Weapon Visibility");
	RegConsoleCmd("sm_hideknife", sm_hideweapons, "Toggle Your Weapon Visibility");
	RegConsoleCmd("sm_usp", sm_usp, "Give Player USP");
	RegConsoleCmd("sm_glock", sm_glock, "Give Player Glock");
	
	RegConsoleCmd("sm_vip", sm_vip, "Access VIP Menu");
	RegConsoleCmd("sm_models", sm_models, "Access VIP Model Menu");
	
	RegConsoleCmd("sm_eve", sm_eve, "EVE Bunnyhop Companion Menu");
	RegConsoleCmd("sm_playauto", sm_playauto, "EVE Plays Auto WR Run");
	RegConsoleCmd("sm_playlegit", sm_playlegit, "EVE Plays Legit WR Run");
	RegConsoleCmd("sm_playfreestyle", sm_playfreestyle, "EVE Freestyle Auto WR Run");
	RegConsoleCmd("sm_playparkour", sm_playparkour, "EVE Plays Parkour WR Run");
	RegConsoleCmd("sm_playhsw", sm_playhsw, "EVE Plays Half-Sideways WR Run");
	RegConsoleCmd("sm_playsw", sm_playsw, "EVE Plays Sideways WR Run");
	RegConsoleCmd("sm_playwonly", sm_playwonly, "EVE Plays W-Only WR Run");
	
	RegAdminCmd("sm_setlevel", SetLevel, ADMFLAG_ROOT, "Change players in-game level");
	RegAdminCmd("sm_givexp", sm_givexp, ADMFLAG_ROOT, "Give Player XP");
	RegAdminCmd("sm_zones", sm_zones, ADMFLAG_CHAT, "Paradise Zone Editor");
	RegAdminCmd("sm_addmap", sm_addmap, ADMFLAG_CHAT, "Add Map To Database");
	RegAdminCmd("sm_deletemap", sm_deletemap, ADMFLAG_CHAT, "Remove Map From Database");
	RegAdminCmd("sm_addvip", sm_addvip, ADMFLAG_ROOT, "Give Player Donator Status");
	
	RegAdminCmd("sm_querycount", sm_querycount, ADMFLAG_ROOT, "Show # of MySQL Queries Ran This Round");
	RegAdminCmd("sm_calcscore", sm_calcscore, ADMFLAG_ROOT, "Calculate Score of STEAM ID");
	RegAdminCmd("bash2_stats", Bash_Stats, ADMFLAG_ROOT, "Check a player's strafe stats");
	
	RegAdminCmd("sm_sh", sm_sh, ADMFLAG_ROOT, "Check a player's strafe stats");
		
	//RegAdminCmd("sm_celebrate", sm_celebrate, ADMFLAG_RCON, "Celebrate Current Event!");
	
	//HUD Timers
	CreateTimer(0.1, HUD, _, TIMER_REPEAT);
	
	//Style Timers
	StyleTimers();
	
	//Activate Security
	LoadSecurity();
	
	CreateDB(db);
	
	//Assign MapChangeTrie Handle
	MapChangeData = CreateTrie();
}

//----------------
// Map Loading.. |
//----------------
public OnMapStart()
{
	for (new i = 1; i <= 27; i++)
	{
		decl String:DownloadSong[128], String:PrecacheSong[128];
		
		Format(DownloadSong, 128, "sound/sourcemod/paradise/wr%d.mp3", i);
		Format(PrecacheSong, 128, "sourcemod/paradise/wr%d.mp3", i);
		
		AddFileToDownloadsTable(DownloadSong);
		PrecacheSoundAny(PrecacheSong);
	}

	QueryCounter = 0;
	
	//Precache Content
	PrecacheModels();
	PrecacheTrails();

	//Set Current Map.
	GetCurrentMap(Map[MapName], sizeof(Map[MapName]));
	
	//Reset WR Cache
	Format(Auto_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Auto_WR[Time] = 0.0;
	
	Format(Legit_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Legit_WR[Time] = 0.0;
	
	Format(Freestyle_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Freestyle_WR[Time] = 0.0;
	
	Format(Parkour_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Parkour_WR[Time] = 0.0;
	
	Format(HalfSideways_WR[PlayerName], MAX_NAME_LENGTH, "None");
	HalfSideways_WR[Time] = 0.0;
	
	Format(Sideways_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Sideways_WR[Time] = 0.0;
	
	Format(WOnly_WR[PlayerName], MAX_NAME_LENGTH, "None");
	WOnly_WR[Time] = 0.0;

	WorldRecordsLoaded = false;
	replayCount = 0;

	if(db != INVALID_HANDLE)
	{
		InitZones();
		MapStarted();
		LoadWorldRecords(Map[MapName]);
		ParadiseSettings();
	}
	else
	{
		CreateTimer(5.0, LateLoad);
	}
	
}

public Action:LateLoad(Handle:timer)
{
	if(db != INVALID_HANDLE)
	{
		InitZones();
		MapStarted();
		LoadWorldRecords(Map[MapName]);
		ParadiseSettings();
	}
	else
	{
		PrintToServer("[Paradise] Error: Cannot Connect To Database!");
	}

	return Plugin_Stop;
}

public OnMapEnd()
{
	SavePreviousMaps();
	
	Format(Map[MapName], 64, "Invalid Map");
	Map[Tier] = 0;
	Format(Map[Stages], 64, "0");
	Map[XPValue] = 0;
}

public Action:event_MapEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	ClearTrie(MapChangeData);
	UpdateCurrentPlayers();
}

//--------------------------------
// Player Connecting To Server.. |
//--------------------------------

public OnClientPutInServer(client)
{
	SS_RefreshClientData(client);
	
	if (IsFakeClient(client))
	{
		CS_SetMVPCount(client, 1);	
		return;
	}
	
	SDKHook(client, SDKHook_WeaponDrop, Hook_WeaponDrop);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public OnClientAuthorized(client)
{
	if(!IsFakeClient(client))
	{
		if(IsValidClient(client, false))
		{
			decl String:name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			
			decl String:steamid[64];
			GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
			
			if(StrEqual(steamid, "STEAM_1:1:86276002", true) || StrEqual(steamid, "STEAM_1:0:48560794", true))
				PrintToChatAll("\x01\x09★ Battle Royale Champion \x01\x04%s \x01\x09has joined the server! ★", name);
			else
				PrintToChatAll("Player \x01\x04%s \x01\x07has joined the server!", name);
		}
	}
}

public OnClientPostAdminCheck(client)
{	
	if(!IsFakeClient(client))
	{
		decl String:steamid[64];
		new TrieIndex = -1;
		
		GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
		
		//Reset Client's Data
		g_info[client][Level] = 0;
		g_info[client][XP] = 0;
		g_info[client][XP_Needed] = 0;
		g_info[client][Score] = 0;
		Format(g_info[client][Status], 15, "INVALID");
		g_info[client][Style] = 0;
		g_timers[client][Bonus] = false;
		ClientDataLoaded[client] = false;
		
		g_oldXP[client] = -1;
		g_oldLevel[client] = -1;
		
		SendConVarValue(client, gh_AutoBhop, "0");
		
		if(GetTrieValue(MapChangeData, steamid, TrieIndex))
		{
			if(TrieIndex >= 0 && IsValidClient(client, false))
			{
				g_info[client][Level] = g_mapchange[TrieIndex][Level]; 
				g_info[client][XP] = g_mapchange[TrieIndex][XP];
				g_info[client][XP_Needed] = g_mapchange[TrieIndex][XP_Needed]; 
				g_info[client][Score] = g_mapchange[TrieIndex][Score];
				strcopy(g_info[client][Status], 15, g_mapchange[TrieIndex][Status]);
				
				g_oldLevel[client] = g_info[client][Level];
				g_oldXP[client] = g_info[client][XP];
				
				ClientDataLoaded[client] = true;
				
				//Debug Messages *Disabled*
				//LogMessage("[ %s]: %N has loaded data from map cache.", Map[MapName], client);
				//LogMessage("[ %s]: Data: %s | Lv. %i | %i/%i XP", Map[MapName], steamid, g_mapchange[TrieIndex][Level], g_mapchange[TrieIndex][XP], g_mapchange[TrieIndex][XP_Needed]);
				
				RemoveFromTrie(MapChangeData, steamid);
			}
		}
		
		if(!ClientDataLoaded[client] && IsValidClient(client, false))
		{
			CreateTimer(3.0, LoadData_Delay, client);
			//LoadPlayerData(client);
		}

		//Reset Client's Records
		ClientRecordsLoaded[client] = false;
		
		g_info[client][Auto] = 0.0;
		g_info[client][Legit] = 0.0;
		g_info[client][Freestyle] = 0.0;
		g_info[client][Parkour] = 0.0;
		g_info[client][HalfSideways] = 0.0;
		g_info[client][Sideways] = 0.0;
		g_info[client][WOnly] = 0.0;
		
		LoadPlayerRecords(client, Map[MapName]);
		
		//Reset Temporary Variables
		g_info[client][Style] = 0;
		
		g_timers[client][Enabled] = false;
		g_timers[client][Bonus] = false;	
		
		IsPlayerInZone[0][client] = false;
		IsPlayerInZone[1][client] = false;
		IsPlayerInZone[2][client] = false;
		IsPlayerInZone[3][client] = false;
		IsPlayerInZone[4][client] = false;
		playerpos[client][0] = 0.0;
		playerpos[client][1] = 0.0;
		playerpos[client][2] = 0.0;
		
		g_bViewModel[client] = true;
		NomStatus[client] = false;
		RTVStatus[client] = false;
		Format(Nomination[client], 255, " ");
		
		TrailEnabled[client] = false;
		Format(g_vip[client][Trail], 100, "");
		PlayerParticle[client] = -1;
		
		SetLevelTag(client);
	}
	else if(IsFakeClient(client))
	{
		LoadEVE(client);
	}
	
	if(StrEqual(g_info[client][Status], "INVALID", true))
	{
		//Reset VIP Cache
		Format(g_vip[client][Model], 100, "");
		VIP_Player[client] = false;
		
		//VIP Player Check
		if(CheckCommandAccess(client, "sm_flag", ADMFLAG_GENERIC, true))
		{
			LoadVIPSettings(client);
			Format(g_info[client][Status], 15, "ADMIN");
			VIP_Player[client] = true;
		}
		else if(CheckCommandAccess(client, "sm_flag", ADMFLAG_CUSTOM2, true))
		{
			Format(g_info[client][Status], 15, "VIP");
			//LoadVIPSettings(client);
			VIP_Player[client] = true;
		}
		else
		{
			Format(g_info[client][Status], 15, "MEMBER");
			VIP_Player[client] = false;
		}
	}
}
public Action:LoadData_Delay(Handle:timer, any:client)
{
	if(IsValidClient(client, false))
	{
		LoadPlayerData(client);
		
		//Debug Message *Disabled*
		//LogMessage("[ %s]: %N Connection Successful - Loading Player Data From DB", Map[MapName], client);
	}
	else
	{
		//Debug Message *Disabled*
		//LogMessage("[ %s]: %N Connection Failed - Load Player Data Aborted", Map[MapName], client);
	}
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	// Reset Parkour Cache
	g_LastSideMove[client][0]   = 0.0;
	g_LastSideMove[client][0]   = 0.0;
	g_LastDodgeTick[client]     = 0;
	g_LandingTick[client]       = 0;
	g_LastTapTick[client]       = 0;
	g_LastTapKey[client]        = 0;
	g_WallJumpCount[client]		= 0;
	g_bCanDodge[client]         = false;
	g_bWaitingForGround[client] = false;
	g_Jumped[client]            = false;
	g_LastButtons[client]       = 0;
	
	
	//Reset Client Security Cache
	p_time_lasthardfld[client] = 0.0;
	p_cmdcnt_hard[client] = 0;
	p_hard_banned[client] = false;
	
	return true;
}


//-------------------------------------
// Player Disconnecting From Server.. |
//-------------------------------------

public OnClientDisconnect(client)
{
	//Reset Client's Records
	g_info[client][Auto] = 0.0;
	g_info[client][Legit] = 0.0;
	g_info[client][Freestyle] = 0.0;
	g_info[client][Parkour] = 0.0;
	g_info[client][HalfSideways] = 0.0;
	g_info[client][Sideways] = 0.0;
	g_info[client][WOnly] = 0.0;
	
	//Reset Client's Timer
	g_timers[client][Enabled] = false;
	g_timers[client][Bonus] = false;
	
	//Reset Client Zone Positions
	IsPlayerInZone[0][client] = false;
	IsPlayerInZone[1][client] = false;
	IsPlayerInZone[2][client] = false;
	IsPlayerInZone[3][client] = false;
	IsPlayerInZone[4][client] = false;
	playerpos[client][0] = 0.0;
	playerpos[client][1] = 0.0;
	playerpos[client][2] = 0.0;
	
	//Reset VIP Cache
	Format(g_vip[client][Model], 100, "");
	VIP_Player[client] = false;
	DisableTrail(client);
	TrailEnabled[client] = false;
	Format(g_vip[client][Trail], 100, "");
	PlayerParticle[client] = -1;
	
	//Reset Client Security Cache
	aiJumps[client] = 0;
	afAvgJumps[client] = 5.0;
	afAvgSpeed[client] = 250.0;
	afAvgPerfJumps[client] = 0.3333;
	aiPattern[client] = 0;
	aiPatternhits[client] = 0;
	aiAutojumps[client] = 0;
	aiIgnoreCount[client] = 0;
	bBanFlagged[client] = false;
	avVEL[client][2] = 0.0;
	new i;
	while (i < 30)
	{
		aaiLastJumps[client][i] = 0;
		i++;
	}
	
	//Reset Hide Players Setting
	g_bViewModel[client] = true;
	
	if(NomStatus[client])
	{
		for(new j = 0; j < NomCount; j++)
		{
			if(StrEqual(Nomination[client], Nominated[j], true))
			{
				NomCount--;
				Format(Nominated[j], 255, "_");
				Format(Nomination[client], 255, " ");
				
				break;
			}
		}
	}
	
	RTVStatus[client] = false;
	NomStatus[client] = false;
	Format(Nomination[client], 255, " ");
	
	//Unload Client's Data Flags
	ClientDataLoaded[client] = false;
	ClientRecordsLoaded[client] = false;
}

public Action:event_PlayerDisconnect(Handle:event, const String:name[], bool:dont_broadcast) 
{
	decl String:steamid[64];
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidClient(client, false) && !IsFakeClient(client) && ClientDataLoaded[client])
	{
		//Debug Message *Disabled*
		//LogMessage("[ %s]: %N has disconnected from server. Saving Player Data.", Map[MapName], client);
		
		GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
		
		UpdatePlayer(client);
		CalculateScore(steamid);
		
		RemoveFromTrie(MapChangeData, steamid);
	}
	
	g_oldXP[client] = -1;
	g_oldLevel[client] = -1;
	
	//Reset Client's Records
	g_info[client][Auto] = 0.0;
	g_info[client][Legit] = 0.0;
	g_info[client][Freestyle] = 0.0;
	g_info[client][Parkour] = 0.0;
	g_info[client][HalfSideways] = 0.0;
	g_info[client][Sideways] = 0.0;
	g_info[client][WOnly] = 0.0;
	
	//Reset Client's Timer
	g_timers[client][Enabled] = false;
	g_timers[client][Bonus] = false;
	
	//Reset Client Zone Positions
	IsPlayerInZone[0][client] = false;
	IsPlayerInZone[1][client] = false;
	IsPlayerInZone[2][client] = false;
	IsPlayerInZone[3][client] = false;
	IsPlayerInZone[4][client] = false;
	playerpos[client][0] = 0.0;
	playerpos[client][1] = 0.0;
	playerpos[client][2] = 0.0;
	
	//Reset VIP Cache
	Format(g_vip[client][Model], 100, "");
	VIP_Player[client] = false;
	DisableTrail(client);
	TrailEnabled[client] = false;
	Format(g_vip[client][Trail], 100, "");
	PlayerParticle[client] = -1;
	
	//Reset Client Security Cache
	aiJumps[client] = 0;
	afAvgJumps[client] = 5.0;
	afAvgSpeed[client] = 250.0;
	afAvgPerfJumps[client] = 0.3333;
	aiPattern[client] = 0;
	aiPatternhits[client] = 0;
	aiAutojumps[client] = 0;
	aiIgnoreCount[client] = 0;
	bBanFlagged[client] = false;
	avVEL[client][2] = 0.0;
	new i;
	while (i < 30)
	{
		aaiLastJumps[client][i] = 0;
		i++;
	}
	
	//Reset Hide Players Setting
	g_bViewModel[client] = true;
	
	if(NomStatus[client])
	{
		for(new j = 0; j < NomCount; j++)
		{
			if(StrEqual(Nomination[client], Nominated[j], true))
			{
				NomCount--;
				Format(Nominated[j], 255, "_");
				Format(Nomination[client], 255, " ");
				
				break;
			}
		}
	}
	
	RTVStatus[client] = false;
	NomStatus[client] = false;
	Format(Nomination[client], 255, " ");
	
	//Unload Client's Data Flags
	ClientDataLoaded[client] = false;
	ClientRecordsLoaded[client] = false;
	
	PrintToChatAll("Player \x01\x04%N \x01\x07has disconnected.", client);

	return Plugin_Handled;
}


//------------------------
// Player Selects A Team |
//------------------------

public Action:Command_JoinTeam(client, const String:command[], argc) 
{ 
	if(!IsFakeClient(client))
	{
		SetLevelTag(client);
		
		if(!IsPlayerAlive(client))
		{
			if(!GetEntProp(g_iGameRulesEnt, Prop_Send, "m_bWarmupPeriod"))
			{
				//CS_RespawnPlayer(client);
			}
		}
	}
	
	if (!client) 
		return Plugin_Continue;
	
	decl String:g_szTeam[4];
	
	GetCmdArgString(g_szTeam, sizeof(g_szTeam));
	
	new oldteam = GetClientTeam(client);
	new team = StringToInt(g_szTeam);
	
	if(team <= 1)
	{
		DisableTrail(client);
	}
	
	if (team == 0) return Plugin_Handled;
	
	if (oldteam == 1)
	{
		new iCTNumber=0;
		new iTNumber=0;
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && (GetClientTeam(i) == 2) && IsPlayerAlive(i)) 
			{
				iTNumber++;
			}
			if (IsClientInGame(i) && (GetClientTeam(i) == 3) && IsPlayerAlive(i)) 
			{
				iCTNumber++;
			}
		}
		
		if ((team == 2) && (iTNumber <= 15))
		{
			if(!IsFakeClient(client))
			{
				CS_SwitchTeam(client, team);
				CS_RespawnPlayer(client);
				return Plugin_Handled;
			}
		}
		else if ((team == 3) && (iCTNumber <= 15))
		{
			if(IsFakeClient(client))
			{
				CS_SwitchTeam(client, team);
				CS_RespawnPlayer(client);
				return Plugin_Handled;
			}
		}
		else
		{
			return Plugin_Handled;
		}
	} 
	return Plugin_Continue; 
}


//--------------------------
// Player Spawns Into Game |
//--------------------------

public Action:event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsPlayerInZone[4][client])
	{
		IsPlayerInZone[4][client] = false;
	}
	
	if(!WorldRecordsLoaded)
	{
		//Load World Records
		LoadWorldRecords(Map[MapName]);
	}
	
	CreateTimer(0.0, RemoveRadar, client);
	
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	
	decl String:AuthID[32];
	GetClientAuthId(client, AuthId_Engine, AuthID, sizeof(AuthID));
	
	if(g_bViewModel[client])
	{
		g_bViewModel[client]=true;
		Client_SetDrawViewModel(client,true);
	}
	else if(!g_bViewModel[client])
	{
		g_bViewModel[client]=false;
		Client_SetDrawViewModel(client,false);
	}
	
	//Player's Timer = Disabled
	g_timers[client][Enabled] = false;
	g_timers[client][Bonus] = false;
	
	if(!IsFakeClient(client))
	{
		//Player Missing Level
		if(g_info[client][Level] == 0 && ClientDataLoaded[client])
		{
			LoadPlayerData(client);
		}
		
		//Player Records Never Loaded
		if(!ClientRecordsLoaded[client] && StrEqual(g_info[client][Status], "INVALID", true))
		{
			LoadPlayerRecords(client, Map[MapName]);
		}
		
		//Player Missing Style
		if(g_info[client][Style] == 0)
		{
			ClientCommand(client, "sm_style");
		}

		SetLevelTag(client);
		
		if(!TrailEnabled[client] && strlen(g_vip[client][Trail]) > 0)
		{
			EnableTrail(client, g_vip[client][Trail]);
		}
		
		if(g_info[client][Style] == 3 || g_info[client][Style] == 4)
		{
			SendConVarValue(client, gh_AutoBhop, "1");
		}
		else
		{
			SendConVarValue(client, gh_AutoBhop, "0");
		}
	}
	
	//Style = Parkour
	if(g_info[client][Style] == 4)
	{
		SetEntityGravity(client, 0.9);
	}
	else
	{
		SetEntityGravity(client, 0.99);
	}
	
	//Set Custom Player Model
	if(VIP_Player[client] && strlen(g_vip[client][Model]) > 0)
	{
		//SetPlayerModel
		SetEntityModel(client, g_vip[client][Model]);
	}
	else if(IsFakeClient(client))
	{
		//SetPlayerModel
		SetEntityModel(client, "models/player/paradise/eve/eve.mdl");
	}
	
	ResetCounters(client);
}


//------------------
// Player Has Died |
//------------------

public event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsFakeClient(client))
	{
		CS_RespawnPlayer(client);
	}
}


//------------------------
// Player Using Commands |
//------------------------

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	if(!IsValidClient(client,false))
		return Plugin_Continue;
		
	if(IsPlayerAlive(client))
	{	
		//Show Keys
		g_iButtonsPressed[client] = buttons;
		
		//Auto Bhop
		AutoBhop(client, buttons);
		
		//Anti-Cheat
		if(g_info[client][Style] != 5)
		{
			//Paradise Bunnyhop Security
			SS_ClientStats(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		}
		else
		{
			
		}
		
		//Strafe Sync
		CheckSync(client, buttons, vel, angles);
		
		//Angle Style Check
		if(g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
		{
			AngleMoves(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		}
		else
		{
			CountStrafes(client, buttons);
		}
		
		//Block +left/+right on styles other than Freestyle/Parkour.
		if(g_info[client][Style] != 3 && g_info[client][Style] != 4)
		{
			//Block +left/+right
			BlockTurnbinds(client, buttons);
		}
		
		switch(g_info[client][Style])
		{
			//Legit
			case 2:
			{
				ScriptCheck(client, buttons, impulse, vel, angles, weapon);
				//SetEntityFlags(client, GetEntityFlags(client) | FL_ONGROUND);
			}
			//Parkour
			case 4:
			{
				ParkourMoves(client, buttons, impulse, vel, angles, weapon);
			}
		}
		
		//Paradise Bunnyhop Security
		SS_ClientStats(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		
		if(IsPlayerInZone[0][client] || IsPlayerInZone[2][client])
		{
			if(g_info[client][Style] < 3 || g_info[client][Style] > 4)
			{
					vel[2] = 0.0;
					buttons &= ~IN_JUMP;
			}
		}
	}
	else if (!IsPlayerAlive(client) || GetClientTeam(client) <= 1)
	{
		if(TrailEnabled[client])
		{
			DisableTrail(client);
		}
	}
	
	return Plugin_Continue;
}


//----------------------
// Player Jumps In Air |
//----------------------

public Action:event_PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	PB_JumpCheck(client);
	
	if(g_timers[client][Enabled])
	{
		g_info[client][Jumps]++;
	}
	
	if(IsPlayerInZone[0][client] || IsPlayerInZone[2][client])
	{
		if(g_info[client][Style] == 1 || g_info[client][Style] == 2 || g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
		{
			CreateTimer(0.01, DelayedSlowDown, client);
		}
	}

	return Plugin_Continue;
}

public Action:DelayedSlowDown(Handle:timer, any:client)
{
	LimitVelocity(client, 300.0);
}

//----------------------------
// Player Sends Chat Message |
//----------------------------

public Action:HookPlayerChat(client, const String:command[], args)
{

	decl String:szText[256];
	GetCmdArg(1, szText, sizeof(szText));
	
	if ( szText[0] == EOS)
	{
		return Plugin_Handled;
	}
	else if((szText[0] == '!') || (szText[0] == '/'))
	{
		if(IsCharUpper(szText[1]))
		{
			for(new i = 0; i <= strlen(szText); ++i)
			{
				szText[i] = CharToLower(szText[i]);
			}

			FakeClientCommand(client, "say %s", szText);
			return Plugin_Handled;
		}
	}
	else if(StrEqual(szText, "rtv", false))
	{
		FakeClientCommand(client, "say !rtv", szText);
	}
	else
	{
		if(IsValidClient(client, false))
		{
			//if(bType:SourceComms_GetClientGagType(client) == bNot)
			//{
				decl String:steamid[64];
				GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
				
				if(CheckCommandAccess(client, "sm_flag", ADMFLAG_BAN, true))
				{
					PrintToChatAll(" \x01\x0E[Admin Lv. %d] \x01%N: %s", g_info[client][Level], client, szText);
				}
				else if(CheckCommandAccess(client, "sm_flag", ADMFLAG_GENERIC, true))
				{
					PrintToChatAll(" \x01\x0B[Mod Lv.%d] \x01%N: %s", g_info[client][Level], client, szText);
				}
				else if(StrEqual(steamid, "STEAM_1:1:86276002", true) || StrEqual(steamid, "STEAM_1:0:48560794", true))
				{
					PrintToChatAll(" \x01\x09[God Lv.%d] \x01%N: %s", g_info[client][Level], client, szText);
				}
				else if(StrEqual(steamid, "STEAM_1:0:19133744", true)  || StrEqual(steamid, "STEAM_1:0:89837224", true))
				{
					PrintToChatAll(" \x01\x08[King Lv.%d] \x01%N: %s", g_info[client][Level], client, szText);
				}
				else if(StrEqual(steamid, "STEAM_1:0:76990244", true)  || StrEqual(steamid, "STEAM_1:0:53620757", true))
				{
					PrintToChatAll(" \x01\x10[Pro Lv.%d] \x01%N: %s", g_info[client][Level], client, szText);
				}
				else if(CheckCommandAccess(client, "sm_flag", ADMFLAG_CUSTOM2, true))
				{
					PrintToChatAll(" \x01\x07★ [Lv. %d] \x01%N: %s", g_info[client][Level], client, szText);
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N: %s", g_info[client][Level], client, szText);
				}
			//}
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}


//-----------------------
// Player HUD Interface |
//-----------------------

public Action:HUD(Handle:timer)
{
	decl Float:fVelocity[3];
	decl String:PlayerTime[10], String:TimeColor[15];
	new Float:currentspeed, Float:currenttime;
	
	for(new i = 1; i <= MaxClients; i++)
    { 
        if(IsClientInGame(i))
        {
			if(IsPlayerAlive(i))
			{
				decl String:Line1[255], String:Line2[255], String:Line3[255], String:StyleMode[32], String:PB[10];
				
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);
				currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
				currenttime = GetEngineTime() - g_timers[i][StartTime];
				
				Format(StyleMode, 32, "None");
				Format(TimeColor, 32, "#8847ff'>");
				
				switch(g_info[i][Style])
				{
					case 1:
					{
						Format(StyleMode, 32, "Auto"); 
						FormatPlayerTime(g_info[i][Auto], PB, 10, false, 1);
						
						if(currenttime > Auto_WR[Time] && Auto_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 2:
					{
						Format(StyleMode, 32, "Legit"); 
						FormatPlayerTime(g_info[i][Legit], PB, 10, false, 1);
						
						if(currenttime > Legit_WR[Time] && Legit_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 3:
					{
						Format(StyleMode, 32, "Freestyle"); 
						FormatPlayerTime(g_info[i][Freestyle], PB, 10, false, 1);
						
						if(currenttime > Freestyle_WR[Time] && Freestyle_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 4:
					{
						Format(StyleMode, 32, "Parkour"); 
						FormatPlayerTime(g_info[i][Parkour], PB, 10, false, 1);
						
						if(currenttime > Parkour_WR[Time] && Parkour_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 5:
					{
						Format(StyleMode, 32, "HSW"); 
						FormatPlayerTime(g_info[i][HalfSideways], PB, 10, false, 1);
						
						if(currenttime > HalfSideways_WR[Time] && HalfSideways_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 6:
					{
						Format(StyleMode, 32, "SW"); 
						FormatPlayerTime(g_info[i][Sideways], PB, 10, false, 1);
						
						if(currenttime > Sideways_WR[Time] && Sideways_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 7:
					{
						Format(StyleMode, 32, "WO"); 
						FormatPlayerTime(g_info[i][WOnly], PB, 10, false, 1);
						
						if(currenttime > WOnly_WR[Time] && WOnly_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
				}
				
				if(!g_timers[i][Enabled])
				{			
					decl String:ClientName[255];
					
					GetClientName(i, ClientName, 255);
					new len = strlen(ClientName);
					
					if(len > 9)
					{
						ClientName[8] = '\0';

						Format(ClientName, sizeof(ClientName), "%s..", ClientName);
					}

					PrintHintText(i, "<font size='19'><font color='#8847ff'> [Lv. %d]</font> %s   \n XP: <font color='#FF1D8E'>%d/%d</font> \n Style: <font color='#ff0000'>%s</font> | Speed: <font color='#10bf9c'>%.0f</font></font>", g_info[i][Level], ClientName, g_info[i][XP], g_info[i][XP_Needed], StyleMode, currentspeed); 
				}
				else
				{
					decl Float:Sync, iButtons, String:W[10], String:A[10], String:S[10], String:D[10];
					
					iButtons = g_iButtonsPressed[i];
				
					if(iButtons & IN_FORWARD)
						Format(W, 10, "  W    ");
					else
						Format(W, 10, "            ");
					
					if(iButtons & IN_MOVELEFT)
						Format(A, 10, "A");
					else
						Format(A, 10, "   ");
						
					if(iButtons & IN_BACK)
						Format(S, 10, "S");
					else
						Format(S, 10, "   ");
						
					if(iButtons & IN_MOVERIGHT)
						Format(D, 10, "D");
					else
						Format(D, 10, "   ");
						
					FormatPlayerTime(currenttime, PlayerTime, 10, false, 2);
					
					Sync = 0.0;
					
					Sync = GetClientSync(i);
					Spectators[i] = 0;
					
					for(new j = 1; j <= MaxClients; j++) 
					{
						if (!IsClientInGame(j) || !IsClientObserver(j))
							continue;
							
						new iSpecMode = GetEntProp(j, Prop_Send, "m_iObserverMode");
						
						// The client isn't spectating any one person, so ignore them.
						if (iSpecMode != 4 && iSpecMode != 5)
							continue;
						
						// Find out who the client is spectating.
						new iTarget = GetEntPropEnt(j, Prop_Send, "m_hObserverTarget");
						
						// Are they spectating our player?
						if (iTarget == i)
						{
							Spectators[i]++;
						}
					}
					
					Format(Line1, sizeof(Line1), "Time: <font color='%s%s</font> \n", TimeColor, PlayerTime);
					
					if(g_info[i][Style] == 7)
					{
						Format(Line2, sizeof(Line2), "%s--<b>/</b> %.0f u/s  \n", W, currentspeed);
					}
					else
					{
						Format(Line2, sizeof(Line2), "%s%.0f%% <b>/</b> %.0f u/s  \n", W, Sync, currentspeed);
					}
					
					Format(Line3, sizeof(Line3), "%s%s%s   Spectators: <font color='#10bf9c'>%i</font>", A, S, D, Spectators[i]);
					
					PrintHintText(i, "<font size='19'>%s %s %s</font>", Line1, Line2, Line3);
				}
			}
			else if(IsClientObserver(i))
			{
				new iSpecModeUser = GetEntProp(i, Prop_Send, "m_iObserverMode");
				
				if(iSpecModeUser == 4 || iSpecModeUser == 5)
				{
					new iTargetUser = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
					
					decl String:Line1[255], String:Line2[255], String:Line3[255], String:StyleMode[64];
				
					if(iTargetUser >= 0 || iTargetUser <= (MAXPLAYERS+1))
					{
						if(IsValidClient(iTargetUser, false))
						{
							if(IsFakeClient(iTargetUser))
							{
								if(BotMimic_IsPlayerMimicing(iTargetUser))
								{
									GetEntPropVector(iTargetUser, Prop_Data, "m_vecVelocity", fVelocity);
									
									currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
									
									decl Float:Sync, iButtons, String:W[10], String:A[10], String:S[10], String:D[10];
									
									iButtons = g_iButtonsPressed[iTargetUser];
								
									if(iButtons & IN_FORWARD)
										Format(W, 10, "  W    ");
									else
										Format(W, 10, "            ");
									
									if(iButtons & IN_MOVELEFT)
										Format(A, 10, "A");
									else
										Format(A, 10, "   ");
										
									if(iButtons & IN_BACK)
										Format(S, 10, "S");
									else
										Format(S, 10, "   ");
										
									if(iButtons & IN_MOVERIGHT)
										Format(D, 10, "D");
									else
										Format(D, 10, "   ");
										
									//currenttime = GetEngineTime() - g_timers[iTargetUser][StartTime];
									//FormatPlayerTime(currenttime, PlayerTime, 10, false, 2);
									
									Sync = 0.0;
									
									Sync = GetClientSync(iTargetUser);
									Spectators[iTargetUser] = 0;
									
									for(new j = 1; j <= MaxClients; j++) 
									{	
										if (!IsClientInGame(j) || !IsClientObserver(j))
											continue;
											
										new iSpecMode = GetEntProp(j, Prop_Send, "m_iObserverMode");
										
										// The client isn't spectating any one person, so ignore them.
										if (iSpecMode != 4 && iSpecMode != 5)
											continue;
										
										// Find out who the client is spectating.
										new iTarget = GetEntPropEnt(j, Prop_Send, "m_hObserverTarget");
										
										// Are they spectating our player?
										if (iTarget == iTargetUser)
										{
											Spectators[iTargetUser]++;
										}
									}
									
									Format(Line1, sizeof(Line1), "<font color='#8847ff'>EVE WR Replay</font> \n");
									
									Format(Line2, sizeof(Line2), "%s%.0f%% <b>/</b> %.0f u/s  \n", W, Sync, currentspeed);
								
									Format(Line3, sizeof(Line3), "%s%s%s   Spectators: <font color='#10bf9c'>%i</font>", A, S, D, Spectators[iTargetUser]);
									
									PrintHintText(i, "<font size='19'>%s %s %s</font>", Line1, Line2, Line3);
								}
							}
							else
							{
								GetEntPropVector(iTargetUser, Prop_Data, "m_vecVelocity", fVelocity);
								
								currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
								
								Format(StyleMode, 64, "None");
								
								switch(g_info[iTargetUser][Style])
								{
									case 1:{Format(StyleMode, 64, "Auto");}
									case 2:{Format(StyleMode, 64, "Legit");}
									case 3:{Format(StyleMode, 64, "Freestyle");}
									case 4:{Format(StyleMode, 64, "Parkour");}
									case 5:{Format(StyleMode, 64, "HSW");}
									case 6:{Format(StyleMode, 64, "SW");}
									case 7:{Format(StyleMode, 64, "WO");}
								}
								
								if(!g_timers[iTargetUser][Enabled] && IsValidClient(i, false))
								{			
									PrintHintText(i, "<font size='19'><font color='#8847ff'> [Lv. %d]</font> %N   \n XP: <font color='#FF1D8E'>%d/%d</font> \n Style: <font color='#ff0000'>%s</font> | Speed: <font color='#10bf9c'>%.0f</font></font>", g_info[iTargetUser][Level], iTargetUser, g_info[iTargetUser][XP], g_info[iTargetUser][XP_Needed], StyleMode, currentspeed); 
								}
								else
								{
									decl Float:Sync, iButtons, String:W[10], String:A[10], String:S[10], String:D[10];
									
									iButtons = g_iButtonsPressed[iTargetUser];
								
									if(iButtons & IN_FORWARD)
										Format(W, 10, "  W    ");
									else
										Format(W, 10, "            ");
									
									if(iButtons & IN_MOVELEFT)
										Format(A, 10, "A");
									else
										Format(A, 10, "   ");
										
									if(iButtons & IN_BACK)
										Format(S, 10, "S");
									else
										Format(S, 10, "   ");
										
									if(iButtons & IN_MOVERIGHT)
										Format(D, 10, "D");
									else
										Format(D, 10, "   ");
										
									currenttime = GetEngineTime() - g_timers[iTargetUser][StartTime];
									FormatPlayerTime(currenttime, PlayerTime, 10, false, 2);
									
									Sync = 0.0;
									
									Sync = GetClientSync(iTargetUser);
									Spectators[iTargetUser] = 0;
									
									for(new j = 1; j <= MaxClients; j++) 
									{	
										if (!IsClientInGame(j) || !IsClientObserver(j))
											continue;
											
										new iSpecMode = GetEntProp(j, Prop_Send, "m_iObserverMode");
										
										// The client isn't spectating any one person, so ignore them.
										if (iSpecMode != 4 && iSpecMode != 5)
											continue;
										
										// Find out who the client is spectating.
										new iTarget = GetEntPropEnt(j, Prop_Send, "m_hObserverTarget");
										
										// Are they spectating our player?
										if (iTarget == iTargetUser)
										{
											Spectators[iTargetUser]++;
										}
									}
									
									Format(Line1, sizeof(Line1), "Time: <font color='%s%s</font> \n", TimeColor, PlayerTime);
									
									if(g_info[iTargetUser][Style] == 7)
									{
										Format(Line2, sizeof(Line2), "%s--<b>/</b> %.0f u/s  \n", W, currentspeed);
									}
									else
									{
										Format(Line2, sizeof(Line2), "%s%.0f%% <b>/</b> %.0f u/s  \n", W, Sync, currentspeed);
									}
								
									Format(Line3, sizeof(Line3), "%s%s%s   Spectators: <font color='#10bf9c'>%i</font>", A, S, D, Spectators[iTargetUser]);
									
									PrintHintText(i, "<font size='19'>%s %s %s</font>", Line1, Line2, Line3);
								}
							}
						}
					}
				}
			}
        }
    } 
}


//-----------------------
// Player On Game Frame |
//-----------------------

public OnGameFrame()
{
	SecurityFrameCheck();
	
	CreateZones();
	
	if(ZoneFrameRepeat == 1)
	{
		if(ZoneFrame < 3)
		{
			ZoneFrame++;
			ZoneFrameRepeat--;
		}
		else if(ZoneFrame == 3)
		{
			ZoneFrame = 0;
			ZoneFrameRepeat--;
		}
	}
	else
	{
		ZoneFrameRepeat++;
	}
	
	if (!GetEntProp(g_iGameRulesEnt, Prop_Send, "m_bWarmupPeriod"))
	{
		EngineTime = GetEngineTime();
		
		decl MapTimeLeft;
		
		//Get The Current Time Remaining (In Seconds)
		GetMapTimeLeft(MapTimeLeft);
		
		//Map Ending
		if(MapTimeLeft == 1 && !MapEnding)
		{
			EndMap();
		}
		
		//EVE Timeleft System
		if(EngineTime >= (SavedTime + 60.0))
		{
			TimeLeft = TimeLeft - 1;
			SavedTime = EngineTime;
			
			MinutePassed();
			
			if(EngineTime > (RTVTime + 300.0) && !RTVEnabled)
			{
				RTVEnabled = true;
			}
			
			if(TimeLeft == 0)
			{
				if(EngineTime >= (InitTime + (float(Map[Time]) * 60.0)))
				{
					if(m_Extend && !MapEnding && MapTimeLeft <= 0)
					{
						MapEnding = true;
						m_Extend = false;
						EndMap();
					}
				}
			}
			
			if(TimeLeft == -1)
			{
				MapEnding = true;
				m_Extend = false;
				EndMap();
			}
		}
		
		//Map Vote At 3 Minutes Remaining
		if(((177 <= MapTimeLeft <= 180) && !m_Extend) || (TimeLeft == 3 && m_Extend))
		{
			if(!VoteStarted)
			{
				MapVote();
				VoteStarted = true;
			}
		}
		
		//Countdown At 14 Seconds Remaining
		if(MapTimeLeft == 14 && !m_Extend && !CountdownPlayed)
		{
			PlayCountdown();
			CountdownPlayed = true;
		}
	}
}



/* Paradise Timer Functions
**
** Functions: Start | Stop | Finish | MapComplete | WRCelebration
** -------------------------------------------------------------------------- */

// Start Timer
public StartTimer(client)
{	
	if(ClientDataLoaded[client])
	{
		g_timers[client][Enabled] = true;
		g_timers[client][StartTime] = GetEngineTime();
		g_timers[client][EndTime] = -1.0;
		TotalSync[client] = 0;
		GoodSync[client] = 0;
		
		ResetCounters(client);
		
		SS_RefreshClientData(client);
		
		//Save PreSpeed Value for Freestyle & Parkour
		if(g_info[client][Style] == 3 || g_info[client][Style] == 4)
		{
			decl Float:fVelocity[3];
			
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			g_info[client][PreSpeed] = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
		}
	}
	else
	{
		PrintToChat(client, "Please Wait.. Loading Player Data");
		
		if(StrEqual(g_info[client][Status], "INVALID"))
		{
			LoadPlayerData(client);
		}
	}
}

//Stop Timer
public StopTimer(client)
{
	g_timers[client][Enabled] = false;
	g_timers[client][StartTime] = 0.0;
	g_timers[client][Bonus] = false;
	TotalSync[client] = 0;
	GoodSync[client] = 0;
	
	ResetCounters(client);
}

//Finish Timer
public FinishTimer(client)
{
	g_timers[client][EndTime] = GetEngineTime() - g_timers[client][StartTime];
	StopTimer(client);
}

//Map Completed
public MapComplete(client, style, Float:time, jumps, strafes, Float:sync, Float:prespeed, wallruns, walljumps, Float:startSD, Float:endSD, Float:keySD)
{
	decl String:StyleName[32], String:ImproveTime[32];
	decl Float:improve;
	new calcXP;
	
	calcXP = Map[XPValue];
	improve = 0.0;
	
	decl String:replaypath[50];
	Format(replaypath, 50, "World Records/%s/%sWR-%i.rec", Map[MapName], Map[MapName], g_info[client][Style]);

	/*if(g_info[client][Auto] == 0.0 && g_info[client][Legit] == 0.0 && g_info[client][Freestyle] == 0.0 && g_info[client][Parkour] == 0.0 && g_info[client][HalfSideways] == 0.0)
	{
		if(g_info[client][Level] >= 10)
		{
			mRating_Main(client);
		}
	}*/

	switch(style)
	{
		//Finished Map On Auto
		case 1:
		{
			Format(StyleName, 32, "Auto");
			
			if(time < g_info[client][Auto] || g_info[client][Auto] == 0.0) //Right Now 0.0..?
			{	
				//Save Player Record
				if(g_info[client][Auto] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][Auto] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Auto] = time;

				if(time <= Auto_WR[Time] || Auto_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(Auto_WR[PlayerID]);
					Auto_WR[Time] = time;
					GetClientName(client, Auto_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, Auto_WR[PlayerID], sizeof(Auto_WR[PlayerID]));
					
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
			
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Legit
		case 2:
		{
			Format(StyleName, 32, "Legit");
			
			if(time < g_info[client][Legit] || g_info[client][Legit] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][Legit] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][Legit] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Legit] = time;

				if(time <= Legit_WR[Time] || Legit_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(Legit_WR[PlayerID]);
					Legit_WR[Time] = time;
					GetClientName(client, Legit_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, Legit_WR[PlayerID], sizeof(Legit_WR[PlayerID]));
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for Legit Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Freestyle
		case 3:
		{
			Format(StyleName, 32, "Freestyle");
			
			if(time < g_info[client][Freestyle] || g_info[client][Freestyle] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				BotMimic_DeleteRecord(replaypath);
				if(g_info[client][Freestyle] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][Freestyle] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Freestyle] = time;

				if(time <= Freestyle_WR[Time] || Freestyle_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(Freestyle_WR[PlayerID]);
					Freestyle_WR[Time] = time;
					GetClientName(client, Freestyle_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, Freestyle_WR[PlayerID], sizeof(Freestyle_WR[PlayerID]));
					
					calcXP *= 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Parkour
		case 4:
		{
			calcXP = (calcXP / 2);
			
			Format(StyleName, 32, "Parkour");
			
			if(time < g_info[client][Parkour] || g_info[client][Parkour] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][Parkour] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][Parkour] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Parkour] = time;

				if(time <= Parkour_WR[Time] || Parkour_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(Parkour_WR[PlayerID]);
					Parkour_WR[Time] = time;
					GetClientName(client, Parkour_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, Parkour_WR[PlayerID], sizeof(Parkour_WR[PlayerID]));
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Half-Sideways
		case 5:
		{
			Format(StyleName, 32, "Half-Sideways");
			
			if(time < g_info[client][HalfSideways] || g_info[client][HalfSideways] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][HalfSideways] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][HalfSideways] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][HalfSideways] = time;

				if(time <= HalfSideways_WR[Time] || HalfSideways_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(HalfSideways_WR[PlayerID]);
					HalfSideways_WR[Time] = time;
					GetClientName(client, HalfSideways_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, HalfSideways_WR[PlayerID], sizeof(HalfSideways_WR[PlayerID]));
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for HSW Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Sideways
		case 6:
		{	
			Format(StyleName, 32, "Sideways");
			
			if(time < g_info[client][Sideways] || g_info[client][Sideways] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][Sideways] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][Sideways] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Sideways] = time;

				if(time <= Sideways_WR[Time] || Sideways_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(Sideways_WR[PlayerID]);
					Sideways_WR[Time] = time;
					GetClientName(client, Sideways_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, Sideways_WR[PlayerID], sizeof(Sideways_WR[PlayerID]));
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for Sideways Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On W-Only
		case 7:
		{
			calcXP = (calcXP / 2);
			
			Format(StyleName, 32, "W-Only");
			
			if(time < g_info[client][WOnly] || g_info[client][WOnly] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][WOnly] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps, startSD, endSD, keySD);
					improve = (g_info[client][WOnly] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][WOnly] = time;

				if(time <= WOnly_WR[Time] || WOnly_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					CalculateScore(WOnly_WR[PlayerID]);
					WOnly_WR[Time] = time;
					GetClientName(client, WOnly_WR[PlayerName], MAX_NAME_LENGTH);
					GetClientAuthId(client, AuthId_Engine, WOnly_WR[PlayerID], sizeof(WOnly_WR[PlayerID]));
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for W-Only Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
	}
}

public WRCelebration(client, const String:userstyle[])
{
	new random = GetRandomInt(1, 27);
	decl String:WRSong[128];
	Format(WRSong, 128, "sourcemod/paradise/wr%d.mp3", random);
	
	EmitSoundToAllAny(WRSong);
	
	for (new i = 1; i <= 10; i++)
	{
		PrintToChatAll(" \x01\x07*** \x01\x09NEW  \x01\x05WOR\x01\x06LD R\x01\x0BECO\x01\x0ERD! \x01\x03***");
	}
		
	PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has SET A NEW WORLD RECORD in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], userstyle);
}


public BonusComplete(client, style, Float:time)
{
	new calcXP;
	
	calcXP = 25;
	
	switch(style)
	{
		//Auto
		case 1:
		{
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Auto]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Legit
		case 2:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for Legit Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Legit]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Freestyle
		case 3:
		{
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Freestyle]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Parkour
		case 4:
		{
			calcXP = calcXP / 2;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Parkour]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Half-Sideways
		case 5:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for Half-Sideways Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Half-Sideways]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Sideways
		case 6:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for Sideways Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Sideways]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//W-Only
		case 7:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for W-Only Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[W-Only]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
	}
	
	GivePlayerXP(client, calcXP);
}



/* Paradise Map Zones
**
** Types: Start Zone | End Zone | Cheat Zone | Bonus Start | Bonus End
** -------------------------------------------------------------------------- */

//------------------------
// Player Entering Zones |
//------------------------

public Zone_OnClientEntry(client, type)
{	
	switch(type)
	{
		//Start Zone
		case 0:
		{				
			StopTimer(client);
			
			if(!IsFakeClient(client))
			{
				if(g_info[client][Style] < 3 || g_info[client][Style] > 4)
				{
					SendConVarValue(client, gh_AutoBhop, "0");
				}
			}
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
			
			new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
			
			if(!onground && !g_PracticeMode[client])
			{
				if(g_info[client][Style] == 1 || g_info[client][Style] == 2 || g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
				{
					LimitVelocity(client, 250.0);	
				}
			}
			
		}
		//End Zone
		case 1:
		{			
			if(g_timers[client][Enabled] && (!g_timers[client][Bonus]) && (!g_PracticeMode[client]))
			{
				decl g_Jumps, g_Strafes, Float:g_Sync, Float:g_PreSpeed, g_WallRuns, g_WallJumps;
				
				g_Jumps = g_info[client][Jumps];
				g_Strafes = g_info[client][Strafes];
				g_Sync = GetClientSync(client);
				g_PreSpeed = g_info[client][PreSpeed];
				g_WallRuns = g_info[client][WallRuns];
				g_WallJumps = g_info[client][WallJumps];
				
				FinishTimer(client);

				FormatPlayerTime(g_timers[client][EndTime], g_timers[client][MapTime], 64, false, 0);
				
				if(g_info[client][Style] <= 3)
				{
					if((g_Strafes > 10 || g_Strafes <= 1) && (g_Jumps > 1))
					{
						SS_StrafeCheck(client, g_info[client][Style], g_timers[client][EndTime], g_Jumps, g_Strafes, g_Sync);
					}
				}
				
				MapComplete(client, g_info[client][Style], g_timers[client][EndTime], g_Jumps, g_Strafes, g_Sync, g_PreSpeed, g_WallRuns, g_WallJumps, g_info[client][SSD], g_info[client][ESD], g_info[client][KSD]);
				
			}
		}
		//Bonus Start
		case 2:
		{	
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
			
			new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
			
			if(!onground)
			{
				if(g_info[client][Style] == 1 || g_info[client][Style] == 2 || g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
				{
					LimitVelocity(client, 300.0);
				}
			}
		}
		//Bonus End
		case 3:
		{
			if(g_timers[client][Enabled] && (g_timers[client][Bonus]) && (!g_PracticeMode[client]))
			{
				g_timers[client][Bonus] = false;
				
				FinishTimer(client);

				FormatPlayerTime(g_timers[client][EndTime], g_timers[client][MapTime], 64, false, 0);
				
				BonusComplete(client, g_info[client][Style], g_timers[client][EndTime]);
				
			}
		}
		//Cheat Zone
		case 4:
		{
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
			
			ClientCommand(client, "sm_r");
			PrintToChat(client, " \x01\x07[Paradise] You have been respawned for entering a restricted zone.");
		}
	}
}

//-----------------------
// Player Exiting Zones |
//-----------------------

public Zone_OnClientLeave(client, type)
{
	switch(type)
	{
		//Start Zone
		case 0:
		{
			g_timers[client][Bonus] = false;
			
			if(g_info[client][Style] > 0 && (!g_PracticeMode[client]))
			{
				if(!IsFakeClient(client))
				{
					if(!IsPlayerInZone[4][client])
					{
						new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
						
						if(onground || g_info[client][Style] == 3 || g_info[client][Style] == 4)
						{
							if(g_info[client][Style] != 2)
							{
								SendConVarValue(client, gh_AutoBhop, "1");
							}
							
							decl String:replayName[255];
							
							StartTimer(client);
							
							Format(replayName, 255, "%sWR-%i", Map[MapName], g_info[client][Style]);
						
							BotMimic_StartRecording(client, replayName, "World Records", Map[MapName]);
						}
					}
				}
			}
		}
		//Bonus Start
		case 2:
		{
			if(g_info[client][Style] > 0)
			{
				if(!IsFakeClient(client))
				{
					StartTimer(client);
					
					g_timers[client][Bonus] = true;
				}
			}
		}
		//Cheat Zone
		case 4:
		{
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
		}
	}
}


/* Paradise Level/XP Functions
**
** Functions: GivePlayerXP | SetLevel | SetLevelTag 
** -------------------------------------------------- */

// Give Player XP
public GivePlayerXP(client, xp)
{
	new xp_needed = g_info[client][XP_Needed];
	
	new old_xp = g_info[client][XP];
	new new_xp = old_xp + xp;
	
	if(g_info[client][Level] > 0)
	{
		//+EXP
		if(xp > 0)
		{
			PrintToChat(client, "You have gained \x01\x04+%d EXP!", xp);
		}
		
		//+Level Up
		if (new_xp >= xp_needed)
		{
			new L = g_info[client][Level];
			
			g_info[client][Level] = g_info[client][Level] + 1;
			g_info[client][XP] = new_xp - xp_needed;
			g_info[client][XP_Needed] = ((L * L + L + 3) * 4);
			
			PrintToChat(client, "Level Up! You are now \x01\x04Level %d", g_info[client][Level]);
			SetLevelTag(client);
			
			
			if(g_info[client][XP] >= g_info[client][XP_Needed])
			{
				GivePlayerXP(client, 0);
			}
		}
		else
		{
			g_info[client][XP] = new_xp;
		}
	}
	else
	{
		LoadPlayerData(client);
	}
}

// Set Clients Level
public Action:SetLevel(client, args) 
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setlevel <#userid|name> [level]");
		return Plugin_Handled;
	}
	
	decl String:arg1[64], String:arg2[20]; 
	new target = -1;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	if(StringToInt(arg2) <= 0 )
	{
		ReplyToCommand(client, "[SM] Invalid Level. Must be greater than zero.");
		return Plugin_Handled;
	}
	 
	for (new i=1; i<=MaxClients; i++)
	{
		if (!IsClientConnected(i))
		{
			continue;
		}
		decl String:other[MAX_NAME_LENGTH];
		GetClientName(i, other, sizeof(other));
		if (StrEqual(arg1, other))
		{
			target = i;
		}
	}
 
	if (target == -1)
	{
		PrintToConsole(client, "Could not find any player with the target in server!");
		return Plugin_Handled;
	}
	
	g_info[target][Level] = StringToInt(arg2);
	g_info[target][XP] = 0;
	
	UpdatePlayer(target);
	SetLevelTag(target);
	
	return Plugin_Handled;
}

//Set Client's Clantag
public SetLevelTag(client)
{
	decl String:name[MAX_NAME_LENGTH];
	decl String:tag[15];
	
	if(IsValidClient(client, false))
	{
		CS_GetClientClanTag(client, name, sizeof(name));
	}
	
	//Admin
	if(CheckCommandAccess(client, "sm_flag", ADMFLAG_BAN, true))
	{
		Format(tag, sizeof(tag), "[Admin Lv.%d]", g_info[client][Level]);
	}
	//Moderator
	else if(CheckCommandAccess(client, "sm_flag", ADMFLAG_GENERIC, true))
	{
		Format(tag, sizeof(tag), "[Mod Lv.%d]", g_info[client][Level]);
	}
	//Donator
	else if(CheckCommandAccess(client, "sm_flag", ADMFLAG_CUSTOM2, true))
	{
		Format(tag, sizeof(tag), "★ [Lv.%d]", g_info[client][Level]);
	}
	//EVE
	else if(IsFakeClient(client))
	{
		Format(tag, sizeof(tag), "EVE");
	}
	//Member
	else
	{
		Format(tag, sizeof(tag), "[Lv.%d]", g_info[client][Level]);
	}
	
	decl String:steamid[64];
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
	
	// Battle Royale Winner's Tags
	if(StrEqual(steamid, "STEAM_1:1:86276002", true) || StrEqual(steamid, "STEAM_1:0:48560794", true))
	{
		Format(tag, sizeof(tag), "[God Lv.%d]", g_info[client][Level]);
	}
	else if(StrEqual(steamid, "STEAM_1:0:19133744", true)  || StrEqual(steamid, "STEAM_1:0:89837224", true))
	{
		Format(tag, sizeof(tag), "[King Lv.%d]", g_info[client][Level]);
	}
	else if(StrEqual(steamid, "STEAM_1:0:76990244", true)  || StrEqual(steamid, "STEAM_1:0:53620757", true))
	{
		Format(tag, sizeof(tag), "[Pro Lv.%d]", g_info[client][Level]);
	}
	
	if(StrContains(name, tag) == -1)
	{
		if(IsValidClient(client, false))
		{
			CS_SetClientClanTag(client, tag);
		}
	}
}