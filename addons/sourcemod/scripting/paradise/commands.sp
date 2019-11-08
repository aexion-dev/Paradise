
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | COMMANDS",
    author = "Aexi0n",
    description = "Official Bhop Plugin for Paradise Servers",
    version = "5.0",
    url = ""
}

//new aiA[1000];
//new Float:aiFade[1000];
/*
new bool:g_EVEMode[MAXPLAYERS+1];
new bool:g_EVERecord[MAXPLAYERS+1];

new g_EVEEntity[MAXPLAYERS+1];
new g_EVEParent[MAXPLAYERS+1];

new Float:g_EVEClientStartVec[MAXPLAYERS+1][3];
new Float:g_EVEClientVec[MAXPLAYERS+1][3];
new Float:g_EVEClientAngles[MAXPLAYERS+1][3];
*/

new bool:g_bViewModel[MAXPLAYERS+1];
new bool:g_PracticeMode[MAXPLAYERS+1];
new testint;



//[ Style Menu - !style ]
public Action:sm_style(client, args)
{
	mStyle_Main(client);
	
	return Plugin_Handled;
}

//[ Map Info Menu - !mapinfo ]
public Action:sm_mapinfo(client, args)
{
	PrintToChat(client, "\x06%s \x01 is a \x07[Tier %d] Map\x01 with \x03%s Stage(s).\x01 Map Reward:\x01\x0B %d XP", Map[MapName], Map[Tier], Map[Stages], Map[XPValue]);
}

//[ Commands Menu - !commands | !help ]
public Action:sm_commands(client, args)
{
	mCommand_Main(client);
	
	return Plugin_Handled;
}

public Action:sm_querycount(client, args)
{
	PrintToChat(client, "%i Queries Executed This Map", QueryCounter);
	
	return Plugin_Handled;
}

//[ Player Profile Menu - !profile | !me ]
public Action:sm_profile(client, args)
{
	if (args == 0)
	{
		decl String:steamid[64];
		GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
		
		LoadProfile(client, steamid);
	}
	else if (args >= 1)
	{
		new String:arg1[MAX_NAME_LENGTH];
		GetCmdArgString(arg1, sizeof(arg1));
		
		LookupPlayer(client, arg1);
	}
	/*else if(args > 1)
	{
		new String:arg1[MAX_NAME_LENGTH];
		GetCmdArgString(arg1, sizeof(arg1));
		
		new String:arg2[MAX_NAME_LENGTH];
		GetCmdArgString(arg2, sizeof(arg2));
		
		Format(arg1, sizeof(arg1), "%s_%s", arg1, arg2);
		PrintToConsole(client, "%s", arg1);
		LookupPlayer(client, arg1);
	}*/
	return Plugin_Handled;
}

//[ World Record Menu - !wr | !worldrecord ]
public Action:sm_wr(client, args)
{
	mWorldRecords_Main(client);
	
	return Plugin_Handled;
}

//[ Top Map Records Menu - !mtop | !maptop ]
public Action:sm_maptop(client, args)
{
	if (args == 0)
	{
		MapTop_Main(client, Map[MapName]);
	}
	else if (args >= 1)
	{
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		MapTop_Main(client, arg1);
	}
	
	return Plugin_Handled;
}

//[ Top Players Menu - !top ]
public Action:sm_top(client, args)
{
	if (args == 0)
	{
		TopPlayers_Main(client);
	}
	
	return Plugin_Handled;
}

//[ Top Players Menu - !topauto ]
public Action:sm_autotop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Auto");
	}
	
	return Plugin_Handled;
}

//[ Top Players Menu - !toplegit ]
public Action:sm_legittop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Legit");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topfreestyle ]
public Action:sm_freestyletop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Freestyle");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topparkour ]
public Action:sm_parkourtop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Parkour");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !tophsw | !tophalfsideways ]
public Action:sm_halfsidewaystop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Half-Sideways");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topsw | !topsideways ]
public Action:sm_sidewaystop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Sideways");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topwonly ]
public Action:sm_wonlytop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "W-Only");
	}
	
	return Plugin_Handled;
}

/*
//||------------------------------------------------------------------------------------||\\
//|| Look Up World Record On Map Via Command. i.e: !autowr or !autowr bhop_mapname_csgo ||
//||------------------------------------------------------------------------------------||\\
*/

//[ Auto WR Look Up Menu - !autowr | !autowr map_name ]
public Action:sm_autowr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Auto");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Auto");
	}
	
	return Plugin_Handled;
}

