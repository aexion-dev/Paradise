
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | VIP",
    author = "Aexi0n",
    description = "Official Bhop Timer for Paradise Servers",
    version = "5.0",
    url = ""
}

enum VIP
{
	String:Model[100],
	String:Trail[100]
}

new bool:TrailEnabled[MAXPLAYERS+1];
new PlayerParticle[MAXPLAYERS+1];
new g_vip[MAXPLAYERS+1][VIP];
new bool:VIP_Player[MAXPLAYERS + 1];

new downloadtype;
new String:mediatype[256];

new String:SpringBR2016_Players[30][64] =
{	
	"STEAM_1:0:78479358", //Dream
	"STEAM_1:1:60451291", //Unity
	"STEAM_1:0:19133744", //Euria
	"STEAM_1:1:59616062", //wave
	"STEAM_1:0:20155813", // THE PONI
	"STEAM_1:0:8663477", // bobby
	"STEAM_1:0:76990244", // W-Only
	"STEAM_1:1:86276002", // eskay
	"STEAM_1:1:18080476", // OLD_MONEY_BOWLING$$$_$$
	"STEAM_1:1:35864722", // Revolution
	"STEAM_1:0:28065001", // Saspatoon
	"STEAM_1:1:6184088", // S I M N
	"STEAM_1:1:57699808", // Hydra
	"STEAM_1:1:53280562", // Carmac
	"STEAM_1:0:40405278", // Nishi
	"STEAM_1:0:96688814", // Numbers
	"STEAM_1:1:9606430", // A.NightWolf
	"STEAM_1:1:46996013", // TonyToes
	"STEAM_1:1:104805984", // RipTide
	"STEAM_1:1:49762667", // Jydus
	"STEAM_1:1:36925186", // SJP
	"STEAM_1:0:143645778", // Blackout
	"STEAM_1:1:40803201", // Syphillis
	"STEAM_1:0:48560794", // F_Proz
	"STEAM_1:0:65503679", // Winter
	"STEAM_1:0:48090049", // Otter
	"STEAM_1:0:6350958", // Tesquo
	"STEAM_1:0:98064868", // Hunny Bop
	"STEAM_1:0:104708577", // UnderUrBedz
	"STEAM_1:0:49616563" // Sixernine
}

new String:SummerBR2016_Players[32][64] =
{	
	"STEAM_1:0:48560794", //F^Proz
	"STEAM_1:0:89837224", //CookiEs
	"STEAM_1:0:53620757", //SomebodyEpic
	"STEAM_1:0:40405278", //nishi
	"STEAM_1:0:147027562", // wind
	"STEAM_1:0:8663477", // bobby
	"STEAM_1:1:35864722", // Revolution
	"STEAM_1:0:143645778", // Blackout
	"STEAM_1:0:128604324", // ZOOM
	"STEAM_1:1:18080476", // OLD_MONEY_BOWLING$$_$
	"STEAM_1:0:65503679", // Winter
	"STEAM_1:1:60451291", // Aqua
	"STEAM_1:0:42675965", // Trevor
	"STEAM_1:0:83329442", // lemin
	"STEAM_1:0:76990244", // W-Only
	"STEAM_1:0:93521844", // Legacy
	"STEAM_1:1:482948", // lily
	"STEAM_1:1:73194443", // PEz
	"STEAM_1:0:98064868", // Hunny Bop
	"STEAM_1:0:28065001", // Saspatoon
	"STEAM_1:1:9606430", // A.NightWolf
	"STEAM_1:0:4392284", // Tony Montana
	"STEAM_1:1:93090125", // biql
	"STEAM_1:0:26680945", // roger
	"STEAM_1:1:49762667", // Jydus
	"STEAM_1:0:40029651", // tonic
	"STEAM_1:1:31047127", // H3adsh0t
	"STEAM_1:1:57699808", // Hydra
	"STEAM_1:0:48090049", // Otter
	"STEAM_1:1:49776999", // Fur
	"STEAM_1:0:104708577", // UnderUrBedz
	"STEAM_1:0:49616563" // Sixernine
}

