# Paradise
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

### Features
### Commands
### Changelog


