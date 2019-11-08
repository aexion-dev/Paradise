
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | ROUTE MODE",
    author = "Aexi0n",
    description = "Official Bhop Timer for Paradise Servers",
    version = "6.0",
    url = ""
}

new Float:pos1Vec[3];
new Float:ang1Vec[3];
new BlueGlowSprite;


public PrecacheOrb()
{
	BlueGlowSprite = PrecacheModel("sprites/blueglow2.vmt");
}

public Action:sm_route(client, args)
{
	GetClientAbsOrigin(client, pos1Vec);
	pos1Vec[2] = pos1Vec[2] + 16.0;
	GetClientEyeAngles(client, ang1Vec);
	
	CreateTimer(1.0, ShowOrb, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action:ShowOrb(Handle:timer)
{
	TE_SetupGlowSprite(pos1Vec, BlueGlowSprite, 1.0, 0.4, 249);
	TE_SendToAll();
}