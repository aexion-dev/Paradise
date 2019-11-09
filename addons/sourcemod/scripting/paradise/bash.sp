#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
    name = "1337H4X",
    author = "Aexi0n",
    description = "????",
    version = "UNKNOWN ERROR 305",
    url = ""
}


#define MAX_FRAMES 300

#define Button_Forward 0
#define Button_Back    1
#define Button_Left    2
#define Button_Right   3

#define Moving_Forward 0
#define Moving_Back    1
#define Moving_Left    2
#define Moving_Right   3

#define Turn_Left 0
#define Turn_Right 1

// Start/End Strafe Data
#define StrafeData_Button 0
#define StrafeData_TurnDirection 1
#define StrafeData_MoveDirection 2
#define StrafeData_Difference 3
#define StrafeData_Tick 4

#define AngleDelay_Difference 0
#define AngleDelay_NegativeEnd 1

// Key switch data
#define KeySwitchData_Button 0
#define KeySwitchData_Difference 1

#define DR_StartStrafe_LowDeviation (1 << 0)
#define DR_StartStrafe_AlwaysPositive (1 << 1)
#define DR_EndStrafe_LowDeviation (1 << 2)
#define DR_EndStrafe_AlwaysPositive (1 << 3)
#define DR_StartStrafeMatchesEndStrafe (1 << 4) // A way to catch an angle delay hack
#define DR_KeySwitchesTooPerfect (1 << 5)
#define DR_FailedManualAngleTest (1 << 6)
#define DR_ButtonsAndSideMoveDontMatch (1 << 7)
#define DR_ImpossibleSideMove (1 << 8)
#define DR_FailedManualMOTDTest (1 << 9)
#define DR_AngleDelay (1 << 10) // Player freezes their angles for 1 or more ticks after they press a button until the angle changes again

new g_iButtons[MAXPLAYERS + 1];
new g_iLastButtons[MAXPLAYERS + 1];
new g_iLastPressTick[MAXPLAYERS + 1][4];
new g_iLastReleaseTick[MAXPLAYERS + 1][4];
new Float:g_fLastMove[MAXPLAYERS + 1][3];
new g_iLastTurnDir[MAXPLAYERS + 1];
new g_iLastTurnTick[MAXPLAYERS + 1];
new g_iLastStopTurnTick[MAXPLAYERS + 1];
new bool:g_bIsTurning[MAXPLAYERS + 1];
new g_iReleaseTickAtLastEndStrafe[MAXPLAYERS + 1][4];
new Float:g_fLastAngles[MAXPLAYERS + 1][3];
new g_InvalidButtonSidemoveCount[MAXPLAYERS + 1];
new g_iCmdNum[MAXPLAYERS + 1];

new g_iStartStrafe_CurrentFrame[MAXPLAYERS + 1];
new g_iStartStrafe_Stats[MAXPLAYERS + 1][MAX_FRAMES][5];
new g_iStartStrafe_LastRecordedTick[MAXPLAYERS + 1];
new bool:g_bStartStrafe_IsRecorded[MAXPLAYERS + 1][MAX_FRAMES];
new g_iEndStrafe_CurrentFrame[MAXPLAYERS + 1];
new g_iEndStrafe_Stats[MAXPLAYERS + 1][MAX_FRAMES][5];
new g_iEndStrafe_LastRecordedTick[MAXPLAYERS + 1];
new bool:g_bEndStrafe_IsRecorded[MAXPLAYERS + 1][MAX_FRAMES];
new g_iKeySwitch_CurrentFrame[MAXPLAYERS + 1];
new g_iKeySwitch_Stats[MAXPLAYERS + 1][MAX_FRAMES][2];
new bool:g_bKeySwitch_IsRecorded[MAXPLAYERS + 1][MAX_FRAMES];
new g_iAngleDelay[MAXPLAYERS + 1][MAX_FRAMES][2];
new bool:g_bAngleDelay_IsRecorded[MAXPLAYERS + 1][MAX_FRAMES];
new g_iAngleDelay_CurrentFrame[MAXPLAYERS + 1];

new bool:g_bCheckedYet[MAXPLAYERS + 1];


//Clear Client Security Variables On Connection
public SS_RefreshClientData(client)
{
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		g_bStartStrafe_IsRecorded[client][idx] = false;
		g_bEndStrafe_IsRecorded[client][idx]   = false;
		g_bKeySwitch_IsRecorded[client][idx]   = false;
		g_bAngleDelay_IsRecorded[client][idx]  = false;
	}
	
	g_iStartStrafe_CurrentFrame[client] = 0;
	g_iEndStrafe_CurrentFrame[client]   = 0;
	g_iKeySwitch_CurrentFrame[client]   = 0;
	g_iAngleDelay_CurrentFrame[client]  = 0;
	g_bCheckedYet[client] = false;
}

public Action:Bash_Stats(client, args)
{
	if(args == 0)
	{
		new target;
		if(IsPlayerAlive(client))
		{
			target = client;
		}
		else
		{
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		}
		
		if(0 < target <= MaxClients)
		{
			ShowBashStats(client, GetClientUserId(target));
		}
	}
	else
	{
		decl String:sArg[MAX_NAME_LENGTH];
		GetCmdArgString(sArg, MAX_NAME_LENGTH);

		if(sArg[0] == '#')
		{
			ReplaceString(sArg, MAX_NAME_LENGTH, "#", "", true);
			new target = GetClientOfUserId(StringToInt(sArg, 10));
			if(target)
			{
				ShowBashStats(client, GetClientUserId(target));
			}
			else
			{
				ReplyToCommand(client, "[BASH] No player with userid '%s'.", sArg);
			}
		}
		
		decl String:sName[MAX_NAME_LENGTH], bool:bFoundTarget;
		
		for(new target = 1; target <= MaxClients; target++)
		{
			if(IsClientInGame(target))
			{
				GetClientName(target, sName, MAX_NAME_LENGTH);
				if(StrContains(sName, sArg, false) != -1)
				{
					bFoundTarget = true;
					ShowBashStats(client, GetClientUserId(target));
				}
			}
		}
		
		if(!bFoundTarget)
		{
			ReplyToCommand(client, "[BASH] No player found with '%s' in their name.", sArg);
		}
	}
	
	return Plugin_Handled;
}

