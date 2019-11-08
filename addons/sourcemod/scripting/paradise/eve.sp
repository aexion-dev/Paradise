
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | EVE",
    author = "Aexi0n",
    description = "Official Bhop Timer for Paradise Servers",
    version = "5.0",
    url = ""
}

new replayCount;

//----------------------------
// Initialize EVE Replay Bot |
//----------------------------

public LoadEVE(client)
{
	decl String:buffer[35];
		
	Format(buffer, sizeof(buffer), "Status: Online | Timeleft: %i min.", TimeLeft);
	CS_SetClientClanTag(client, "EVE");
	SetClientName(client, buffer);
}

public Action:BotMimic_OnPlayerStartsMimicing(client, String:name[], String:category[], String:evePath[])
{
	decl String:buffer[256];
	decl String:sTime[15];
	decl String:Message[256];
	
	if(StrContains(name, "1", false) != -1)
	{
		FormatPlayerTime(Auto_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[Auto] %s | %s", Auto_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[Auto World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", Auto_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
	else if(StrContains(name, "2", false) != -1)
	{
		FormatPlayerTime(Legit_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[Legit] %s | %s", Legit_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[Legit World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", Legit_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
	else if(StrContains(name, "3", false) != -1)
	{
		FormatPlayerTime(Freestyle_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[Freestyle] %s | %s", Freestyle_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[Freestyle World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", Freestyle_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
	else if(StrContains(name, "4", false) != -1)
	{
		FormatPlayerTime(Parkour_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[Parkour] %s | %s", Parkour_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[Parkour World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", Parkour_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
	else if(StrContains(name, "5", false) != -1)
	{
		FormatPlayerTime(HalfSideways_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[HSW] %s | %s", HalfSideways_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[Half-Sideways World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", HalfSideways_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
	else if(StrContains(name, "6", false) != -1)
	{
		FormatPlayerTime(Sideways_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[SW] %s | %s", Sideways_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[Sideways World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", Sideways_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
	else if(StrContains(name, "7", false) != -1)
	{
		FormatPlayerTime(WOnly_WR[Time], sTime, 15, false, 2);
		Format(buffer, 256, "[W-Only] %s | %s", WOnly_WR[PlayerName], sTime);
			
		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Now Playing: \x01\x06[W-Only World Record]");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Player: \x01%s", WOnly_WR[PlayerName]);
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Time: \x01\x06%s", sTime);
		PrintToChatAll(Message);
	}
}

public BotMimic_OnPlayerMimicLoops(client)
{
	if(replayCount == 1)
	{
		decl String:buffer[35];
		replayCount = 0;
		BotMimic_StopPlayerMimic(client);
		PrintToChatAll(" \x01\x03[EVE]: \x01Replay Finished!");
		
		Format(buffer, sizeof(buffer), "Status: Online | Timeleft: %i min.", TimeLeft);
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
	}
	else if(replayCount == 0)
	{
		replayCount++;
	}
}

