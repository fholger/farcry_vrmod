# Far Cry VR Mod

This is a mod for the 2004 Crytek game *Far Cry* which makes it possible to experience it in Virtual Reality.
You need to own and have installed the original Far Cry. It is available at:
* [Steam](https://store.steampowered.com/app/13520/Far_Cry/)

This mod is still very early in its development. It has working stereoscopic rendering with 6DOF headset tracking.
There is currently no roomscale support, so you'll have to play seated.
There is currently no support for motion controllers, you'll have to play with  mouse and keyboard.
These things may be added later.

## Installation

Download and install Far Cry. Then head over to the mod's [Releases](https://github.com/fholger/farcry_vrmod/releases) and
find the latest release at the top of the page. Under the "Assets" section find and download the `farcry-vrmod-x.y.zip` archive.
Open it and extract all files into your Far Cry install directory. If you are not sure where it is located,
right-click on Far Cry in your Steam library, then select "Manage" -> "Browse local files", and it will show you the game's install location.

Launch the `FarCryVR.bat` to start the game in VR.

## Configuration

There is currently no way to change VR-specific settings in the game's options, so you have to edit the `system.cfg` file or use the ingame console to edit these settings.
The following VR specific options are available:

- `vr_yaw_deadzone_angle` - by default, you can move the mouse a certain distance in the horizontal direction before your view starts to rotate. This is to allow you to aim more precisely without constantly rotating your view. If you do not like this, set it to 0 to disable the deadzone.
- `vr_render_force_max_terrain_detail` - if enabled (default), will force distant terrain to render at a higher level of detail.

You may also be interested in the following base game options to improve the look of the game:

- `e_vegetation_sprites_distance_ratio` - Increase this value to something like 100 to render vegetation at full detail even far in the distance. Significantly improves the look of the game and avoids the constant changes between vegetation models and sprites as you move around the world. Might cause some glitches in specific scenes, though, so you may have to lower it as needed.

## Playing

The mod is currently a seated experience and requires that you calibrate your seated position in your VR runtime. 
Once in position, go to your desktop and bring up the SteamVR desktop menu and select "Recenter view".

## Known issues

- The desktop mirror does not display anything beyond the menu or HUD. If you wish to record gameplay, use the SteamVR mirror view, instead.
- Distant LOD may under certain viewing angles cause stereo artifacting.
- Binoculars and possibly other zoomed views are non-functional.
- Videos are not being played. The Mod SDK does not possess any ability to play video files; I may restore videos later, but it is low priority. If you are playing Far Cry for the first time, be aware that you will miss out on a few video cutscenes throughout the game.
- The compass has a black rectangular border.

## Legal notices

This mod is developed and its source code is covered under the CryEngine Mod SDK license which you can review in the `EULA.txt` file.

This mod is not endorsed by or affiliated with Crytek or Ubisoft.  Trademarks are the property of their respective owners.  Game content copyright Crytek.