new g_iTarget[MAXPLAYERS + 1];

public ShowBashStats(client, userid)
{
	new target = GetClientOfUserId(userid);
	if(target == 0)
	{
		PrintToChat(client, "[BASH] Selected player no longer ingame.");
		return;
	}

	g_iTarget[client] = userid;
	new Handle:menu = CreateMenu(BashStats_MainMenu);
	
	decl String:sName[MAX_NAME_LENGTH];
	GetClientName(target, sName, sizeof(sName));
	
	SetMenuTitle(menu, "[BASH] - Select stats for %N", target);
	
	AddMenuItem(menu, "start",      "Start Strafe (Original)");
	AddMenuItem(menu, "end",        "End Strafe");
	AddMenuItem(menu, "angledelay", "Angle Delay");
	AddMenuItem(menu, "occdev",     "Poor Occurrence Deviation");
	AddMenuItem(menu, "keys",       "Key Switch");
	AddMenuItem(menu, "flags",      "Player flags", ITEMDRAW_DISABLED);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public BashStats_MainMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:sInfo[32];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		
		if(StrEqual(sInfo, "start"))
		{
			ShowBashStats_StartStrafes(param1);
		}
		else if(StrEqual(sInfo, "end"))
		{
			ShowBashStats_EndStrafes(param1);
		}
		else if(StrEqual(sInfo, "angledelay"))
		{
			ShowBashStats_StartEndDifference(param1);
		}
		else if(StrEqual(sInfo, "occdev"))
		{
			ShowBashStats_OccurrenceDeviation(param1);
		}
		else if(StrEqual(sInfo, "keys"))
		{
			ShowBashStats_KeySwitches(param1);
		}
		else if(StrEqual(sInfo, "flags"))
		{
			
		}
	}
	
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}	
}

public ShowBashStats_OccurrenceDeviation(client)
{
	new target = GetClientOfUserId(g_iTarget[client]);
	if(target == 0)
	{
		PrintToChat(client, "[BASH] Selected player no longer ingame.");
		return;
	}
	
	// [Sample Size] [0 = Neg, 1 = Pos] [Maximum Allowed Difference];
	new sStrafe[2][16];
	new eStrafe[2][16];
	new sSize, eSize;
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		if(g_bStartStrafe_IsRecorded[target][idx] == true)
		{
			new difference = g_iStartStrafe_Stats[target][idx][StrafeData_Difference];
			new absDiff    = RoundToFloor(FloatAbs(float(difference)));
			sStrafe[difference >= 0][absDiff]++;
			sSize++;
		}
		
		if(g_bEndStrafe_IsRecorded[target][idx] == true)
		{
			new difference = g_iEndStrafe_Stats[target][idx][StrafeData_Difference];
			new absDiff    = RoundToFloor(FloatAbs(float(difference)));
			eStrafe[difference >= 0][absDiff]++;
			eSize++;
		}
	}
	
	if(sSize == 0 && eSize == 0)
	{
		PrintToChat(client, "[BASH] Player '%N' has no strafe stats.", target);
		ShowBashStats(client, GetClientUserId(target));
		return;
	}
	
	new Float:startStrafeMean[2], Float:startStrafeSD[2], Float:endStrafeMean[2], Float:endStrafeSD[2];
	startStrafeMean[0] = GetAverage(sStrafe[0], 16, false);
	startStrafeMean[1] = GetAverage(sStrafe[1], 16, false);
	startStrafeSD[0]   = StandardDeviation(sStrafe[0], 16, startStrafeMean[0], false);
	startStrafeSD[1]   = StandardDeviation(sStrafe[1], 16, startStrafeMean[1], false);
	endStrafeMean[0]   = GetAverage(sStrafe[0], 16, false);
	endStrafeMean[1]   = GetAverage(sStrafe[1], 16, false);
	endStrafeSD[0]     = StandardDeviation(eStrafe[0], 16, endStrafeMean[0], false);
	endStrafeSD[1]     = StandardDeviation(eStrafe[1], 16, endStrafeMean[1], false);
	
	new Handle:menu = CreateMenu(BashStats_StartStrafesMenu);
	SetMenuTitle(menu, "[BASH] Occurence Deviation stats for %N\n \nStart Strafe (N): %.1f, Start Strafe (P): %.1f\nEnd Strafe (N): %.1f, End Strafe (P): %.1f",
		target,
		startStrafeSD[0], startStrafeSD[1],
		endStrafeSD[0], endStrafeSD[1]);
	AddMenuItem(menu, "", "-------------------", ITEMDRAW_DISABLED);
	
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public SS_StrafeCheck(client, style, Float:time, jumps, strafes, Float:sync)
{
	new SSarray[MAX_FRAMES];
	new SSbuttons[4];
	new SSsize;
	
	new ESarray[MAX_FRAMES];
	new ESbuttons[4];
	new ESsize;
	
	new KSarray[MAX_FRAMES];
	new KSsize;
	
	//Check Player Strafes & Player KeySwitches
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		if(g_bStartStrafe_IsRecorded[client][idx] == true)
		{
			SSarray[idx] = g_iStartStrafe_Stats[client][idx][StrafeData_Difference];
			SSbuttons[g_iStartStrafe_Stats[client][idx][StrafeData_Button]]++;
			SSsize++;
		}
		
		if(g_bEndStrafe_IsRecorded[client][idx] == true)
		{
			ESarray[idx] = g_iEndStrafe_Stats[client][idx][StrafeData_Difference];
			ESbuttons[g_iEndStrafe_Stats[client][idx][StrafeData_Button]]++;
			ESsize++;
		}
		
		if(g_bKeySwitch_IsRecorded[client][idx] == true)
		{
			KSarray[idx] = g_iKeySwitch_Stats[client][idx][KeySwitchData_Difference];
			KSsize++;
		}
	}
	
	new Float:startStrafeMean = GetAverage(SSarray, SSsize);
	new Float:startStrafeSD   = StandardDeviation(SSarray, SSsize, startStrafeMean);
	
	new Float:endStrafeMean = GetAverage(ESarray, ESsize);
	new Float:endStrafeSD   = StandardDeviation(ESarray, ESsize, endStrafeMean);
	
	new Float:keyswitchMean = GetAverage(KSarray, KSsize);
	new Float:keyswitchSD   = StandardDeviation(KSarray, KSsize, keyswitchMean);
	
	g_info[client][SSD] = startStrafeSD;
	g_info[client][ESD] = endStrafeSD;
	g_info[client][KSD] = keyswitchSD;
	
	if((startStrafeSD <= 1.0 || endStrafeSD <= 1.0 || keyswitchSD <= 0.5) || sync >= 97.0 || sync < 1.0 || strafes > 1000 || strafes <= 1) 
	{
		decl String:SS_CurMap[120], String:SS_CurStyle[64];
		GetCurrentMap(SS_CurMap, 120);
		
		switch(style)
		{
			case 1: {Format(SS_CurStyle, 32, "Auto");}
			case 2: {Format(SS_CurStyle, 32, "Legit");}
			case 3: {Format(SS_CurStyle, 32, "Freestyle");}
			case 4: {Format(SS_CurStyle, 32, "Parkour");}
			case 5: {Format(SS_CurStyle, 32, "Half-Sideways");}
			case 6: {Format(SS_CurStyle, 32, "Sideways");}
			case 7: {Format(SS_CurStyle, 32, "W-Only");}
		}
		
		
		SS_UploadStats(client, SS_CurMap, SS_CurStyle, time, jumps, strafes, sync, startStrafeSD, endStrafeSD, keyswitchSD);
	}
}