//[ Legit WR Look Up Menu - !Legitwr | !Legitwr map_name ]
public Action:sm_legitwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Legit");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Legit");
	}
	
	return Plugin_Handled;
}

//[ Freestyle WR Look Up Menu - !Freestylewr | !Freestylewr map_name ]
public Action:sm_freestylewr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Freestyle");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Freestyle");
	}
	
	return Plugin_Handled;
}

//[ Parkour WR Look Up Menu - !Parkourwr | !Parkourwr map_name ]
public Action:sm_parkourwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Parkour");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Parkour");
	}
	
	return Plugin_Handled;
}

//[ Half-Sideways WR Look Up Menu - !hswwr | !hswwr map_name ]
public Action:sm_hswwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Half-Sideways");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Half-Sideways");
	}
	
	return Plugin_Handled;
}

//[ Sideways WR Look Up Menu - !swwr | !swwr map_name ]
public Action:sm_swwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Sideways");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Sideways");
	}
	
	return Plugin_Handled;
}

//[ W-Only WR Look Up Menu - !wonlywr | !wonlywr map_name ]
public Action:sm_wonlywr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "W-Only");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "W-Only");
	}
	
	return Plugin_Handled;
}



//[ Leaderboard Menu - !leaderboard | !ranks ]
public Action:sm_leaderboard(client, args)
{
	mLeaderboard_Main(client);
	
	return Plugin_Handled;
}

//[ Zone Editor Menu - !zones ]
public Action:sm_zones(client, args)
{
	mZones_Main(client);
	
	return Plugin_Handled;
}



//[ Rock The Vote - !rtv ]
public Action:sm_rtv(client, args)
{
	if(RTVEnabled)
	{
		new RTVTotal, RTVCount;
		RTVTotal = 0;
		RTVCount = 0;
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				RTVTotal++;
				
				if(RTVStatus[i])
				{
					RTVCount++;
				}
			}
		}
		
		new RTVNeeded = ((RTVTotal / 2) + 1);
		
		if(RTVStatus[client])
		{
			PrintToChat(client, " \x01\x06[Paradise] \x01You have already voted to change the map! Currently \x03%i/%i \x01votes to switch the map.", RTVCount, RTVNeeded);
		}
		else
		{
			if(RTVCount < (RTVNeeded))
			{
				RTVStatus[client] = true;
				
				RTVCount = RTVCount + 1;
				
				PrintToChatAll(" \x01\x06[Paradise] \x01%N has voted to change the map! Currently \x03%i/%i \x01votes to switch the map.", client, RTVCount, RTVNeeded);
				
				if(RTVCount >= (RTVNeeded))
				{
					m_RTV = true;
					MapVote();
				}
			}
		}
	}
	else
	{
		PrintToChat(client, " \x01\x06[Paradise] \x01Please wait at least 5 min. before attempting to rock the vote.");
	}
	
	return Plugin_Handled;
}


//[ Nominate - !nominate  | !nominate map_name ]
public Action:sm_nominate(client, args)
{
	if(TimeLeft > 3)
	{
		if(g_info[client][Level] >= 10)
		{
			if(NomCount <= 5)
			{
				if(args == 0) {
					SortNominations(client);
				}
				else if (args == 1) {
					
					new String:arg1[64];
					GetCmdArgString(arg1, sizeof(arg1));
					
					FindNomination(client, arg1); 
					
				}
			}
			else
			{
				PrintToChat(client, " \x01\x06[Paradise] \x01Nominations have been filled for this map!");
			}
		}
		else
		{
			PrintToChat(client, " \x01\x06[Paradise] \x01You must be above Level 10 to use the nomination feature!");
		}
	}
	
	return Plugin_Handled;
}


//[ Restart CMD - !r | !restart ]
public Action:sm_r(client, args)
{
	if(IsClientInGame(client))
	{
		new team = GetClientTeam(client);
		
		if(1 < team < 4)
		{
			CS_RespawnPlayer(client);
			if((g_ZonesLoaded) && g_ZoneExists[0])
			{
				TeleportToZone(client, 0);
				StopTimer(client);
			}
		}
	}
	
	return Plugin_Handled;
}

