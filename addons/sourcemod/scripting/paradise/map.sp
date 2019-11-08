
enum MapInfo
{
	String:MapName[64],
	Tier,
	String:Stages[64],
	XPValue,
	Float:Average,
	Time,
	RecordCount
}

new Map[MapInfo];
new String:PreviousMap[7][255];

new TimeLeft;
new Float:SavedTime;
new Float:InitTime;
new Float:EngineTime;

new bool:m_Extend;	
new ExtendCount;
new bool:m_RTV;
new Float:RTVTime;

new bool:RTVEnabled;
new bool:RTVStatus[MAXPLAYERS+1];

new VoteCount[6];
new VoteTotal;

new bool:MapEnding;
new bool:CountdownPlayed;
new bool:VoteStarted;

new String:Nominated[10][255];
new bool:NomStatus[MAXPLAYERS+1];
new String:Nomination[MAXPLAYERS+1][255];
new NomCount;

new bool:StartMSG;
new g_iGameRulesEnt;

new const String:RELATIVE_SOUND_PATH[] = "*/sourcemod/paradise/countdown";

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | MAPS <3",
    author = "Aexi0n",
    description = "Official Bhop Plugin for Paradise Servers",
    version = "5.0",
	url = ""
}

public MapStarted()
{	
	AddFileToDownloadsTable("sound/sourcemod/paradise/countdown.mp3");
	FakePrecacheSound("*/sourcemod/paradise/countdown.mp3");

	GetCurrentMap(Map[MapName], sizeof(Map[MapName]));
	
	decl String:LoadingText[150];
	
	Format(LoadingText, sizeof(LoadingText), "maps/%s.txt", Map[MapName]);
	AddFileToDownloadsTable(LoadingText);
	
	LoadMap(Map[MapName]);

	StartMSG = true;
	
	SavedTime = GetEngineTime();
	InitTime = GetEngineTime();
	EngineTime = GetEngineTime();
	
	RTVTime = GetEngineTime();
	RTVEnabled = false;
	
	MapEnding = false;
	CountdownPlayed = false;
	VoteStarted = false;
	
	ExtendCount = 0;
	
	NomCount = 0;
	
	Format(Nominated[0], 255, "_");
	Format(Nominated[1], 255, "_");
	Format(Nominated[2], 255, "_");
	Format(Nominated[3], 255, "_");
	Format(Nominated[4], 255, "_");
	
	m_Extend = false;
	m_RTV = false;
	
	CreateTimer(15.0, MapMessage);
	CreateTimer(300.0, MapMessage, _, TIMER_FLAG_NO_MAPCHANGE);
}

public OnEntityCreated(entity, const String:classname[])
{
    if(StrEqual(classname, "cs_gamerules"))
	{
		g_iGameRulesEnt = entity;
	}
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{	
	if (GetEntProp(g_iGameRulesEnt, Prop_Send, "m_bWarmupPeriod"))
        return Plugin_Continue;
		
	if (reason == CSRoundEnd_GameStart)
        return Plugin_Handled;
		
	return Plugin_Continue;
}

public MapVote()
{
	PrintToChatAll(" \x01\x06[Paradise] \x01Voting for the next map has started! Please select a map from the menu.");
	
	VoteCount[0] = 0;
	VoteCount[1] = 0;
	VoteCount[2] = 0;
	VoteCount[3] = 0;
	VoteCount[4] = 0;
	VoteCount[5] = 0;
	
	VoteTotal = 0;
	
	RandomMaps();
}

public PlayCountdown()
{
		PrintToChatAll(" \x01\x06[Paradise] Map Changing in..");
		
		decl String:CountdownSND[128];
		Format(CountdownSND, 128, "%s.mp3", RELATIVE_SOUND_PATH);
		EmitSoundToAll(CountdownSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);  
		
}

public EndMap()
{
	if(m_Extend)
	{
		TimeLeft = 10;
		
		VoteStarted = false;
	}
	else
	{
		MapEnding = true;
		
		SetCvar("mp_ignore_round_win_conditions", "0");

		CreateTimer(2.0, End_Round, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:End_Round(Handle:timer)
{
	if(!m_Extend)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, true))
			{
				ForcePlayerSuicide(i);
			}
		}
				
		//CS_TerminateRound(4.0, CSRoundEnd_Draw, true);
	}
	
	timer = INVALID_HANDLE;
}

public SavePreviousMaps()
{
	if(!StrEqual(PreviousMap[0], Map[MapName], true))
	{
		Format(PreviousMap[6], 255, "%s", PreviousMap[5]);
		Format(PreviousMap[5], 255, "%s", PreviousMap[4]);
		Format(PreviousMap[4], 255, "%s", PreviousMap[3]);
		Format(PreviousMap[3], 255, "%s", PreviousMap[2]);
		Format(PreviousMap[2], 255, "%s", PreviousMap[1]);
		Format(PreviousMap[1], 255, "%s", PreviousMap[0]);
		Format(PreviousMap[0], 255, "%s", Map[MapName]);
	}
}


public Action:MapMessage(Handle:timer)
{
	PrintToChatAll(" \x01\x06[Paradise] \x01Welcome to \x06%s!", Map[MapName]);
	PrintToChatAll("This is a \x07[Tier %d] Map\x01 with \x03%s Stage(s).\x01 Map Reward:\x01\x0B %d XP", Map[Tier], Map[Stages], Map[XPValue]);
	
	decl String:AverageTime[10];
	FormatPlayerTime(Map[Average], AverageTime, 10, false, 2);
	PrintToChatAll("The Timelimit has been set to \x07%i min. \x01based on \x07%i Records\x01 with an Avg. Completion Time of \x07%s.", Map[Time], Map[RecordCount], AverageTime);
	
	if(StartMSG)
	{
		StartMSG = false;
		
		return Plugin_Stop;
	}
	else
	{
		return Plugin_Continue;
	}

}


public MinutePassed()
{		
	new g_EVEBot = -1;

	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) >= CS_TEAM_T)
		{
			g_EVEBot = i;
		}
	}
	
	if(g_EVEBot != -1)
	{
		if(!BotMimic_IsPlayerMimicing(g_EVEBot))
		{
			LoadEVE(g_EVEBot);
		}
	}
}