public ShowBashStats_StartStrafes(client)
{
	new target = GetClientOfUserId(g_iTarget[client]);
	if(target == 0)
	{
		PrintToChat(client, "[BASH] Selected player no longer ingame.");
		return;
	}
	
	new array[MAX_FRAMES];
	new buttons[4];
	new size;
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		if(g_bStartStrafe_IsRecorded[target][idx] == true)
		{
			array[idx] = g_iStartStrafe_Stats[target][idx][StrafeData_Difference];
			buttons[g_iStartStrafe_Stats[target][idx][StrafeData_Button]]++;
			size++;
		}
	}
	
	if(size == 0)
	{
		PrintToChat(client, "[BASH] Player '%N' has no start strafe stats.", target);
	}
	
	new Float:startStrafeMean = GetAverage(array, size);
	new Float:startStrafeSD   = StandardDeviation(array, size, startStrafeMean);
	
	new Handle:menu = CreateMenu(BashStats_StartStrafesMenu);
	SetMenuTitle(menu, "[BASH] Start Strafe stats for %N\nAverage: %.2f | Deviation: %.2f\nA: %d, D: %d, W: %d, S: %d\n ", 
		target, startStrafeMean, startStrafeSD,
		buttons[2], buttons[3], buttons[0], buttons[1]);
	
	new String:sDisplay[128];
	for(new idx; idx < size; idx++)
	{
		Format(sDisplay, sizeof(sDisplay), "%s%d ", sDisplay, array[idx]);
		
		if((idx + 1) % 10 == 0  || size - idx == 1)
		{
			AddMenuItem(menu, "", sDisplay, ITEMDRAW_DISABLED);
			FormatEx(sDisplay, sizeof(sDisplay), "");
		}
	}
	
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public BashStats_StartStrafesMenu(Handle:menu, MenuAction:action, param1, param2)
{
	/*
	if(action == MenuAction_Select)
	{
		
	}	
	*/
	if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			ShowBashStats(param1, g_iTarget[param1]);
	}
	
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}	
}

public ShowBashStats_EndStrafes(client)
{
	new target = GetClientOfUserId(g_iTarget[client]);
	if(target == 0)
	{
		PrintToChat(client, "[BASH] Selected player no longer ingame.");
		return;
	}
	
	new array[MAX_FRAMES];
	new buttons[4];
	new size;
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		if(g_bEndStrafe_IsRecorded[target][idx] == true)
		{
			array[idx] = g_iEndStrafe_Stats[target][idx][StrafeData_Difference];
			buttons[g_iEndStrafe_Stats[target][idx][StrafeData_Button]]++;
			size++;
		}
	}
	
	if(size == 0)
	{
		PrintToChat(client, "[BASH] Player '%N' has no end strafe stats.", target);
	}
	
	new Float:mean = GetAverage(array, size);
	new Float:sd   = StandardDeviation(array, size, mean);
	
	new Handle:menu = CreateMenu(BashStats_EndStrafesMenu);
	SetMenuTitle(menu, "[BASH] End Strafe stats for %N\nAverage: %.2f | Deviation: %.2f\nA: %d, D: %d, W: %d, S: %d\n ", 
		target, mean, sd,
		buttons[2], buttons[3], buttons[0], buttons[1]);
	
	new String:sDisplay[128];
	for(new idx; idx < size; idx++)
	{
		Format(sDisplay, sizeof(sDisplay), "%s%d ", sDisplay, array[idx]);
		
		if((idx + 1) % 10 == 0  || (size - idx == 1))
		{
			AddMenuItem(menu, "", sDisplay, ITEMDRAW_DISABLED);
			FormatEx(sDisplay, sizeof(sDisplay), "");
		}
	}
	
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXITBACK);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public BashStats_EndStrafesMenu(Handle:menu, MenuAction:action, param1, param2)
{
	/*
	if(action == MenuAction_Select)
	{
		
	}	
	*/
	if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			ShowBashStats(param1, g_iTarget[param1]);
	}
	
	if (action & MenuAction_End)
	{
		CloseHandle(menu);
	}	
}

