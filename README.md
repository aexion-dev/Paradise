<h1 align="center"><img src="https://panels-images.twitch.tv/panel-112057792-image-ec75027f8b5d1c45-320.png"></h1>
<h4 align="center"></h4>
<p align="center">
  <a href="https://travis-ci.com/aexion-dev/Paradise"><img src="http://img.shields.io/badge/build-passing-brightgreen?style=flat-square"></a>
  <a href="https://github.com/aexion-dev/Paradise"><img src="https://img.shields.io/badge/release-v5.0.0-blue?style=flat-square"></a>
  <a href="https://github.com/aexion-dev/Paradise/issues"><img src="https://img.shields.io/badge/issues-0-brightgreen?style=flat-square&logo=github"></a>
  <br>
  <a href="#requirements">Requirements</a> •
  <a href="#installation">Installation</a> •
  <a href="#features">Features</a> •
  <a href="#commands">Commands</a> •
  <a href="#wiki">Wiki</a> •
  <a href="#support">Support</a> •
  <a href="#changelog">Changelog</a>
</p>
Paradise is a CS:GO server plug-in built from the ground up to re-define bunnyhopping within the Counter-Strike franchise. New styles, complex features and global competitions combine to create an experience unlike anything you've played before.

### Requirements
```
* CS:GO Dedicated Server
  o SourceMod: Greater Than or Equal To 1.7
  o MetaMod: Source
* MySQL Database
  o MySQL 5.6 or MariaDB 10 and higher
```
### Installation
1. Download the latest version of Paradise and extract it to any folder.
2. Compile the plug-ins. (Optional)
    * Download Sourcemod V1.8 or later and extract it to any folder.
    * Copy all files from Paradise/addons/sourcemod/scripting/ into Sourcemod/addons/sourcemod/scripting.
    * Drag-and-drop paradise-plugin.sp onto compile.exe.
    * Copy paradise-plugin.smx from Sourcemod/addons/sourcemod/compiled/ to Paradise/addons/sourcemod/plugins.
3. Install plug-ins to CS:GO Dedicated Server.
    * Copy all files from Paradise/ into the server's csgo directory.
4. Configure MySQL/MariaDB Database.
    * Open the config file located at addons/sourcemod/configs/databases.cfg and add the following:
      ```
      "Databases"
      {
        "default"
        {
            "driver"			"mysql"
            "host"			"YourURL"
            "database"		"YourDatabaseName"
            "user"			"user"
            "pass"			"pass"
            //"timeout"		"0"
            //"port"			"0"
        }
      }
      ```
