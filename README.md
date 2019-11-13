<h1 align="center">Paradise</h1>
<h4 align="center"></h4>
<p align="center">
  <a href="https://travis-ci.com/aexion-dev/Paradise"><img src="http://img.shields.io/badge/build-passing-brightgreen?style=flat-square"></a>
  <a href="https://www.google.com/"><img src="https://img.shields.io/badge/release-v5.0.0-blue?style=flat-square"></a>
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
    * Download Sourcemod V1.5 or earlier and extract it to any folder.
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
        // other configurations here

        "paradise_db"
        {
          "driver"	"mysql"
          "database"	"paradise_db"
        }
      }
      ```
4. Restart Game Server and open server console to verify Paradise has been installed successfully.
### Recommended Add-ons
* Slope Boost Fix v1.2 by Blacky
    * https://forums.alliedmods.net/showthread.php?t=266888
* CS:GO Movement Unlocker v1.0 by Peace-Maker
    * https://forums.alliedmods.net/showthread.php?t=255298
* Trigger_Push Fix v1.3 by Blacky/Hmmmm
    * https://forums.alliedmods.net/showthread.php?t=255298
* MPBhops v1.0.1 by DaFox/Hmmmmm
    * https://forums.alliedmods.net/showthread.php?t=255298
## Features
### Maps
Every map is assigned a tier and XP value based on the difficulty of the map, average completion time and number of overall completions. A custom map vote is held near the end of each round to decide the next map. A single map from each tier is randomly selected for the vote and nominated maps will appear in place of the corresponding map's tier. For an in-depth look at the map system in Paradise, read about it on our wiki page.
* Add a New Map
    * Upload map to server's csgo/maps directory. (.nav file is required. if one doesn't exist, copy/paste one from another map and rename it to yourmapname.nav)
    * In-game use the admin command `sm_add_map [mapname | tier | xp]` to add your map to the database.
* Remove an Existing Map
    * In-game use the admin command `sm_delete_map [mapname | tier | xp]` to remove your map from the database.
* Import existing maps.sql data (500+ maps)
    * Coming Soon
### Zones
There are five zone types in Paradise: Start Zone, End Zone, Bonus Start Zone, Bonus End Zone and Cheat Zone. Every zone can contain up to 6 vertices and the area defined functions  Each zone can contain up to 6 vertices and will perform a different function when a player enters/exits the defined area. Every map will require Start/End Zones to be playable. For information on all of the zones and their uses, read about it on our wiki page.
* Create a New Zone
    * In-game type `!zones` into the chat to open the zone editor.
    * Select the type of zone and press place zones.
    * Place your crosshair on the ground at the first point and select place point.
    * Select Save Zones and ensure they were saved to the database successfully.
* Edit an Current Zone
    * Coming Soon
* Delete an Existing Zone
    * Coming Soon
* Import existing zones.sql data (500+ zones)
    * Coming Soon
### Styles
There are seven different bunnyhop styles on Paradise: Auto, Legit, Freestyle, Parkour, Half-Sideways, Sideways and W-Only. Each style has unique characteristics that change the way you play, and map completion XP is dependent on the difficulty of the style. For an overview of how each style works and tutorials on getting started with a new style, read about them on our wiki page.
### Profiles
Player profiles contain a robust amount of information on a player's level, map completion, records, paradise score and other useful data. Paradise score is a unique statistic that factors in map records, total map completion and level/xp to calculate a player's overall skill level on the server. For more information on player profiles and the paradise score formula, read about it on our wiki page.
### Records
Every player's personal best records are stored in the database along with the # of jumps, strafes, sync and date recorded. Each map also has a leaderboard of the top 100 records for each style and the top record for each is replayable through [EVE]. For more information on how records work, please read about them on our wiki page.
### EVE
### Security
### VIP
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
## Changelog