public ShowBashStats_StartEndDifference(client)
{
	new target = GetClientOfUserId(g_iTarget[client]);
	if(target == 0)
	{
		PrintToChat(client, "[BASH] Selected player no longer ingame.");
		return;
	}
	
	new array[MAX_FRAMES];
	new header[4];
	new size;
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		if(g_bAngleDelay_IsRecorded[target][idx] == true)
		{
			array[idx] = g_iAngleDelay[target][idx][AngleDelay_Difference];
			size++;
			
			if(g_iAngleDelay[target][idx][AngleDelay_NegativeEnd] == 1)
			{
				header[1]++;
				
				if(array[idx])
				{
					header[0]++;
				}
			}
			else
			{
				header[3]++;
				
				if(array[idx])
				{
					header[2]++;
				}
			}
		}
	}
	
	if(size == 0)
	{
		PrintToChat(client, "[BASH] Player '%N' has no stats.", target);
	}
	
	new Handle:menu = CreateMenu(BashStats_EndStrafesMenu);
	// NES must be close 100% and the denominator must be 25 +- 10. PES % must be under 70%
	SetMenuTitle(menu, "[BASH] Angle delay stats for %N\nNES: %d/%d (%.1f) | PES: %d/%d (%.1f)\n ", 
		target, header[0], header[1], float(header[0]) / float(header[1]) * 100.0, header[2], header[3], float(header[2]) / float(header[3]) * 100.0); 

	new String:sDisplay[128];
	for(new idx; idx < size; idx++)
	{
		Format(sDisplay, sizeof(sDisplay), "%s%d ", sDisplay, array[idx]);
		
		if((idx + 1) % 10 == 0  || (size - idx == 1))
		{
			AddMenuItem(menu, "", sDisplay, ITEMDRAW_DISABLED);
			FormatEx(sDisplay, sizeof(sDisplay), "");
		}
	}
	
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXITBACK);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public ShowBashStats_KeySwitches(client)
{
	new target = GetClientOfUserId(g_iTarget[client]);
	if(target == 0)
	{
		PrintToChat(client, "[BASH] Selected player no longer ingame.");
		return;
	}
	
	new array[MAX_FRAMES];
	new size;
	for(new idx; idx < MAX_FRAMES; idx++)
	{
		if(g_bKeySwitch_IsRecorded[target][idx] == true)
		{
			array[idx] = g_iKeySwitch_Stats[target][idx][KeySwitchData_Difference];
			size++;
		}
	}
	new Float:mean = GetAverage(array, size);
	new Float:sd   = StandardDeviation(array, size, mean);
	
	new Handle:menu = CreateMenu(BashStats_KeySwitchesMenu);
	SetMenuTitle(menu, "[BASH] Key Switch stats for %N\nAverage: %.2f | Deviation: %.2f\n ", target, mean, sd);
	
	new String:sDisplay[128];
	for(new idx; idx < size; idx++)
	{
		Format(sDisplay, sizeof(sDisplay), "%s%d ", sDisplay, array[idx]);
		
		if((idx + 1) % 10 == 0  || (size - idx == 1))
		{
			AddMenuItem(menu, "", sDisplay, ITEMDRAW_DISABLED);
			FormatEx(sDisplay, sizeof(sDisplay), "");
		}
	}
	
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXITBACK);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public BashStats_KeySwitchesMenu(Handle:menu, MenuAction:action, param1, param2)
{
	/*
	if(action == MenuAction_Select)
	{
		
	}	
	*/
	if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			ShowBashStats(param1, g_iTarget[param1]);
	}
	
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}	
}

Float:StandardDeviation(array[], size, Float:mean, bool:countZeroes = true)
{
	new Float:sd;
	
	for(new idx; idx < size; idx++)
	{
		if(countZeroes || array[idx] != 0)
		{
			sd += Pow(float(array[idx]) - mean, 2.0);
		}
	}
	
	return SquareRoot(sd/size);
}

Float:GetAverage(array[], size, bool:countZeroes = true)
{
	new total;
	
	for(new idx; idx < size; idx++)
	{
		if(countZeroes || array[idx] != 0)
		{
			total += array[idx];
		}
		
	}
	
	return float(total) / float(size);
}

new g_iRunCmdsPerSecond[MAXPLAYERS + 1];
new Float:g_fLastCheckTime[MAXPLAYERS + 1];
new MoveType:g_mLastMoveType[MAXPLAYERS + 1];