4. Restart Game Server and open server console to verify Paradise has been installed successfully.
### Recommended Add-ons
* [Slope Boost Fix v1.2](https://forums.alliedmods.net/showthread.php?t=266888) by Blacky
* [CS:GO Movement Unlocker v1.0](https://forums.alliedmods.net/showthread.php?t=255298) by Peace-Maker
* [Trigger_Push Fix v1.3](https://forums.alliedmods.net/showthread.php?t=267131) by Blacky/Hmmmm
* [MPBhops v1.0.1](https://forums.alliedmods.net/showpost.php?p=2561012&postcount=118) by DaFox/Hmmmmm
## Features
### Maps
Every map is assigned a tier and XP value based on the difficulty of the map, average completion time and number of overall completions. A custom map vote is held near the end of each round to decide the next map. A single map from each tier is randomly selected for the vote and nominated maps will appear in place of the corresponding map's tier. For an in-depth look at the map system in Paradise, read about it on our wiki page.
* Add a New Map
    * Upload map to server's csgo/maps directory. (.nav file is required. if one doesn't exist, copy/paste one from another map and rename it to yourmapname.nav)
    * In-game use the admin command `sm_add_map [mapname | tier | xp]` to add your map to the database.
* Remove an Existing Map
    * In-game use the admin command `sm_delete_map [mapname | tier | xp]` to remove your map from the database.
### Zones
There are five zone types in Paradise: Start Zone, End Zone, Bonus Start Zone, Bonus End Zone and Cheat Zone. Every zone can contain up to 6 vertices and the area defined functions  Each zone can contain up to 6 vertices and will perform a different function when a player enters/exits the defined area. Every map will require Start/End Zones to be playable. For information on all of the zones and their uses, read about it on our wiki page.
* Create a New Zone
    * In-game type `!zones` into the chat to open the zone editor.
    * Select the type of zone you wish to create.
    * Place your crosshair at the location of the first zone point and select `Start Point`.
    * Repeat this for each zone point, and selecting `Next Point` each time.
    * When the zone is complete, select `Save Zone` and reload map to ensure it was saved successfully.
* Delete an Existing Zone
    * In-game type `!zones` into the chat to open the zone editor.
    * Select the type of zone you wish to delete.
    * Select `Delete Zone` and then select `Save Zone`.
    * After zone is deleted, reload map to ensure it was removed successfully.
### Styles
There are seven different bunnyhop styles on Paradise: Auto, Legit, Freestyle, Parkour, Half-Sideways, Sideways and W-Only. Each style has unique characteristics that change the way you play, and map completion XP is dependent on the difficulty of the style. For an overview of how each style works and tutorials on getting started with a new style, read about them on our wiki page.
### Profiles
Player profiles contain a robust amount of information on a player's level, map completion, records, paradise score and other useful data. Paradise score is a unique statistic that factors in map records, total map completion and level/xp to calculate a player's overall skill level on the server. For more information on player profiles and the paradise score formula, read about it on our wiki page.
### Records
Every player's personal best records are stored in the database along with the # of jumps, strafes, sync and date recorded. Each map also has a leaderboard of the top 100 records for each style and the top record for each is replayable through [EVE]. For more information on how records work, please read about them on our wiki page.
### EVE
Meet the first bunnyhop companion: EVE! She keeps track of the current timeleft on a map and displays it on the scoreboard. Timeleft is dynamically calculated for each map based on the the number of records and the average completion time of the map. EVE also can replay the top world record runs for the current map. For more information on EVE's features and how she can help you, read about her on our wiki page.
### StrafeSecurity
Complex anti-cheat system designed specifically for bunnyhop. The system uses a variety of techniques to catch hackers depending on the style being used. When a cheater is detected a record is logged of the evidence/reasoning behind the detection and optional sourcebans integration allows for automatic punishment. For more information on the techniques used by the anti-cheat system and how to integrate it with sourcebans, please read our wiki page.
### VIP
Donators/Staff are given an exclusive menu system that is built-in to Paradise. From there, VIP clients are allowed to spawn custom weapons, equip custom models (and even purchase their own custom-made models) or equip a custom trail. Trails utilize the particle system for easy downloadability and custom trails exist for events/giveaways such as the Bunnyhop Battle Royale winners. Learn more about the VIP system by reading our wiki page.
## Commands
Client Commands | Variables | Description
------------ | ------------- | -------------
sm_style | none | Open style selection menu
sm_r | none | Respawn at start of map
sm_b | none | Respawn at start of bonus map
sm_spec | [playername] | Spectate target player
sm_me | none | View your player profile
sm_profile | [playername] | View target player profile
sm_wr | none | Open world records menu
sm_maptop | [mapname] | View top records on map
sm_top | none | View top style ranks
sm_leaderboard | none | View Paradise Leaderboard
sm_eve | none | Open EVE Bunnyhop Companion menu
sm_hideweapons | none | Toggle weapon visibility
sm_hideknife | none | Toggle knife visibility
sm_vip | none | Open VIP menu
sm_mapinfo | none |  View map information
sm_rtv | none | Rock the vote
sm_nominate | none | Nominate map for map vote

Admin Commands | Variables | Description
------------ | ------------- | -------------
sm_setlevel | [playername] [level] | Manually set player's level
sm_givexp | [playername] [XP] | Manually give player XP amount
sm_zones | none | Open Paradise Zone Editor
sm_spec | [target] | Spectate target player
sm_addmap | [mapname] [tier] [XP] | Add new map to database
sm_deletemap | [mapname] | Remove existing map from database
sm_addvip| [playername] | Give player VIP Status
sm_calcscore | [playername] | Force Paradise Score calculation
sm_querycount | none | Show # of MySQL Queries ran this round
sm_sh | [playername] | Show players strafes/angles for cheat detection

For a full list of commands and their functions, view our wiki page.
## Wiki
Paradise is a complex plug-in that provides a variety of new features/mechanics. If you'd like to learn more about the plug-in's capabilities or still have questions, please read through the articles on the wiki.
## Support
Feel free to reach out with any questions/feedback:
  * Website: [aexion.dev](https://www.aexion.dev/)
  * Steam: [Hunny Bop](https://steamcommunity.com/profiles/[U:1:196129736])
  * AlliedModders: [aexi0n](https://forums.alliedmods.net/member.php?u=255100)
## Changelog