public PrecacheModels()
{
	PrecacheModel("models/player/paradise/hands/default/paradise_hands.mdl", true);
	PrecacheModel("models/player/kuristaja/paradise/rosalina/rosalina_arms.mdl", true);
	PrecacheModel("models/player/pokemon_trainer/pokemon_trainer.mdl", true);
	PrecacheModel("models/player/bbs_93x_net/miku_skin/miku_spring.mdl", true);
	PrecacheModel("models/player/paradise/elsa/elsa2.mdl", true);
	PrecacheModel("models/player/paradise/mario/mario2.mdl", true);
	PrecacheModel("models/player/paradise/sonic/sonic.mdl", true);
	PrecacheModel("models/player/paradise/eve/eve.mdl", true);
	PrecacheModel("models/player/kuristaja/paradise/rosalina/rosalinaluma.mdl", true);
	PrecacheModel("models/blackout.mdl", true);
	
	ReadDownloads();
}

public PrecacheTrails()
{
	AddFileToDownloadsTable("particles/paradise_trailsv5.pcf");
	PrecacheGeneric("particles/paradise_trailsv5.pcf", true);  
}

stock CreateParticle(ent, String:particleType[])
{
    new particle = CreateEntityByName("info_particle_system");

	decl String:name[64];

    if (IsValidEdict(particle))
    {
		Format(name, sizeof(name), "target%i", ent);
		DispatchKeyValue(ent, "targetname", name);
		
        new Float:position[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
        TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
        GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
        DispatchKeyValue(particle, "targetname", "tf2particle");
        DispatchKeyValue(particle, "parentname", name);
        DispatchKeyValue(particle, "effect_name", particleType);
        DispatchSpawn(particle);
        SetVariantString(name);
        AcceptEntityInput(particle, "SetParent", particle, particle, 0);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");
		
		PlayerParticle[ent] = particle;
		
		if(GetEdictFlags(particle) & FL_EDICT_ALWAYS)
		{
			SetEdictFlags(particle, GetEdictFlags(particle) ^ FL_EDICT_ALWAYS);
		}
		
		
    }
}

public EnableTrail(client, String:particleName[])
{
	if(!TrailEnabled[client] && IsValidClient(client, true))
	{
		CreateParticle(client, particleName);
		TrailEnabled[client] = true;
	}
}

public DisableTrail(client)
{
	if(TrailEnabled[client] && IsValidEdict(PlayerParticle[client]))
	{
		new String:classN[64];
        GetEdictClassname(PlayerParticle[client], classN, sizeof(classN));
        if(StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(PlayerParticle[client]);
			Format(g_vip[client][Trail], 100, "");
			TrailEnabled[client] = false;
			PlayerParticle[client] = -1;
        }
	}
}


public ReadDownloads()
{
	new String:file[256];
	BuildPath(Path_SM, file, 255, "configs/sm_skinchooser/skinchooserdownloads.ini");
	new Handle:fileh = OpenFile(file, "r");
	new String:buffer[256];
	downloadtype = 1;
	new len;
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{	
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE)
	{
		CloseHandle(fileh);
	}
}

public ReadFileFolder(String:filepath[])
{
	new Handle:dirh = INVALID_HANDLE;
	new String:buffer[256];
	new String:tmp_path[256];
	new FileType:type = FileType_Unknown;
	new len;
	
	len = strlen(filepath);
	if (filepath[len-1] == '\n')
		filepath[--len] = '\0';

	TrimString(filepath);
	
	if(DirExists(filepath))
	{
		dirh = OpenDirectory(filepath);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type))
		{
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (!StrEqual(buffer,"",false) && !StrEqual(buffer,".",false) && !StrEqual(buffer,"..",false))
			{
				strcopy(tmp_path,255,filepath);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File)
				{
					if(downloadtype == 1)
					{
						ReadItem(tmp_path);
					}
					
				
				}
			}
		}
	}
	else
	{
		if(downloadtype == 1)
		{
			ReadItem(filepath);
		}
		
	}
	if(dirh != INVALID_HANDLE)
	{
		CloseHandle(dirh);
	}
}

public ReadItem(String:buffer[])
{
	new len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	
	if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	{
		if(StrContains(buffer,"//") >= 0)
		{
			ReplaceString(buffer,255,"//","");
		}
	}
	else if (!StrEqual(buffer,"",false) && FileExists(buffer))
	{
		if(StrContains(mediatype, "Model", true) >= 0)
		{
			PrecacheModel(buffer,true);
		}
		AddFileToDownloadsTable(buffer);
	}
}