public SS_ClientStats(client, buttons, impulse, Float:vel[3], Float:angles[3], weapon, subtype, cmdnum, tickcount, seed, mouse[2])
{
/*
	if(g_bCheckedYet[client] == false)
	{
		g_bCheckedYet[client] = true;
		g_fLastCheckTime[client] = GetEngineTime();
	}
	
	if(GetEntityMoveType(client) != MOVETYPE_NONE)
	{
		g_mLastMoveType[client] = GetEntityMoveType(client);
	}
	
	float tickRate = 1.0 / GetTickInterval();
	g_iRunCmdsPerSecond[client]++;
	if(GetEngineTime() - g_fLastCheckTime[client] >= 1.0)
	{
		g_fLastCheckTime[client] = GetEngineTime();
		if(float(g_iRunCmdsPerSecond[client]) / tickRate <= 0.95)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		else
		{
			SetEntityMoveType(client, g_mLastMoveType[client]);
		}
		
		g_iRunCmdsPerSecond[client] = 0;
	}
	*/
	
	
	
	if(!IsFakeClient(client) && IsPlayerAlive(client))
	{
		decl bool:bCheck;
		
		bCheck = true;
		
		UpdateButtons(client, vel, buttons);
		
		if(bCheck == true)
		{
			CheckForIllegalMovement(client, vel, buttons);
		}
		
		// Check for any changes that need to update
		CheckForEndKey(client);
		CheckForTurn(client, angles);
		CheckForStartKey(client);
		if(!(GetEntityFlags(client) & (FL_ONGROUND|FL_INWATER)) && bCheck)
		{
			// Update the stats after everything has been checked (end stats first, then start)
			for(new idx; idx < 4; idx++)
			{
				if(g_iLastReleaseTick[client][idx] == g_iCmdNum[client])
				{
					ClientReleasedKey(client, idx);
				}
			}
			
			if(g_iLastTurnTick[client] == g_iCmdNum[client])
			{
				ClientTurned(client, g_iLastTurnDir[client]);
			}
			
			if(g_iLastStopTurnTick[client] == g_iCmdNum[client])
			{
				ClientStoppedTurning(client);
			}
			
			for(new idx; idx < 4; idx++)
			{
				if(g_iLastPressTick[client][idx] == g_iCmdNum[client])
				{
					ClientPressedKey(client, idx);
				}
			}
		}
		
		g_fLastMove[client][0]   = vel[0];
		g_fLastMove[client][1]   = vel[1];
		g_fLastMove[client][2]   = vel[2];
		g_fLastAngles[client][0] = angles[0];
		g_fLastAngles[client][1] = angles[1];
		g_fLastAngles[client][2] = angles[2];
		g_iCmdNum[client]++;
	}
}

public CheckForStartKey(client)
{
	for(new idx; idx < 4; idx++)
	{
		if(!(g_iLastButtons[client] & (1 << idx)) && (g_iButtons[client] & (1 << idx)))
		{
			g_iLastPressTick[client][idx] = g_iCmdNum[client];
		}
	}
}

public ClientPressedKey(client, button)
{
	g_iLastPressTick[client][button] = g_iCmdNum[client];
	new turnDir = GetDesiredTurnDir(client, button, false);
	
	if(g_iLastTurnDir[client] == turnDir && g_iStartStrafe_LastRecordedTick[client] != g_iCmdNum[client])
	{
		new difference = g_iLastTurnTick[client] - g_iLastPressTick[client][button];
	
		if(-15 <= difference <= 15)
		{
			RecordStartStrafe(client, button, turnDir);
		}
	}
	
	// Record key switching
	new oppositeButton = GetOppositeButton(button);
	new difference = g_iLastPressTick[client][button] - g_iLastReleaseTick[client][oppositeButton];

	if(-15 <= difference <= 15)
	{
		RecordKeySwitch(client, button, oppositeButton);
	}
}

public CheckForEndKey(client)
{
	for(new idx; idx < 4; idx++)
	{
		if((g_iLastButtons[client] & (1 << idx)) && !(g_iButtons[client] & (1 << idx)))
		{
			g_iLastReleaseTick[client][idx] = g_iCmdNum[client];
		}
	}
}

public ClientReleasedKey(client, button)
{
	new turnDir = GetDesiredTurnDir(client, button, true);
	
	if((g_iLastTurnDir[client] == turnDir || g_bIsTurning[client] == false) && 
		g_iEndStrafe_LastRecordedTick[client] != g_iCmdNum[client])
	{
		new difference = g_iLastTurnTick[client] - g_iLastReleaseTick[client][button];
	
		if(-15 <= difference <= 15)
		{
			RecordEndStrafe(client, button, turnDir, "ClientReleasedKey");
		}
	}
}

public CheckForTurn(client, Float:angles[3])
{
	new Float:fAngleDiff = angles[1] - g_fLastAngles[client][1];
		
	if (fAngleDiff > 180)
		fAngleDiff -= 360;
	else if(fAngleDiff < -180)
		fAngleDiff += 360;
		
	if(fAngleDiff == 0.0 && g_bIsTurning[client] == true)
	{
		g_iLastStopTurnTick[client] = g_iCmdNum[client];
		g_bIsTurning[client]        = false;
	}
	else if(fAngleDiff > 0)
	{
		if(g_iLastTurnDir[client] == Turn_Right)
		{
			// Turned left
			g_iLastTurnTick[client] = g_iCmdNum[client];
			g_iLastTurnDir[client]  = Turn_Left;
			g_bIsTurning[client]    = true;
		}
	}
	else if(fAngleDiff < 0)
	{
		if(g_iLastTurnDir[client] == Turn_Left)
		{
			// Turned right
			g_iLastTurnTick[client] = g_iCmdNum[client];
			g_iLastTurnDir[client]  = Turn_Right;
			g_bIsTurning[client]    = true;
		}
	}
}

public ClientTurned(client, turnDir)
{
	new button         = GetDesiredButton(client, turnDir);
	
	new oppositeButton = GetOppositeButton(button);
	if(!(g_iButtons[client] & (1 << oppositeButton)) && 
		g_iEndStrafe_LastRecordedTick[client] != g_iCmdNum[client] &&
		g_iReleaseTickAtLastEndStrafe[client][oppositeButton] != g_iLastReleaseTick[client][oppositeButton])
	{
		new difference = g_iLastTurnTick[client] - g_iLastReleaseTick[client][oppositeButton];
	
		if(-15 <= difference <= 15)
		{
			RecordEndStrafe(client, oppositeButton, turnDir, "ClientTurned");
		}
	}
	
	// Check if client just ended the start of a strafe
	if(g_iButtons[client] & (1 << button) && g_iStartStrafe_LastRecordedTick[client] != g_iCmdNum[client])
	{
		new difference = g_iLastTurnTick[client] - g_iLastPressTick[client][button];
	
		if(-15 <= difference <= 15)
		{
			RecordStartStrafe(client, button, turnDir);
		}
	}
	
	// if client already let go of movement button, and end strafe hasn't been recorded this tick and since they released their key
	
}