//[ Practice CMD - !p | !practice ]
public Action:sm_p(client, args)
{	
	if(!g_PracticeMode[client])
	{
		if(!IsPlayerInZone[0][client])
		{
			StopTimer(client);
			SetEntityMoveType(client, MOVETYPE_NOCLIP);
			g_PracticeMode[client] = true;
		
			PrintToChat(client, " \x01\x06[Paradise] \x01Practice Mode Toggled!");
		}
		else
		{
			PrintToChat(client, " \x01\x06[Paradise] You must be outside the Start Zone to use this command!");
		}
	}
	else if(g_PracticeMode[client])
	{
		if(!IsPlayerInZone[0][client])
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			g_PracticeMode[client] = false;
			//FakeClientCommand(client, "sm_r");
			
			PrintToChat(client, " \x01\x06[Paradise] \x01Practice Mode Toggled!");
		}
		else
		{
			PrintToChat(client, " \x01\x06[Paradise] You must be outside the Start Zone to use this command!");
		}
	}
	
	return Plugin_Handled;
}


//[ Auto CMD - !auto ]
public Action:sm_auto(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 1;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Legit CMD - !legit ]
public Action:sm_legit(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 2;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Freestyle CMD - !freestyle ]
public Action:sm_freestyle(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 3;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Parkour CMD - !parkour ]
public Action:sm_parkour(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 4;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Half-Sideways CMD - !hsw | !half-sideways ]
public Action:sm_hsw(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 5;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Sideways CMD - !sideways | !sw ]
public Action:sm_sideways(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 6;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ W-Only CMD - !wonly ]
public Action:sm_wonly(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		g_info[client][Style] = 7;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Bonus CMD - !b | !bonus ]
public Action:sm_b(client, args)
{
	new team = GetClientTeam(client);
	
	if(1 < team < 4)
	{
		if(!IsPlayerInZone[0][client])
		{
			if((g_ZonesLoaded) && g_ZoneExists[2])
			{
				TeleportToZone(client, 2);
				CreateTimer(0.2, ResetTimer, GetClientSerial(client))
			}
			else
			{
				PrintToChat(client, " \x01\x06[Paradise] This Map Has No Bonus Stage!");
			}
		}
		else
		{
			PrintToChat(client, " \x01\x06[Paradise] You must be outside the Start Zone to use this command!");
		}
	}
	
	return Plugin_Handled;
}

public Action:ResetTimer(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial); // Validate the client serial
	
	if (client == 0) // The serial is no longer valid, the player must have disconnected
	{
		return Plugin_Stop;
	}
	
	StopTimer(client);
	
	return Plugin_Stop;
}

//[ Spectate CMD - !spec PlayerName | !spectate PlayerName ]
public Action:sm_spectate(client, args)
{
	if (args == 0)
	{
		if (IsPlayerAlive(client) && IsClientInGame(client))
		{
			ChangeClientTeam(client, 1);
		}
	}
	else if (args == 1)
	{
		new String:arg1[64];
		GetCmdArgString(arg1, sizeof(arg1));
		
		new target = FindTarget(client, arg1, true, true);
		if (target == -1) 
		{
			return Plugin_Handled;
		}
		if (IsClientInGame(target))
		{
			if (!IsPlayerAlive(target))
			{
				ReplyToCommand(client, "[SM] %t", "Target must be alive");
				return Plugin_Handled;
			}
			ChangeClientTeam(client, 1);
			FakeClientCommand(client, "spec_player_by_name %N", target);
		}
		if (!IsClientInGame(target)) ReplyToCommand(client, "[SM] %t", "Target is not in game");
	}
	return Plugin_Handled;
}

//[ Hide Weapons - !hideweapons ]
public Action:sm_hideweapons(client, args)
{
	HideViewModel(client);
	
	if (g_bViewModel[client])
		PrintToChat(client, " \x01\x06[Paradise] \x01Your weapons are now visible!");
	else
		PrintToChat(client, " \x01\x06[Paradise] \x01Your weapons are now hidden!");
		
		
	return Plugin_Handled;
}

public HideViewModel(client)
{
	if (!g_bViewModel[client])
	{
		g_bViewModel[client]=true;
		Client_SetDrawViewModel(client,true);
	}
	else
	{
		g_bViewModel[client]=false;
		Client_SetDrawViewModel(client,false);
	}
}

//[ Give Player Pistols - !usp | !glock ]
public Action:sm_usp(client, args)
{
	decl String:CurWeapon[64];
	GetClientWeapon(client, CurWeapon, sizeof(CurWeapon));
		
	if(!StrEqual(CurWeapon, "weapon_usp_silencer", false))
	{
		new ent = GetPlayerWeaponSlot(client, 1);
		RemovePlayerItem(client, ent);
		RemoveEdict(ent);
		
		GivePlayerItem(client, "weapon_usp_silencer");
	}
}