public ClientStoppedTurning(client)
{
	new turnDir = g_iLastTurnDir[client];
	new button  = GetDesiredButton(client, turnDir);
	
	// if client already let go of movement button, and end strafe hasn't been recorded this tick and since they released their key
	if(!(g_iButtons[client] & (1 << button)) && 
		g_iEndStrafe_LastRecordedTick[client] != g_iCmdNum[client] &&
		g_iReleaseTickAtLastEndStrafe[client][button] != g_iLastReleaseTick[client][button])
	{
		new difference = g_iLastStopTurnTick[client] - g_iLastReleaseTick[client][button];
	
		if(-15 <= difference <= 15)
		{
			RecordEndStrafe(client, button, turnDir, "ClientStoppedTurning");
		}
	}
}

public RecordStartStrafe(client, button, turnDir)
{	
	g_iStartStrafe_LastRecordedTick[client] = g_iCmdNum[client];
	new moveDir = GetDirection(client);
	new currFrame = g_iStartStrafe_CurrentFrame[client];
	g_iStartStrafe_Stats[client][currFrame][StrafeData_Button]        = button;
	g_iStartStrafe_Stats[client][currFrame][StrafeData_TurnDirection] = turnDir;
	g_iStartStrafe_Stats[client][currFrame][StrafeData_MoveDirection] = moveDir;
	g_iStartStrafe_Stats[client][currFrame][StrafeData_Difference]    = g_iLastPressTick[client][button] - g_iLastTurnTick[client];
	g_iStartStrafe_Stats[client][currFrame][StrafeData_Tick]          = g_iCmdNum[client];
	g_bStartStrafe_IsRecorded[client][currFrame] = true;
	g_iStartStrafe_CurrentFrame[client] = (g_iStartStrafe_CurrentFrame[client] + 1) % MAX_FRAMES;
	
	StartStrafeRecorded(client, currFrame);
	
	//char sOutput[128], sButton[16], sTurn[16], sMove[16];
	//GetTurnDirectionName(turnDir, sTurn, sizeof(sTurn));
	//GetMoveDirectionName(button, sButton, sizeof(sButton));
	//GetMoveDirectionName(moveDir, sMove, sizeof(sMove));
	
	//PrintToBlacky("Turned %s | Pressed %s | Moving %s | Difference %d",
	//	sTurn,
	//	sButton,
	//	sMove,
	//	g_iStartStrafe_Stats[client][currFrame][StrafeData_Difference]);
}

stock RecordEndStrafe(client, button, turnDir, const String:caller[])
{
	g_iReleaseTickAtLastEndStrafe[client][button] = g_iLastReleaseTick[client][button];
	g_iEndStrafe_LastRecordedTick[client] = g_iCmdNum[client];
	new moveDir = GetDirection(client);
	
	new currFrame = g_iEndStrafe_CurrentFrame[client];
	g_iEndStrafe_Stats[client][currFrame][StrafeData_Button]        = button;
	g_iEndStrafe_Stats[client][currFrame][StrafeData_TurnDirection] = turnDir;
	g_iEndStrafe_Stats[client][currFrame][StrafeData_MoveDirection] = moveDir;
	
	new difference = g_iLastReleaseTick[client][button] - g_iLastStopTurnTick[client];
	
	if(g_iLastTurnTick[client] > g_iLastStopTurnTick[client])
	{
		difference = g_iLastReleaseTick[client][button] - g_iLastTurnTick[client];
	}
	g_iEndStrafe_Stats[client][currFrame][StrafeData_Difference] = difference;
	g_bEndStrafe_IsRecorded[client][currFrame]                   = true;
	g_iEndStrafe_Stats[client][currFrame][StrafeData_Tick]       = g_iCmdNum[client];
	g_iEndStrafe_CurrentFrame[client] = (g_iEndStrafe_CurrentFrame[client] + 1) % MAX_FRAMES;
	/*
	char sButton[16], sTurn[16], sMove[16];
	GetTurnDirectionName(turnDir, sTurn, sizeof(sTurn));
	GetMoveDirectionName(button, sButton, sizeof(sButton));
	GetMoveDirectionName(moveDir, sMove, sizeof(sMove));
	
	PrintToBlacky("Turned %s | Pressed %s | Moving %s | Difference %d |%s",
		sTurn,
		sButton,
		sMove,
		g_iEndStrafe_Stats[client][currFrame][StrafeData_Difference],
		caller);
	*/
}

public RecordKeySwitch(client, button, oppositeButton)
{
	new currFrame = g_iKeySwitch_CurrentFrame[client];
	g_iKeySwitch_Stats[client][currFrame][KeySwitchData_Button]     = button;
	g_iKeySwitch_Stats[client][currFrame][KeySwitchData_Difference] = g_iLastPressTick[client][button] - g_iLastReleaseTick[client][oppositeButton];
	g_bKeySwitch_IsRecorded[client][currFrame]                      = true;
	g_iKeySwitch_CurrentFrame[client] = (g_iKeySwitch_CurrentFrame[client] + 1) % MAX_FRAMES;
}

public StartStrafeRecorded(client, frame)
{
	// Get last end strafe
	new endStrafeFrame = g_iEndStrafe_CurrentFrame[client];
	endStrafeFrame -= 1;
	if(endStrafeFrame < 0)
	{
		endStrafeFrame = MAX_FRAMES - 1;
	}
	
	if(g_iStartStrafe_Stats[client][frame][StrafeData_Tick] - g_iEndStrafe_Stats[client][endStrafeFrame][StrafeData_Tick] <= 15 &&
		g_iEndStrafe_Stats[client][endStrafeFrame][StrafeData_Difference] < 0)
	{
		new bool:important = g_iEndStrafe_Stats[client][endStrafeFrame][StrafeData_Difference] < 0;
		RecordStartEndDifference(client, frame, endStrafeFrame, important);
	}
}

public RecordStartEndDifference(client, startStrafeFrame, endStrafeFrame, important)
{
	new currFrame = g_iAngleDelay_CurrentFrame[client];
	g_iAngleDelay[client][currFrame][AngleDelay_Difference]  = g_iStartStrafe_Stats[client][startStrafeFrame][StrafeData_Difference] >= g_iEndStrafe_Stats[client][endStrafeFrame][StrafeData_Difference];
	g_iAngleDelay[client][currFrame][AngleDelay_NegativeEnd] = important;
	g_bAngleDelay_IsRecorded[client][currFrame] = true;
	g_iAngleDelay_CurrentFrame[client] = (currFrame + 1) % MAX_FRAMES;
}

new Float:g_fLastIllegalMovementDetection[MAXPLAYERS + 1];

public CheckForIllegalMovement(client, Float:vel[3], buttons)
{
	decl bool:bInvalid;
	if(vel[1] > 0 && (buttons & IN_MOVELEFT))
	{
		bInvalid = true;
	}
	if(vel[1] > 0 && (buttons & (IN_MOVELEFT|IN_MOVERIGHT) == IN_MOVELEFT|IN_MOVERIGHT))
	{
		bInvalid = true;
	}
	if(vel[1] < 0 && (buttons & IN_MOVERIGHT))
	{
		bInvalid = true;
	}
	if(vel[1] < 0 && (buttons & (IN_MOVELEFT|IN_MOVERIGHT) == IN_MOVELEFT|IN_MOVERIGHT))
	{
		bInvalid = true;
	}
	if(vel[1] == 0.0 && ((buttons & (IN_MOVELEFT|IN_MOVERIGHT)) == IN_MOVELEFT || (buttons & (IN_MOVELEFT|IN_MOVERIGHT)) == IN_MOVERIGHT))
	{
		bInvalid = true;
	}
	if(vel[1] != 0.0 && !(buttons & IN_MOVELEFT|IN_MOVERIGHT))
	{
		bInvalid = true;
	}
	
	if(bInvalid == true)
	{
		g_InvalidButtonSidemoveCount[client]++;
		vel[0] = 0.0;
		vel[1] = 0.0;
	}
	else
	{
		g_InvalidButtonSidemoveCount[client] = 0;
	}
	
	if(g_InvalidButtonSidemoveCount[client] >= 2)
	{
		if(GetEngineTime() - g_fLastIllegalMovementDetection[client] > 30.0)
		{
			g_fLastIllegalMovementDetection[client] = GetEngineTime();
			//PrintToBlacky("%N invalid buttons and sidemove combination", client);
		}
		
	}
	
	if((vel[0] != float(RoundToFloor(vel[0])) || vel[1] != float(RoundToFloor(vel[1]))) || (RoundFloat(vel[0]) % 25 != 0 || RoundFloat(vel[1]) % 25 != 0))
	{
		// Extra checks for values that the modulo dosent pick up
		if(FloatAbs(vel[0]) != 112.500000 && FloatAbs(vel[1]) != 112.500000)
		{
			vel[0] = 0.0;
			vel[1] = 0.0;
		}
	}
}

stock UpdateButtons(client,  Float:vel[3], buttons)
{
	g_iLastButtons[client] = g_iButtons[client];
	g_iButtons[client] = 0;
	
	if(vel[0] > 0)
	{
		g_iButtons[client] |= 1 << Button_Forward;
	}
	else if(vel[0] < 0)
	{
		g_iButtons[client] |= 1 << Button_Back;
	}
	
	if(vel[1] > 0)
	{
		g_iButtons[client] |= 1 << Button_Right;
	}
	else if(vel[1] < 0)
	{
		g_iButtons[client] |= 1 << Button_Left;
	}
	
	/*
	if(buttons & IN_FORWARD)
	{
		g_iButtons[client] |= 1 << Button_Forward;
	}
	else if(buttons & IN_BACK)
	{
		g_iButtons[client] |= 1 << Button_Back;
	}
	
	if(buttons & IN_MOVERIGHT)
	{
		g_iButtons[client] |= 1 << Button_Right;
	}
	else if(buttons & IN_MOVELEFT)
	{
		g_iButtons[client] |= 1 << Button_Left;
	}
	*/
}

public GetDesiredTurnDir(client, button, bool:opposite)
{
	new direction = GetDirection(client);
	new desiredTurnDir;
	
	// if holding a and going forward then look for left turn
	if(button == Button_Left && direction == Moving_Forward)
	{
		desiredTurnDir = Turn_Left;
	}
	
	// if holding d and going forward then look for right turn
	if(button == Button_Right && direction == Moving_Forward)
	{
		desiredTurnDir = Turn_Right;
	}
	
	// if holding a and going backward then look for right turn
	if(button == Button_Left && direction == Moving_Back)
	{
		desiredTurnDir = Turn_Right;
	}
	
	// if holding d and going backward then look for left turn
	if(button == Button_Right && direction == Moving_Back)
	{
		desiredTurnDir = Turn_Left;
	}
	
	// if holding w and going left then look for right turn
	if(button == Button_Forward && direction == Moving_Left)
	{
		desiredTurnDir = Turn_Right;
	}
	
	// if holding s and going left then look for left turn
	if(button == Button_Back && direction == Moving_Left)
	{
		desiredTurnDir = Turn_Left;
	}
	
	// if holding w and going right then look for left turn
	if(button == Button_Forward && direction == Moving_Right)
	{
		desiredTurnDir = Turn_Left;
	}
	
	// if holding s and going right then look for right turn
	if(button == Button_Back && direction == Moving_Right)
	{
		desiredTurnDir = Turn_Right;
	}
	
	if(!opposite)
	{
		return desiredTurnDir;
	}
	else
	{
		if(desiredTurnDir == Turn_Right)
		{
			return Turn_Left;
		}
		else
		{
			return Turn_Right;
		}
	}
}