public Action:sm_sh(client, args)
{
	CreateTimer(0.1, StrafeHack, TIMER_REPEAT, client);
	testint = 0;
}

public Action:StrafeHack(Handle:timer, any:client)
{
	new Float:vec[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
	
	new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
	
	if(testint == 0)
	{
		testint = 1;
	}
	
	if(vec[0] == 0.0)
		vec[0] = 1.0;
	if(vec[1] == 0.0)
		vec[1] = 1.0;
	if(vec[2] == 0.0)
		vec[2] = 1.0;
	
	if(testint == 1 && !onground)
	{
		vec[1] = -400.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);  
		testint = 2;
	}
	else if(testint == 2 && !onground)
	{
		vec[1] = 400.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);
		testint = 1;
	}
}


public Action:sm_glock(client, args)
{
	decl String:CurWeapon[64];
	GetClientWeapon(client, CurWeapon, sizeof(CurWeapon));
		
	if(!StrEqual(CurWeapon, "weapon_glock", false))
	{
		new ent = GetPlayerWeaponSlot(client, 1);
		RemovePlayerItem(client, ent);
		RemoveEdict(ent);
		
		GivePlayerItem(client, "weapon_glock");
	}
}



public Action:sm_vip(client, args)
{
	if(IsValidClient(client, true))
	{
		if(CheckCommandAccess(client, "sm_vip", ADMFLAG_CUSTOM2, true))
		{
			mDonator_Main(client);
		}
		else
		{
			decl String:steamid[64];
			
			GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
			
			new f = 0;
			
			for(new i = 0; i <= 29; i++)
			{
				if(StrEqual(steamid, SpringBR2016_Players[i], true))
				{
					mDonator_Main(client);
					
					i = 30;
					f++;
				}
			}
			
			if(f == 0)
			{
				for(new i = 0; i <= 31; i++)
				{
					if(StrEqual(steamid, SummerBR2016_Players[i], true))
					{
						mDonator_Main(client);
						
						i = 32;
						f++;
					}
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_models(client, args)
{
	if(IsValidClient(client, true))
	{
		if(CheckCommandAccess(client, "sm_models", ADMFLAG_CUSTOM2, true))
		{
			mDonator_Models(client);
		}
	}
	
	return Plugin_Handled;
}






//|| ADMIN COMMANDS ||//

public Action:sm_calcscore(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_calcscore <steamid>");
		return Plugin_Handled;
	}
	
	decl String:arg1[64];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	CalculateScore(arg1);
	
	return Plugin_Handled;
}

// Give Players XP
public Action:sm_givexp(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_givexp <#userid|name> [XP]");
		return Plugin_Handled;
	}
	
	decl String:arg1[64], String:arg2[20]; 
	new target = -1;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	if(StringToInt(arg2) <= 0 )
	{
		ReplyToCommand(client, "[SM] Invalid XP. Must be greater than zero.");
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
	
	GivePlayerXP(target, StringToInt(arg2));
	
	return Plugin_Handled;
}

public Action:sm_addmap(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_addmap <mapname>, 'tier', 'stages', 'XP'");
		return Plugin_Handled;
	}

	decl String:arg[255], String:amMap[65], amTier, String:amStages[15], amXP;
	GetCmdArg(1, amMap, sizeof(amMap));
	GetCmdArg(3, amStages, sizeof(amStages));
	
	GetCmdArg(2, arg, sizeof(arg));
	amTier = StringToInt(arg);
	GetCmdArg(4, arg, sizeof(arg));
	amXP = StringToInt(arg);
	
	AddMap(amMap, amTier, amStages, amXP);
	
	PrintToChat(client, " \x01\x06[Paradise] Your Map has been added successfully!");
	
	return Plugin_Handled;
}

public Action:sm_deletemap(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_deletemap <mapname>");
		return Plugin_Handled;
	}

	decl String:amMap[65];
	GetCmdArg(1, amMap, sizeof(amMap));
	
	DeleteMap(amMap);
	
	PrintToChat(client, " \x01\x06[Paradise] Your Map has been removed successfully!");
	
	return Plugin_Handled;
}

public Action:sm_addvip(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_addvip <steamid> 'amount'");
		return Plugin_Handled;
	}

	decl String:arg[255], String:amID[64], Float:amAmount;
	GetCmdArg(1, amID, sizeof(amID));
	GetCmdArg(2, arg, sizeof(arg));
	
	amAmount = StringToFloat(arg);
	
	AddVIP(amID, amAmount);
	
	return Plugin_Handled;
}

/**public Action:sm_celebrate(client, args)
{	
	PrintToChatAll(" \n\n\n");
	PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \n\n\n");
	PrintToChatAll(" \x07★\x01★\x01\x0B★ \x01HAPPY 4TH OF JULY! \x01\x0BITS TIME TO CELEBRATE! \x07★\x01★\x01\x0B★");
	
	CreateTimer(15.0, MessageCeleb_Timer, _, TIMER_REPEAT);
	
	CreateTimer(4.0, Celebration_Timer, GetClientSerial(client), TIMER_REPEAT);
	
	return Plugin_Handled;
}

public Action:MessageCeleb_Timer(Handle:timer, any:serial)
{
	PrintToChatAll(" \n\n\n");
	PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \n\n\n");
	PrintToChatAll(" \x07★\x01★\x01\x0B★ \x01HAPPY 4TH OF JULY! \x01\x0BITS TIME TO CELEBRATE! \x07★\x01★\x01\x0B★");
	
	return Plugin_Continue;
}

public Action:Celebration_Timer(Handle:timer, any:serial)
{	
	decl String:FireworkSND[128];
	Format(FireworkSND, 128, "sourcemod/paradise/firework.mp3");
	FakePrecacheSound("/sourcemod/paradise.firework.mp3");

	new client = GetClientFromSerial(serial);
	
	GetClientAbsOrigin(client, g_fOrigin);
	
	new Float:FireworkHeight;
	FireworkHeight = GetRandomFloat(400.0, 500.0);
	g_fOrigin[2] = (g_fOrigin[2] + FireworkHeight);
	
	new FireworkType = GetRandomInt(1, 3);
	
	if(FireworkType == 1)
	{
		EmitSoundToAllAny(FireworkSND);
		TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
		TE_SendToAll();
		
		TE_SetupGlowSprite(g_fOrigin, g_GlowMaterial, 3.0, 3.0, 3);
		TE_SendToAll();
	}
	else if(FireworkType == 2)
	{
		decl Float:g_fAir[3];
		
		EmitSoundToAllAny(FireworkSND);
		TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
		TE_SendToAll();
		
		AddVectors(g_fOrigin, g_fAir, g_fAir);
		g_fAir[2] = (g_fAir[2] - 50.0);
		g_fAir[1] = (g_fAir[1] + 100.0);
		
		TE_SetupSparks(g_fAir, g_fDir, 1000, 1000);
		TE_SendToAll();
	}
	else if(FireworkType == 3)
	{
		decl Float:g_fAir[3];
		
		EmitSoundToAllAny(FireworkSND);
		TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
		TE_SendToAll();
		
		AddVectors(g_fOrigin, g_fAir, g_fAir);
		g_fAir[2] = (g_fAir[2] - 50.0);
		g_fAir[1] = (g_fAir[1] + 100.0);
		
		TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
		TE_SendToAll();

		g_fAir[2] = (g_fAir[2] + 25.0);
		g_fAir[0] = (g_fAir[0] + 100.0);
		
		TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
		TE_SendToAll();
	}
	
	return Plugin_Continue;
}**/




public Action:sm_eve(client, args)
{
	mEVE_Main(client);
	
	return Plugin_Handled;
}

public Action:sm_playauto(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-1", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_playlegit(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-2", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_playfreestyle(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-3", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_playparkour(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-4", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_playhsw(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-5", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_playsw(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-6", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_playwonly(client, args)
{
	new g_EVEBot = -1;
	
	decl String:sPath[PLATFORM_MAX_PATH];
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
		
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
			
			Format(sPath, sizeof(sPath), "%sWR-7", Map[MapName]);
			
			BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
		}
		else
		{
			PrintToChat(client, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
		}
	}
	
	return Plugin_Handled;
}


/*
public Action:sm_spawneve(client, args)
{
    new String:entIndex_tmp[16];
	new Float:evepos[3];
	new Float:playerang[3];
	
	new Float:pos[3], Float:ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
				
	TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	TR_GetEndPosition(evepos);
	
	new ent = CreateEntityByName("hostage_entity");
	new temp_image = CreateEntityByName("prop_dynamic_override");
	
	IntToString(EntIndexToEntRef(temp_image), entIndex_tmp, sizeof(entIndex_tmp)-1);
	
	DispatchKeyValue(ent, "targetname", entIndex_tmp);
	DispatchSpawn(ent);
	if( DispatchSpawn(ent) )
	{
		
	}
	
	DispatchKeyValue(temp_image, "model", "models/player/paradise/eve/eve.mdl");
	DispatchKeyValue(temp_image, "DefaultAnim", "Idle_lower");
	DispatchKeyValue(temp_image, "parent", entIndex_tmp);

	if( DispatchSpawn(temp_image) )
	{
		GetClientEyeAngles(client, playerang);
		
		TeleportEntity(temp_image, evepos, playerang, NULL_VECTOR);
		SetEntProp(temp_image, Prop_Data, "m_CollisionGroup", 0);
		SetEntProp(temp_image, Prop_Data, "m_nRenderMode", 3);
		
		SetVariantString("Idle_lower");
		AcceptEntityInput(temp_image, "SetAnimation"); 
	
		// Parent
		SetVariantString(entIndex_tmp);
		AcceptEntityInput(temp_image, "SetAttached");
		
		ActivateEntity(temp_image);
		
		SetClientViewEntity(client, temp_image);
		
		g_EVEMode[client] = true;
		g_EVEEntity[client] = temp_image;
		g_EVEParent[client] = ent;
	}
	
	return Plugin_Handled;
}

public Action:sm_regview(client, args)
{
	SetClientViewEntity(client, client);
	
	g_EVEMode[client] = false;
}

public Action:sm_eveview(client, args)
{
	SetClientViewEntity(client, g_EVEEntity[client]);
	
	g_EVEMode[client] = true;
}

public SyncEVE()
{	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && g_EVEMode[i])
		{
		}
	}
}

public Action:sm_afterimage(client, args)
{
    new String:entIndex_tmp[16];
	new Float:playerpos[3];
	new Float:playerang[3];
	
	new ent = CreateEntityByName("hostage_entity");
	new temp_image = CreateEntityByName("prop_dynamic_override");
	
	IntToString(EntIndexToEntRef(temp_image), entIndex_tmp, sizeof(entIndex_tmp)-1);
	
	DispatchKeyValue(ent, "targetname", entIndex_tmp);
	DispatchKeyValue(ent, "disableshadows", "1");
	DispatchSpawn(ent);
	if( DispatchSpawn(ent) )
	{
		SetEntityModel(ent, "models/blackout.mdl");
		SetEntProp(temp_image, Prop_Data, "m_CollisionGroup", 0);
	}
	
	DispatchKeyValue(temp_image, "model", "models/player/paradise/eve/eve.mdl");
	DispatchKeyValue(temp_image, "DefaultAnim", "Idle_lower");
	DispatchKeyValue(temp_image, "parent", entIndex_tmp);

	if( DispatchSpawn(temp_image) )
	{
		GetClientAbsOrigin(client, playerpos);
		GetClientEyeAngles(client, playerang);
		
		TeleportEntity(temp_image, playerpos, playerang, NULL_VECTOR);
		SetEntProp(temp_image, Prop_Data, "m_CollisionGroup", 0);
		SetEntProp(temp_image, Prop_Data, "m_nRenderMode", 3);
		
		SetVariantString("Idle_lower");
		AcceptEntityInput(temp_image, "SetAnimation"); 
	
		// Parent
		SetVariantString(entIndex_tmp);
		AcceptEntityInput(temp_image, "SetAttached");
		
		ActivateEntity(temp_image);
	}

	aiFade[temp_image] = 17.0;
	aiA[temp_image] = 255;

	CreateTimer(0.1, FadeImage, EntIndexToEntRef(temp_image), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action:FadeImage(Handle:timer, any:entRef)
{
	new botimage = EntRefToEntIndex(entRef);

	if(aiFade[botimage] <= 0.0)
	{
		SetEntityRenderMode(botimage, RENDER_NONE);
		SetEntityRenderColor(botimage, 0, 0, 0, 0);
		AcceptEntityInput(botimage, "kill");
	
		return Plugin_Stop;
	}
	else
	{
		SetVariantInt(aiA[botimage]);
		AcceptEntityInput(botimage, "Alpha");

		aiA[botimage] = (aiA[botimage] - 15);
		
		aiFade[botimage] = (aiFade[botimage] - 1.0);

		return Plugin_Continue;
	}

}
*/