public GetDesiredButton(client, dir)
{
	new moveDir = GetDirection(client);
	new button;
	if(dir == Turn_Left)
	{
		if(moveDir == Moving_Forward)
		{
			button = Button_Left;
		}
		else if(moveDir == Moving_Back)
		{
			button = Button_Right;
		}
		else if(moveDir == Moving_Left)
		{
			button = Button_Back;
		}
		else if(moveDir == Moving_Right)
		{
			button = Button_Forward;
		}
	}
	else if(dir == Turn_Right)
	{
		if(moveDir == Moving_Forward)
		{
			button = Button_Right;
		}
		else if(moveDir == Moving_Back)
		{
			button = Button_Left;
		}
		else if(moveDir == Moving_Left)
		{
			button = Button_Forward;
		}
		else if(moveDir == Moving_Right)
		{
			button = Button_Back;
		}
	}
	
	return button;
}

public GetOppositeButton(button)
{
	if(button == Button_Forward)
	{
		return Button_Back;
	}
	else if(button == Button_Back)
	{
		return Button_Forward;
	}
	else if(button == Button_Right)
	{
		return Button_Left;
	}
	else if(button == Button_Left)
	{
		return Button_Right;
	}
	
	return -1;
}

public GetDirection(client)
{
	new Float:vVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
	
	new Float:vAng[3];
	GetClientEyeAngles(client, vAng);
   
	new Float:movementDiff = ArcTangent(vVel[1] / vVel[0]) * 180.0 / FLOAT_PI;
   
	if (vVel[0] < 0.0)
	{
		if (vVel[1] > 0.0)
			movementDiff += 180.0;
		else
			movementDiff -= 180.0;
	}

	if(movementDiff < 0.0)
		movementDiff += 360.0;

	if(vAng[1] < 0.0)
		vAng[1] += 360.0;

	movementDiff = movementDiff - vAng[1];

	new bool:flipped = false;

	if(movementDiff < 0.0)
	{
		flipped = true;
		movementDiff = -movementDiff;
	}

	if(movementDiff > 180.0)
	{
		if(flipped)
			flipped = false;
		else
			flipped = true;
	   
		movementDiff = FloatAbs(movementDiff - 360.0);
	}

	if(-0.1 < movementDiff < 67.5)
	{
		return Moving_Forward; // Forwards
	}
	if(67.5 < movementDiff < 112.5)
	{
		if(flipped)
		{
			return Moving_Right; // Sideways
		}
		else
		{
			return Moving_Left; // Sideways other way
		}
	}
	if(112.5 < movementDiff <= 180.0)
	{
		return Moving_Back; // Backwards
	}
	return 0; // Unknown should never happend
}

stock GetTurnDirectionName(direction, String:buffer[], maxlength)
{
	if(direction == Turn_Left)
	{
		FormatEx(buffer, maxlength, "Left");
	}
	else if(direction == Turn_Right)
	{
		FormatEx(buffer, maxlength, "Right");
	}
	else
	{
		FormatEx(buffer, maxlength, "Unknown");
	}
}

stock GetMoveDirectionName(direction, String:buffer[], maxlength)
{
	if(direction == Moving_Forward)
	{
		FormatEx(buffer, maxlength, "Forward");
	}
	else if(direction == Moving_Back)
	{
		FormatEx(buffer, maxlength, "Backward");
	}
	else if(direction == Moving_Left)
	{
		FormatEx(buffer, maxlength, "Left");
	}
	else if(direction == Moving_Right)
	{
		FormatEx(buffer, maxlength, "Right");
	}
	else
	{
		FormatEx(buffer, maxlength, "Unknown");
	}
}

/*
stock bool IsBlacky(int client)
{
	char sAuth[32];
	GetClientAuthId(client, AuthId_Steam2, sAuth, sizeof(sAuth));
	return StrContains(sAuth, "0:1739936") != -1;
}

stock void PrintToBlacky(const char[] msg, any ...)
{
	//0:1739936
	char sAuth[32];
	int  blacky;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			GetClientAuthId(client, AuthId_Steam2, sAuth, sizeof(sAuth));
			
			if(StrContains(sAuth, "0:1739936") != -1)
			{
				blacky = client;
				break;
			}
		}
	}
	
	if(blacky == 0)
	{
		return;
	}
	
	char buffer[300];
	VFormat(buffer, sizeof(buffer), msg, 2);
	
	Handle hMessage = StartMessageOne("SayText2", blacky); 
	if (hMessage != INVALID_HANDLE) 
	{ 
		if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
		{
			PbSetInt(hMessage, "ent_idx", blacky);
			PbSetBool(hMessage, "chat", true);
			PbSetString(hMessage, "msg_name", buffer);
			PbAddString(hMessage, "params", "");
			PbAddString(hMessage, "params", "");
			PbAddString(hMessage, "params", "");
			PbAddString(hMessage, "params", "");
		}
		else
		{
			BfWriteByte(hMessage, blacky);
			BfWriteByte(hMessage, true);
			BfWriteString(hMessage, buffer);
		}
		
		EndMessage();
	}
}
*/